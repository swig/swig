/* -----------------------------------------------------------------------------
 * typemaps.swg
 *
 * SWIG Library file containing the main typemap code to support Duktape modules.
 * ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
 *                          Basic inout typemaps
 * ----------------------------------------------------------------------------- */
/*
These provide the basic ability for passing in & out of standard numeric data types
(int,long,float,double, etc)

The basic code looks like this:

%typemap(in,checkfn="duk_is_number") int *INPUT(int temp), int &INPUT(int temp)
%{ temp = (int)duk_tonumber(ctx,$input);
   $1 = &temp; %}

%typemap(in, numinputs=0) int *OUTPUT (int temp)
%{ $1 = &temp; %}

%typemap(argout) int *OUTPUT
%{  duk_push_number(ctx, (double) *$1); %}

%typemap(in) int *INOUT = int *INPUT;
%typemap(argout) int *INOUT = int *OUTPUT;

However the code below is a mixture of #defines & such, so nowhere as easy to read

To make you code work correctly its not just a matter of %including this file
You also have to give SWIG the hints on which to use where

eg
extern int add_pointer(int* a1,int* a2); // a1 & a2 are pointer values to be added
extern void swap(int* s1, int* s2);	// does the swap

You will need to either change the argument names
extern int add_pointer(int* INPUT,int* INPUT);

or provide a %apply statement

%apply int* INOUT{ int *s1, int *s2 };
	// if SWIG sees int* s1, int* s2, assume they are inout params
*/


%define SWIG_NUMBER_TYPEMAP(TYPE)
%typemap(in,checkfn="duk_is_number")	TYPE *INPUT($*ltype temp), TYPE &INPUT($*ltype temp)
%{ temp = ($*ltype)duk_to_number(ctx,$input);
   $1 = &temp; %}
%typemap(in, numinputs=0) TYPE *OUTPUT ($*ltype temp)
%{ $1 = &temp; %}
%typemap(argout) TYPE *OUTPUT
%{  duk_push_number(ctx, (duk_double_t) *$1); %}
%typemap(in) TYPE *INOUT = TYPE *INPUT;
%typemap(argout) TYPE *INOUT = TYPE *OUTPUT;
%typemap(in) TYPE &OUTPUT = TYPE *OUTPUT;
%typemap(argout) TYPE &OUTPUT = TYPE *OUTPUT;
%typemap(in) TYPE &INOUT = TYPE *INPUT;
%typemap(argout) TYPE &INOUT = TYPE *OUTPUT;
// const version (the $*ltype is the basic number without ptr or const's)
%typemap(in,checkfn="duk_is_number")	const TYPE *INPUT($*ltype temp)
%{ temp = ($*ltype)duk_to_number(ctx,$input);
   $1 = &temp; %}
%enddef

// now the code
SWIG_NUMBER_TYPEMAP(unsigned char); SWIG_NUMBER_TYPEMAP(signed char);

SWIG_NUMBER_TYPEMAP(short); SWIG_NUMBER_TYPEMAP(unsigned short); SWIG_NUMBER_TYPEMAP(signed short);
SWIG_NUMBER_TYPEMAP(int); SWIG_NUMBER_TYPEMAP(unsigned int); SWIG_NUMBER_TYPEMAP(signed int);
SWIG_NUMBER_TYPEMAP(long); SWIG_NUMBER_TYPEMAP(unsigned long); SWIG_NUMBER_TYPEMAP(signed long);
SWIG_NUMBER_TYPEMAP(float);
SWIG_NUMBER_TYPEMAP(double);
SWIG_NUMBER_TYPEMAP(enum SWIGTYPE);
// also for long longs's
SWIG_NUMBER_TYPEMAP(long long); SWIG_NUMBER_TYPEMAP(unsigned long long); SWIG_NUMBER_TYPEMAP(signed long long);

// note we dont do char, as a char* is probably a string not a ptr to a single char

// similar for booleans
%typemap(in,checkfn="duk_is_boolean") bool *INPUT(bool temp), bool &INPUT(bool temp)
%{
  temp = (duk_to_boolean(ctx,$input)!=0);
  $1 = &temp;
%}

