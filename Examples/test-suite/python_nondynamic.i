%module python_nondynamic

/*
 Use the %pythonnondynamic directive to make the wrapped class a
 nondynamic one, ie, a python class that doesn't dynamically add new
 attributes.  Hence, for the class

  %pythonnondynamic A;
  struct A 
  {
    int a;
    int b;
  };

 you will get:

  aa = A()
  aa.a = 1  # Ok
  aa.b = 1  # Ok
  aa.c = 3  # error

 Since "nondynamic" is a feature, if you use

  %pythonnondynamic;

 it will make all the wrapped class nondynamic ones.

 The implementation is based on the recipe:

   http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/252158

*/



%pythonnondynamic A;
%pythondynamic C;
%pythonnondynamic D;


%inline %{

  struct A 
  {
    int a;
    int b;
  };


  struct C
  {
    int a;
    int b;
  };

  int retrieve_A_a(const struct A* self) { return self->a; }
  int retrieve_A_b(const struct A* self) { return self->b; }
%}

// The getter of this property fails until the value is set, so setting it
// works only if the setter doesn't call the getter.
%ignore D::value_;
%ignore D::set_;

%inline %{
  struct D
  {
    int value_;
    int set_;
  };
%}

%{
  static int D_value_get(struct D *self) {
    if (!self->set_) {
      PyErr_SetString(PyExc_RuntimeError, "value not set");
      return 0;
    }
    return self->value_;
  }

  static void D_value_set(struct D *self, int value) {
    self->value_ = value;
    self->set_ = 1;
  }
%}

%exception {
  $action
  if (PyErr_Occurred())
    SWIG_fail;
}

%extend D {
  int value;
}

%exception;
%inline %{
#ifdef SWIGPYTHON_BUILTIN
int is_python_builtin() { return 1; }
#else
int is_python_builtin() { return 0; }
#endif
%}

