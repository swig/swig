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
%inline %{
#ifdef SWIGPYTHON_BUILTIN
int is_python_builtin() { return 1; }
#else
int is_python_builtin() { return 0; }
#endif
%}

