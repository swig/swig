TOP        = ../../..
SWIG       = $(TOP)/../swig
CHICKGEN   = gifplot_wrap.c csi.c precsi.c ogifplot.c 
SRCS       = $(CHICKGEN)
TARGET     = gifplot
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

gifplot_wrap.c gifplot.scm: ./gifplot.i
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
		INCLUDE='$(INCLUDE)' INTERFACE='gifplot.i' chicken_c

ogifplot.c: gifplot.scm
	$(MAKE) -f $(TOP)/Makefile TARGET='ogifplot.c' \
		INTERFACE='$<' chicken

$(TARGET): $(SRCS)
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
		INCLUDE='$(INCLUDE)' SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' \
		LIBS='$(LIBS)' INTERFACE='$(INTERFACE)' chicken_static

clean::
	rm -f *_wrap* *.o core *~ *.so *.stackdump STACKTRACE
	rm -f $(CHICKGEN)
	rm -f gifplot.scm
	rm -f $(TARGET)
	rm -f *.gif

check:: all