%typemap(in, numinputs=0) bool *OUTPUT (bool temp),bool &OUTPUT (bool temp)
%{ $1 = &temp; %}

%typemap(argout) bool *OUTPUT,bool &OUTPUT
%{  duk_push_boolean(ctx, (int)((*$1)!=0)); %}

%typemap(in) bool *INOUT = bool *INPUT;
%typemap(argout) bool *INOUT = bool *OUTPUT;
%typemap(in) bool &INOUT = bool &INPUT;
%typemap(argout) bool &INOUT = bool &OUTPUT;

/* -----------------------------------------------------------------------------
 *                          Basic Array typemaps
 * ----------------------------------------------------------------------------- */
/*
I have no idea why this kind of code does not exist in SWIG as standard,
but here is it.
This code will convert to/from 1D numeric arrays.
In order to reduce code bloat, there are a few macros
and quite a few functions defined
(unfortunately this makes it a lot less clear)

assuming we have functions
void process_array(int arr[3]);	// nice fixed size array
void process_var_array(float arr[],int len);	// variable sized array
void process_var_array_inout(double* arr,int len);	// variable sized array
			// data passed in & out
void process_enum_inout_array_var(enum Days *arrinout, int len);	// using enums
void return_array_5(int arrout[5]);	// out array only

in order to wrap them correctly requires a typemap

// inform SWIG of the correct typemap
// For fixed length, you must specify it as <type> INPUT[ANY]
%apply (int INPUT[ANY]) {(int arr[3])};
// variable length arrays are just the same
%apply (float INPUT[],int) {(float arr[],int len)};
// it is also ok, to map the TYPE* instead of a TYPE[]
%apply (double *INOUT,int) {(double arr*,int len)};
// for the enum's you must use enum SWIGTYPE
%apply (enum SWIGTYPE *INOUT,int) {(enum Days *arrinout, int len)};
// fixed length out if also fine
%apply (int OUTPUT[ANY]) {(int arrout[5])};

Generally, you could use %typemap(...)=...
but the %apply is neater & easier

The following are not yet supported:
* variable length output only array (inout works ok)
* multidimensional arrays
* arrays of objects/structs
* arrays of pointers

*/

/*
The internals of the array management stuff
helper fns/macros
SWIG_ALLOC_ARRAY(TYPE,LEN)	// returns a typed array TYPE[LEN]
SWIG_FREE_ARRAY(PTR)		// delete the ptr (if not zero)

// counts the specified table & gets the size
// integer version
int SWIG_itable_size(duk_context* ctx, int idx);
// other version
int SWIG_table_size(duk_context* ctx, int idx);

SWIG_DECLARE_TYPEMAP_ARR_FN(NAME,TYPE)
// this fn declares up 4 functions for helping to read/write tables
// these can then be called by the macros ...
// all assume the table is an integer idxes from 1
// but the C array is a idxed from 0
	// created a fixed size array, reads the specified table
	// and then fills the array with numbers
	// returns ptr to the array if ok, or 0 for error
	// (also pushes a error message to the stack)
TYPE* SWIG_get_NAME_num_array_fixed(duk_context* ctx, int idx, int size);
	// as per SWIG_get_NAME_num_array_fixed()
	// but reads the entire table & creates an array of the correct size
	// (if the table is empty, it returns an error rather than a zero length array)
TYPE* SWIG_get_NAME_num_array_var(duk_context* ctx, int idx, int* size);
	// writes a table to Lua with all the specified numbers
void SWIG_write_NAME_num_array(duk_context* ctx,TYPE *array,int size);
	// read the specified table, and fills the array with numbers
	// returns 1 of ok (only fails if it doesnt find numbers)
	// helper fn (called by SWIG_get_NAME_num_array_*() fns)
int SWIG_read_NAME_num_array(duk_context* ctx,int idx,TYPE *array,int size);

*/

