TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
CXXSRCS    = example.cxx
TARGET     = example
INTERFACE  = example.i
SWIGOPT    =
MODULA3SRCS = *.[im]3
MODULA3FLAGS= -o runme

all::	modula3

modula3::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' modula3_cpp
#	$(MAKE) -f $(TOP)/Makefile MODULA3SRCS='$(MODULA3SRCS)' MODULA3FLAGS='$(MODULA3FLAGS)' modula3_compile
	m3ppinplace $(MODULA3SRCS)
	mv m3makefile $(MODULA3SRCS) src/
	cm3

clean::
	$(MAKE) -f $(TOP)/Makefile modula3_clean

check: all
