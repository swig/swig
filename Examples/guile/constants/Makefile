TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS       = 
TARGET     = my-guile
INTERFACE  = example.i

check: build
	$(MAKE) -f $(TOP)/Makefile TARGET='$(TARGET)' guile_augmented_run

build:
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' guile_augmented

clean:
	$(MAKE) -f $(TOP)/Makefile TARGET='$(TARGET)' guile_clean
