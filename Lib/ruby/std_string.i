//
// SWIG typemaps for std::string
// Luigi Ballabio
// Apr 8, 2002
//
// Ruby implementation


// ------------------------------------------------------------------------
// std::string is typemapped by value
// This can prevent exporting methods which return a string
// in order for the user to modify it.
// However, I think I'll wait until someone asks for it...
// ------------------------------------------------------------------------

%include exception.i

%{
#include <string>
%}

namespace std {

    // Ruby wants class names to start with a capital letter
    %rename(String) string;
    class string;

    /* Overloading check */
    %typemap(typecheck) string = char *;
    %typemap(typecheck) const string & = char *;

    %typemap(in) string {
        if (TYPE($input) == T_STRING) {
            $1 = std::string(StringValuePtr($input));
        } else {
            SWIG_exception(SWIG_TypeError, "not a string");
        }
    }

    %typemap(in) const string & (std::string temp) {
        if (TYPE($input) == T_STRING) {
            temp = std::string(StringValuePtr($input));
            $1 = &temp;
        } else {
            SWIG_exception(SWIG_TypeError, "not a string");
        }
    }

    %typemap(out) string {
        $result = rb_str_new2($1.c_str());
    }

    %typemap(out) const string & {
        $result = rb_str_new2($1->c_str());
    }

    %typemap(directorin) string, const string &, string & {
      $input = rb_str_new2($1_name.c_str());
    }  

    %typemap(directorin) string *, const string * {
      $input = rb_str_new2($1_name->c_str());
    }
    
    %typemap(directorout) string {
        if (TYPE($input) == T_STRING)
            $result = std::string(StringValuePtr($input));
        else
            throw Swig::DirectorTypeMismatchException("string expected");
    }
    
  %typemap(directorout,warning=SWIG_WARN_TYPEMAP_THREAD_UNSAFE) const string &  {
        if (TYPE($input) == T_STRING) {
            static std::string temp = std::string(StringValuePtr($input));
            $result = &temp;
        } else {
            throw Swig::DirectorTypeMismatchException("string expected");
        }
    }

    %typemap(throws) string, const string &
        "rb_raise(rb_eRuntimeError, $1.c_str());";

    %typemap(throws) string *, const string *
        "rb_raise(rb_eRuntimeError, $1->c_str());";
}
