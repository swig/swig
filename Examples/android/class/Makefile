TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
TARGET     = example
INTERFACE  = example.i
PACKAGEDIR = src/org/swig
PACKAGENAME= org.swig.classexample
SWIGOPT    = -package $(PACKAGENAME) -outdir $(PACKAGEDIR)/classexample 
PROJECTNAME= SwigClass
TARGETID  = 1

all::	android

android::
	android update project --target $(TARGETID) --name $(PROJECTNAME) --path .
	$(SWIG) -c++ -java $(SWIGOPT) -o jni/$(TARGET)_wrap.cpp jni/$(INTERFACE)
	ndk-build
	ant debug

install::
	-adb uninstall $(PACKAGENAME)
	adb install bin/$(PROJECTNAME)-debug.apk

clean::
	ant clean
	rm -f jni/$(TARGET)_wrap.cpp
	rm -f `find $(PACKAGEDIR) -name \*.java | grep -v $(PROJECTNAME).java`
	

check: all
