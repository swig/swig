/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * std_string.i
 *
 * std::string typemaps for LUA
 * ----------------------------------------------------------------------------- */

%{
	#include <string>
%}
/*
Only std::string and const std::string& are typemaped
they are converted to the Lua strings automatically

eg.

std::string test_value(std::string x) {
   return x;
}

can be used as

s="hello world"
s2=test_value(s)
assert(s==s2)

*/

%naturalvar std::string;

%typemap(in,checkfn="lua_isstring") std::string
%{$1 = (char*)lua_tostring(L, $input);%}

%typemap(out) std::string
%{  lua_pushstring(L,$1.c_str()); SWIG_arg++;%}

%typemap(in,checkfn="lua_isstring")	const std::string& (std::string temp)
%{temp=(char*)lua_tostring(L, $input); $1=&temp;%}
%typemap(out) const std::string&
%{  lua_pushstring(L,$1->c_str()); SWIG_arg++;%}

%typemap(throws) std::string,const std::string&
%{lua_pushstring(L,$1.c_str());
SWIG_fail; %}

// and the typechecks
%typecheck(SWIG_TYPECHECK_STRING) std::string,const std::string& {
  $1 = lua_isstring(L,$input);
}

/*
std::string& can be wrappered, but you must inform SWIG if it is in or out

eg:
void fn(std::string& str);
Is this an in/out/inout value?

Therefore you need the usual
%apply (std::string& INOUT) {(std::string& str)};
or
%apply std::string& INOUT {std::string& str};
typemaps to tell SWIG what to do.
*/

%typemap(in) std::string &INPUT=const std::string &;
%typemap(in, numinputs=0) std::string &OUTPUT (std::string temp)
%{ $1 = &temp; %}
%typemap(argout) std::string &OUTPUT
%{  lua_pushstring(L,$1.c_str()); SWIG_arg++;%}
%typemap(in) std::string &INOUT =const std::string &;
%typemap(argout) std::string &INOUT = std::string &OUTPUT;

/*
For const std::string* and std::string* is not clear
is this a pointer or an array?

Therefore just leaving it as is
(there is some rough code below which could be used if needed

// SWIG wraps const ref's as pointer
// typemaps to deal with this and const ptrs
%typemap(in,checkfn="lua_isstring")
	const std::string& INPUT(std::string temp),
	const std::string* INPUT(std::string temp)
%{temp=(char*)lua_tostring(L, $input); $1=&temp;%}
%typemap(out) const std::string&, const std::string*
%{  lua_pushstring(L,$1->c_str()); SWIG_arg++;%}

// the non-const pointer version
%typemap(in) std::string *INPUT=const std::string *INPUT;
%typemap(in, numinputs=0) std::string *OUTPUT (std::string temp)
%{ $1 = &temp; %}
%typemap(argout) std::string *OUTPUT
%{  lua_pushstring(L,$1->c_str()); SWIG_arg++;%}
%typemap(in) std::string *INOUT = std::string *INPUT;
%typemap(argout) std::string *INOUT = std::string *OUTPUT;

*/

/*
A really cut down version of the string class

This provides basic mapping of lua strings <-> std::string
and little else
(the std::string has a lot of unneeded functions anyway)

note: no fn's taking the const string&
as this is overloaded by the const char* version
*/
namespace std {

    class string {
      public:
        string();
        string(const char*);
        //string(const string&);
        unsigned int size() const;
        unsigned int length() const;
        bool empty() const;
        // no support for operator[]
        const char* c_str()const;
        const char* data()const;
        // assign does not return a copy of this object
        // (no point in a scripting language)
        void assign(const char*);
        //void assign(const string&);
        // no support for all the other features
        // its probably better to do it in lua
    };
}

