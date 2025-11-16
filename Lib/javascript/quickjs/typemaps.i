/* -----------------------------------------------------------------------------
 * typemaps.i
 *
 * Pointer handling
 * These mappings provide support for input/output arguments and common
 * uses for C/C++ pointers.
 * ----------------------------------------------------------------------------- */

// INPUT typemaps.
// These remap a C pointer to be an "INPUT" value which is passed by value
// instead of reference.

/*
The following methods can be applied to turn a pointer into a simple
"input" value.  That is, instead of passing a pointer to an object,
you would use a real value instead.

         int            *INPUT
         short          *INPUT
         long           *INPUT
         long long      *INPUT
         unsigned int   *INPUT
         unsigned short *INPUT
         unsigned long  *INPUT
         unsigned long long *INPUT
         unsigned char  *INPUT
         bool           *INPUT
         float          *INPUT
         double         *INPUT

To use these, suppose you had a C function like this :

        double fadd(double *a, double *b) {
               return *a+*b;
        }

You could wrap it with SWIG as follows :

        %include <typemaps.i>
        double fadd(double *INPUT, double *INPUT);

or you can use the %apply directive :

        %include <typemaps.i>
        %apply double *INPUT { double *a, double *b };
        double fadd(double *a, double *b);

*/

// OUTPUT typemaps.   These typemaps are used for parameters that
// are output only.   The output value is appended to the result as
// a list element.

/*
The following methods can be applied to turn a pointer into an "output"
value.  When calling a function, no input value would be given for
a parameter, but an output value would be returned.  In the case of
multiple output values, they are returned in the form of a Python tuple.

         int            *OUTPUT
         short          *OUTPUT
         long           *OUTPUT
         long long      *OUTPUT
         unsigned int   *OUTPUT
         unsigned short *OUTPUT
         unsigned long  *OUTPUT
         unsigned long long *OUTPUT
         unsigned char  *OUTPUT
         bool           *OUTPUT
         float          *OUTPUT
         double         *OUTPUT

For example, suppose you were trying to wrap the modf() function in the
C math library which splits x into integral and fractional parts (and
returns the integer part in one of its parameters) :

        double modf(double x, double *ip);

You could wrap it with SWIG as follows :

        %include <typemaps.i>
        double modf(double x, double *OUTPUT);

or you can use the %apply directive :

        %include <typemaps.i>
        %apply double *OUTPUT { double *ip };
        double modf(double x, double *ip);

The Python output of the function would be a tuple containing both
output values.

*/

// INOUT
// Mappings for an argument that is both an input and output
// parameter

/*
The following methods can be applied to make a function parameter both
an input and output value.  This combines the behavior of both the
"INPUT" and "OUTPUT" methods described earlier.  Output values are
returned in the form of a Python tuple.

         int            *INOUT
         short          *INOUT
         long           *INOUT
         long long      *INOUT
         unsigned int   *INOUT
         unsigned short *INOUT
         unsigned long  *INOUT
         unsigned long long *INOUT
         unsigned char  *INOUT
         bool           *INOUT
         float          *INOUT
         double         *INOUT

For example, suppose you were trying to wrap the following function :

        void neg(double *x) {
             *x = -(*x);
        }

You could wrap it with SWIG as follows :

        %include <typemaps.i>
        void neg(double *INOUT);

or you can use the %apply directive :

        %include <typemaps.i>
        %apply double *INOUT { double *x };
        void neg(double *x);

Unlike C, this mapping does not directly modify the input value (since
this makes no sense in Python).  Rather, the modified input value shows
up as the return value of the function.  Thus, to apply this function
to a Python variable you might do this :

       x = neg(x)

*/

%include <typemaps/typemaps.swg>

/*
 * Arrays of pointers
 */

