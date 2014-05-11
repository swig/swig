TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
TARGET     = embed3
SRCS       = example.cpp
INTERFACE  = example.i
LUA_INTERP = embed3.cpp

# this is a little different to normal as we have our own special interpreter
# which we want to static link
# we also need the external runtime, so we can get access to certain internals of SWIG
check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' TARGET='$(TARGET)' lua_embed_run

build:
	$(SWIG) -c++ -lua $(SWIGOPT) -external-runtime swigluarun.h
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' $(SWIGLIB) SRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='example.i' LUA_INTERP='$(LUA_INTERP)' lua_static_cpp

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' lua_clean
	rm -f swigluarun.h $(TARGET)
