TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS       =
TARGET     = example
INTERFACE  = example.i
SWIGOPT    = -const
all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' perl5

static::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='myperl' INTERFACE='$(INTERFACE)' perl5_static

clean::
	$(MAKE) -f $(TOP)/Makefile perl5_clean

check: all