/* Reported that you don't need to check for NULL for delete & free
There probably is some compiler that its not true for, so the code is left here just in case.
#ifdef __cplusplus	
#define SWIG_ALLOC_ARRAY(TYPE,LEN) 	new TYPE[LEN]
#define SWIG_FREE_ARRAY(PTR)		if(PTR){delete[] PTR;}
#else
#define SWIG_ALLOC_ARRAY(TYPE,LEN) 	(TYPE *)malloc(LEN*sizeof(TYPE))
#define SWIG_FREE_ARRAY(PTR)		if(PTR){free(PTR);}
#endif
*/
%{
#ifdef __cplusplus	/* generic alloc/dealloc fns*/
#define SWIG_ALLOC_ARRAY(TYPE,LEN) 	new TYPE[LEN]
#define SWIG_FREE_ARRAY(PTR)		delete[] PTR
#else
#define SWIG_ALLOC_ARRAY(TYPE,LEN) 	(TYPE *)malloc(LEN*sizeof(TYPE))
#define SWIG_FREE_ARRAY(PTR)		free(PTR)
#endif
/* counting the size of arrays:*/
SWIGINTERN int SWIG_itable_size(duk_context* ctx, int idx)
{
	int n=0;
	while(1){
		duk_get_prop_index(ctx,idx,n);
		if (duk_is_undefined(ctx,-1))break;
		++n;
		duk_pop_n(ctx,1);
	}
	duk_pop_n(ctx,1);
	return n;
}

SWIGINTERN int SWIG_table_size(duk_context* ctx, int idx)
{
	int n=0;
	duk_push_null(ctx);  /* first key*/
	while (duk_next(ctx, idx, n) != 0) {
		++n;
		duk_pop_n(ctx, 1);  /* removes `value'; keeps `key' for next iteration*/
	}
	return n;
}

/* super macro to declare array typemap helper fns */
#define SWIG_DECLARE_TYPEMAP_ARR_FN(NAME,TYPE)\
	SWIGINTERN int SWIG_read_##NAME##_num_array(duk_context *ctx,int idx,TYPE *array,int size){\
		int i;\
		for (i = 0; i < size; i++) {\
			duk_get_prop_index(ctx,idx,i);\
			if (duk_is_number(ctx,-1)){\
				array[i] = (TYPE)duk_to_number(ctx,-1);\
			} else {\
				duk_pop_n(ctx,1);\
				return 0;\
			}\
			duk_pop_n(ctx,1);\
		}\
		return 1;\
	}\
	SWIGINTERN TYPE* SWIG_get_##NAME##_num_array_fixed(duk_context* ctx, int idx, int size){\
		TYPE *array;\
		if (!duk_is_object(ctx,idx) || SWIG_itable_size(ctx,idx) != size) {\
			duk_push_sprintf(ctx,"expected a table of size %d",size);\
			return 0;\
		}\
		array=SWIG_ALLOC_ARRAY(TYPE,size);\
		if (!SWIG_read_##NAME##_num_array(ctx,idx,array,size)){\
			duk_push_string(ctx,"Array must contain numbers");\
			SWIG_FREE_ARRAY(array);\
			return 0;\
		}\
		return array;\
	}\
	SWIGINTERN TYPE* SWIG_get_##NAME##_num_array_var(duk_context* ctx, int idx, int* size)\
	{\
		TYPE *array;\
		if (!duk_is_object(ctx,idx)) {\
			duk_push_sprintf(ctx,"expected an object");\
			return 0;\
		}\
		*size=SWIG_itable_size(ctx,idx);\
		if (*size<1){\
			duk_push_sprintf(ctx,"array appears to be empty");\
			return 0;\
		}\
		array=SWIG_ALLOC_ARRAY(TYPE,*size);\
		if (!SWIG_read_##NAME##_num_array(ctx,idx,array,*size)){\
			duk_push_sprintf(ctx,"array must contain numbers");\
			SWIG_FREE_ARRAY(array);\
			return 0;\
		}\
		return array;\
	}\
	SWIGINTERN void SWIG_write_##NAME##_num_array(duk_context *ctx,TYPE *array,int size){\
		int i;\
		duk_idx_t arr_idx = duk_push_array(ctx);\
		for (i = 0; i < size; i++){\
			duk_push_number(ctx,(duk_double_t)array[i]);\
			duk_put_prop_index(ctx,-2,i);/* -1 is the number, -2 is the object */ \
		}\
    duk_pop(ctx); \
	}
%}

