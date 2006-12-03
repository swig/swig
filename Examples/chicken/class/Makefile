TOP         = ../..
SWIG        = $(TOP)/../preinst-swig
INTERFACE   = example.i
SRCS        = 
CXXSRCS     = example.cxx
TARGET      = class
INCLUDE     =
SWIGOPT     =
CFLAGS      = 
VARIANT     =

# uncomment the following lines to build a static exe (only pick one of the CHICKEN_MAIN lines)
#CHICKEN_MAIN = test-lowlevel-class.scm
#CHICKEN_MAIN = test-tinyclos-class.scm
#VARIANT      = _static

all:: $(TARGET) $(TARGET)_proxy

$(TARGET): $(INTERFACE) $(SRCS)
	$(MAKE) -f $(TOP)/Makefile \
		SRCS='$(SRCS)' CXXSRCS='$(CXXSRCS)' CHICKEN_MAIN='$(CHICKEN_MAIN)' \
		INCLUDE='$(INCLUDE)' SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' \
		SWIG='$(SWIG)' INTERFACE='$(INTERFACE)' CHICKENOPTS='$(CHICKENOPTS)' chicken$(VARIANT)_cpp

$(TARGET)_proxy: $(INTERFACE) $(SRCS)
	$(MAKE) -f $(TOP)/Makefile \
		SRCS='$(SRCS)' CXXSRCS='$(CXXSRCS)' CHICKEN_MAIN='$(CHICKEN_MAIN)' \
		INCLUDE='$(INCLUDE)' SWIGOPT='$(SWIGOPT) -proxy' TARGET='$(TARGET)_proxy' \
		SWIG='$(SWIG)' INTERFACE='$(INTERFACE)' CHICKENOPTS='$(CHICKENOPTS)' chicken$(VARIANT)_cpp

clean::
	$(MAKE) -f $(TOP)/Makefile chicken_clean
	rm -f example.scm
	rm -f $(TARGET)

check::
	env LD_LIBRARY_PATH=.:$$LD_LIBRARY_PATH csi test-lowlevel-class.scm
	env LD_LIBRARY_PATH=.:$$LD_LIBRARY_PATH csi test-tinyclos-class.scm
