/* Testcase for the Kotlin array typemaps which are not used by default. */
%module kotlin_lib_arrays

%include "enumtypeunsafe.swg"

/* Use the Kotlin library typemaps */
%include <arrays_kotlin.i>

/*
 * This testcase mirrors java_lib_arrays. It exercises both the primitive array
 * member typemaps (JAVA_ARRAYS_TYPEMAPS / ARRAYSOFENUMS), which map C arrays to the
 * Kotlin primitive array types (ByteArray, ShortArray, IntArray, LongArray,
 * FloatArray, DoubleArray), and the JAVA_ARRAYSOFCLASSES array-of-classes feature,
 * which maps C arrays of wrapped structs to Kotlin Array<ProxyClass> using the
 * cArrayWrap/cArrayUnwrap companion helpers.
 */

JAVA_ARRAYSOFCLASSES(SimpleStruct)
%apply ARRAYSOFENUMS[ANY] { finger[ANY] }
//%apply signed char[ANY] { char array_c2[ANY] }

%include "arrays.i"

// This tests that the JAVA_ARRAYSOFCLASSES helpers work with C structs amongst other things
JAVA_ARRAYSOFCLASSES(struct AnotherStruct)
%inline %{
struct AnotherStruct {
	SimpleStruct  simple;
};
double extract(struct AnotherStruct as[], int index) {
  return as[index].simple.double_field;
}
double extract2(struct AnotherStruct as[5], int index) {
  return as[index].simple.double_field;
}
%}

// Test %apply to pointers
JAVA_ARRAYSOFCLASSES(struct YetAnotherStruct)
%apply struct YetAnotherStruct[] { struct YetAnotherStruct *yas }
%inline %{
struct YetAnotherStruct {
	SimpleStruct  simple;
};
double extract_ptr(struct YetAnotherStruct *yas, int index) {
  return yas[index].simple.double_field;
}
void modifyYAS(struct YetAnotherStruct yas[], int size) {
  int i;
  for (i=0; i<size; ++i) {
    SimpleStruct ss;
    ss.double_field = yas[i].simple.double_field * 10.0;
    yas[i].simple = ss;
  }
}
%}

%apply ARRAYSOFENUMS[ANY] { toe[ANY] }
%apply ARRAYSOFENUMS[] { toe[] }
%apply ARRAYSOFENUMS[] { toe* }
%inline %{
typedef enum { Big, Little } toe;
void toestest(toe *t, toe tt[], toe ttt[2]) {}
%}


JAVA_ARRAYS_IMPL(char, jbyte, Byte, Char)
JAVA_ARRAYS_TYPEMAPS(char, ByteArray, jbyte, Char, "[B")
%typecheck(SWIG_TYPECHECK_INT8_ARRAY) /* Kotlin ByteArray */
    signed char[ANY], signed char[]
    ""

%inline %{
struct ArrayStructExtra {
	char           array_c2[ARRAY_LEN];
};
%}
