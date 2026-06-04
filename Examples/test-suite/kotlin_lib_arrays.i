/* Testcase for the Kotlin array typemaps which are not used by default. */
%module kotlin_lib_arrays

%include "enumtypeunsafe.swg"

/* Use the Kotlin library typemaps */
%include <arrays_kotlin.i>

/*
 * NOTE: The JAVA_ARRAYSOFCLASSES(...) array-of-classes feature is intentionally NOT
 * exercised here (unlike the java_lib_arrays testcase). The JAVA_ARRAYSOFCLASSES macro in
 * arrays_kotlin.i still emits Java syntax for its proxy helpers and for its kstype/kin/kout
 * typemaps (e.g. "protected static long[] cArrayUnwrap($kotlinclassname[] ...)", "new
 * $kotlinclassname[...]"), which is not valid Kotlin and fails to compile. Supporting it
 * requires porting that macro in Lib/kotlin/arrays_kotlin.i to emit kcode/Kotlin syntax
 * (Array<$kotlinclassname>, LongArray, etc.). This testcase therefore covers the primitive
 * array member typemaps (JAVA_ARRAYS_TYPEMAPS / ARRAYSOFENUMS) only, which map C arrays to
 * the Kotlin primitive array types (ByteArray, ShortArray, IntArray, LongArray, FloatArray,
 * DoubleArray) and work correctly.
 */

%apply ARRAYSOFENUMS[ANY] { finger[ANY] }
//%apply signed char[ANY] { char array_c2[ANY] }

%include "arrays.i"

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
