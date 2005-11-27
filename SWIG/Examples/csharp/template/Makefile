TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
CXXSRCS    =
TARGET     = example
INTERFACE  = example.i
SWIGOPT    =
CSHARPSRCS = *.cs
CSHARPFLAGS= -nologo -out:runme.exe

all::	csharp

csharp::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' csharp_cpp
	$(MAKE) -f $(TOP)/Makefile CSHARPSRCS='$(CSHARPSRCS)' CSHARPFLAGS='$(CSHARPFLAGS)' csharp_compile

clean::
	$(MAKE) -f $(TOP)/Makefile csharp_clean

check: all
