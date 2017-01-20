all: overctor

overctor:
	swig -cffi -c++  overctor.i
	g++ -c overctor_wrap.cxx -fpic -o overctor_wrap.o
	g++ -c overctor.cpp      -fpic -o overctor.o
	g++ -shared overctor.o overctor_wrap.o -o overctor.so

test:
	ccl < overctor_test.cl


clean:
	rm -f *.o overctor_wrap.cxx overctor-clos.lisp overctor.lisp overctor.so *.lx64fsl *~


