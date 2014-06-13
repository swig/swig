TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS       =
TARGET     = example
INTERFACE  = example.i
CONSTNUMERIC = example_const
SWIGOPT      = -c++
MODULA3SRCS  = *.[im]3

check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' modula3_run

build:
	$(SWIG) -modula3 $(SWIGOPT) -module Example -generateconst $(CONSTNUMERIC) $(TARGET).h
	$(CXX) -Wall $(CONSTNUMERIC).c -o $(CONSTNUMERIC)
	$(CONSTNUMERIC) >$(CONSTNUMERIC).i

	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' SRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' modula3
	m3ppinplace $(MODULA3SRCS)
	mv m3makefile $(MODULA3SRCS) src/
	cm3

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' modula3_clean
