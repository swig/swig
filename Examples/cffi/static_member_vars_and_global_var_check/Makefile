all: avar

avar:
	swig -cffi -c++  avar.i
	g++ -c avar_wrap.cxx -fpic -o avar_wrap.o
	g++ -c avar.cpp      -fpic -o avar.o
	g++ -shared avar.o avar_wrap.o -o avar.so

test:
	ccl < avar_test.cl


clean:
	rm -f *.o avar_wrap.cxx avar-clos.lisp avar.lisp avar.so *.lx64fsl *~