%{
SWIGINTERN int SWIG_QuickJS_read_ptr_array(JSContext *ctx, JSValueConst arr, void **array,int size, swig_type_info *type)
{
	JSValue v;
  int i;
	for (i = 0; i < size; i++) {
		v = JS_GetPropertyUint32(ctx, arr, i);
    if(JS_IsException(v)) return 0;
		if (!SWIG_IsOK(SWIG_QuickJS_ConvertPtr(ctx, v, &array[i], type, 0))) {
			JS_FreeValue(ctx, v);
			return 0;
		}
		JS_FreeValue(ctx, v);
	}
	return 1;
}

SWIGINTERN void** SWIG_QuickJS_get_ptr_array_fixed(JSContext *ctx, JSValueConst arr, int size, swig_type_info *type)
{
	void **array;
	if ((!JS_IsArray(ctx, arr)) || (SWIG_QuickJS_ArrayLength(ctx, arr) != (uint32_t)size)) {
		JS_ThrowTypeError(ctx, "expected an array of size %d", size);
		return 0;
	}
	array=js_malloc(ctx, size*sizeof(void*));
  if(array == NULL) {
    JS_ThrowOutOfMemory(ctx);
    return 0;
  }
	if (!SWIG_QuickJS_read_ptr_array(ctx,arr,array,size,type)) {
		JS_ThrowTypeError(ctx, "array must contain pointers of type %s", SWIG_TypeName(type));
		js_free(ctx, array);
		return 0;
	}
	return array;
}

SWIGINTERN void** SWIG_QuickJS_get_ptr_array_var(JSContext *ctx, JSValueConst arr, int* size,swig_type_info *type)
{
	void **array;
  if (!JS_IsArray(ctx, arr)) {
		JS_ThrowTypeError(ctx, "expected an array");
		return 0;
	}
	*size=SWIG_QuickJS_ArrayLength(ctx, arr);
	if (*size<1){
		JS_ThrowTypeError(ctx, "array appears to be empty");
		return 0;
	}
	array=js_malloc(ctx,(*size)*sizeof(void*));
  if(array == NULL) {
    JS_ThrowOutOfMemory(ctx);
    return 0;
  }  
	if (!SWIG_QuickJS_read_ptr_array(ctx, arr, array, *size, type)) {
		JS_ThrowTypeError(ctx, "array must contain pointers of type %s", SWIG_TypeName(type));
		js_free(ctx, array);
		return 0;
	}
	return array;
}

SWIGINTERN void SWIG_QuickJS_write_ptr_array(JSContext *ctx, void **array, int size, swig_type_info *type, int own)
{
	int i;
	JSValue arr = JS_NewArray(ctx);
  
  if(JS_IsException(arr)) return;
	for (i = 0; i < size; i++) {
		JS_SetPropertyUint32(ctx, arr, (uint32_t)i,
      SWIG_QuickJS_NewPointerObj(ctx, array[i], type, own));
	}
}
%}

// fixed size array's
%typemap(in) SWIGTYPE* INPUT[ANY]
%{	$1 = ($ltype)SWIG_QuickJS_get_ptr_array_fixed(ctx, $input,$1_dim0,$*1_descriptor);
	if (!$1) SWIG_fail;%}

%typemap(freearg) SWIGTYPE* INPUT[ANY]
%{	js_free(ctx, $1);%}

// variable size array's
%typemap(in) (SWIGTYPE **INPUT,int)
%{	$1 = ($ltype)SWIG_QuickJS_get_ptr_array_var(ctx, $input,&$2,$*1_descriptor);
	if (!$1) SWIG_fail;%}

%typemap(freearg) (SWIGTYPE **INPUT,int)
%{	js_free(ctx, $1);%}

// out fixed arrays
%typemap(in,numinputs=0) SWIGTYPE* OUTPUT[ANY]
%{  $1 = js_malloc(ctx,(sizeof $*1_type)*($1_dim0)); %}

%typemap(argout) SWIGTYPE* OUTPUT[ANY]
%{	SWIG_QuickJS_write_ptr_array(ctx, (void**)$1,$1_dim0,$*1_descriptor,0); %}

%typemap(freearg) SWIGTYPE* OUTPUT[ANY]
%{	js_free(ctx, $1); %}

// inout fixed arrays
%typemap(in) SWIGTYPE* INOUT[ANY]=SWIGTYPE* INPUT[ANY];
%typemap(argout) SWIGTYPE* INOUT[ANY]=SWIGTYPE* OUTPUT[ANY];
%typemap(freearg) SWIGTYPE* INOUT[ANY]=SWIGTYPE* INPUT[ANY];
// inout variable arrays
%typemap(in) (SWIGTYPE** INOUT,int)=(SWIGTYPE** INPUT,int);
%typemap(argout) (SWIGTYPE** INOUT,int)
%{	SWIG_write_ptr_array(ctx, (void**)$1,$2,$*1_descriptor,0); %}
%typemap(freearg) (SWIGTYPE**INOUT,int)=(SWIGTYPE**INPUT,int);

