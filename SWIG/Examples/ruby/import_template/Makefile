TOP        = ../..
SWIG       = $(TOP)/../swig

# You might have to include some options like -R or -Xlinker -rpath to
# tell the linker where -lswigrb is located.
 
LIBS       = -lswigrb
SWIGOPT    = -c

all::
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' TARGET='base' INTERFACE='base.i' ruby_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' TARGET='foo' INTERFACE='foo.i' ruby_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' TARGET='bar' INTERFACE='bar.i' ruby_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' LIBS='$(LIBS)' TARGET='spam' INTERFACE='spam.i' ruby_cpp


clean::
	@rm -f base_wrap.cxx base_wrap.o base.so foo_wrap.cxx foo_wrap.o foo.so bar_wrap.cxx bar_wrap.o bar.so spam_wrap.cxx spam_wrap.o spam.so

check: all
