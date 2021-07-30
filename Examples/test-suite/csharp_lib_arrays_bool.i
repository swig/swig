%module csharp_lib_arrays_bool

%include "arrays_csharp.i"

%apply bool INPUT[] { bool* sourceArray }
%apply bool OUTPUT[] { bool* targetArray }

%apply bool INOUT[] { bool* array1 }
%apply bool INOUT[] { bool* array2 }

%inline %{
#include <iostream>

/* copy the contents of the first array to the second */
void myArrayCopyBool( bool* sourceArray, bool* targetArray, int nitems ) {
  int i;
  for ( i = 0; i < nitems; i++ ) {
    targetArray[ i ] = sourceArray[ i ];
  }
}

/* swap the contents of the two arrays */
void myArraySwapBool( bool* array1, bool* array2, int nitems ) {
  int i;
  bool temp;
  for ( i = 0; i < nitems; i++ ) {
    temp = array1[ i ];
    array1[ i ] = array2[ i ];
    array2[ i ] = temp;
  }
}

bool checkBoolArrayCorrect( bool* sourceArray, int sourceArraySize ) {
  if( sourceArraySize != 8 ) {
    std::cout << "checkBoolArrayCorrect: Expected array with 8 elements" << std::endl;
    return false;
  }
  return sourceArray[0] == true &&
         sourceArray[1] == false &&
         sourceArray[2] == false &&
         sourceArray[3] == true &&
         sourceArray[4] == false &&
         sourceArray[5] == true &&
         sourceArray[6] == true &&
         sourceArray[7] == false;
}
%}

%clear bool* sourceArray;
%clear bool* targetArray;

%clear bool* array1;
%clear bool* array2;

// Below replicates the above array handling but this time using the pinned (fixed) array typemaps
%csmethodmodifiers myArrayCopyUsingFixedArraysBool "public unsafe";
%csmethodmodifiers myArraySwapUsingFixedArraysBool "public unsafe";

%apply bool FIXED[] { bool* sourceArray }
%apply bool FIXED[] { bool* targetArray }

%inline %{
void myArrayCopyUsingFixedArraysBool( bool *sourceArray, bool* targetArray, int nitems ) {
  myArrayCopyBool(sourceArray, targetArray, nitems);
}
%}

%apply bool FIXED[] { bool* array1 }
%apply bool FIXED[] { bool* array2 }

%inline %{
void myArraySwapUsingFixedArraysBool( bool* array1, bool* array2, int nitems ) {
  myArraySwapBool(array1, array2, nitems);
}
%}



