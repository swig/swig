/* -----------------------------------------------------------------------------
 * std_string.i
 *
 * Typemaps for std::string and const std::string&
 * These are mapped to an Objective-C NSString*
 *
 * To use non-const std::string references use the following %apply.
 * %apply const std::string & {std::string &};
 * ----------------------------------------------------------------------------- */

%{
#include <string>
%}

namespace std {

%naturalvar string;

class string;

// string
%typemap(imtype) string "NSString*"
%typemap(objctype) string "NSString*"

%typemap(in) string 
%{ if(!$input) {
	NSException* anException = [NSException exceptionWithName:@"NullPointerException" 
	reason:@"null std::string" userInfo:nil];
	@throw anException;
    } 
    int length = [$input length];
    int bufferSize = sizeof(char) * (length + 1);
    char *buffer = (char*)malloc(bufferSize);
    memset(buffer, 0, bufferSize);
    int i = 0;
    for (; i < length; ++i)
        buffer[i] = [$input characterAtIndex: i];

    const char *$1_pstr = (const char *)buffer; 
    $1.assign($1_pstr);
    free(buffer); %}

%typemap(out) string 
%{ $result = [NSString stringWithUTF8String: $1.c_str()]; %}

%typemap(objcin) string "$objcinput"

%typemap(objcout) string {
    return $imcall;
  }

// const string &
%typemap(imtype) const string & "NSString*"
%typemap(objctype) const string & "NSString*"

%typemap(in) const string &
%{ if(!$input) {
	NSException* anException = [NSException exceptionWithName:@"NullPointerException" 
	reason:@"null std::string" userInfo:nil];
	@throw anException;
   }
   int length = [$input length];
   int bufferSize = sizeof(char) * (length + 1);
   char *buffer = (char*)malloc(bufferSize);
   memset(buffer, 0, bufferSize);
   int i = 0;
   for (; i < length; ++i)
       buffer[i] = [$input characterAtIndex: i];

   const char *$1_pstr = (const char *)buffer; 
   std::string $1_str($1_pstr);
   $1 = &$1_str;
   free(buffer); %}

%typemap(out) const string & 
%{ $result = [NSString stringWithUTF8String: $1->c_str()]; %}

%typemap(objcin) const string & "$objcinput"

%typemap(objcout) const string & {
    return $imcall;
  }
}


//C strings: replace swig default conversion from `NSString *' to C string
%typemap(in) char *, char[ANY], char[]  {
    $1 = 0;
    if ($input) {
        $1 = ($1_ltype)[$input UTF8String];
    }
}

// wchar_t
%wrapper %{
    
static inline NSString *getNSString(const wchar_t *wstr) {
    if (wstr) {
        return [[[NSString alloc] initWithBytes:wstr length:wcslen(wstr)*sizeof(wchar_t) encoding:WCHAR_ENCODING] autorelease];
    } else {
        return nil;
    }
}

static inline NSString *getNSString(const char *str) {
    return str ? [NSString stringWithUTF8String:str] : nil;
}

    
%}

%typemap(objctype)  wchar_t                 "wchar_t"
%typemap(imtype)    wchar_t                 "wchar_t"
%typemap(objcin)    wchar_t                 "$objcinput"
%typemap(out)       wchar_t                 %{ $result = $1; %}
%typemap(objcout)   wchar_t                 %{ return $imcall; %}

%typemap(objctype)  const wchar_t *         "NSString *"
%typemap(imtype)    const wchar_t *         "NSString *"
%typemap(objcin)    const wchar_t *         "$objcinput"
%typemap(arginit)   const wchar_t *         %{ $1 = NULL; %}
%typemap(in)        const wchar_t *         (WString wstr) %{
    wstr = NSSrting2WChar($input);
    $1 = ($1_ltype)(wchar_t const*)wstr;
%}
%typemap(out)       const wchar_t *         %{ $result = getNSString($1); %}
%typemap(objcout)   const wchar_t *         %{ return $imcall; %}
