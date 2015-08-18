TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
INTERFACE  = example.i
SRCS       =
CXXSRCS    = example.cxx
TARGET     = class
INCLUDE    =
SWIGOPT    =
VARIANT    =

# uncomment the following lines to build a static exe (only pick one of the CHICKEN_MAIN lines)
#CHICKEN_MAIN = runme-lowlevel.scm
#CHICKEN_MAIN = runme-tinyclos.scm
#VARIANT    = _static

check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' CHICKEN_SCRIPT='runme-lowlevel.scm' chicken_run
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' CHICKEN_SCRIPT='runme-tinyclos.scm' chicken_run

build: $(TARGET) $(TARGET)_proxy

$(TARGET): $(INTERFACE) $(SRCS)
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' \
	SRCS='$(SRCS)' CXXSRCS='$(CXXSRCS)' CHICKEN_MAIN='$(CHICKEN_MAIN)' \
	INCLUDE='$(INCLUDE)' SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' \
	SWIG='$(SWIG)' INTERFACE='$(INTERFACE)' CHICKENOPTS='$(CHICKENOPTS)' chicken$(VARIANT)_cpp

$(TARGET)_proxy: $(INTERFACE) $(SRCS)
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' \
	SRCS='$(SRCS)' CXXSRCS='$(CXXSRCS)' CHICKEN_MAIN='$(CHICKEN_MAIN)' \
	INCLUDE='$(INCLUDE)' SWIGOPT='$(SWIGOPT) -proxy' TARGET='$(TARGET)_proxy' \
	SWIG='$(SWIG)' INTERFACE='$(INTERFACE)' CHICKENOPTS='$(CHICKENOPTS)' chicken$(VARIANT)_cpp

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' chicken_clean
	rm -f example.scm
	rm -f $(TARGET)
