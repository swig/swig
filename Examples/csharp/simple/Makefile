TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS       = example.c
TARGET     = example
INTERFACE  = example.i
SWIGOPT    =
CSHARPSRCS = *.cs
CSHARPFLAGS= -nologo -debug+ -out:runme.exe

check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' csharp_run

build:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' SRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' csharp
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' CSHARPSRCS='$(CSHARPSRCS)' CSHARPFLAGS='$(CSHARPFLAGS)' csharp_compile

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' csharp_clean
