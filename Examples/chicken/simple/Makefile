TOP         = ../..
SWIG        = $(TOP)/../preinst-swig
INTERFACE   = example.i
SRCS        = example.c
CXXSRCS     = 
TARGET      = simple
INCLUDE     =
SWIGOPT     = 
CFLAGS      = 
VARIANT     = 

# uncomment the following two lines to build a static exe
#CHICKEN_MAIN = test-simple.scm
#VARIANT      = _static

all:: $(TARGET)

$(TARGET): $(INTERFACE) $(SRCS)
	$(MAKE) -f $(TOP)/Makefile \
		SRCS='$(SRCS)' CXXSRCS='$(CXXSRCS)' CHICKEN_MAIN='$(CHICKEN_MAIN)' \
		INCLUDE='$(INCLUDE)' SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' \
		SWIG='$(SWIG)' INTERFACE='$(INTERFACE)' CHICKENOPTS='$(CHICKENOPTS)' chicken$(VARIANT)

clean::
	$(MAKE) -f $(TOP)/Makefile chicken_clean
	rm -f example.scm example-generic.scm example-clos.scm
	rm -f $(TARGET)

check::
	env LD_LIBRARY_PATH=.:$$LD_LIBRARY_PATH csi test-simple.scm
