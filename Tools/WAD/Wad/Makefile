
SRCS = stab.c elf.c object.c init.c segment.c signal.c
OBJS = stab.o elf.o object.o signal.o segment.o init.o main.o
INCLUDE = -I../Include

all::
	CC -Kpic -c $(INCLUDE) main.cxx
	cc -c $(INCLUDE) $(SRCS)
	CC -G $(OBJS) -o libwad.so
	cp libwad.so ..

wc::
	wc $(SRCS)

semi::
	egrep ";" $(SRCS) | wc


clean::
	rm -f *.o *.so *~ 

