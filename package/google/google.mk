SUB_MAKEFILES := $(wildcard package/google/*/*.mk)

ifeq ($(BR2_arc),y)
  SUB_MAKEFILES := $(filter-out package/google/google_dart_vm/google_dart_vm.mk, $(SUB_MAKEFILES))
endif

include $(SUB_MAKEFILES)
