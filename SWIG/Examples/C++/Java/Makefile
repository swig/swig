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

TESTS = 

# We haven't checked for JPython in the configure step, so don't run
# any tests that require it.

# ../test_repo/constructor.py  \
# 	../test_repo/constructor_user_type.py \
# 	../test_repo/inheritence_map_to_base_class.py \
# 	../test_repo/object_method.py \
# 	../test_repo/object_method_user_type.py \
# 	../test_repo/primitive_method.py \
# 	../test_repo/primitive_method_user_type.py
