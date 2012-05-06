TOP         = ../../..
SWIG        = $(TOP)/../preinst-swig
INTERFACE   = gifplot.i
SRCS        = 
CXXSRCS     = 
TARGET      = gifplot
INCLUDE     = -I. -I../../Include
SWIGOPT     = -I../../Include
CFLAGS      = 
VARIANT     = 
LIBS        = -L../.. -lgifplot -lm

# comment the following two lines to build a dynamic so file
CHICKEN_MAIN = test-gifplot.scm
VARIANT      = _static

all:: $(TARGET)

$(TARGET): $(INTERFACE) $(SRCS)
	$(MAKE) -f $(TOP)/Makefile \
		SRCS='$(SRCS)' CXXSRCS='$(CXXSRCS)' CHICKEN_MAIN='$(CHICKEN_MAIN)' \
		INCLUDE='$(INCLUDE)' SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' TARGET='$(TARGET)' \
		SWIG='$(SWIG)' INTERFACE='$(INTERFACE)' CHICKENOPTS='$(CHICKENOPTS)' chicken$(VARIANT)

clean::
	$(MAKE) -f $(TOP)/Makefile chicken_clean
	rm -f gifplot.scm image.gif
	rm -f $(TARGET)
