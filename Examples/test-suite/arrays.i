/*
This test case tests that various types of arrays are working.
*/

%module arrays

%{
#include <stdlib.h>
%}

#if defined(SWIGSCILAB)
%rename(ArrSt) ArrayStruct;
#endif

%inline %{
#define ARRAY_LEN 2

typedef enum {One, Two, Three, Four, Five} finger;

typedef struct {
	double         double_field;
} SimpleStruct;

typedef struct {
	char           array_c [ARRAY_LEN];
	signed char    array_sc[ARRAY_LEN];
	unsigned char  array_uc[ARRAY_LEN];
	short          array_s [ARRAY_LEN];
	unsigned short array_us[ARRAY_LEN];
	int            array_i [ARRAY_LEN];
	unsigned int   array_ui[ARRAY_LEN];
	long           array_l [ARRAY_LEN];
	unsigned long  array_ul[ARRAY_LEN];
	long long      array_ll[ARRAY_LEN];
	float          array_f [ARRAY_LEN];
        double         array_d [ARRAY_LEN];
        SimpleStruct   array_struct[ARRAY_LEN];
        SimpleStruct*  array_structpointers[ARRAY_LEN];
        int*           array_ipointers [ARRAY_LEN];
	finger         array_enum[ARRAY_LEN];
	finger*        array_enumpointers[ARRAY_LEN];
	const int      array_const_i[ARRAY_LEN];
} ArrayStruct;

void fn_taking_arrays(SimpleStruct array_struct[ARRAY_LEN]) {}

/* Pointer helper functions used in the Java run test */
int* newintpointer() {
    return (int*)malloc(sizeof(int));
}
void setintfrompointer(int* intptr, int value) {
    *intptr = value;
}
int getintfrompointer(int* intptr) {
    return *intptr;
}

%}

// This tests wrapping of function that involves pointer to array


%inline %{
void array_pointer_func(int (*x)[10]) {}
%}


%inline %{
typedef float FLOAT;

typedef FLOAT cartPosition_t[3];

typedef struct {
cartPosition_t p;
} CartPoseData_t;

%}

#ifdef SWIGFORTRAN
/* Fortran can't handle hex, but it can substitute compile-time constants like
 * the enum into the 'contains' part of the code. HOWEVER, the interface must
 * "import" the enums, so enums don't work after all. */
%ignore oned_hex;
%ignore oned_enum;
%ignore twod_enum;

%inline %{
enum {TEN = 10};
void oned_int(int a[10]);
void oned_expr(int a[2*5]);
void oned_enum(int a[TEN]);
void oned_hex(int a[0xa]);
void twod_int(int a[10][4]);
void twod_expr1(int a[2*5][4]);
void twod_expr2(int a[10][2*2]);
void twod_expr3(int a[2*5][2*2]);
void twod_enum(int a[TEN][4]);

#ifdef __cplusplus
extern "C" {
#endif
void oned_unknown(int a[]);
void twod_unknown_int(int a[][10]);
#ifdef __cplusplus
}
#endif
%}
#endif

