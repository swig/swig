%module input

%apply int *INPUT {int *bar};

%typemap(out) int * Foo::foo {
  if ($1) {
    $result = PyInt_FromLong(*$1);
  } else {
    Py_INCREF(Py_None);
    $result = Py_None;
  }
}

%inline 
{
  struct Foo {
    int *foo(int *bar) {
      if (bar) {
	*bar *= 2;
      }
      return (bar) ? bar : 0;
    }
  };
}



%include std_string.i
%apply std::string *INPUT {std::string *bar};
%typemap(out) int * sfoo {
  if ($1) {
    $result = PyInt_FromLong(*$1);
  } else {
    Py_INCREF(Py_None);
    $result = Py_None;
  }
}

%typemap(out, fragment=SWIG_From_frag(std::string)) std::string * sfoo {
  if ($1) {
    $result = SWIG_From(std::string)(*$1);
  } else {
    Py_INCREF(Py_None);
    $result = Py_None;
  }
}

%inline %{
  std::string *sfoo(std::string *bar) {
    if (bar) *bar += " world";
    return (bar) ? bar : 0;
  }
%}
