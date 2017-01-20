TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS       = example.cxx
TARGET     = example
INTERFACE  = example.i
SWIGOPT    = -c++ -cffi

# notes: here's what I usually have to do to build a .so library on linux
#
#	swig -c++ -cffi -structs-as-classes example.i
#	g++ -c example_wrap.cxx -fPIC -o example_wrap.o
#	g++ -c example.cxx      -fPIC -o example.o
#	g++ -shared example.o example_wrap.o -o example.so

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' cffi

static::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='mycffi' INTERFACE='$(INTERFACE)' cffi_static

clean::
	$(MAKE) -f $(TOP)/Makefile cffi_clean

check: all
