
SRCS = default.c stack.c stab.c elf.c object.c init.c segment.c signal.c
OBJS = default.o stack.o stab.o elf.o object.o signal.o segment.o init.o main.o
INCLUDE = -I../Include

PYINCLUDE = -I/usr/local/include/python2.0
TCLINCLUDE = -I/usr/local/include

all::
	CC -Kpic -c $(INCLUDE) main.cxx
	cc -c $(INCLUDE) $(SRCS)
	CC -G $(OBJS) -o libwad.so
	cp libwad.so ..

python::
	cc -c $(INCLUDE) $(SRCS)
	CC -Kpic -c $(INCLUDE) $(PYINCLUDE) wadpy.cxx
	CC -G $(OBJS) wadpy.o -o wadmodule.so
	cp wadmodule.so libwadpy.so
	cp libwadpy.so ..

tcl::
	cc -c $(INCLUDE) $(SRCS)
	CC -Kpic -c $(INCLUDE) $(TCLINCLUDE) wadtcl.cxx
	CC -G $(OBJS) wadtcl.o -o wad.so
	cp wad.so libwadtcl.so
	cp libwadtcl.so ..

debug::
	cc -g debug.c $(INCLUDE) -L. -R. -lwad

wc::
	wc $(SRCS)

semi::
	egrep ";" $(SRCS) | wc


clean::
	rm -f *.o *.so *~ 

