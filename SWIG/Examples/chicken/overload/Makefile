TOP        = ../..
SWIG       = $(TOP)/../swig
CHICKGEN   = csi.o precsi.o oexample.o example.cxx example_wrap.cxx
SRCS       = $(CHICKGEN)
TARGET     = overload
INCLUDE    =
SWIGOPT    =
CFLAGS     = 

all:: $(TARGET) example_generic.scm example_clos.scm

.c.o:
	$(MAKE) -f $(TOP)/Makefile CFLAGS='$(CFLAGS)' TARGET='$@' \
		INCLUDE='$(INCLUDE)' INTERFACE='$<' compile

csi.c:
	$(MAKE) -f $(TOP)/Makefile TARGET='csi.c' \
		INTERFACE='precsi' chicken_csi

precsi.c: precsi.scm
	$(MAKE) -f $(TOP)/Makefile TARGET='precsi.c' \
		INTERFACE='$<' chicken

example_wrap.cxx example.scm example_generic.scm example_clos.scm: example.i
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
		INCLUDE='$(INCLUDE)' INTERFACE='example.i' chicken_cpp

oexample.c: example.scm
	$(MAKE) -f $(TOP)/Makefile TARGET='oexample.c' \
		INTERFACE='$<' chicken

$(TARGET): $(SRCS)
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
		INCLUDE='$(INCLUDE)' SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' \
		INTERFACE='$(INTERFACE)' chicken_cpp_static

clean::
	rm -f *_wrap* *.o core *~ *.so *.stackdump STACKTRACE
	rm -f $(CHICKGEN)
	rm -f example.scm example_generic.scm example_clos.scm
	rm -f $(TARGET)

check:: all
