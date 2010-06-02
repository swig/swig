TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
TARGET     = embed2
SRCS      = example.c
INTERFACE  = example.i
LUA_INTERP = embed2.c

# this is a little different to normal as we have our own special interpreter
# which we want to static link
all::
	$(MAKE) -f $(TOP)/Makefile $(SWIGLIB) SRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='example.i' LUA_INTERP='$(LUA_INTERP)' lua_static

clean::
	$(MAKE) -f $(TOP)/Makefile lua_clean

check: all

