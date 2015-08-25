From 0246de745bba48aafdba6e9a618f97ef238911ea Mon Sep 17 00:00:00 2001
From: Richard Frankel <rofrankel@google.com>
Date: Mon, 10 Aug 2015 17:37:25 -0400
Subject: [PATCH 1/2] ARC support

---
 common/image.c  | 1 +
 include/image.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/common/image.c b/common/image.c
index f63a2ff..be5d475 100644
--- a/common/image.c
+++ b/common/image.c
@@ -77,6 +77,7 @@ static const image_header_t* image_get_ramdisk (ulong rd_addr, uint8_t arch,
 static const table_entry_t uimage_arch[] = {
 	{	IH_ARCH_INVALID,	NULL,		"Invalid ARCH",	},
 	{	IH_ARCH_ALPHA,		"alpha",	"Alpha",	},
+	{	IH_ARCH_ARC,		"arc",		"ARC",		},
 	{	IH_ARCH_ARM,		"arm",		"ARM",		},
 	{	IH_ARCH_I386,		"x86",		"Intel x86",	},
 	{	IH_ARCH_IA64,		"ia64",		"IA64",		},
diff --git a/include/image.h b/include/image.h
index 005e0d2..12746e7 100644
--- a/include/image.h
+++ b/include/image.h
@@ -106,6 +106,7 @@
 #define IH_ARCH_BLACKFIN	16	/* Blackfin	*/
 #define IH_ARCH_AVR32		17	/* AVR32	*/
 #define IH_ARCH_ST200	        18	/* STMicroelectronics ST200  */
+#define IH_ARCH_ARC		19	/* ARC */
 
 /*
  * Image Types
-- 
2.5.0.276.gf5e568e

