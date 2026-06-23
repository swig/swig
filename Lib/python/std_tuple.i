%include <pystdcommon.swg>

// Define traits for primitive types (int, double, etc.) so they're available
// when tuple_asptr/tuple_from instantiate swig::asval/swig::from for element types.
%include <std_common.i>

%fragment("StdTupleTraits", "header",
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

    template <size_t I, size_t N, typename... Ts>
    struct tuple_asptr_elements {
      static int apply(std::tuple<Ts...>& t, PyObject* obj) {
        int res = swig::asval(PyTuple_GET_ITEM(obj, I), &std::get<I>(t));
        if (!SWIG_IsOK(res)) return res;
        return tuple_asptr_elements<I+1, N, Ts...>::apply(t, obj);
      }
    };

    template <size_t N, typename... Ts>
    struct tuple_asptr_elements<N, N, Ts...> {
      static int apply(std::tuple<Ts...>&, PyObject*) {
        return SWIG_OK;
      }
    };

    template <typename... Ts>
    int tuple_asptr(PyObject* obj, std::tuple<Ts...>** val) {
      if (!PyTuple_Check(obj) || (size_t)PyTuple_GET_SIZE(obj) != sizeof...(Ts)) {
        return SWIG_ERROR;
      }
      if (val) {
        std::tuple<Ts...>* t = new std::tuple<Ts...>();
        int res = tuple_asptr_elements<0, sizeof...(Ts), Ts...>::apply(*t, obj);
        if (!SWIG_IsOK(res)) {
          delete t;
          return res;
        }
        *val = t;
        return SWIG_NEWOBJMASK;
      }
      return SWIG_OK;
    }

    template <size_t I, size_t N, typename... Ts>
    struct tuple_from_elements {
      static void apply(PyObject* obj, const std::tuple<Ts...>& val) {
        PyTuple_SetItem(obj, I, swig::from(std::get<I>(val)));
        tuple_from_elements<I+1, N, Ts...>::apply(obj, val);
      }
    };

    template <size_t N, typename... Ts>
    struct tuple_from_elements<N, N, Ts...> {
      static void apply(PyObject*, const std::tuple<Ts...>&) {}
    };

    template <typename... Ts>
    PyObject* tuple_from(const std::tuple<Ts...>& val) {
      PyObject* obj = PyTuple_New(sizeof...(Ts));
      tuple_from_elements<0, sizeof...(Ts), Ts...>::apply(obj, val);
      return obj;
    }

    template <typename... Ts>
    int tuple_check(PyObject* obj) {
      if (PyTuple_Check(obj) && (size_t)PyTuple_GET_SIZE(obj) == sizeof...(Ts))
        return 1;
      return 0;
    }

  }
}

%typemap(in, fragment="StdTupleTraits") std::tuple {
  $ltype *ptr = 0;
  int res = 0;
  res = swig::tuple_asptr($input, &ptr);
  if (!SWIG_IsOK(res) || !ptr) {
    SWIG_exception_fail(SWIG_ArgError((ptr ? res : SWIG_TypeError)),
      "in method '" "$symname" "', argument " "$argnum"" of type '" "$1_type""'");
  }
  $1 = *ptr;
  if (SWIG_IsNewObj(res)) delete ptr;
}

%typemap(in, fragment="StdTupleTraits") const std::tuple &
  (int res = 0) {
  $ltype ptr = 0;
  res = swig::tuple_asptr($input, &ptr);
  if (!SWIG_IsOK(res)) {
    SWIG_exception_fail(SWIG_ArgError(res),
      "in method '" "$symname" "', argument " "$argnum"" of type '" "$1_type""'");
  }
  if (!ptr) {
    SWIG_exception_fail(SWIG_TypeError,
      "in method '" "$symname" "', argument " "$argnum"" of type '" "$1_type""'");
  }
  $1 = ptr;
}

%typemap(freearg) const std::tuple & {
  if (SWIG_IsNewObj(res$argnum)) delete $1;
}

%typemap(out, fragment="StdTupleTraits") std::tuple {
  $result = swig::tuple_from($1);
}

%typemap(out, fragment="StdTupleTraits") const std::tuple & {
  $result = swig::tuple_from(*$1);
}

%typemap(typecheck, fragment="StdTupleTraits") std::tuple, const std::tuple & {
  $1 = swig::tuple_check($input);
}

%include <std/std_tuple.i>