/*
This is one giant macro to define the typemaps & the helpers
for array handling
*/
%define SWIG_TYPEMAP_NUM_ARR(NAME,TYPE)
%{SWIG_DECLARE_TYPEMAP_ARR_FN(NAME,TYPE)%}

// fixed size array's
%typemap(in) TYPE INPUT[ANY]
%{	$1 = SWIG_get_##NAME##_num_array_fixed(ctx,$input,$1_dim0);
	if (!$1) SWIG_fail;%}

%typemap(freearg) TYPE INPUT[ANY]
%{	SWIG_FREE_ARRAY($1);%}

// variable size array's
%typemap(in) (TYPE *INPUT,int)
%{	$1 = SWIG_get_##NAME##_num_array_var(ctx,$input,&$2);
	if (!$1) SWIG_fail;%}

%typemap(freearg) (TYPE *INPUT,int)
%{	SWIG_FREE_ARRAY($1);%}

// out fixed arrays
%typemap(in,numinputs=0) TYPE OUTPUT[ANY]
%{  $1 = SWIG_ALLOC_ARRAY(TYPE,$1_dim0); %}

%typemap(argout) TYPE OUTPUT[ANY]
%{	SWIG_write_##NAME##_num_array(ctx,$1,$1_dim0); %}

%typemap(freearg) TYPE OUTPUT[ANY]
%{	SWIG_FREE_ARRAY($1); %}

// inout fixed arrays
%typemap(in) TYPE INOUT[ANY]=TYPE INPUT[ANY];
%typemap(argout) TYPE INOUT[ANY]=TYPE OUTPUT[ANY];
%typemap(freearg) TYPE INOUT[ANY]=TYPE INPUT[ANY];
// inout variable arrays
%typemap(in) (TYPE *INOUT,int)=(TYPE *INPUT,int);
%typemap(argout) (TYPE *INOUT,int)
%{	SWIG_write_##NAME##_num_array(ctx,$1,$2); %}
%typemap(freearg) (TYPE *INOUT,int)=(TYPE *INPUT,int);

// TODO out variable arrays (is there a standard form for such things?)

// referencing so that (int *INPUT,int) and (int INPUT[],int) are the same
%typemap(in) (TYPE INPUT[],int)=(TYPE *INPUT,int);
%typemap(freearg) (TYPE INPUT[],int)=(TYPE *INPUT,int);

%enddef

// the following line of code
// declares the C helper fns for the array typemaps
// as well as defining typemaps for
// fixed len arrays in & out, & variable length arrays in

SWIG_TYPEMAP_NUM_ARR(schar,signed char);
SWIG_TYPEMAP_NUM_ARR(uchar,unsigned char);
SWIG_TYPEMAP_NUM_ARR(int,int);
SWIG_TYPEMAP_NUM_ARR(uint,unsigned int);
SWIG_TYPEMAP_NUM_ARR(short,short);
SWIG_TYPEMAP_NUM_ARR(ushort,unsigned short);
SWIG_TYPEMAP_NUM_ARR(long,long);
SWIG_TYPEMAP_NUM_ARR(ulong,unsigned long);
SWIG_TYPEMAP_NUM_ARR(float,float);
SWIG_TYPEMAP_NUM_ARR(double,double);

// again enums are a problem so they need their own type
// we use the int conversion routine & recast it
%typemap(in) enum SWIGTYPE INPUT[ANY]
%{	$1 = ($ltype)SWIG_get_int_num_array_fixed(ctx,$input,$1_dim0);
	if (!$1) SWIG_fail;%}

%typemap(freearg) enum SWIGTYPE INPUT[ANY]
%{	SWIG_FREE_ARRAY($1);%}

// variable size arrays
%typemap(in) (enum SWIGTYPE *INPUT,int)
%{	$1 = ($ltype)SWIG_get_int_num_array_var(ctx,$input,&$2);
	if (!$1) SWIG_fail;%}

%typemap(freearg) (enum SWIGTYPE *INPUT,int)
%{	SWIG_FREE_ARRAY($1);%}

// out fixed arrays
%typemap(in,numinputs=0) enum SWIGTYPE OUTPUT[ANY]
%{  $1 = SWIG_ALLOC_ARRAY(enum SWIGTYPE,$1_dim0); %}

%typemap(argout) enum SWIGTYPE OUTPUT[ANY]
%{	SWIG_write_int_num_array(ctx,(int*)$1,$1_dim0); %}

%typemap(freearg) enum SWIGTYPE OUTPUT[ANY]
%{	SWIG_FREE_ARRAY($1); %}

// inout fixed arrays
%typemap(in) enum SWIGTYPE INOUT[ANY]=enum SWIGTYPE INPUT[ANY];
%typemap(argout) enum SWIGTYPE INOUT[ANY]=enum SWIGTYPE OUTPUT[ANY];
%typemap(freearg) enum SWIGTYPE INOUT[ANY]=enum SWIGTYPE INPUT[ANY];
// inout variable arrays
%typemap(in) (enum SWIGTYPE *INOUT,int)=(enum SWIGTYPE *INPUT,int);
%typemap(argout) (enum SWIGTYPE *INOUT,int)
%{	SWIG_write_int_num_array(ctx,(int*)$1,$2);  %}
%typemap(freearg) (enum SWIGTYPE *INOUT,int)=(enum SWIGTYPE *INPUT,int);


/* Surprisingly pointer arrays are easier:
this is because all ptr arrays become void**
so only a few fns are needed & a few casts

The function defined are
	// created a fixed size array, reads the specified table
	// and then fills the array with pointers (checking the type)
	// returns ptr to the array if ok, or 0 for error
	// (also pushes a error message to the stack)
void** SWIG_get_ptr_array_fixed(duk_context* ctx, int idx, int size,swig_type_info *type);
	// as per SWIG_get_ptr_array_fixed()
	// but reads the entire table & creates an array of the correct size
	// (if the table is empty, it returns an error rather than a zero length array)
void** SWIG_get_ptr_array_var(duk_context* ctx, int idx, int* size,swig_type_info *type);
	// writes a table to Lua with all the specified pointers
	// all pointers have the ownership value 'own' (normally 0)
void SWIG_write_ptr_array(duk_context* ctx,void **array,int size,int own);
	// read the specified table, and fills the array with ptrs
	// returns 1 of ok (only fails if it doesn't find correct type of ptrs)
	// helper fn (called by SWIG_get_ptr_array_*() fns)
int SWIG_read_ptr_array(duk_context* ctx,int idx,void **array,int size,swig_type_info *type);

The key thing to remember is that it is assumed that there is no
modification of pointers ownership in the arrays

eg A fn:
void pointers_in(TYPE* arr[],int len);
will make copies of the pointer into a temp array and then pass it into the fn
Lua does not remember that this fn held the pointers, so it is not safe to keep
these pointers until later

eg A fn:
void pointers_out(TYPE* arr[3]);
will return a table containing three pointers
however these pointers are NOT owned by Duktape, merely borrowed
so if the C/C++ frees then Duktape is not aware

*/

%{
SWIGINTERN int SWIG_read_ptr_array(duk_context *ctx,int idx,void **array,int size,swig_type_info *type){
	int i;
	for (i = 0; i < size; i++) {
    duk_get_prop_index(ctx, idx, i);
		if (!duk_is_pointer(ctx,-1) || SWIG_ConvertPtr(ctx,-1,&array[i],type,0)==-1){
			duk_pop_n(ctx,1);
			return 0;
		}
		duk_pop_n(ctx,1);
	}
	return 1;
}
SWIGINTERN void** SWIG_get_ptr_array_fixed(duk_context* ctx, int idx, int size,swig_type_info *type){
	void **array;
	if (!duk_is_object(ctx,idx) || SWIG_itable_size(ctx,idx) != size) {
		duk_push_sprintf(ctx,"expected a table of size %d",size);
		return 0;
	}
	array=SWIG_ALLOC_ARRAY(void*,size);
	if (!SWIG_read_ptr_array(ctx,idx,array,size,type)){
		duk_push_sprintf(ctx,"table must contain pointers of type %s",type->name);
		SWIG_FREE_ARRAY(array);
		return 0;
	}
	return array;
}
SWIGINTERN void** SWIG_get_ptr_array_var(duk_context* ctx, int idx, int* size,swig_type_info *type){
	void **array;
	if (!duk_is_array(ctx,idx)) {
		duk_push_sprintf(ctx,"expected an array");
		return 0;
	}
	*size=SWIG_itable_size(ctx,idx);
	if (*size<1){
		duk_push_sprintf(ctx,"array appears to be empty");
		return 0;
	}
	array=SWIG_ALLOC_ARRAY(void*,*size);
	if (!SWIG_read_ptr_array(ctx,idx,array,*size,type)){
		duk_push_sprintf(ctx,"array must contain pointers of type %s",type->name);
		SWIG_FREE_ARRAY(array);
		return 0;
	}
	return array;
}
SWIGINTERN void SWIG_write_ptr_array(duk_context* ctx,void **array,int size,swig_type_info *type,int own){
	int i;
  duk_push_array(ctx);
	for (i = 0; i < size; i++){
		SWIG_NewPointerObj(ctx,array[i],type,own);
    duk_put_prop_index(ctx, -2, i);
		/* -1 is the number, -2 is the object */
	}
}
%}

// fixed size array's
%typemap(in) SWIGTYPE* INPUT[ANY]
%{	$1 = ($ltype)SWIG_get_ptr_array_fixed(ctx,$input,$1_dim0,$*1_descriptor);
	if (!$1) SWIG_fail;%}

%typemap(freearg) SWIGTYPE* INPUT[ANY]
%{	SWIG_FREE_ARRAY($1);%}

// variable size array's
%typemap(in) (SWIGTYPE **INPUT,int)
%{	$1 = ($ltype)SWIG_get_ptr_array_var(ctx,$input,&$2,$*1_descriptor);
	if (!$1) SWIG_fail;%}

%typemap(freearg) (SWIGTYPE **INPUT,int)
%{	SWIG_FREE_ARRAY($1);%}

// out fixed arrays
%typemap(in,numinputs=0) SWIGTYPE* OUTPUT[ANY]
%{  $1 = SWIG_ALLOC_ARRAY($*1_type,$1_dim0); %}

%typemap(argout) SWIGTYPE* OUTPUT[ANY]
%{	SWIG_write_ptr_array(ctx,(void**)$1,$1_dim0,$*1_descriptor,0); %}

%typemap(freearg) SWIGTYPE* OUTPUT[ANY]
%{	SWIG_FREE_ARRAY($1); %}

// inout fixed arrays
%typemap(in) SWIGTYPE* INOUT[ANY]=SWIGTYPE* INPUT[ANY];
%typemap(argout) SWIGTYPE* INOUT[ANY]=SWIGTYPE* OUTPUT[ANY];
%typemap(freearg) SWIGTYPE* INOUT[ANY]=SWIGTYPE* INPUT[ANY];
// inout variable arrays
%typemap(in) (SWIGTYPE** INOUT,int)=(SWIGTYPE** INPUT,int);
%typemap(argout) (SWIGTYPE** INOUT,int)
%{	SWIG_write_ptr_array(ctx,(void**)$1,$2,$*1_descriptor,0); %}
%typemap(freearg) (SWIGTYPE**INOUT,int)=(SWIGTYPE**INPUT,int);

/* -----------------------------------------------------------------------------
 *                          Pointer-Pointer typemaps
 * ----------------------------------------------------------------------------- */
/*
This code is to deal with the issue for pointer-pointer's
In particular for factory methods.

for example take the following code segment:

struct iMath;    // some structure
int Create_Math(iMath** pptr); // its factory (assume it mallocs)

to use it you might have the following C code:

iMath* ptr;
int ok;
ok=Create_Math(&ptr);
// do things with ptr
//...
free(ptr);

With the following SWIG code
%apply SWIGTYPE** OUTPUT{iMath **pptr };

You can get natural wrapping in Lua as follows:
ok,ptr=Create_Math() -- ptr is a iMath* which is returned with the int
ptr=nil -- the iMath* will be GC'ed as normal
*/

%typemap(in,numinputs=0) SWIGTYPE** OUTPUT ($*ltype temp)
%{ temp = ($*ltype)0;
   $1 = &temp; %}
%typemap(argout) SWIGTYPE** OUTPUT
%{SWIG_NewPointerObj(ctx,*$1,$*descriptor,1); %}

