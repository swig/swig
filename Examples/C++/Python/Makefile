TARGETS = python_cpp

include ../common.mk

SWIGOPT    = -o cpptest_wrap.c  -shadow $(INCLUDE)
SRCS       =
TARGET     = cpptestc
INTERFACE  = ../interface/cpptest.i


clean:
	rm -f *_wrap* *.py *.pyc *.o *~ .~* core *.so *.sl so_locations

PYTHON = python

TESTS = $(wildcard ../test_repo/*.py)
