TOP        = ../..
SWIG       = $(TOP)/../swig
CHICKGEN   = example_wrap.c csi.c precsi.c oexample.c
SRCS       = $(CHICKGEN)
TARGET     = constants
INCLUDE    = -I$(SOURCE_DIR)
SWIGOPT    = 

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

$(TARGET): $(SRCS)
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
		INCLUDE='$(INCLUDE)' SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' \
		INTERFACE='$(INTERFACE)' chicken_static

clean::
	rm -f *_wrap* *.o core *~ *.so *.stackdump STACKTRACE
	rm -f $(CHICKGEN)
	rm -f example.scm
	rm -f $(TARGET)

check:: all
