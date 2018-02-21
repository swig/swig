/*
This testcase tests whether the sizeof operator on a pointer is working.
*/

%module sizeof_pointer

#ifdef SWIGFORTRAN
%warnfilter(SWIGWARN_LANG_IDENTIFIER); /* incompatible array expressions */
#endif

%inline %{

#define  NO_PROBLEM sizeof(char)
#define  STAR_PROBLEM sizeof(char*)
#define  STAR_STAR_PROBLEM sizeof(char**)

typedef struct SizePtrTst {
  unsigned char array1[NO_PROBLEM];
  unsigned char array2[STAR_PROBLEM];
  unsigned char array3[STAR_STAR_PROBLEM];
} SizePtrTst;

%}
