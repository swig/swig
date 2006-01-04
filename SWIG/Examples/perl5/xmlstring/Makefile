TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
CXXSRCS    = example.cxx
TARGET     = example
INTERFACE  = example.i
LIBS       = -lxerces-c -lxerces-depdom -lm

all::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' LIBS=$(LIBS) CXX="g++ -g3" perl5_cpp

static::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='myperl' INTERFACE='$(INTERFACE)' perl5_cpp_static

clean::
	$(MAKE) -f $(TOP)/Makefile perl5_clean

check: all


run:
	perl runme.pl
