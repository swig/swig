/* -------------------------------------------------------------
 * SWIG library containing argc and argv multi-argument typemaps
 * ------------------------------------------------------------- */

%typemap(cstype) (int ARGC, char **ARGV) "string[]"
%typemap(imtype) (int ARGC, char **ARGV) "global::System.IntPtr"
%typemap(ctype) (int ARGC, char **ARGV) "void*"
%typemap(csin) (int ARGC, char **ARGV) "$modulePINVOKE.SWIG_csharp_string_array_to_c($csinput.Length, $csinput)"
%pragma(csharp) imclasscode=%{
  [global::System.Runtime.InteropServices.DllImport("$module", EntryPoint="SWIG_csharp_string_array_to_c")]
  public static extern global::System.IntPtr SWIG_csharp_string_array_to_c(int len, [global::System.Runtime.InteropServices.In,global::System.Runtime.InteropServices.MarshalAs(global::System.Runtime.InteropServices.UnmanagedType.LPArray, ArraySubType=global::System.Runtime.InteropServices.UnmanagedType.LPStr, SizeParamIndex=0)] string[] array);
%}
%fragment("SWIG_csharp_string_array", "header") %{
#ifdef __cplusplus
extern "C" {
#endif
typedef struct { int len; char* array[1]; } SWIG_csharp_string_array;

static void* SWIG_csharp_string_array_free(SWIG_csharp_string_array *arr) {
  if (arr != SWIG_NULLPTR) {
    int i;
    for(i = 0; i < arr->len; i++) {
      free(arr->array[i]);
    }
    free(arr);
  }
  return SWIG_NULLPTR;
}

SWIGEXPORT void* SWIGSTDCALL SWIG_csharp_string_array_to_c(int len, void *array) {
  int i;
  size_t alen, slen;
  char *p, **ptr;
  SWIG_csharp_string_array *ret;
  /* We don't need to add one to len for the terminating NULL here because
   * SWIG_csharp_string_array includes one element already.
   */
  alen = sizeof(SWIG_csharp_string_array) + sizeof(char *) * len;
  ret = (SWIG_csharp_string_array *)malloc(alen);
  if (ret == SWIG_NULLPTR) {
    SWIG_CSharpSetPendingException(SWIG_CSharpOutOfMemoryException, "fail to duplicate array.");
    return SWIG_NULLPTR;
  }
  memset(ret, 0, alen);
  ret->len = len;
  ptr = (char **)array;
  for(i = 0; i < len; i++) {
    slen = strlen(ptr[i]) + 1;
    p = (char*)malloc(slen);
    if (p == SWIG_NULLPTR) {
      SWIG_CSharpSetPendingException(SWIG_CSharpOutOfMemoryException, "fail to alloc a string.");
      return SWIG_csharp_string_array_free(ret);
    }
    memcpy(p, ptr[i], slen);
    ret->array[i] = p;
  }
  ret->array[i] = SWIG_NULLPTR;
  return ret;
}

#ifdef __cplusplus
}
#endif
%}

%typemap(in, canthrow=1, fragment="SWIG_csharp_string_array") (int ARGC, char **ARGV) %{
  SWIG_csharp_string_array *arr = (SWIG_csharp_string_array*)$input;
  if (arr != SWIG_NULLPTR) {
    $1 = ($1_ltype)arr->len;
    $2 = ($2_ltype)arr->array;
  }
%}

%typemap(freearg, fragment="SWIG_csharp_string_array") (int ARGC, char **ARGV) %{
  SWIG_csharp_string_array_free((SWIG_csharp_string_array*)$input);
%}
