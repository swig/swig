/* -----------------------------------------------------------------------------
 * wchar.i
 *
 * Objective-C typemaps for wchar_t and wchar_t strings.
 * ----------------------------------------------------------------------------- */

#define SWIG_WCHAR

%typemap(imtype) wchar_t "wchar_t"
%typemap(objctype) wchar_t "wchar_t"
%typemap(in) wchar_t %{ $1 = ($1_ltype)$input; %}
%typemap(out) wchar_t %{ $result = (wchar_t)$1; %}
%typemap(objcin) wchar_t "$objcinput"
%typemap(objcout) wchar_t "return $imcall;"

%typemap(imtype) wchar_t *, const wchar_t *, wchar_t[ANY], wchar_t[] "NSString *"
%typemap(objctype) wchar_t *, const wchar_t *, wchar_t[ANY], wchar_t[] "NSString *"
%typemap(objcin) wchar_t *, const wchar_t *, wchar_t[ANY], wchar_t[] "$objcinput"

%define OBJC_WCHAR_STRING_IN_TYPEMAP(TYPE)
%typemap(in) TYPE (wchar_t *buffer = 0) {
  if ($input) {
    NSUInteger length = [$input length];
    buffer = (wchar_t *)calloc(length + 1, sizeof(wchar_t));
    for (NSUInteger i = 0; i < length; ++i)
      buffer[i] = (wchar_t)[$input characterAtIndex:i];
    buffer[length] = 0;
  }
  $1 = ($1_ltype)buffer;
}
%enddef

OBJC_WCHAR_STRING_IN_TYPEMAP(wchar_t *)
OBJC_WCHAR_STRING_IN_TYPEMAP(const wchar_t *)
OBJC_WCHAR_STRING_IN_TYPEMAP(wchar_t[ANY])
OBJC_WCHAR_STRING_IN_TYPEMAP(wchar_t[])

%typemap(freearg) wchar_t *, const wchar_t *, wchar_t[ANY], wchar_t[] {
  if (buffer$argnum)
    free(buffer$argnum);
}

%typemap(out) wchar_t *, const wchar_t *, wchar_t[ANY], wchar_t[] {
  if ($1) {
    size_t length = 0;
    while ($1[length])
      ++length;
    unichar *buffer = (unichar *)calloc(length ? length : 1, sizeof(unichar));
    for (size_t i = 0; i < length; ++i)
      buffer[i] = (unichar)$1[i];
    $result = [NSString stringWithCharacters:buffer length:(NSUInteger)length];
    free(buffer);
  } else {
    $result = 0;
  }
}

%typemap(objcout) wchar_t *, const wchar_t *, wchar_t[ANY], wchar_t[] {
  return $imcall;
}
