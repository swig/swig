/* Testcase for the Java array typemaps which are not used by default. */
%module java_lib_arrays

/* Use the Java library typemaps */
%include "arrays_java.i"

JAVA_ARRAYSOFCLASSES(SimpleStruct)
%apply ARRAYSOFENUMS[ANY] { finger[ANY] }

%include "arrays.i"

