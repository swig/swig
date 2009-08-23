/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
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
%typemap(ocpptype) string "NSString*"
%typemap(objctype) string "NSString*"

%typemap(in) string 
%{ if(!$input) {
	NSException* anException = [NSException exceptionWithName:@"NullPointerException" 
	reason:@"null std::string" userInfo:nil];
	@throw anException;
	return $null;
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
%{ $result = [NSString stringWithCString: $1.c_str()]; %}

%typemap(objcin) string "$objcinput"

%typemap(objcout) string {
    return $imcall;
  }

%typemap(typecheck) string = char *;

%typemap(throws) string
%{ 	NSException* anException = [NSException exceptionWithName:@"RuntimeException" 
	reason:@"$1.c_str()" userInfo:nil];
	@throw anException;
	return $null; %}

// const string &
%typemap(ocpptype) const string & "NSString*"
%typemap(objctype) const string & "NSString*"

%typemap(in) const string &
%{ if(!$input) {
	NSException* anException = [NSException exceptionWithName:@"NullPointerException" 
	reason:@"null std::string" userInfo:nil];
	@throw anException;
	return $null;
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
%{ $result = [NSString stringWithCString: $1->c_str()]; %}

%typemap(objcin) const string & "$objcinput"

%typemap(objcout) const string & {
    return $imcall;
  }

%typemap(typecheck) const string & = char *;

%typemap(throws) const string &
%{ NSException* anException = [NSException exceptionWithName:@"RuntimeException" 
   reason:@"$1.c_str()" userInfo:nil];
   @throw anException;
   return $null; %}

}

