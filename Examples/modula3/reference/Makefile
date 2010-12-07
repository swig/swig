TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS       = 
TARGET     = example
INTERFACE  = example.i
SWIGOPT    = -c++
MODULA3SRCS = *.[im]3

all::	modula3

modula3::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' modula3
	m3ppinplace $(MODULA3SRCS)
	mv m3makefile $(MODULA3SRCS) src/
	cm3

clean::
	$(MAKE) -f $(TOP)/Makefile modula3_clean

check: all
