/* 
Support for setting values in arrays. This is intended to cover all types of arrays.
*/
%typemap(memberin) SWIGTYPE [] {
    int i;
    for (i=0; i<$dim0; i++) {
        $1[i] = $input[i];
    }
}
%typemap(globalin) SWIGTYPE [] {
    int i;
    for (i=0; i<$dim0; i++) {
        $1[i] = $input[i];
    }
}

