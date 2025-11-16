/* -----------------------------------------------------------------------------
 * arrays_javascript.i
 *
 * These typemaps give more natural support for arrays. The typemaps are not efficient
 * as there is a lot of copying of the array values whenever the array is passed to C/C++
 * from JavaScript and vice versa. The JavaScript array is expected to be the same size as the C array.
 * An exception is thrown if they are not.
 *
 * Example usage:
 * Wrapping:
 *
 *   %include <arrays_javascript.i>
 *   %inline %{
 *       extern int FiddleSticks[3];
 *   %}
 *
 * Use from JavaScript like this:
 *
 *   var fs = [10, 11, 12];
 *   example.FiddleSticks = fs;
 *   fs = example.FiddleSticks;
 * ----------------------------------------------------------------------------- */


%fragment("SWIG_GetIntProperty", "header", fragment=SWIG_AsVal_frag(int)) {}
%fragment("SWIG_GetNumberProperty", "header", fragment=SWIG_AsVal_frag(double)) {}
%fragment("SWIG_OutInt", "header", fragment=SWIG_From_frag(int)) {}
%fragment("SWIG_OutNumber", "header", fragment=SWIG_From_frag(double)) {}

%define JAVASCRIPT_ARRAYS_IN_DECL(NAME, CTYPE, ANY, ANYLENGTH)

%typemap(in, fragment=NAME) CTYPE[ANY] {
  int i;
  int length;
  JSValue array;
  
  if(!JS_IsArray(ctx, $input)) {
    SWIG_exception_fail(SWIG_ERROR, "input is not an array");
  }  
  array = $input;
  length = ANYLENGTH;  
  $1  = ($*1_ltype *)js_malloc(ctx, sizeof($*1_ltype) * length);
  
  // Get each element from array
  for (i = 0; i < length; i++) {
    JSValue jsvalue = JS_GetPropertyUint32(ctx, array, i);
    $*1_ltype temp;

    // Get primitive value from JSObject
    int res = SWIG_AsVal(CTYPE)(jsvalue, &temp);
    if (!SWIG_IsOK(res)) {
      SWIG_exception_fail(SWIG_ERROR, "Failed to convert $input to array item type");
    }
    arg$argnum[i] = temp;
    JS_FreeValue(ctx, jsvalue);
  }
}

%typemap(freearg) CTYPE[ANY] {
    js_free(ctx, $1);
}

%enddef

%define JAVASCRIPT_ARRAYS_OUT_DECL(NAME, CTYPE)

%typemap(out, fragment=NAME) CTYPE[ANY] {
  int length = $1_dim0;
  int i;

  $result = JS_NewArray(ctx);
  if(!JS_IsException($result)) {
    for (i = 0; i < length; i++) {
      JS_SetPropertyUint32(ctx, $result, (uint32_t)i, SWIG_From(CTYPE)($1[i]));
    }
  }
}

%enddef

JAVASCRIPT_ARRAYS_IN_DECL("SWIG_GetIntProperty", int, , SWIG_ArrayLength(array))
JAVASCRIPT_ARRAYS_IN_DECL("SWIG_GetIntProperty", int, ANY, $1_dim0)
JAVASCRIPT_ARRAYS_IN_DECL("SWIG_GetNumberProperty", double, , SWIG_ArrayLength(array))
JAVASCRIPT_ARRAYS_IN_DECL("SWIG_GetNumberProperty", double, ANY, $1_dim0)

JAVASCRIPT_ARRAYS_OUT_DECL("SWIG_OutInt", int)
JAVASCRIPT_ARRAYS_OUT_DECL("SWIG_OutNumber", double)

%define JAVASCRIPT_VARARRAYS_IN_DECL(NAME, CTYPE, LTYPE)

%typemap(in, fragment=NAME) (CTYPE *INPUT, LTYPE) {
  LTYPE i;
  LTYPE length;
  JSValue array;
  
  if(!JS_IsArray(ctx, $input)) {
    SWIG_exception_fail(SWIG_ERROR, "input is not an array");
  }  
  array = $input;
  length = $2;  
  $1  = ($*1_ltype *)js_malloc(ctx, sizeof($*1_ltype) * length);
  
  // Get each element from array
  for (i = 0; i < length; i++) {
    JSValue jsvalue = JS_GetPropertyUint32(ctx, array, (uint32_t)i);
    $*1_ltype temp;

    // Get primitive value from JSObject
    int res = SWIG_AsVal(CTYPE)(jsvalue, &temp);
    if (!SWIG_IsOK(res)) {
      SWIG_exception_fail(SWIG_ERROR, "Failed to convert $input to array item type");
    }
    arg$argnum[i] = temp;
    JS_FreeValue(ctx, jsvalue);
  }
}

%typemap(freearg) (CTYPE *INPUT, LTYPE) {
    js_free(ctx, $1);
}

%enddef

%define JAVASCRIPT_VARARRAYS_ARGOUT_DECL(NAME, CTYPE, LTYPE)

%typemap(out, fragment=NAME) (CTYPE *INOUT, LTYPE) {
  LTYPE length = $2;
  LTYPE i;

  $result = JS_NewArray(ctx);
  if(!JS_IsException($result)) {
    for (i = 0; i < length; i++) {
      JS_SetPropertyUint32(ctx, $result, (uint32_t)i, SWIG_From(CTYPE)($1[i]));
    }
  }
}

%enddef
