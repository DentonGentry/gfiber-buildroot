/*
 * Copyright (C) 2012 Google Inc.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program; if not, write to the Free Software Foundation, Inc., 51
 * Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
 */

#define PROGRAM_NAME    "ubiscrubber"

#include <stdio.h>
#include <getopt.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdlib.h>
#include <time.h>

#include <libubi.h>
#include "common.h"
#include "ubiutils-common.h"

#define CYCLE_DURATION_MIN (60*60*24*1)
#define CYCLE_DURATION_MAX (60*60*24*7)
#define MAX_EC_END_OF_LIFE 10000

/* The variables below are set by command line arguments */
struct args {
	int cycle_duration;
	unsigned int verbose:1;
	const char *node;
};

static struct args args = {
	.cycle_duration = -1,
	.verbose = 0,
	.node = NULL,
};

static const char doc[] = PROGRAM_NAME " version " VERSION
			 " - a tool to scrub UBI volumes.";

static const char optionsstr[] =
"-d, --cycle-duration=<seconds>  take this much time to read the volume\n"
"-v, --verbose                   be verbose\n"
"-h, --help                      print help message\n"
"-V, --version                   print program version";

static const char usage[] =
"Usage 1: " PROGRAM_NAME " <UBI volume node file name>\n"
"Usage 2: " PROGRAM_NAME "[-h] [-V] [--help] [--version]\n"
"\n"
"Example 1: " PROGRAM_NAME " /dev/ubi2_0 - scrub UBI volume /dev/ubi2_0\n";

static const struct option long_options[] = {
	{ .name = "cycle-duration",
		.has_arg = 1, .flag = NULL, .val = 'd' },
	{ .name = "verbose",   .has_arg = 0, .flag = NULL, .val = 'v' },
	{ .name = "help",      .has_arg = 0, .flag = NULL, .val = 'h' },
	{ .name = "version",   .has_arg = 0, .flag = NULL, .val = 'V' },
	{ NULL, 0, NULL, 0},
};

static int parse_opt(int argc, char * const argv[])
{
	int key, error = 0;
	while ( (key = getopt_long(argc, argv, "d:e:hVv", long_options, NULL)) != -1) {
		switch (key) {
		case 'd':
			args.cycle_duration = simple_strtol(optarg, &error);
			if (error)
				return errmsg("bad cycle duration: " "\"%s\"", optarg);
			break;

		case 'h':
			printf("%s\n\n", doc);
			printf("%s\n\n", usage);
			printf("%s\n", optionsstr);
			exit(EXIT_SUCCESS);

		case 'v':
			args.verbose = 1;
			break;

		case 'V':
			common_print_version();
			exit(EXIT_SUCCESS);

		case ':':
			return errmsg("parameter is missing");

		default:
			fprintf(stderr, "Use -h for help\n");
			return -1;
		}
	}

	if (optind != argc - 1)
		return errmsg("No UBI volume specified (use -h for help)");

	args.node = argv[optind];

	return 0;
}


struct scrubber_state {
	struct ubi_vol_info vol_info;
	struct ubi_dev_info dev_info;
	char *pagebuf;
	int fd;
	/* pages = total size of volume in bytes / min_io_size */
	long long pages;
	long long start_page;
	long long max_ec;
};

static struct scrubber_state s;

#define PRINT_DURATION_FORMAT_STRING "%dd %dh %dm %ds"
#define PRINT_DURATION_ARGS(d) (d) / (24 * 60 * 60), (d) / (60 * 60) % (24), (d) / (60) % (60), (d) % (60)

static int scrubbing_cycle_duration(int max_ec) {
	int cd;
	if (args.cycle_duration != -1) {
		bareverbose(args.verbose, "Cycle duration (cmdline option):           "
			PRINT_DURATION_FORMAT_STRING "\n",
			PRINT_DURATION_ARGS(args.cycle_duration));
		return args.cycle_duration;
	}
	max_ec = MAX(max_ec, 0);
	max_ec = MIN(max_ec, MAX_EC_END_OF_LIFE);
	cd = (double)CYCLE_DURATION_MAX -
		(double)max_ec / (double)MAX_EC_END_OF_LIFE *
		((double)CYCLE_DURATION_MAX - (double)CYCLE_DURATION_MIN);
	bareverbose(args.verbose, "Cycle duration:                            "
		PRINT_DURATION_FORMAT_STRING "\n", PRINT_DURATION_ARGS(cd));
	return cd;
}

static int get_info(libubi_t libubi, const char *node, struct ubi_vol_info *vol_info, struct ubi_dev_info *dev_info) {
	int err;
	err = ubi_get_vol_info(libubi, node, vol_info);
	if (err) {
		return sys_errmsg("cannot get information about UBI volume \"%s\"", node);
	}
	err = ubi_get_dev_info1(libubi, vol_info->dev_num, dev_info);
	if (err) {
		return sys_errmsg("cannot get information about UBI device %d", vol_info->dev_num);
	}
	return 0;
}

static int scrub_page(int page) {
	ssize_t rc;
	bareverbose(args.verbose, "scrubbing page %d\n", page);
	lseek(s.fd, page * s.dev_info.min_io_size, SEEK_SET);
	rc = read(s.fd, s.pagebuf, s.dev_info.min_io_size);
	if (rc == -1) {
		return sys_errmsg("read failed");
	}
	return 0;
}

