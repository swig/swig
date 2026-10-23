/* Testcase for the Java array typemaps which are not used by default. */
%module java_lib_arrays

%include "enumtypeunsafe.swg"

/* Use the Java library typemaps */
%include "arrays_java.i"

JAVA_ARRAYSOFCLASSES(SimpleStruct)
%apply ARRAYSOFENUMS[ANY] { finger[ANY] }
//%apply signed char[ANY] { char array_c2[ANY] }

%include "arrays.i"

%inline %{
int ints_isnull(int array[]) { return array == 0; }
int ints_sized_isnull(int array[ARRAY_LEN]) { return array == 0; }
int fingers_isnull(finger array[ARRAY_LEN]) { return array == 0; }
int structs_isnull(SimpleStruct array[]) { return array == 0; }
int structs_sized_isnull(SimpleStruct array[ARRAY_LEN]) { return array == 0; }
%}

// This will test the %typemap(javacode) in the JAVA_ARRAYSOFCLASSES works with C structs amongst other things
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
//%apply struct YetAnotherStruct[] { struct YetAnotherStruct * } // Note: Does not work unless this is put after the YetAnotherStruct definition
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
JAVA_ARRAYS_TYPEMAPS(char, byte, jbyte, Char, "[B")
%typecheck(SWIG_TYPECHECK_INT8_ARRAY) /* Java byte[] */
    signed char[ANY], signed char[]
    ""

%inline %{
struct ArrayStructExtra {
	char           array_c2[ARRAY_LEN];
};
%}
