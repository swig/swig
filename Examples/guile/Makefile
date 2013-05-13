# Makefile for Guile.  Used by all of the example programs.

subdirs		= simple matrix port constants class multimap multivalue std_vector

top_srcdir	= ../..
SWIG		= ../$(top_srcdir)/preinst-swig
CC		= gcc
CXX		= g++
CFLAGS		= 
LIBS		=
GUILE		= /usr/bin/guile
GUILE_CFLAGS	=   -pthread
GUILE_LIBS	=  -pthread  -lguile  
SWIGOPT		=

WRAP		= $(IFILE:.i=_wrap.c)
CXXWRAP		= $(IFILE:.i=_wrap.cxx)

SO		= .so

all:
	for d in $(subdirs) ; do (cd $$d ; $(MAKE)) ; done

clean:
	for d in $(subdirs) ; do (cd $$d ; $(MAKE) clean) ; done
	rm -f *~ .~*

guile_clean:
	rm -f *.o *$(SO) *_wrap* *~ .~* core my-guile $(TARGET)

# This is meant to be used w/ "make -f ../Makefile" from subdirs.
# Doesn't make sense to use it from here.

sub-all:
	$(SWIG) -guile $(SWIGOPT) $(IFILE)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRCS) $(WRAP) $(GUILE_CFLAGS) $(GUILE_LIBS) $(LIBS)

sub-all-cxx:
	$(SWIG) -c++ -guile $(SWIGOPT) $(IFILE)
	$(CXX) $(CFLAGS) -o $(TARGET) $(SRCS) $(CXXWRAP) $(GUILE_CFLAGS) $(GUILE_LIBS) $(LIBS)

run_example:
	if [ -f $(RUNSCRIPT) ]; then \
          env GUILE_AUTO_COMPILE=0 LD_LIBRARY_PATH=.:$$LD_LIBRARY_PATH $(RUNTOOL) $(GUILE) -l $(RUNSCRIPT); \
        fi

# Makefile ends here
