TOP         = ../..
SWIG        = $(TOP)/../preinst-swig
INTERFACE   = example.i
SRCS        =
CXXSRCS     = 
TARGET      = zlib
INCLUDE     =
SWIGOPT     = -I/usr/include -mixed -prefix zlib
CFLAGS      = 
VARIANT     = 
LIBS        = -lz

# comment out the following two lines to build a dynamic exe
CHICKEN_MAIN = test-zlib.scm
VARIANT      = _static

all:: $(TARGET)

$(TARGET): $(INTERFACE) $(SRCS)
	$(MAKE) -f $(TOP)/Makefile \
		SRCS='$(SRCS)' CXXSRCS='$(CXXSRCS)' CHICKEN_MAIN='$(CHICKEN_MAIN)' \
		INCLUDE='$(INCLUDE)' SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' TARGET='$(TARGET)' \
		SWIG='$(SWIG)' INTERFACE='$(INTERFACE)' CHICKENOPTS='$(CHICKENOPTS)' chicken$(VARIANT)

clean::
	$(MAKE) -f $(TOP)/Makefile chicken_clean
	rm -f example.scm example-generic.scm example-clos.scm
	rm -f $(TARGET)

check::
	csi -batch simple.so test-zlib.scm
