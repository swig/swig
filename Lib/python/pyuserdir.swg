/* -----------------------------------------------------------------------------
 *  Special user directives
 * ----------------------------------------------------------------------------- */

/* shadow code */
#define %shadow      %insert("shadow")
#define %pythoncode  %insert("python")


/* 
Use the "nondynamic" feature to make a wrapped class behaves as a "nondynamic"
one, ie, a python class that doesn't dynamically add new attributes.

For example, for the class

%pythonnondynamic(1) A;
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

Since "nondynamic" is a feature, if you use it like

%pythonnondynamic(1);

it will make all the wrapped classes nondynamic ones.

The implementation is based on the recipe:

 http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/252158

and works for modern (-modern) and plain python. We don't use __slots__, 
so, it works with old python versions. 

You can also use the raw %feature form

%feature("pythonnondynamic") A;

or the inverse form

%pythondynamic(0) A;


*/


#define %pythonnondynamic(FLAG) %feature("python:nondynamic", #FLAG)
#define %pythondynamic(FLAG) %pythonnondynamic(!FLAG)
