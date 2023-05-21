/* -------------------------------------------------------------
 * SWIG library containing argc and argv multi-argument typemaps
 * ------------------------------------------------------------- */

%typemap(cstype) (int ARGC, char **ARGV) "string[]"
%typemap(imtype) (int ARGC, char **ARGV) "global::System.IntPtr"
%typemap(ctype) (int ARGC, char **ARGV) "void*"
%typemap(csin) (int ARGC, char **ARGV) "$modulePINVOKE.Swig_strings_array_to_c($csinput.Length, $csinput)"
%pragma(csharp) imclasscode=%{
  [global::System.Runtime.InteropServices.DllImport("$module", EntryPoint="C_Swig_strings_array_to_c")]
  public static extern global::System.IntPtr Swig_strings_array_to_c(int len, [global::System.Runtime.InteropServices.In,global::System.Runtime.InteropServices.MarshalAs(global::System.Runtime.InteropServices.UnmanagedType.LPArray, ArraySubType=global::System.Runtime.InteropServices.UnmanagedType.LPStr, SizeParamIndex=0)] string[] array);
%}
%insert(wrapper) %{
typedef struct { int len; char* array[1]; } c_csstrings_array;
static void* C_Swig_strings_array_free(c_csstrings_array *arr) {
  if (arr != SWIG_NULLPTR) {
    int i;
    for(i = 0; i < arr->len; i++) {
      free(arr->array[i]);
    }
    free(arr);
  }
  return SWIG_NULLPTR;
}
SWIGEXPORT void* SWIGSTDCALL C_Swig_strings_array_to_c(int len, void *array) {
  int i;
  size_t alen, slen;
  char *p, **ptr;
  c_csstrings_array *ret;
  SWIG_contract_assert(SWIG_NULLPTR, len >= 1, "Strings array can not be empty.");
  alen = sizeof(c_csstrings_array) + sizeof(char *) * (len - 1);
  ret = (c_csstrings_array *)malloc(alen);
  if (ret == SWIG_NULLPTR) {
    SWIG_CSharpSetPendingException(SWIG_CSharpOutOfMemoryException, "fail to duplicate array.");
    return SWIG_NULLPTR;
  }
  memset(ret, 0, alen);
  ret->len = len;
  ptr = (char **)array;
  for(i = 0; i < len; i++) {
    slen = strlen(ptr[i]) + 1;
    SWIG_contract_assert(C_Swig_strings_array_free(ret), slen > 1, "String can not be empty");
    p = (char*)malloc(slen);
    if (p == SWIG_NULLPTR) {
      SWIG_CSharpSetPendingException(SWIG_CSharpOutOfMemoryException, "fail to alloc a string.");
      return C_Swig_strings_array_free(ret);
    }
    memcpy(p, ptr[i], slen);
    ret->array[i] = p;
  }
  return ret;
}
%}

%typemap(in, canthrow=1) (int ARGC, char **ARGV) {
  c_csstrings_array *arr = (c_csstrings_array*)$input;
  if (arr != SWIG_NULLPTR) {
    $1 = ($1_ltype)arr->len;
    $2 = ($2_ltype)arr->array;
  }
}

%typemap(freearg) (int ARGC, char **ARGV) "C_Swig_strings_array_free((c_csstrings_array*)$input);"
