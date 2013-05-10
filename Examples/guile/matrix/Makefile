TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS       = matrix.c vector.c
TARGET     = matrix
INTERFACE  = example.i

check: build
	$(MAKE) -f $(TOP)/Makefile TARGET='$(TARGET)' GUILE_RUNOPTIONS='-e do-test' guile_augmented_run

build:
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' LIBS='-lm' guile_augmented

clean:
	$(MAKE) -f $(TOP)/Makefile TARGET='$(TARGET)' guile_clean
