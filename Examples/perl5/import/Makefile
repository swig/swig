TOP        = ../..
SWIG       = $(TOP)/../swig
SWIGOPT    = -c -shadow 
#If your system requires linking with the runtime libraries then set the directory location here
RUNTIMEDIR = 

all::
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	RUNTIMEDIR='$(RUNTIMEDIR)' TARGET='baseclass' INTERFACE='base.i' perl5_multi_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	RUNTIMEDIR='$(RUNTIMEDIR)' TARGET='foo' INTERFACE='foo.i' perl5_multi_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	RUNTIMEDIR='$(RUNTIMEDIR)' TARGET='bar' INTERFACE='bar.i' perl5_multi_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	RUNTIMEDIR='$(RUNTIMEDIR)' TARGET='spam' INTERFACE='spam.i' perl5_multi_cpp


clean::
	$(MAKE) -f $(TOP)/Makefile perl5_clean

check: all
