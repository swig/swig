// Tests custom allocator and deallocator callbacks for %typemaps_string_alloc.
%module typemap_string_alloc

#if defined(SWIGUTL)

%include <typemaps/string.swg>

%{
bool Custom_AllocationCalled = false;
bool Custom_DeallocationCalled = false;
%}

%inline %{
void Custom_Reset() {
  Custom_AllocationCalled = false;
  Custom_DeallocationCalled = false;
}

bool Custom_WasAllocated() {
  return Custom_AllocationCalled;
}

bool Custom_WasDeallocated() {
  return Custom_DeallocationCalled;
}
%}

%fragment("Custom_NewCopyCharArray", "header", fragment="<string.h>") {
SWIGINTERNINLINE char *Custom_NewCopyCharArray(const char *ptr, size_t size) {
  char *copy = 0;
  if (size) {
    copy = %new_array(size, char);
    if (copy) {
      memcpy(copy, ptr, size * sizeof(char));
      Custom_AllocationCalled = true;
    }
  }
  return copy;
}
SWIGINTERNINLINE void Custom_DeleteCharArray(char *ptr) {
  if (ptr)
    Custom_DeallocationCalled = true;
  %delete_array(ptr);
}
}
%fragment("Custom_NewCopyCharArray");

%fragment("Custom_AsCharPtrAndSize", "header", fragment="SWIG_AsCharPtrAndSize", fragment="Custom_NewCopyCharArray") {
SWIGINTERNINLINE int Custom_CopyConvertedCharArray(int res, char **ptr, size_t *size, int *alloc) {
  if (SWIG_IsOK(res) && ptr) {
    char *original = *ptr;
    size_t length = size ? *size : (original ? strlen(original) + 1 : 0);
    *ptr = original ? Custom_NewCopyCharArray(original, length) : 0;
    if (alloc && *alloc == SWIG_NEWOBJ)
      %delete_array(original);
    if (alloc)
      *alloc = SWIG_NEWOBJ;
  }
  return res;
}
%#define Custom_AsCharPtrAndSize(obj, ptr, size, alloc) Custom_CopyConvertedCharArray(SWIG_AsCharPtrAndSize(obj, ptr, size, alloc), ptr, size, alloc)
}
%fragment("Custom_AsCharPtrAndSize");

%typemaps_string_alloc(
  %checkcode(STRING),
  %checkcode(CHAR),
  SWIGWARN_TYPEMAP_CHARLEAK_MSG,
  char,
  Char,
  Custom_AsCharPtrAndSize,
  SWIG_FromCharPtrAndSize,
  strlen,
  SWIG_strnlen,
  Custom_NewCopyCharArray,
  Custom_DeleteCharArray,
  "<limits.h>",
  CHAR_MIN,
  CHAR_MAX)

%inline %{
char *some_text = Custom_NewCopyCharArray("initial", sizeof("initial"));
%}

#endif