static int scrub(void) {
	long long cur_page;
	int err;
	int cycle_duration;
	double duration;
	struct timespec sleep_duration;

	/* Determine duration of one cycle. */
	cycle_duration = scrubbing_cycle_duration(s.max_ec);
	duration = (double)cycle_duration/(double)s.pages;

	sleep_duration.tv_sec = duration;
	sleep_duration.tv_nsec = (duration - sleep_duration.tv_sec) * 1000000000;
	/* Account for inaccurate floating point arithmetic. */
	if (sleep_duration.tv_nsec > 999999999)
		sleep_duration.tv_nsec = 999999999;
	if (sleep_duration.tv_nsec < 0)
		sleep_duration.tv_nsec = 0;

	for(cur_page=0; cur_page<s.pages; cur_page++) {
		while(1) {
			if (nanosleep(&sleep_duration, NULL)) {
				if (errno == EINTR) continue;
				return sys_errmsg("nanosleep");
			}
			break;
		}
		scrub_page((s.start_page + cur_page)%s.pages);
	}
	bareverbose(args.verbose, "\n");
	return 0;
}

int main(int argc, char * const argv[])
{
	int err;
	libubi_t libubi;
	off_t lseek_size;

	err = parse_opt(argc, argv);
	if (err)
		return -1;

	memset(&s, 0, sizeof(s));
	s.fd = -1;

	libubi = libubi_open();
	if (!libubi) {
		if (errno == 0)
			return errmsg("UBI is not present in the system");
		return sys_errmsg("cannot open libubi");
	}
	err = get_info(libubi, args.node, &s.vol_info, &s.dev_info);
	if (err)
		goto out_libubi;

	/* Open UBI volume */
	s.fd = open(args.node, O_RDONLY);
	if (s.fd == -1) {
		sys_errmsg("cannot open \"%s\"", args.node);
		goto out_libubi;
	}

	/* Determine size of UBI volume through lseek() */
	lseek_size = lseek(s.fd, 0, SEEK_END);
	if (lseek_size == -1) {
		sys_errmsg("cannot lseek \"%s\"", args.node);
		goto out_libubi;
	}

	s.max_ec = s.dev_info.max_ec;

	bareverbose(args.verbose, "Logical eraseblock size:                   ");
	if (args.verbose) {
		ubiutils_print_bytes(s.dev_info.leb_size, 1);
	}
	bareverbose(args.verbose, "\n");
	bareverbose(args.verbose, "Volume size:                               %d LEBs (", s.vol_info.rsvd_lebs);
	if (args.verbose) {
		ubiutils_print_bytes(s.vol_info.rsvd_bytes, 0);
	}
	bareverbose(args.verbose, ")\n");
	bareverbose(args.verbose, "Minimum i/o unit size (i.e. page size):    %d %s\n",
	       s.dev_info.min_io_size, s.dev_info.min_io_size > 1 ? "bytes" : "byte");
	bareverbose(args.verbose, "Current max. erase counter value:          %lld\n", s.dev_info.max_ec);
	bareverbose(args.verbose, "Estimated max. erase counter value at EOL: %lld\n", (long long) MAX_EC_END_OF_LIFE);
	/* Ensure size determined through lseek matches size announced in sysfs */
	if (lseek_size != s.vol_info.rsvd_bytes) {
		errmsg("Size reported by lseek(=%lld) is different from size reported by libubi", (long long) lseek_size);
		goto out_libubi;
	}

	/* Ensure size in bytes is multiple of page size. */
	if (s.vol_info.rsvd_bytes % s.dev_info.min_io_size) {
		errmsg("Reserved bytes is not a multiple of min io size");
		goto out_libubi;
	}

	/* Calculate number of pages. */
	s.pages = s.vol_info.rsvd_bytes / s.dev_info.min_io_size;

	/* Choose a random page where we start scrubbing at. */
	ubiutils_srand();
	s.start_page = (rand() * (long long) RAND_MAX + rand()) % s.pages;

	/* Allocate buffer to read in flash pages */
	s.pagebuf = malloc(s.dev_info.min_io_size);
	if (!s.pagebuf) {
		sys_errmsg("out of memory");
		goto out_libubi;
	}

	bareverbose(args.verbose, "Total number of pages:                     %lld\n", s.pages);
	bareverbose(args.verbose, "Scrubbing starts at page:                  %lld\n", s.start_page);
	bareverbose(args.verbose, "Cycle duration for brand new devices:      " PRINT_DURATION_FORMAT_STRING "\n", PRINT_DURATION_ARGS(CYCLE_DURATION_MAX));
	bareverbose(args.verbose, "Cycle duration for devices at EOL:         "    PRINT_DURATION_FORMAT_STRING "\n", PRINT_DURATION_ARGS(CYCLE_DURATION_MIN));

	err = scrub();
	if (err)
		goto out_libubi;

	if (s.fd != -1) close(s.fd);
	if (s.pagebuf) free(s.pagebuf);
	libubi_close(libubi);
	return 0;

out_libubi:
	if (s.fd != -1) close(s.fd);
	if (s.pagebuf) free(s.pagebuf);
	libubi_close(libubi);
	return -1;
}

