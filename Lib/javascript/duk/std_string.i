/* -----------------------------------------------------------------------------
 * std_string.i
 *
 * std::string typemaps for Duktape
 * ----------------------------------------------------------------------------- */

%{
#include <string>
%}

/*
Only std::string and const std::string& are typemapped
they are converted to the Lua strings automatically

std::string& and std::string* are not
they must be explicitly managed (see below)

eg.

std::string test_value(std::string x) {
   return x;
}

can be used as

s="hello world"
s2=test_value(s)
assert(s==s2)
*/


namespace std {

%typemap(in) string
%{ if (!duk_is_string(ctx, $input)) { duk_push_string(ctx,"Expected string in $input argument"); goto fail; }
   $1.assign(duk_to_string(ctx,$input),duk_get_length(ctx,$input)); %}

%typemap(out) string
%{ duk_push_lstring(ctx,$1.data(),$1.size());%}


%typemap(in) const string& ($*1_ltype temp)
%{ if (!duk_is_string(ctx, $input)) { duk_push_string(ctx,"Expected string in $input argument"); goto fail; }
   temp.assign(duk_to_string(ctx,$input),duk_get_length(ctx,$input)); $1=&temp;%}

%typemap(out) const string&
%{ duk_push_lstring(ctx,$1->data(),$1->size()); 
%}

// for throwing of any kind of string, string ref's and string pointers
// we convert all to Duktape strings
%typemap(throws) string, string&, const string&
%{
  duk_push_lstring(ctx,$1.data(),$1.size());
  duk_throw(ctx);
%}

%typemap(throws) string*, const string*
%{
  duk_push_lstring(ctx,$1->data(),$1->size());
  duk_throw(ctx);
%}

/*
std::string& can be wrapped, but you must inform SWIG if it is in or out

eg:
void fn(std::string& str);
Is this an in/out/inout value?

Therefore you need the usual
%apply (std::string& INOUT) {std::string& str};
or
%apply std::string& INOUT {std::string& str};
typemaps to tell SWIG what to do.
*/

/*
A really cut down version of the string class

This provides basic mapping of Duktape strings <-> std::string
and little else
(the std::string has a lot of unneeded functions anyway)

note: no fn's taking the const string&
as this is overloaded by the const char* version
*/

  %naturalvar string;
  class string {
    public:
      string();
      string(const char*);
      //string(const string&);
      unsigned int size() const;
      bool empty() const;
      // no support for operator[]
      const char* c_str()const;
      const char* data()const;
      // assign does not return a copy of this object
      // (no point in a scripting language)
      void assign(const char*);
      //void assign(const string&);
      // no support for all the other features
  };
}
