# Makefile for to build a gcc/uClibc toolchain linked vs uClibc
#
# Copyright (C) 2002 Erik Andersen <andersen@uclibc.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

#############################################################
#
# You should probably leave this stuff alone unless you are
# hacking on the toolchain...
#
#############################################################
GNU_TARGET_NAME:=$(ARCH)-linux
TARGET_LANGUAGES:=c,c++
MAKE:=make

# If you want multilib enabled, enable this...
#MULTILIB:=--enable-multilib

#############################################################
#
# Where we can find things....
#
# for various dependancy reasons, these need to live
# here at the top...  Easier to find things here anyways...
#
#############################################################
BINUTILS_DIR2:=$(BUILD_DIR)/binutils-target
GCC_BUILD_DIR3:=$(BUILD_DIR)/gcc-target


#############################################################
#
# build binutils
#
#############################################################
$(BINUTILS_DIR2)/.configured:
	mkdir -p $(BINUTILS_DIR2)
	mkdir -p $(TARGET_DIR)/usr/include
	mkdir -p $(TARGET_DIR)/usr/$(GNU_TARGET_NAME)/
	#(cd $(TARGET_DIR)/usr/$(GNU_TARGET_NAME); ln -fs ../lib)
	#(cd $(TARGET_DIR)/usr/$(GNU_TARGET_NAME); ln -fs ../include)
	(cd $(TARGET_DIR)/usr/$(GNU_TARGET_NAME); ln -fs ../include sys-include)
	(cd $(BINUTILS_DIR2); PATH=$(STAGING_DIR)/bin:$$PATH CC=$(TARGET_CROSS)gcc \
		$(BINUTILS_DIR)/configure \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--sbindir=/usr/sbin \
		--sysconfdir=/etc \
		--datadir=/usr/share \
		--includedir=/usr/include \
		--libdir=/usr/lib \
		--localstatedir=/var \
		--mandir=/usr/man \
		--infodir=/usr/info \
		--with-gxx-include-dir=/usr/include/c++ \
		--disable-shared $(MULTILIB) );
	touch $(BINUTILS_DIR2)/.configured

$(BINUTILS_DIR2)/binutils/objdump: $(BINUTILS_DIR2)/.configured
	PATH=$(STAGING_DIR)/bin:$$PATH $(MAKE) AR=$(TARGET_CROSS)ar \
		RANLIB=$(TARGET_CROSS)ranlib LD=$(TARGET_CROSS)ld \
		CC=$(TARGET_CROSS)gcc -C $(BINUTILS_DIR2)

