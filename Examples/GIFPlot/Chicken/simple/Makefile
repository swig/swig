TOP        = ../../..
SWIG       = $(TOP)/../swig
CHICKSRCS  = precsi.c osimple.c
SRCS       = simple_wrap.c
CXXSRCS    = 
CHICKGEN   = $(CHICKSRCS) csi.c simple_wrap.c
TARGET     = simple
INCLUDE    = -I. -I../../Include
LIBS       = -L../.. -lgifplot -lm
SWIGOPT    = -I../../Include

all:: $(TARGET)

csi.c:
	$(MAKE) -f $(TOP)/Makefile TARGET='csi.c' \
		INTERFACE='precsi' chicken_csi

precsi.c: precsi.scm
	$(MAKE) -f $(TOP)/Makefile TARGET='precsi.c' \
		INTERFACE='$<' chicken

simple_wrap.c simple.scm: simple.i
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
		INCLUDE='$(INCLUDE)' INTERFACE='simple.i' chicken_c

osimple.c: simple.scm
	$(MAKE) -f $(TOP)/Makefile TARGET='osimple.c' \
		INTERFACE='$<' chicken

$(TARGET): csi.c $(CHICKSRCS) $(SRCS) $(CXXSRCS)
	$(MAKE) -f $(TOP)/Makefile LIBS='$(LIBS)' \
		CHICKSRCS='$(CHICKSRCS)' SRCS='$(SRCS)' CXXSRCS='$(CXXSRCS)' \
		INCLUDE='$(INCLUDE)' SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' \
		SWIG='$(SWIG)' INTERFACE='$(INTERFACE)' chicken_static

module:: $(CHICKSRCS) $(SRCS) $(CXXSRCS)
	$(MAKE) -f $(TOP)/Makefile LIBS='$(LIBS)' \
		CHICKSRCS='$(CHICKSRCS)' SRCS='$(SRCS)' CXXSRCS='$(CXXSRCS)' \
		INCLUDE='$(INCLUDE)' SWIGOPT='$(SWIGOPT)' TARGET='module' \
		SWIG='$(SWIG)' INTERFACE='$(INTERFACE)' chicken_module

clean::
	$(MAKE) -f $(TOP)/Makefile chicken_clean
	rm -f $(CHICKGEN)
	rm -f simple.scm
	rm -f $(TARGET) image.gif

check:: all
