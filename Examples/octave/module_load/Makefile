TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS       = example.c
TARGET     = swigexample
INTERFACE  = example.i

check: build
	$(MAKE) -f $(TOP)/Makefile octave_run

build:
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' SWIGOPT='-module $$(TARGET)' INTERFACE='$(INTERFACE)' octave
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)2' SWIGOPT='-module $$(TARGET) -globals .' INTERFACE='$(INTERFACE)' octave

clean:
	$(MAKE) -f $(TOP)/Makefile octave_clean
	rm -f $(TARGET).m
