TARGETS = python_cpp

include ../common.mk

SWIGOPT    = -o cpptest_wrap.c  -shadow $(INCLUDE)
SRCS       =
TARGET     = cpptestc
INTERFACE  = ../interface/cpptest.i


clean:
	rm -f *_wrap* *.py *.pyc *.o *~ .~* core *.so *.sl so_locations

PYTHON = python

TESTS = ../test_repo/constructor.py  \
	../test_repo/constructor_user_type.py \
	../test_repo/inheritence_map_to_base_class.py \
	../test_repo/object_method.py \
	../test_repo/object_method_user_type.py \
	../test_repo/primitive_method.py \
	../test_repo/primitive_method_user_type.py
