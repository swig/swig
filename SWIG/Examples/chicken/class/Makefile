TOP        = ../..
SWIG       = $(TOP)/../swig
INTERFACE  = example.i
CHICKSRCS  = precsi.c oexample.c
SRCS       =
CXXSRCS    = example_wrap.cxx example.cxx
CHICKGEN   = $(CHICKSRCS) csi.c example_wrap.cxx
TARGET     = class
INCLUDE    =
SWIGOPT    = 
CFLAGS     = 

all:: $(TARGET) example-generic.scm example-clos.scm

csi.c:
	$(MAKE) -f $(TOP)/Makefile TARGET='csi.c' \
		INTERFACE='precsi' chicken_csi

precsi.c: precsi.scm
	$(MAKE) -f $(TOP)/Makefile TARGET='precsi.c' \
		INTERFACE='$<' chicken_chicken

example_wrap.cxx example.scm example-generic.scm example-clos.scm: example.i
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
		INCLUDE='$(INCLUDE)' INTERFACE='example.i' chicken_swig_cpp

oexample.c: example.scm
	$(MAKE) -f $(TOP)/Makefile TARGET='oexample.c' \
		INTERFACE='$<' chicken_chicken

$(TARGET): csi.c $(CHICKSRCS) $(SRCS) $(CXXSRCS)
	$(MAKE) -f $(TOP)/Makefile \
		CHICKSRCS='$(CHICKSRCS)' SRCS='$(SRCS)' CXXSRCS='$(CXXSRCS)' \
		INCLUDE='$(INCLUDE)' SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' \
		SWIG='$(SWIG)' INTERFACE='$(INTERFACE)' chicken_static_cpp

module:: $(CHICKSRCS) $(SRCS) $(CXXSRCS)
	$(MAKE) -f $(TOP)/Makefile \
		CHICKSRCS='$(CHICKSRCS)' SRCS='$(SRCS)' CXXSRCS='$(CXXSRCS)' \
		INCLUDE='$(INCLUDE)' SWIGOPT='$(SWIGOPT)' TARGET='module' \
		SWIG='$(SWIG)' INTERFACE='$(INTERFACE)' chicken_module_cpp

clean::
	$(MAKE) -f $(TOP)/Makefile chicken_clean
	rm -f $(CHICKGEN)
	rm -f example.scm example-generic.scm example-clos.scm
	rm -f $(TARGET)

check:: module
