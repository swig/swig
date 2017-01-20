all: example

LISP=ccl

example:
	swig -cffi -c++  example.i
	g++ -c example_wrap.cxx -fpic -o example_wrap.o
	g++ -c example.c      -fpic -o example.o
	g++ -shared example.o example_wrap.o -o example.so

test:
	$(LISP) < runme.cl


clean:
	rm -f *.o example_wrap.cxx example-clos.lisp example.lisp example.so *.lx64fsl *~


