/* Testcase for the Java array typemaps which are not used by default. */
%module java_lib_arrays

%include "enumtypeunsafe.swg"

/* Use the Java library typemaps */
%include "arrays_java.i"

JAVA_ARRAYSOFCLASSES(SimpleStruct)
%apply ARRAYSOFENUMS[ANY] { finger[ANY] }

%include "arrays.i"

// This will test the %typemap(javacode) in the JAVA_ARRAYSOFCLASSES works with C structs amongst other things
JAVA_ARRAYSOFCLASSES(struct AnotherStruct)
%inline %{
struct AnotherStruct {
	SimpleStruct  simple;
};
double extract(struct AnotherStruct as[], int index) {
  return as[index].simple.double_field;
}
%}

