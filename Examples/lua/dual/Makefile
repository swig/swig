TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
TARGET     = dual
CXXSRCS    = example2_wrap.cxx
INTERFACE  = dual.i
LUA_INTERP = dual.cpp

# this is a little different ot normal as we need to static link two modules and a custom intepreter
# we need the external runtime, then swig examples2, and build the module as normal
all::
	$(SWIG) -lua -external-runtime
	$(SWIG) -c++ -lua $(SWIGOPT) example2.i
	$(MAKE) -f $(TOP)/Makefile $(SWIGLIB) CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='example.i' LUA_INTERP='$(LUA_INTERP)' lua_static_cpp

clean::
	$(MAKE) -f $(TOP)/Makefile lua_clean

check: all

