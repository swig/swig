
SRCS = return.c default.c stack.c stab.c elf.c object.c init.c segment.c signal.c
OBJS = return.o default.o stack.o stab.o elf.o object.o signal.o segment.o init.o main.o
INCLUDE = -I../Include -I.
OPT  = -DWAD_SOLARIS
LIBS = 

PYINCLUDE = -I/usr/local/include/python2.0
TCLINCLUDE = -I/usr/local/include

all::
	CC -Kpic -c $(OPT) $(INCLUDE) main.cxx
	cc -c $(OPT) $(INCLUDE) $(SRCS)
	CC -G $(OBJS) -o libwad.so $(LIBS)
	cp libwad.so ..

python::
	cc -c $(OPT) $(INCLUDE) $(SRCS)
	CC -Kpic -c $(INCLUDE) $(PYINCLUDE) wadpy.cxx
	CC -G $(OBJS) wadpy.o -o libwadpy.so $(LIBS)
	cp libwadpy.so ..

tcl::
	cc -c $(OPT) $(INCLUDE) $(SRCS)
	CC -Kpic -c $(INCLUDE) $(TCLINCLUDE) wadtcl.cxx
	CC -G $(OBJS) wadtcl.o -o wad.so $(LIBS)
	cp wad.so libwadtcl.so
	cp libwadtcl.so ..

linux::
	cc -DWAD_LINUX $(INCLUDE) segment.c init.c debug.c

debug::
	cc -g debug.c $(INCLUDE) -L. -R. -lwad

plus::
	CC -g debug.cxx $(INCLUDE) -L. -R. -lwad

wc::
	wc $(SRCS)

semi::
	egrep ";" $(SRCS) wadpy.cxx | wc


clean::
	rm -f *.o *.so *~ 

