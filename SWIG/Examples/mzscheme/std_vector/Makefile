TOP        = ../..
SWIG       = $(TOP)/../swig
SRCS       = 
TARGET     = example
INTERFACE  = example.i
INCLUDE    = -I.
SWIGOPT    = 

GPP        = `which g++`
MZC        = test -n "/usr/bin/mzc" && /usr/bin/mzc

all::
	$(SWIG) -mzscheme -c++ $(SWIGOPT) $(INTERFACE)
	$(MZC) --compiler $(GPP) ++ccf "-I." --cc example_wrap.cxx
	$(MZC) --linker $(GPP) --ld $(TARGET).so example_wrap.o 
	
clean:
	rm -f *_wrap* *.o core *~ *.so

check: all
