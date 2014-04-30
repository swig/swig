TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS       =
TARGET     = example
INTERFACE  = example.i

check: build
	$(MAKE) -f $(TOP)/Makefile ruby_run

build:
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' ruby

static:
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='myruby' INTERFACE='$(INTERFACE)' ruby_static

clean:
	$(MAKE) -f $(TOP)/Makefile ruby_clean
