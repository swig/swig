TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
TARGET     = embed
SRCS       = example.c
INTERFACE  = example.i
LUA_INTERP = embed.c
LIBS       = -lm

# this is a little different to normal as we have our own special interpreter
# which we want to static link
check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' TARGET='$(TARGET)' lua_embed_run

build:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' $(SWIGLIB) SRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' LIBS='$(LIBS)' INTERFACE='example.i' LUA_INTERP='$(LUA_INTERP)' lua_static

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' lua_clean
	rm -f $(TARGET)
