%module input

%apply int *INPUT {int *bar};

%typemap(out, fragment=SWIG_From_frag(int)) int * Foo::foo {
  if ($1) {
    $result = SWIG_From(int)(*$1);
  } else {
    Py_INCREF(Py_None);
    $result = Py_None;
  }
}

%inline 
{
  struct Foo {
    int *foo(int *bar = 0) {
      if (bar) {
	*bar *= 2;
      }
      return (bar) ? bar : 0;
    }
  };
}

%include std_string.i
%apply std::string *INPUT {std::string *bar};

%typemap(out, fragment=SWIG_From_frag(std::string)) std::string *sfoo {
  if ($1) {
    $result = SWIG_From(std::string)(*$1);
  } else {
    Py_INCREF(Py_None);
    $result = Py_None;
  }
}

%inline %{
  std::string *sfoo(std::string *bar = 0) {
    if (bar) *bar += " world";
    return (bar) ? bar : 0;
  }
%}
