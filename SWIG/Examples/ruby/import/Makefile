TOP        = ../..
SWIG       = $(TOP)/../swig

# You might have to include some options like -R or -Xlinker -rpath to
# tell the linker where -lswigrb is located.
 
all::
	$(SWIG) -c -c++ -ruby bar.i
	$(SWIG) -c -c++ -ruby base.i
	$(SWIG) -c -c++ -ruby foo.i
	$(SWIG) -c -c++ -ruby spam.i
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' CXXSRCS='bar_wrap.cxx base_wrap.cxx foo_wrap.cxx spam_wrap.cxx' TARGET='example' INTERFACE='example.i' ruby_multi_cpp

clean::
	@rm -f *_wrap* *.o *~ *.so *.dll .~* core

check: all
