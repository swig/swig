TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
TARGET     = example
INTERFACE  = example.i
INTERFACEDIR = jni/
PACKAGEDIR = src/org/swig
PACKAGENAME= org.swig.extendexample
SWIGOPT    = -package $(PACKAGENAME) -outdir $(PACKAGEDIR)/extendexample
PROJECTNAME= SwigExtend
TARGETID  = 1
#INSTALLOPTIONS = -s # To install on SD Card

check: build

build:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' INTERFACEDIR='$(INTERFACEDIR)' \
	PROJECTNAME='$(PROJECTNAME)' TARGETID='$(TARGETID)' android_cpp

install:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' INSTALLOPTIONS='$(INSTALLOPTIONS)' PROJECTNAME='$(PROJECTNAME)' \
	PACKAGEDIR='$(PACKAGEDIR)' PACKAGENAME='$(PACKAGENAME)' android_install

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' TARGET='$(TARGET)' PROJECTNAME='$(PROJECTNAME)' \
	PACKAGEDIR='$(PACKAGEDIR)' INTERFACEDIR='$(INTERFACEDIR)' android_clean
