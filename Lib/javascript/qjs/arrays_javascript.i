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


%fragment("SWIG_JSCGetIntProperty", "header", fragment=SWIG_AsVal_frag(int)) {}
%fragment("SWIG_JSCGetNumberProperty", "header", fragment=SWIG_AsVal_frag(double)) {}
%fragment("SWIG_JSCOutInt", "header", fragment=SWIG_From_frag(int)) {}
%fragment("SWIG_JSCOutNumber", "header", fragment=SWIG_From_frag(double)) {}

%define JAVASCRIPT_ARRAYS_IN_DECL(NAME, CTYPE, ANY, ANYLENGTH)

%typemap(in, fragment=NAME) CTYPE[ANY] {
  if (JS_IsArray(context, $input))
  {
    int i;
    // Convert into Array
    JSObject array = JS_ToObject(context, $input);

    int length = ANYLENGTH;

    $1 = ($*1_ltype *)malloc(sizeof($*1_ltype) * length);

    // Get each element from array
    for (i = 0; i < length; i++)
    {
      JSValue jsvalue = JS_GetPropertyUint32(context, array, i);
      $*1_ltype temp;

      // Get primitive value from JSObject
      int res = SWIG_AsVal(CTYPE)(jsvalue, &temp);
      if (!SWIG_IsOK(res)) {
        SWIG_exception_fail(SWIG_ERROR, "Failed to convert $input to double");
      }
      arg$argnum[i] = temp;
    }
  } else {
    SWIG_exception_fail(SWIG_ERROR, "$input is not an array");
  }
}

%typemap(freearg) CTYPE[ANY] {
    free($1);
}

%enddef

%define JAVASCRIPT_ARRAYS_OUT_DECL(NAME, CTYPE)

%typemap(out, fragment=NAME) CTYPE[ANY] {
  int length = $1_dim0;
  JSValue values = JS_NewArray(context);
  int i;

  for (i = 0; i < length; i++)
  {
     JS_DefinePropertyValueUint32(context, values, i, SWIG_From(CTYPE)($1[i], JS_PROP_C_W_E);
  }

  $result = JS_DupValue(context, values);
}

%enddef

JAVASCRIPT_ARRAYS_IN_DECL("SWIG_JSCGetIntProperty", int, , JS_GetPropertyStr(context, values, "length"))
JAVASCRIPT_ARRAYS_IN_DECL("SWIG_JSCGetIntProperty", int, ANY, $1_dim0)
JAVASCRIPT_ARRAYS_IN_DECL("SWIG_JSCGetNumberProperty", double, , JS_GetPropertyStr(context, values, "length"))
JAVASCRIPT_ARRAYS_IN_DECL("SWIG_JSCGetNumberProperty", double, ANY, $1_dim0)

JAVASCRIPT_ARRAYS_OUT_DECL("SWIG_JSCOutInt", int)
JAVASCRIPT_ARRAYS_OUT_DECL("SWIG_JSCOutNumber", double)

