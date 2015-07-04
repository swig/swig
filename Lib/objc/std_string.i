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
%typemap(objcdirectorin) string "$iminput"
%typemap(objcdirectorout) string "$objccall"

%typemap(in) string 
%{
    if(!$input) {
        NSException* anException = [NSException exceptionWithName:@"NullPointerException"
                                                           reason:@"null std::string" userInfo:nil];
        @throw anException;
    } else {
        $1.assign([$input UTF8String]);
    }
%}
%typemap(directorout) string 
%{
    if(!$input) {
        NSException* anException = [NSException exceptionWithName:@"NullPointerException"
                                                           reason:@"null std::string" userInfo:nil];
        @throw anException;
    } else {
        $result.assign([$input UTF8String]);
    }
%}

%typemap(directorin) string 
%{ $input = [NSString stringWithUTF8String: $1.c_str()]; %}

%typemap(out) string 
%{ $result = [NSString stringWithUTF8String: $1.c_str()]; %}

%typemap(objcin) string "$objcinput"

%typemap(objcout) string
%{   return $imcall; %}

// const string &
%typemap(imtype) const string & "NSString*"
%typemap(objctype) const string & "NSString*"
%typemap(objcdirectorin) const string & "$iminput"
%typemap(objcdirectorout) const string & "$objccall"

%typemap(in) const string &
%{
    std::string $1_str;
    if(!$input) {
        NSException* anException = [NSException exceptionWithName:@"NullPointerException"
        reason:@"null std::string" userInfo:nil];
        @throw anException;
    } else {
        $1_str.assign([$input UTF8String]);
        $1 = &$1_str;
    }
%}
%typemap(directorout) const string &
%{
    std::string $1_str;
    if(!$input) {
        NSException* anException = [NSException exceptionWithName:@"NullPointerException"
        reason:@"null std::string" userInfo:nil];
        @throw anException;
    } else {
        $1_str.assign([$input UTF8String]);
        $result = &$1_str;
    }
%}

%typemap(directorin) const string &
%{ $input = [NSString stringWithUTF8String: $1.c_str()]; %}

%typemap(out) const string & 
%{ $result = [NSString stringWithUTF8String: $1->c_str()]; %}

%typemap(objcin) const string & "$objcinput"

%typemap(objcout) const string &
%{   return $imcall; %}
    
}