$(TARGET_DIR)/usr/bin/ld: $(BINUTILS_DIR2)/binutils/objdump 
	PATH=$(STAGING_DIR)/bin:$$PATH $(MAKE) \
	    prefix=$(TARGET_DIR)/usr \
	    exec_prefix=$(TARGET_DIR)/usr \
	    bindir=$(TARGET_DIR)/usr/bin \
	    sbindir=$(TARGET_DIR)/usr/sbin \
	    libexecdir=$(TARGET_DIR)/usr/lib \
	    datadir=$(TARGET_DIR)/usr/share \
	    sysconfdir=$(TARGET_DIR)/etc \
	    sharedstatedir=$(TARGET_DIR)/usr/com \
	    localstatedir=$(TARGET_DIR)/var \
	    libdir=$(TARGET_DIR)/usr/lib \
	    infodir=$(TARGET_DIR)/usr/info \
	    mandir=$(TARGET_DIR)/usr/man \
	    includedir=$(TARGET_DIR)/usr/include \
	    gxx_include_dir=$(TARGET_DIR)/usr/include/c++ \
	    toolexecdir=$(TARGET_DIR)/lib/gcc-lib/$(GNU_TARGET_NAME) \
	    -C $(BINUTILS_DIR2) install;
	rm -rf $(TARGET_DIR)/usr/info $(TARGET_DIR)/usr/man $(TARGET_DIR)/usr/share/doc
	-$(STRIP) $(TARGET_DIR)/usr/$(GNU_TARGET_NAME)/bin/*
	-$(STRIP) $(TARGET_DIR)/usr/bin/* 

$(TARGET_DIR)/usr/lib/libg.a:
	$(STAGING_DIR)/$(GNU_TARGET_NAME)/bin/ar rv $(TARGET_DIR)/usr/lib/libg.a;

binutils_target: gcc_final $(TARGET_DIR)/usr/bin/ld $(TARGET_DIR)/usr/lib/libg.a

binutils_target-clean:
	rm -f $(TARGET_DIR)/bin/$(GNU_TARGET_NAME)*
	-$(MAKE) -C $(BINUTILS_DIR2) clean

binutils_target-dirclean:
	rm -rf $(BINUTILS_DIR2)




#############################################################
#
# uClibc just needs its header files and whatnot installed.
#
#############################################################

$(TARGET_DIR)/usr/lib/libc.a: $(STAGING_DIR)/lib/libc.a
	$(MAKE) DEVEL_PREFIX=$(TARGET_DIR)/usr SYSTEM_DEVEL_PREFIX=$(TARGET_DIR) \
		DEVEL_TOOL_PREFIX=$(TARGET_DIR) -C $(UCLIBC_DIR) \
		install_dev
	(cd $(TARGET_DIR)/usr/lib; \
		ln -fs /lib/libc.so.0 libc.so; \
		ln -fs /lib/libdl.so.0 libdl.so; \
		ln -fs /lib/libcrypt.so.0 libcrypt.so; \
		ln -fs /lib/libresolv.so.0 libresolv.so; \
		ln -fs /lib/libutil.so.0 libutil.so; \
		ln -fs /lib/libm.so.0 libm.so; \
		ln -fs /lib/libpthread.so.0 libpthread.so; \
	)
	rm -rf $(TARGET_DIR)/include

uclibc_target: gcc_final $(TARGET_DIR)/usr/lib/libc.a

uclibc_target-clean:
	rm -f $(TARGET_DIR)/include

uclibc_target-dirclean:
	rm -f $(TARGET_DIR)/include



#############################################################
#
# Next build target gcc compiler
#
#############################################################
$(GCC_BUILD_DIR3)/.gcc_build_hacks:
	#
	# Make certain the uClibc start files are found
	#
	perl -i -p -e "s,standard_startfile_prefix_1 = \".*,standard_startfile_prefix_1=\
		\"/lib/\";,;" $(GCC_DIR)/gcc/gcc.c;
	perl -i -p -e "s,standard_startfile_prefix_2 = \".*,standard_startfile_prefix_2=\
		\"/usr/lib/\";,;" $(GCC_DIR)/gcc/gcc.c;
	#
	# Make certain the uClibc include files are found
	#
	perl -i -p -e "s,^NATIVE_SYSTEM_HEADER_DIR.*,NATIVE_SYSTEM_HEADER_DIR=\
		$(STAGING_DIR)/usr/include,;" $(GCC_DIR)/gcc/Makefile.in;
	perl -i -p -e "s,^CROSS_SYSTEM_HEADER_DIR.*,CROSS_SYSTEM_HEADER_DIR=\
		$(STAGING_DIR)/usr/include,;" $(GCC_DIR)/gcc/Makefile.in;
	perl -i -p -e "s,^#define.*STANDARD_INCLUDE_DIR.*,#define STANDARD_INCLUDE_DIR \
		\"/usr/include\",;" $(GCC_DIR)/gcc/cppdefault.h;
	mkdir -p $(GCC_BUILD_DIR3)
	touch $(GCC_BUILD_DIR3)/.gcc_build_hacks

$(GCC_BUILD_DIR3)/.configured: $(GCC_BUILD_DIR3)/.gcc_build_hacks
	(cd $(GCC_BUILD_DIR3); PATH=$(STAGING_DIR)/bin:$$PATH AR=$(TARGET_CROSS)ar \
		RANLIB=$(TARGET_CROSS)ranlib LD=$(TARGET_CROSS)ld CC=$(TARGET_CROSS)gcc \
		$(GCC_DIR)/configure \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--sbindir=/usr/sbin \
		--sysconfdir=/etc \
		--datadir=/usr/share \
		--libdir=/usr/lib \
		--localstatedir=/var \
		--mandir=/usr/man \
		--infodir=/usr/info \
		--enable-shared $(MULTILIB) \
		--enable-target-optspace --disable-nls --with-gnu-ld \
		--enable-languages=$(TARGET_LANGUAGES) --disable-__cxa_atexit );
	touch $(GCC_BUILD_DIR3)/.configured

$(GCC_BUILD_DIR3)/.compiled: $(GCC_BUILD_DIR3)/.configured
	PATH=$(STAGING_DIR)/bin:$$PATH $(MAKE) AR=$(TARGET_CROSS)ar \
		RANLIB=$(TARGET_CROSS)ranlib LD=$(TARGET_CROSS)ld \
		CC=$(TARGET_CROSS)gcc -C $(GCC_BUILD_DIR3)
	touch $(GCC_BUILD_DIR3)/.compiled

$(TARGET_DIR)/usr/bin/gcc: $(GCC_BUILD_DIR3)/.compiled
	PATH=$(STAGING_DIR)/bin:$$PATH $(MAKE) \
	    prefix=$(TARGET_DIR)/usr \
	    exec_prefix=$(TARGET_DIR)/usr \
	    bindir=$(TARGET_DIR)/usr/bin \
	    sbindir=$(TARGET_DIR)/usr/sbin \
	    libexecdir=$(TARGET_DIR)/usr/lib \
	    datadir=$(TARGET_DIR)/usr/share \
	    sysconfdir=$(TARGET_DIR)/etc \
	    sharedstatedir=$(TARGET_DIR)/usr/com \
	    localstatedir=$(TARGET_DIR)/var \
	    libdir=$(TARGET_DIR)/usr/lib \
	    infodir=$(TARGET_DIR)/usr/info \
	    mandir=$(TARGET_DIR)/usr/man \
	    toolexecdir=$(TARGET_DIR)/lib/gcc-lib/$(GNU_TARGET_NAME) \
	    -C $(GCC_BUILD_DIR3) install;
	rm -rf $(TARGET_DIR)/usr/info $(TARGET_DIR)/usr/man $(TARGET_DIR)/usr/share/doc \
		$(TARGET_DIR)/usr/share/locale
	(cd $(TARGET_DIR)/usr/bin; ln -fs gcc cc)
	-$(STRIP) $(TARGET_DIR)/bin/* 
	-$(STRIP) $(TARGET_DIR)/usr/bin/* 

gcc_target: uclibc_target binutils_target $(TARGET_DIR)/usr/bin/gcc

gcc_target-clean:
	rm -rf $(GCC_BUILD_DIR3)
	rm -f $(TARGET_DIR)/bin/$(GNU_TARGET_NAME)*

gcc_target-dirclean:
	rm -rf $(GCC_BUILD_DIR3)

