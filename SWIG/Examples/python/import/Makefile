TOP        = ../..
SWIG       = $(TOP)/../swig

# You might have to include some options like -R or -Xlinker -rpath to
# tell the linker where -lswigpy is located.
 
LIBS       = -lswigpy
SWIGOPT    = -c -shadow 

all::
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' TARGET='basec' INTERFACE='base.i' python_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' TARGET='fooc' INTERFACE='foo.i' python_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' TARGET='barc' INTERFACE='bar.i' python_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' TARGET='spamc' INTERFACE='spam.i' python_cpp


clean::
	$(MAKE) -f $(TOP)/Makefile python_clean
	rm foo.py bar.py spam.py base.py

check: all
