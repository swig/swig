%module python_typemap_macro

/*
This testcase pushes $typemap() to the limit, but does show how the UTL could be replaced with a different approach.

It results in very bloated code as all the typemaps expanded by $typemap() are inline and recursive use such as with
containers of containers or pairs of pairs demonstrated here.
The other gotcha using this approach is using local variables declared within the typemap body does not usually work
if the typemaps are recursively called and the temporary variables are used for typemap outputs, such as $1 or $result.
Using typemap temporary variables does work around this, such as temp in:
  %typemap(out) (int temp) { ... }
This works as each typemap temporary is renamed and given a unique numeric suffix, for example temp1, temp2.

Consider this approach to using typemaps experimental and use at your own risk!
*/


%include <std_string.i>

#if 0
%include <std_pair.i>
#else
namespace std {
  template <class T, class U > struct pair {

// Adaption of PyObject *swig::traits_from<std::pair<T,U> >::from((const std::pair<T,U>& val)) in Lib/python/std_pair.i
%typemap(out) pair(PyObject *resultobj_pair_first, PyObject *resultobj_pair_second) {
  /* pair out $1_type start */
  $result = PyTuple_New(2);

  $typemap(out, T, 1=$1.first, result=resultobj_pair_first)
  PyTuple_SetItem($result, 0, resultobj_pair_first);

  $typemap(out, U, 1=$1.second, result=resultobj_pair_second)
  PyTuple_SetItem($result, 1, resultobj_pair_second);
  /* pair out $1_type end */
}

// Adaption of int traits_asptr<std::pair<T,U> >::asptr(PyObject *obj, std::pair<T,U> **val) in Lib/python/std_pair.i
%typemap(in) pair {
  /* pair in $1_type start */
  PyObject *obj = $input;
  if (PyTuple_Check(obj) && PyTuple_GET_SIZE(obj) == 2) {
    PyObject *first = PyTuple_GET_ITEM(obj, 0);
    PyObject *second = PyTuple_GET_ITEM(obj, 1);
    $typemap(in, T, input=first, 1=$1.first)
    $typemap(in, U, input=second, 1=$1.second)
  } else if (PySequence_Check(obj) && PySequence_Size(obj) == 2) {
    swig::SwigVar_PyObject first = PySequence_GetItem(obj, 0);
    swig::SwigVar_PyObject second = PySequence_GetItem(obj, 1);
    $typemap(in, T, input=(PyObject*)first, 1=$1.first)
    $typemap(in, U, input=(PyObject*)second, 1=$1.second)
  } else {
    void *argp;
    int res = SWIG_ConvertPtr($input, &argp, $&descriptor, 0);
    if (!SWIG_IsOK(res)) {
      %argument_fail(res, "$type", $symname, $argnum);
    }
    if (!argp) {
      %argument_nullref("$type", $symname, $argnum);
    } else {
      $&ltype temp = %reinterpret_cast(argp, $&ltype);
      $1 = *temp;
      if (SWIG_IsNewObj(res)) %delete(temp);
    }
  }
  /* pair in $1_type end */
}

%typemap(typecheck) pair {
  /* pair typecheck $1_type start */
  PyObject *obj = $input;
  if (PyTuple_Check(obj) && PyTuple_GET_SIZE(obj) == 2) {
    PyObject *first = PyTuple_GET_ITEM(obj, 0);
    PyObject *second = PyTuple_GET_ITEM(obj, 1);
    $typemap(typecheck, T, input=first)
    if ($1) {
      $typemap(typecheck, U, input=second)
    }
  } else if (PySequence_Check(obj) && PySequence_Size(obj) == 2) {
    swig::SwigVar_PyObject first = PySequence_GetItem(obj, 0);
    swig::SwigVar_PyObject second = PySequence_GetItem(obj, 1);
    $typemap(typecheck, T, input=(PyObject*)first)
    if ($1) {
      $typemap(typecheck, U, input=(PyObject*)second)
    }
  } else {
    void *vptr = 0;
    int res = SWIG_ConvertPtr($input, &vptr, $&descriptor, SWIG_POINTER_NO_NULL);
    $1 = SWIG_CheckState(res);
  }
  /* pair typecheck $1_type end */
}

    typedef T first_type;
    typedef U second_type;
    pair();
    pair(T first, U second);
//    pair(const pair& other); // TODO: similar typemaps for pair&
    pair(pair other);

    template <class U1, class U2> pair(const pair< U1, U2 > &other);

    T first;
    U second;
};
}
#endif

%template(PairStringInt) std::pair<std::string, int>;
%template(PairCharPairStringInt) std::pair<char, std::pair<std::string, int> >;

%inline %{
std::pair<std::string, int> PairInputOutput(std::pair<std::string, int> ppp) {
  return ppp;
}
std::pair<char, std::pair<std::string, int> > PairInputOutput2(std::pair<char, std::pair<std::string, int> > p) {
  return p;
}
std::pair<char, std::pair<std::string, int> > MakePair() {
  return std::pair<char, std::pair<std::string, int> >('x', std::pair<std::string, int>("outstring", 111));
}
/*
*/
%}
