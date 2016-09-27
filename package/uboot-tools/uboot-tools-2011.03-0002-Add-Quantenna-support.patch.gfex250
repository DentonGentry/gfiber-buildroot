From e5304b9c610c5dfdabd265ef418145843f287300 Mon Sep 17 00:00:00 2001
From: Richard Frankel <rofrankel@google.com>
Date: Mon, 27 Jul 2015 18:04:55 -0400
Subject: [PATCH 2/2] Add Quantenna support.

This includes:

- A much larger (zero-padded) header of at least 8192 bytes (and
  changes to some references to header size but not others).
- Support for Quantenna-specific flags which live in this new header
  padding.
---
 common/image.c        |  6 +++---
 include/image.h       | 21 ++++++++++++++++++++-
 tools/default_image.c |  6 +++---
 tools/mkimage.c       | 31 ++++++++++++++++++++++++++++---
 tools/mkimage.h       |  1 +
 5 files changed, 55 insertions(+), 10 deletions(-)

diff --git a/common/image.c b/common/image.c
index be5d475..22d94e1 100644
--- a/common/image.c
+++ b/common/image.c
@@ -166,14 +166,13 @@ static void genimg_print_time (time_t timestamp);
 int image_check_hcrc (const image_header_t *hdr)
 {
 	ulong hcrc;
-	ulong len = image_get_header_size ();
 	image_header_t header;
 
 	/* Copy header so we can blank CRC field for re-calculation */
-	memmove (&header, (char *)hdr, image_get_header_size ());
+	memmove (&header, (char *)hdr, sizeof(header));
 	image_set_hcrc (&header, 0);
 
-	hcrc = crc32 (0, (unsigned char *)&header, len);
+	hcrc = crc32 (0, (unsigned char *)&header, sizeof(header));
 
 	return (hcrc == image_get_hcrc (hdr));
 }
@@ -315,6 +314,7 @@ void image_print_contents (const void *ptr)
 	genimg_print_size (image_get_data_size (hdr));
 	printf ("%sLoad Address: %08x\n", p, image_get_load (hdr));
 	printf ("%sEntry Point:  %08x\n", p, image_get_ep (hdr));
+	printf ("%sQtn flags:    %08x\n", p, image_get_qtn_flags (hdr));
 
 	if (image_check_type (hdr, IH_TYPE_MULTI) ||
 			image_check_type (hdr, IH_TYPE_SCRIPT)) {
diff --git a/include/image.h b/include/image.h
index 12746e7..a90a5fc 100644
--- a/include/image.h
+++ b/include/image.h
@@ -359,7 +359,9 @@ int boot_get_kbd (struct lmb *lmb, bd_t **kbd, ulong bootmap_base);
 /*******************************************************************/
 static inline uint32_t image_get_header_size (void)
 {
-	return (sizeof (image_header_t));
+#define MAX_KNOWN_PAGE_SIZE 8192
+#define ROUND_UP(N, S) ((((N) + (S) - 1) / (S)) * (S))
+	return ROUND_UP(sizeof(image_header_t), MAX_KNOWN_PAGE_SIZE);
 }
 
 #define image_get_hdr_l(f) \
@@ -411,6 +413,23 @@ static inline ulong image_get_data (const image_header_t *hdr)
 	return ((ulong)hdr + image_get_header_size ());
 }
 
+static inline uint32_t *image_get_qtn_flags_addr (image_header_t *hdr)
+{
+	return (void *) ((image_get_data(hdr) - sizeof(uint32_t) + 0x3) & ~0x3);
+}
+
+static inline uint32_t image_get_qtn_flags (image_header_t *hdr)
+{
+	uint32_t *flags_addr = image_get_qtn_flags_addr(hdr);
+	return *flags_addr;
+}
+
+static inline void image_set_qtn_flags (image_header_t *hdr, uint32_t val)
+{
+	uint32_t *flags_addr = image_get_qtn_flags_addr(hdr);
+	*flags_addr = val;
+}
+
 static inline uint32_t image_get_image_size (const image_header_t *hdr)
 {
 	return (image_get_size (hdr) + image_get_header_size ());
diff --git a/tools/default_image.c b/tools/default_image.c
index f5bad47..493acd1 100644
--- a/tools/default_image.c
+++ b/tools/default_image.c
@@ -106,13 +106,13 @@ static void image_set_header (void *ptr, struct stat *sbuf, int ifd,
 
 	checksum = crc32 (0,
 			(const unsigned char *)(ptr +
-				sizeof(image_header_t)),
-			sbuf->st_size - sizeof(image_header_t));
+				image_get_header_size()),
+			sbuf->st_size - image_get_header_size());
 
 	/* Build new header */
 	image_set_magic (hdr, IH_MAGIC);
 	image_set_time (hdr, sbuf->st_mtime);
