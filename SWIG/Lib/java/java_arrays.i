/* 
Support for setting values in arrays. This is intended to cover all types of
arrays, that is arrays of basic types, eg int, unsigned int, arrays of
structures/classes, arrays of enums and arrays of pointers.
*/
%typemap(java, memberin) SWIGTYPE [] {
    int i;
    for (i=0; i<$dim0; i++)
        $target[i] = $source[i];
}

