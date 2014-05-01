TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
CXXSRCS    = example.cxx
TARGET     = example
INTERFACE  = example.i
LIBS       = -lm
SWIGOPT    = -noproxy

check: build
	$(MAKE) -f $(TOP)/Makefile perl5_run

build:
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' SWIGOPT='$(SWIGOPT)' perl5_cpp

static:
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='myperl' INTERFACE='$(INTERFACE)' SWIGOPT='$(SWIGOPT)' perl5_cpp_static

clean:
	$(MAKE) -f $(TOP)/Makefile perl5_clean
