TOP        = ../..
SWIG       = $(TOP)/../swig
SRCS       = 
TARGET     = example
INTERFACE  = example.i
LIBS       = -lm
SWIGOPT    = 

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' ruby

static::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='myruby' INTERFACE='$(INTERFACE)' ruby_static

clean::
	@rm -f example_wrap.c example_wrap.o example.so

check: all
