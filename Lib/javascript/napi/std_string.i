%include <typemaps/std_string.swg>

/* throws maps that support asynchronous throwing */
%typemap(throws,noblock=1) char *, const char *, char[ANY], const char[ANY] {
  SWIG_NAPI_Raise(env, $1);
}
%typemap(throws,noblock=1) std::string, std::string *, std::string & {
  SWIG_NAPI_Raise(env, $1.c_str());
}
