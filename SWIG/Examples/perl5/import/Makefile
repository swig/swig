TOP        = ../..
SWIG       = $(TOP)/../swig

# You might have to include some options like -R or -Xlinker -rpath to
# tell the linker where -lswigpl is located.
 
LIBS       = -lswigpl
SWIGOPT    = -c -shadow 

all::
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' TARGET='baseclass' INTERFACE='base.i' perl5_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' TARGET='foo' INTERFACE='foo.i' perl5_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' TARGET='bar' INTERFACE='bar.i' perl5_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' TARGET='spam' INTERFACE='spam.i' perl5_cpp


clean::
	rm -f *_wrap* *.o *~ *.so *.pm .~* core

check: all
