TOP         = ../..
SWIG        = $(TOP)/../preinst-swig
INTERFACE   = example.i
SRCS        =
CXXSRCS     = 
TARGET      = zlib
INCLUDE     =
SWIGOPT     = -I/usr/include
CFLAGS      = 
VARIANT     = 
LIBS        = -lz
VARIANT     = _direct

all:: $(TARGET)

$(TARGET): $(INTERFACE) $(SRCS)
	$(MAKE) -f $(TOP)/Makefile \
		SRCS='$(SRCS)' CXXSRCS='$(CXXSRCS)' \
		INCLUDE='$(INCLUDE)' SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' TARGET='$(TARGET)' \
		SWIG='$(SWIG)' INTERFACE='$(INTERFACE)' CHICKENOPTS='$(CHICKENOPTS)' chicken$(VARIANT)

clean::
	$(MAKE) -f $(TOP)/Makefile chicken_clean
	rm -f example.scm
	rm -f $(TARGET)

check::
	csi test-zlib.scm
