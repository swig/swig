TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SWIGOPT    =
LIBS       =

all:: 
	$(CXX) -shared -o cbase.so cbase.cxx
	$(CXX) -shared -o cbar.so cbar.cxx
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	LIBS='$(LIBS) cbase.so' TARGET='base' INTERFACE='base.i' python_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	LIBS='$(LIBS) cbase.so' TARGET='foo' INTERFACE='foo.i' python_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	LIBS='$(LIBS) cbase.so cbar.so' TARGET='bar' INTERFACE='bar.i' python_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	LIBS='$(LIBS) cbase.so cbar.so' TARGET='spam' INTERFACE='spam.i' python_cpp


clean::
	$(MAKE) -f $(TOP)/Makefile python_clean
	@rm -f foo.py bar.py spam.py base.py

check: all
