TARGETS = java_cpp $(JAR)
JAR = cpptest.jar

include ../common.mk

PACKAGE = cpptest
SWIGOPT    = -o cpptest_wrap.c -package $(PACKAGE) -shadow $(INCLUDE)
SRCS       = 
TARGET     = libcpptest
INTERFACE  = ../interface/cpptest.i
JAR_FILES = cpptestJava.java cpptest.java cpptest_base.java cpptest_empty.java

clean::
	rm -f *_wrap* *.o *~ .~* core *.so *.sl so_locations
	rm -f $(JAR_FILES) $(JAR)
	rm -rf class

PYTHON = jpython

TESTS = $(wildcard ../test_repo/*.py)
