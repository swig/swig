
SRCS = return.c default.c stack.c stab.c elf.c object.c init.c segment.c signal.c
OBJS = return.o default.o stack.o stab.o elf.o object.o signal.o segment.o init.o
INCLUDE = -I../Include -I.
OPT  = -DWAD_SOLARIS
LIBS = 

#PYINCLUDE = -I/usr/local/include/python2.0
PYINCLUDE = -I/usr/local/include/python1.5
TCLINCLUDE = -I/usr/local/include
PERLINCLUDE = -I/usr/local/lib/perl5/5.6.0/sun4-solaris/CORE

all::
	CC -Kpic -c $(OPT) $(INCLUDE) main.cxx
	cc -c $(OPT) $(INCLUDE) $(SRCS)
	CC -G $(OBJS) main.o -o libwad.so $(LIBS)
	cp libwad.so ..

python::
	cc -c $(OPT) $(INCLUDE) $(SRCS)
	CC -Kpic -c $(INCLUDE) $(PYINCLUDE) wadpy.cxx
	CC -G $(OBJS) main.o wadpy.o -o libwadpy.so $(LIBS)
	cp libwadpy.so ..

tcl::
	cc -c $(OPT) $(INCLUDE) $(SRCS)
	CC -Kpic -c $(INCLUDE) $(TCLINCLUDE) wadtcl.cxx
	CC -G $(OBJS) wadtcl.o -o wad.so $(LIBS)
	cp wad.so libwadtcl.so
	cp libwadtcl.so ..

perl::
	makehandler.py
	cc -c $(OPT) $(INCLUDE) $(SRCS)
	CC -Kpic -c $(INCLUDE) $(PERLINCLUDE) wadpl.cxx
	CC -G $(OBJS) wadpl.o -o libwadpl.so $(LIBS)
	cp libwadpl.so ..

linux::
	g++ -fpic -c -DWAD_LINUX $(INCLUDE) main.cxx
	gcc -g -c -DWAD_LINUX $(INCLUDE) $(SRCS)
	g++ -shared $(OBJS) main.o -o libwad.so $(LIBS)
	cp libwad.so ..

linux-python::
	gcc -c -DWAD_LINUX $(INCLUDE) $(SRCS)
	g++ -fpic -c -DWAD_LINUX $(INCLUDE) $(PYINCLUDE) wadpy.cxx
	g++ -shared $(OBJS) wadpy.o -o libwadpy.so $(LIBS)
	cp libwadpy.so ..

linux2::
	cc -DWAD_LINUX $(INCLUDE) signal.c stack.c default.c demangle.c return.c stab.c elf.c object.c segment.c init.c debug.c

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