-	image_set_size (hdr, sbuf->st_size - sizeof(image_header_t));
+	image_set_size (hdr, sbuf->st_size - image_get_header_size());
 	image_set_load (hdr, params->addr);
 	image_set_ep (hdr, params->ep);
 	image_set_dcrc (hdr, checksum);
diff --git a/tools/mkimage.c b/tools/mkimage.c
index f5859d7..5338ac6 100644
--- a/tools/mkimage.c
+++ b/tools/mkimage.c
@@ -38,6 +38,7 @@ struct mkimage_params params = {
 	.comp = IH_COMP_GZIP,
 	.dtc = MKIMAGE_DEFAULT_DTC_OPTIONS,
 	.imagename = "",
+	.qtn_flags = 0,
 };
 
 /*
@@ -249,6 +250,17 @@ main (int argc, char **argv)
 			case 'x':
 				params.xflag++;
 				break;
+			case 'Q':
+				if (--argc <= 0)
+					usage ();
+				params.qtn_flags = strtoul (*++argv, (char **)&ptr, 16);
+				if (*ptr) {
+					fprintf (stderr,
+							"%s: invalid Quantenna flags %s\n",
+							params.cmdname, *argv);
+					exit (EXIT_FAILURE);
+				}
+				goto NXTARG;
 			default:
 				usage ();
 			}
@@ -357,14 +369,24 @@ NXTARG:		;
 	 *
 	 * write dummy header, to be fixed later
 	 */
-	memset (tparams->hdr, 0, tparams->header_size);
+	memset (tparams->hdr, 0, sizeof(image_header_t));
 
-	if (write(ifd, tparams->hdr, tparams->header_size)
-					!= tparams->header_size) {
+	if (write(ifd, tparams->hdr, sizeof(image_header_t))
+					!= sizeof(image_header_t)) {
 		fprintf (stderr, "%s: Write error on %s: %s\n",
 			params.cmdname, params.imagefile, strerror(errno));
 		exit (EXIT_FAILURE);
 	}
+	// Zero-fill the extra header space (bytes 64-8191).
+	unsigned int i = 0;
+	for (i = sizeof(image_header_t); i < image_get_header_size(); ++i) {
+		char c = 0;
+		if (write(ifd, &c, 1) != 1) {
+			fprintf (stderr, "%s: Write error on %s: %s\n",
+			         params.cmdname, params.imagefile, strerror(errno));
+			exit (EXIT_FAILURE);
+		}
+	}
 
 	if (params.type == IH_TYPE_MULTI || params.type == IH_TYPE_SCRIPT) {
 		char *file = params.datafile;
@@ -457,6 +479,9 @@ NXTARG:		;
 		exit (EXIT_FAILURE);
 	}
 
+	/* set Quantenna flags; not part of regular header */
+	image_set_qtn_flags((image_header_t *)ptr, params.qtn_flags);
+
 	/* Print the image information by processing image header */
 	if (tparams->print_header)
 		tparams->print_header (ptr);
diff --git a/tools/mkimage.h b/tools/mkimage.h
index 9033a7d..000b21a 100644
--- a/tools/mkimage.h
+++ b/tools/mkimage.h
@@ -60,6 +60,7 @@ struct mkimage_params {
 	int lflag;
 	int vflag;
 	int xflag;
+	uint32_t qtn_flags;
 	int os;
 	int arch;
 	int type;
-- 
2.5.0.276.gf5e568e

