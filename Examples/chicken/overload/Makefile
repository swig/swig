TOP         = ../..
SWIG        = $(TOP)/../preinst-swig
INTERFACE   = example.i
SRCS        = 
CXXSRCS     = example.cxx
TARGET      = overload
INCLUDE     =
SWIGOPT     = 
CFLAGS      = 
VARIANT     = 

# uncomment the following lines to build a static exe
#CHICKEN_MAIN = test-overload.scm
#VARIANT      = _static

all:: $(TARGET)

$(TARGET): $(INTERFACE) $(SRCS)
	$(MAKE) -f $(TOP)/Makefile \
		SRCS='$(SRCS)' CXXSRCS='$(CXXSRCS)' CHICKEN_MAIN='$(CHICKEN_MAIN)' \
		INCLUDE='$(INCLUDE)' SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' \
		SWIG='$(SWIG)' INTERFACE='$(INTERFACE)' CHICKENOPTS='$(CHICKENOPTS)' chicken$(VARIANT)_cpp

clean::
	$(MAKE) -f $(TOP)/Makefile chicken_clean
	rm -f example.scm example-generic.scm example-clos.scm
	rm -f $(TARGET)

check::
	csi -batch $(TARGET).so test-overload.scm
