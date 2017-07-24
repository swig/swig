
// see https://github.com/JetBrains/kotlin-native/blob/master/INTEROP.md

%typemap(cinterop) int          "Int"
%typemap(cinterop) double       "Double"