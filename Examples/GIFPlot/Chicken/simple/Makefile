TOP        = ../../..
SWIG       = $(TOP)/../swig
CHICKGEN   = simple_wrap.c csi.c precsi.c osimple.c 
SRCS       = $(CHICKGEN)
TARGET     = simple
INCLUDE    = -I. -I../../Include
LIBS       = -L../.. -lgifplot -lm
SWIGOPT    = -I../../Include

all:: $(TARGET)

csi.c:
	$(MAKE) -f $(TOP)/Makefile TARGET='csi.c' \
		INTERFACE='precsi' chicken_csi

precsi.c: ./precsi.scm
	$(MAKE) -f $(TOP)/Makefile TARGET='precsi.c' \
		INTERFACE='$<' chicken

simple_wrap.c simple.scm: ./simple.i
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
		INCLUDE='$(INCLUDE)' INTERFACE='simple.i' chicken_c

osimple.c: simple.scm
	$(MAKE) -f $(TOP)/Makefile TARGET='osimple.c' \
		INTERFACE='$<' chicken

$(TARGET): $(SRCS)
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
		INCLUDE='$(INCLUDE)' SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' \
		LIBS='$(LIBS)' INTERFACE='$(INTERFACE)' chicken_static

clean::
	rm -f *_wrap* *.o core *~ *.so *.stackdump STACKTRACE
	rm -f $(CHICKGEN)
	rm -f simple.scm
	rm -f $(TARGET)
	rm -f *.gif

check:: all
