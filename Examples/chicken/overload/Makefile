TOP         = ../..
SWIG        = $(TOP)/../preinst-swig
INTERFACE   = example.i
SRCS        = 
CXXSRCS     = example.cxx
TARGET      = overload
INCLUDE     =
SWIGOPT     = -proxy -unhideprimitive
CFLAGS      = 
VARIANT     = 

# uncomment the following lines to build a static exe
#CHICKEN_MAIN = test-overload.scm
#VARIANT      = _static

check: build
	env LD_LIBRARY_PATH=.:$$LD_LIBRARY_PATH csi test-overload.scm

build: $(TARGET)

$(TARGET): $(INTERFACE) $(SRCS)
	$(MAKE) -f $(TOP)/Makefile \
		SRCS='$(SRCS)' CXXSRCS='$(CXXSRCS)' CHICKEN_MAIN='$(CHICKEN_MAIN)' \
		INCLUDE='$(INCLUDE)' SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' \
		SWIG='$(SWIG)' INTERFACE='$(INTERFACE)' CHICKENOPTS='$(CHICKENOPTS)' chicken$(VARIANT)_cpp

clean:
	$(MAKE) -f $(TOP)/Makefile chicken_clean
	rm -f example.scm
	rm -f $(TARGET)
