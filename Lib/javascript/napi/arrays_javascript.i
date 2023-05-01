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


%fragment("SWIG_NAPI_GetIntProperty", "header", fragment=SWIG_AsVal_frag(int)) {}
%fragment("SWIG_NAPI_GetNumberProperty", "header", fragment=SWIG_AsVal_frag(double)) {}
%fragment("SWIG_NAPI_OutInt", "header", fragment=SWIG_From_frag(int)) {}
%fragment("SWIG_NAPI_OutNumber", "header", fragment=SWIG_From_frag(double)) {}

%define JAVASCRIPT_ARRAYS_IN_DECL(NAME, CTYPE, ANY, ANYLENGTH)

%typemap(in, fragment=NAME) CTYPE[ANY] {
  if ($input.IsArray()) {
    Napi::Env env = $input.Env();
    // Convert into Array
    Napi::Array array = $input.As<Napi::Array>();

    int length = ANYLENGTH;

    $1 = ($*1_ltype *)malloc(sizeof($*1_ltype) * length);

    // Get each element from array
    for (int i = 0; i < length; i++) {
      Napi::Value jsvalue = array.Get(i);
      $*1_ltype temp;

      // Get primitive value from JSObject
      int res = SWIG_AsVal(CTYPE)(jsvalue, &temp);
      if (!SWIG_IsOK(res)) {
        SWIG_Error(SWIG_ERROR, "Failed to convert $input to double");
      }
      arg$argnum[i] = temp;
    }
  } else {
    Napi::Env env = $input.Env();
    SWIG_Error(SWIG_ERROR, "$input is not an array");
  }
}

%typemap(freearg) CTYPE[ANY] {
  free($1);
}

%enddef

%define JAVASCRIPT_ARRAYS_OUT_DECL(NAME, CTYPE)

%typemap(out, fragment=NAME) CTYPE[ANY] {
  int length = $1_dim0;
  Napi::Array array = Napi::Array::New(env, length);

  for (int i = 0; i < length; i++) {
    array.Set(i, SWIG_From(CTYPE)($1[i]));
  }

  $result = array;
}

%enddef

JAVASCRIPT_ARRAYS_IN_DECL("SWIG_NAPI_GetIntProperty", int, , array.Length())
JAVASCRIPT_ARRAYS_IN_DECL("SWIG_NAPI_GetIntProperty", int, ANY, $1_dim0)
JAVASCRIPT_ARRAYS_IN_DECL("SWIG_NAPI_GetNumberProperty", double, , array.Length())
JAVASCRIPT_ARRAYS_IN_DECL("SWIG_NAPI_GetNumberProperty", double, ANY, $1_dim0)

JAVASCRIPT_ARRAYS_OUT_DECL("SWIG_NAPI_OutInt", int)
JAVASCRIPT_ARRAYS_OUT_DECL("SWIG_NAPI_OutNumber", double)

