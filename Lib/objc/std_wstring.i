/* -----------------------------------------------------------------------------
 * std_wstring.i
 *
 * Objective-C typemaps for std::wstring using NSString.
 * ----------------------------------------------------------------------------- */

%{
#include <string>
%}

%include <wchar.i>

namespace std {

%naturalvar wstring;

class wstring;

%typemap(imtype) wstring, const wstring & "NSString *"
%typemap(objctype) wstring, const wstring & "NSString *"
%typemap(objcin) wstring, const wstring & "$objcinput"

%typemap(in) wstring {
  if (!$input) {
    NSException *anException = [NSException exceptionWithName:@"NullPointerException"
                                                       reason:@"null std::wstring"
                                                     userInfo:0];
    @throw anException;
  }
  NSUInteger length = [$input length];
  $1.reserve((size_t)length);
  for (NSUInteger i = 0; i < length; ++i)
    $1.push_back((wchar_t)[$input characterAtIndex:i]);
}

%typemap(in) const wstring & (std::wstring temp) {
  if (!$input) {
    NSException *anException = [NSException exceptionWithName:@"NullPointerException"
                                                       reason:@"null std::wstring"
                                                     userInfo:0];
    @throw anException;
  }
  NSUInteger length = [$input length];
  temp.reserve((size_t)length);
  for (NSUInteger i = 0; i < length; ++i)
    temp.push_back((wchar_t)[$input characterAtIndex:i]);
  $1 = &temp;
}

%typemap(out) wstring {
  size_t length = $1.length();
  unichar *buffer = (unichar *)calloc(length ? length : 1, sizeof(unichar));
  for (size_t i = 0; i < length; ++i)
    buffer[i] = (unichar)$1[i];
  $result = [NSString stringWithCharacters:buffer length:(NSUInteger)length];
  free(buffer);
}

%typemap(out) const wstring & {
  size_t length = $1 ? $1->length() : 0;
  unichar *buffer = (unichar *)calloc(length ? length : 1, sizeof(unichar));
  for (size_t i = 0; i < length; ++i)
    buffer[i] = (unichar)(*$1)[i];
  $result = [NSString stringWithCharacters:buffer length:(NSUInteger)length];
  free(buffer);
}

%typemap(objcout) wstring, const wstring & {
  return $imcall;
}

}
