TOP        = ../..
SWIG       = $(TOP)/../swig
CHICKSRCS  = precsi.c oexample.c
SRCS       = example.c example_wrap.c
CXXSRCS    = 
CHICKGEN   = $(CHICKSRCS) csi.c example_wrap.c
TARGET     = simple
INCLUDE    =
SWIGOPT    = 
CFLAGS     = 

all:: $(TARGET)

csi.c:
	$(MAKE) -f $(TOP)/Makefile TARGET='csi.c' \
		INTERFACE='precsi' chicken_csi

precsi.c: precsi.scm
	$(MAKE) -f $(TOP)/Makefile TARGET='precsi.c' \
		INTERFACE='$<' chicken

example_wrap.c example.scm: example.i
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
		INCLUDE='$(INCLUDE)' INTERFACE='example.i' chicken_c

oexample.c: example.scm
	$(MAKE) -f $(TOP)/Makefile TARGET='oexample.c' \
		INTERFACE='$<' chicken

$(TARGET): csi.c $(CHICKSRCS) $(SRCS) $(CXXSRCS)
	$(MAKE) -f $(TOP)/Makefile \
		CHICKSRCS='$(CHICKSRCS)' SRCS='$(SRCS)' CXXSRCS='$(CXXSRCS)' \
		INCLUDE='$(INCLUDE)' SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' \
		SWIG='$(SWIG)' INTERFACE='$(INTERFACE)' chicken_static

module:: $(CHICKSRCS) $(SRCS) $(CXXSRCS)
	$(MAKE) -f $(TOP)/Makefile \
		CHICKSRCS='$(CHICKSRCS)' SRCS='$(SRCS)' CXXSRCS='$(CXXSRCS)' \
		INCLUDE='$(INCLUDE)' SWIGOPT='$(SWIGOPT)' TARGET='module' \
		SWIG='$(SWIG)' INTERFACE='$(INTERFACE)' chicken_module

clean::
	$(MAKE) -f $(TOP)/Makefile chicken_clean
	rm -f $(CHICKGEN)
	rm -f example.scm example_generic.scm example_clos.scm
	rm -f $(TARGET)

check:: all
