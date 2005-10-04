%module nondynamic

/*
 Use the "static" feature to make the wrapped class a static one,
 ie, a python class that doesn't dynamically add new attributes.
 Hence, for the class

  %feature("static") A;
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

 Since "static" is a feature, if you use

  %feature("static");

 it will make all the wrapped class static ones.

 The implementation is based on the recipe:

   http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/252158

 and works for modern (-modern) and plain python.

*/



//%pythonnondynamic(1);
%pythonnondynamic(1) A;
%pythonnondynamic(0) C;


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

%}

