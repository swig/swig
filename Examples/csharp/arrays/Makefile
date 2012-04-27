TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS       = example.c
TARGET     = example
INTERFACE  = example.i
SWIGOPT    =
CSHARPSRCS = *.cs
CSHARPFLAGS= -nologo -unsafe -out:runme.exe

all::	csharp

csharp::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' csharp
	$(MAKE) -f $(TOP)/Makefile CSHARPSRCS='$(CSHARPSRCS)' CSHARPFLAGS='$(CSHARPFLAGS)' csharp_compile

clean::
	$(MAKE) -f $(TOP)/Makefile csharp_clean

check: all
