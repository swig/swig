%include <rubystdcommon.swg>

%include <std_common.i>

%fragment("StdOptionalTraits", "header",
          fragment="StdTraits",
          fragment=SWIG_Traits_frag(int),
          fragment=SWIG_Traits_frag(double),
          fragment=SWIG_Traits_frag(long),
          fragment=SWIG_Traits_frag(short),
          fragment=SWIG_Traits_frag(unsigned int),
          fragment=SWIG_Traits_frag(unsigned long),
          fragment=SWIG_Traits_frag(unsigned short),
          fragment=SWIG_Traits_frag(float),
          fragment=SWIG_Traits_frag(long long),
          fragment=SWIG_Traits_frag(unsigned long long),
          fragment=SWIG_Traits_frag(bool),
          fragment=SWIG_Traits_frag(char),
          fragment=SWIG_Traits_frag(signed char),
          fragment=SWIG_Traits_frag(unsigned char)) {
  namespace swig {

    template <typename T>
    int optional_asptr(VALUE obj, std::optional<T>** val) {
      if (obj == Qnil) {
        if (val) *val = new std::optional<T>();
        return SWIG_OK;
      }
      if (val) {
        T v;
        int res = swig::asval(obj, &v);
        if (!SWIG_IsOK(res)) return res;
        *val = new std::optional<T>(std::move(v));
        return SWIG_AddNewMask(res);
      }
      T* vp = 0;
      return swig::asval(obj, vp);
    }

    template <typename T>
    VALUE optional_from(const std::optional<T>& val) {
      if (!val.has_value()) {
        return Qnil;
      }
      return swig::from(val.value());
    }

    int optional_check(VALUE obj) {
      (void)obj;
      return 1;
    }

  }
}

%typemap(in, fragment="StdOptionalTraits") std::optional {
  $ltype *ptr = 0;
  int res = swig::optional_asptr($input, &ptr);
  if (!SWIG_IsOK(res) || !ptr) {
    %argument_fail(res, "$1_type", $symname, $argnum);
  }
  $1 = *ptr;
  if (SWIG_IsNewObj(res)) delete ptr;
}

%typemap(in, fragment="StdOptionalTraits") const std::optional &
  (int res = 0) {
  $ltype ptr = 0;
  res = swig::optional_asptr($input, &ptr);
  if (!SWIG_IsOK(res)) {
    %argument_fail(res, "$1_type", $symname, $argnum);
  }
  if (!ptr) {
    %argument_fail(SWIG_TypeError, "$1_type", $symname, $argnum);
  }
  $1 = ptr;
}

%typemap(freearg) const std::optional & {
  if (SWIG_IsNewObj(res$argnum)) delete $1;
}

%typemap(out, fragment="StdOptionalTraits") std::optional {
  $result = swig::optional_from($1);
}

%typemap(out, fragment="StdOptionalTraits") const std::optional & {
  $result = swig::optional_from(*$1);
}

%typemap(typecheck, fragment="StdOptionalTraits") std::optional, const std::optional & {
  $1 = swig::optional_check($input);
}

%include <std/std_optional.i>
