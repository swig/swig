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

Since nondynamic is a feature, if you use it like

 %pythonnondynamic;

it will make all the wrapped classes nondynamic ones.

The implementation is based on the recipe:

   http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/252158

and works for modern (-modern) and plain python. We don not use __slots__, 
so, it works with old python versions.

*/

#define %pythonnondynamic      %feature("python:nondynamic", "1")
#define %nopythonnondynamic    %feature("python:nondynamic", "0")
#define %clearpythonnondynamic %feature("python:nondynamic", "")
#define %pythondynamic         %nopythonnondynamic

/*

Use %pythonmaybecall to flag a method like __add__ or __radd__, which
don't produce an error when called, they just return NotImplemented.

These methods "may be called" if needed.

*/

#define %pythonmaybecall      %feature("python:maybecall", "1") 
#define %nopythonmaybecall    %feature("python:maybecall", "0")
#define %clearpythonmaybecall %feature("python:maybecall", "")

/*
  The %pythoncallback feature produce a more natural callback wrap
  than the  %callback mechanism, ie, it use the original name for
  the callback and callable objects. 

  Just use it as

    %pythoncallback(1) foo;
    int foo(int a);

    %pythoncallback(1) A::foo;
    struct A {
     static int foo(int a);
    };

    int bar(int, int (*pf)(int));

  then, you can use it as:

   a = foo(1)
   b = bar(2, foo)

   c = A.foo(3)
   d = bar(4, A.foo)


   If you use it with a member method
   %pythoncallback(1) A::foom;
   struct A {
      int foom(int a);
   };

   then you can use it as

     r = a.foom(3)             # eval the method
     mptr = A.foom_cb_ptr      # returns the callback pointer

   where the '_cb_ptr' termination is added for the callback pointer.

*/

#define %pythoncallback      %feature("python:callback")
#define %nopythoncallback    %feature("python:callback","0")
#define %clearpythoncallback %feature("python:callback","")

/*
  Support for the old %callback directive name
*/
#ifdef %callback
#undef %callback
#endif

#ifdef %nocallback
#undef %nocallback
#endif

#ifdef %clearcallback
#undef %clearcallback
#endif

#define %callback(x)     %feature("python:callback",`x`)
#define %nocallback      %nopythoncallback
#define %clearcallback   %clearpythoncallback

