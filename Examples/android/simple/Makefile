TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
TARGET     = example
INTERFACE  = example.i
PACKAGEDIR = src/org/swig
PACKAGENAME= org.swig.simple
SWIGOPT    = -package $(PACKAGENAME) -outdir $(PACKAGEDIR)/simple
PROJECTNAME= SwigSimple
TARGETID  = 1

all::	android

android::
	android update project --target $(TARGETID) --name $(PROJECTNAME) --path .
	$(SWIG) -java $(SWIGOPT) -o jni/$(TARGET)_wrap.c jni/$(INTERFACE)
	ndk-build
	ant debug

install::
	-adb uninstall $(PACKAGENAME)
	adb install bin/$(PROJECTNAME)-debug.apk

clean::
	ant clean
	rm -f jni/$(TARGET)_wrap.c
	rm -f `find $(PACKAGEDIR) -name \*.java | grep -v $(PROJECTNAME).java`
	

check: all
