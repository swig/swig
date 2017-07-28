
// see https://github.com/JetBrains/kotlin-native/blob/master/INTEROP.md

%typemap(cinterop) int          "Int"
%typemap(cinterop) double       "Double"
%typemap(cinterop) SWIGTYPE *   "COpaquePointer"

%typemap(kt_wrap) int           "int"
%typemap(kt_wrap) double        "double"
%typemap(kt_wrap) SWIGTYPE *    "void *"

%insert(begin_kt)
{
import kotlinx.cinterop.*

abstract class SwigObject(val ref: COpaquePointer)
}