
SRCS = stab.c elf.c object.c init.c segment.c signal.c
OBJS = stab.o elf.o object.o signal.o segment.o init.o main.o

all::
	CC -Kpic -c main.cxx
	cc -c $(SRCS)
	CC -G $(OBJS) -o libwad.so

swig::
	swig -python wad.i
	CC -Kpic -c main.cxx
	cc -c $(SRCS) wad_wrap.c -I/usr/local/include/python1.6
	CC -G $(OBJS) wad_wrap.o -o wadmodule.so


some::
	cc -g bar.c blah.c -L. -lwad -R /u0/beazley/Projects/WAD -lelf

wc::
	wc $(SRCS)

semi::
	egrep ";" $(SRCS) | wc


