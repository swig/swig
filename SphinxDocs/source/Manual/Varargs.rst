Variable Length Arguments
============================

**(a.k.a, "The horror. The horror.")**

This chapter describes the problem of wrapping functions that take a
variable number of arguments. For instance, generating wrappers for the
C ``printf()`` family of functions.

This topic is sufficiently advanced to merit its own chapter. In fact,
support for varargs is an often requested feature that was first added
in SWIG-1.3.12. Most other wrapper generation tools have wisely chosen
to avoid this issue.

Introduction
-----------------

Some C and C++ programs may include functions that accept a variable
number of arguments. For example, most programmers are familiar with
functions from the C library such as the following:

.. container:: code

   ::

      int printf(const char *fmt, ...)
      int fprintf(FILE *, const char *fmt, ...);
      int sprintf(char *s, const char *fmt, ...);

Although there is probably little practical purpose in wrapping these
specific C library functions in a scripting language (what would be the
point?), a library may include its own set of special functions based on
a similar API. For example:

.. container:: code

   ::

      int  traceprintf(const char *fmt, ...);

In this case, you may want to have some kind of access from the target
language.

Before describing the SWIG implementation, it is important to discuss
the common uses of varargs that you are likely to encounter in real
programs. Obviously, there are the ``printf()`` style output functions
as shown. Closely related to this would be ``scanf()`` style input
functions that accept a format string and a list of pointers into which
return values are placed. However, variable length arguments are also
sometimes used to write functions that accept a NULL-terminated list of
pointers. A good example of this would be a function like this:

.. container:: code

   ::

      int execlp(const char *path, const char *arg1, ...);
      ...

      /* Example */
      execlp("ls", "ls", "-l", NULL);

In addition, varargs is sometimes used to fake default arguments in
older C libraries. For instance, the low level ``open()`` system call is
often declared as a varargs function so that it will accept two or three
arguments:

.. container:: code

   ::

      int open(const char *path, int oflag, ...);
      ...

      /* Examples */
      f = open("foo", O_RDONLY);
      g = open("bar", O_WRONLY | O_CREAT, 0644);

Finally, to implement a varargs function, recall that you have to use
the C library functions defined in ``<stdarg.h>``. For example:

.. container:: code

   ::

      List make_list(const char *s, ...) {
        va_list ap;
        List    x;
        ...
        va_start(ap, s);
        while (s) {
          x.append(s);
          s = va_arg(ap, const char *);
        }
        va_end(ap);
        return x;
      }

The Problem
----------------

Generating wrappers for a variable length argument function presents a
number of special challenges. Although C provides support for
implementing functions that receive variable length arguments, there are
no functions that can go in the other direction. Specifically, you can't
write a function that dynamically creates a list of arguments and which
invokes a varargs function on your behalf.

Although it is possible to write functions that accept the special type
``va_list``, this is something entirely different. You can't take a
``va_list`` structure and pass it in place of the variable length
arguments to another varargs function. It just doesn't work.

The reason this doesn't work has to do with the way that function calls
get compiled. For example, suppose that your program has a function call
like this:

.. container:: code

   ::

      printf("Hello %s. Your number is %d\n", name, num);

When the compiler looks at this, it knows that you are calling
``printf()`` with exactly three arguments. Furthermore, it knows that
the number of arguments as well are their types and sizes is *never*
going to change during program execution. Therefore, this gets turned to
machine code that sets up a three-argument stack frame followed by a
call to ``printf()``.

In contrast, suppose you attempted to make some kind of wrapper around
``printf()`` using code like this:

.. container:: code

   ::

      int wrap_printf(const char *fmt, ...) {
        va_list ap;
        va_start(ap, fmt);
        ...
        printf(fmt, ap);
        ...
        va_end(ap);
      };

Although this code might compile, it won't do what you expect. This is
because the call to ``printf()`` is compiled as a procedure call
involving only two arguments. However, clearly a two-argument
configuration of the call stack is completely wrong if your intent is to
pass an arbitrary number of arguments to the real ``printf()``. Needless
to say, it won't work.

Unfortunately, the situation just described is exactly the problem faced
by wrapper generation tools. In general, the number of passed arguments
will not be known until run-time. To make matters even worse, you won't
know the types and sizes of arguments until run-time as well. Needless
to say, there is no obvious way to make the C compiler generate code for
a function call involving an unknown number of arguments of unknown
types.

In theory, it *is* possible to write a wrapper that does the right
thing. However, this involves knowing the underlying ABI for the target
platform and language as well as writing special purpose code that
manually constructed the call stack before making a procedure call.
Unfortunately, both of these tasks require the use of inline assembly
code. Clearly, that's the kind of solution you would much rather avoid.

With this nastiness in mind, SWIG provides a number of solutions to the
varargs wrapping problem. Most of these solutions are compromises that
provide limited varargs support without having to resort to assembly
language. However, SWIG can also support real varargs wrapping (with
stack-frame manipulation) if you are willing to get hands dirty. Keep
reading.

Default varargs support
----------------------------

When variable length arguments appear in an interface, the default
behavior is to drop the variable argument list entirely, replacing them
with a single NULL pointer. For example, if you had this function,

.. container:: code

   ::

      void traceprintf(const char *fmt, ...);

it would be wrapped as if it had been declared as follows:

.. container:: code

   ::

      void traceprintf(const char *fmt);

When the function is called inside the wrappers, it is called as
follows:

.. container:: code

   ::

      traceprintf(arg1, NULL);

Arguably, this approach seems to defeat the whole point of variable
length arguments. However, this actually provides enough support for
many simple kinds of varargs functions to still be useful, however it
does come with a caveat. For instance, you could make function calls
like this (in Python):

.. container:: targetlang

   ::

      >>> traceprintf("Hello World")
      >>> traceprintf("Hello %s. Your number is %d\n" % (name, num))
      >>> traceprintf("Your result is 90%%.")

Notice how string formatting is being done in Python instead of C. The
caveat is the strings passed must be safe to use in C though. For
example if name was to contain a "%" it should be double escaped in
order to avoid unpredictable behaviour:

.. container:: targetlang

   ::

      >>> traceprintf("Your result is 90%.\n")  # unpredictable behaviour
      >>> traceprintf("Your result is 90%%.\n") # good

Read on for further solutions.

Argument replacement using %varargs
----------------------------------------

Instead of dropping the variable length arguments, an alternative
approach is to replace ``(...)`` with a set of suitable arguments. SWIG
provides a special ``%varargs`` directive that can be used to do this.
For example,

.. container:: code

   ::

      %varargs(int mode = 0) open;
      ...
      int open(const char *path, int oflags, ...);

is equivalent to this:

.. container:: code

   ::

      int open(const char *path, int oflags, int mode = 0);

In this case, ``%varargs`` is simply providing more specific information
about the extra arguments that might be passed to a function. If the
arguments to a varargs function are of uniform type, ``%varargs`` can
also accept a numerical argument count as follows:

.. container:: code

   ::

      %varargs(3, char *str = NULL) execlp;
      ...
      int execlp(const char *path, const char *arg, ...);

and is effectively seen as:

.. container:: code

   ::

      int execlp(const char *path, const char *arg, 
                 char *str1 = NULL, 
                 char *str2 = NULL, 
                 char *str3 = NULL);

This would wrap ``execlp()`` as a function that accepted up to 3
optional arguments. Depending on the application, this may be more than
enough for practical purposes.

The handling of `default
arguments <SWIGPlus.html#SWIGPlus_default_args>`__ can be changed via
the ``compactdefaultargs`` feature. If this feature is used, for example

.. container:: code

   ::

      %feature("compactdefaultargs") execlp;
      %varargs(3, char *str = NULL) execlp;
      ...
      int execlp(const char *path, const char *arg, ...);

a call from the target language which does not provide the maximum
number of arguments, such as, ``execlp("a", "b", "c")`` will generate C
code which includes the missing default values, that is,
``execlp("a", "b", "c", NULL, NULL)``. If ``compactdefaultargs`` is not
used, then the generated code will be ``execlp("a", "b", "c")``. The
former is useful for helping providing a sentinel to terminate the
argument list. However, this is not guaranteed, for example when a user
passes a non-NULL value for all the parameters. When using
``compactdefaultargs`` it is possible to guarantee the NULL sentinel is
passed through the, ``numinputs=0`` `'in' typemap
attribute <Typemaps.html#Typemaps_nn26>`__, naming the **last
parameter**. For example,

.. container:: code

   ::

      %feature("compactdefaultargs") execlp;
      %varargs(3, char *str = NULL) execlp;
      %typemap(in, numinputs=0) char *str3 ""
      ...
      int execlp(const char *path, const char *arg, ...);

Note that ``str3`` is the name of the last argument, as we have used
``%varargs`` with 3. Now ``execlp("a", "b", "c", "d", "e")`` will result
in an error as one too many arguments has been passed, as now only 2
additional 'str' arguments can be passed with the 3rd one always using
the specified default ``NULL``.

Argument replacement is most appropriate in cases where the types of the
extra arguments are uniform and the maximum number of arguments are
known. Argument replacement is not as useful when working with functions
that accept mixed argument types such as ``printf()``. Providing general
purpose wrappers to such functions presents special problems (covered
shortly).

Varargs and typemaps
-------------------------

Variable length arguments may be used in typemap specifications. For
example:

.. container:: code

   ::

      %typemap(in) (...) {
        // Get variable length arguments (somehow)
        ...
      }

      %typemap(in) (const char *fmt, ...) {
          // Multi-argument typemap
      }

However, this immediately raises the question of what "type" is actually
used to represent ``(...)``. For lack of a better alternative, the type
of ``(...)`` is set to ``void *``. Since there is no way to dynamically
pass arguments to a varargs function (as previously described), the
``void *`` argument value is intended to serve as a place holder for
storing some kind of information about the extra arguments (if any). In
addition, the default behavior of SWIG is to pass the ``void *`` value
as an argument to the function. Therefore, you could use the pointer to
hold a valid argument value if you wanted.

To illustrate, here is a safer version of wrapping ``printf()`` in
Python:

.. container:: code

   ::

      %typemap(in) (const char *fmt, ...) {
          $1 = "%s";                                /* Fix format string to %s */
          $2 = (void *) PyString_AsString($input);  /* Get string argument */
      };
      ...
      int printf(const char *fmt, ...);

In this example, the format string is implicitly set to ``"%s"``. This
prevents a program from passing a bogus format string to the extension.
Then, the passed input object is decoded and placed in the ``void *``
argument defined for the ``(...)`` argument. When the actual function
call is made, the underlying wrapper code will look roughly like this:

.. container:: code

   ::

      wrap_printf() {
        char *arg1;
        void *arg2;
        int   result;

        arg1 = "%s";
        arg2 = (void *) PyString_AsString(arg2obj);
        ...
        result = printf(arg1, arg2);
        ...
      }

Notice how both arguments are passed to the function and it does what
you would expect.

The next example illustrates a more advanced kind of varargs typemap.
Disclaimer: this requires special support in the target language module
and is not guaranteed to work with all SWIG modules at this time. It
also starts to illustrate some of the more fundamental problems with
supporting varargs in more generality.

If a typemap is defined for any form of ``(...)``, many SWIG modules
will generate wrappers that accept a variable number of arguments as
input and will make these arguments available in some form. The precise
details of this depends on the language module being used (consult the
appropriate chapter for more details). However, suppose that you wanted
to create a Python wrapper for the ``execlp()`` function shown earlier.
To do this using a typemap instead of using ``%varargs``, you might
first write a typemap like this:

.. container:: code

   ::

      %typemap(in) (...)(char *vargs[10]) {
        int i;
        int argc;
        for (i = 0; i < 10; i++) vargs[i] = 0;
        argc = PyTuple_Size(varargs);
        if (argc > 10) {
          PyErr_SetString(PyExc_ValueError, "Too many arguments");
          SWIG_fail;
        }
        for (i = 0; i < argc; i++) {
          PyObject *pyobj = PyTuple_GetItem(varargs, i);
          char *str = 0;
      %#if PY_VERSION_HEX>=0x03000000
          PyObject *pystr;
          if (!PyUnicode_Check(pyobj)) {
            PyErr_SetString(PyExc_ValueError, "Expected a string");
            SWIG_fail;
          }
          pystr = PyUnicode_AsUTF8String(pyobj);
          if (!pystr) {
            SWIG_fail;
          }
          str = strdup(PyBytes_AsString(pystr));
          Py_DECREF(pystr);
      %#else  
          if (!PyString_Check(pyobj)) {
            PyErr_SetString(PyExc_ValueError, "Expected a string");
            SWIG_fail;
          }
          str = PyString_AsString(pyobj);
      %#endif
          vargs[i] = str;
        }
        $1 = (void *)vargs;
      }

      %typemap(freearg) (...) {
      %#if PY_VERSION_HEX>=0x03000000
        int i;
        for (i = 0; i < 10; i++) {
          free(vargs$argnum[i]);
        }
      %#endif
      }

In the 'in' typemap, the special variable ``varargs`` is a tuple holding
all of the extra arguments passed (this is specific to the Python
module). The typemap then pulls this apart and sticks the values into
the array of strings ``args``. Then, the array is assigned to ``$1``
(recall that this is the ``void *`` variable corresponding to
``(...)``). However, this assignment is only half of the
picture----clearly this alone is not enough to make the function work.
The 'freearg' typemap cleans up memory allocated in the 'in' typemap;
this code is generated to be called after the ``execlp`` function is
called. To patch everything up, you have to rewrite the underlying
action code using the ``%feature`` directive like this:

.. container:: code

   ::

      %feature("action") execlp {
        char **vargs = (char **) arg3;
        result = execlp(arg1, arg2, vargs[0], vargs[1], vargs[2], vargs[3], vargs[4],
                        vargs[5], vargs[6], vargs[7], vargs[8], vargs[9], NULL);
      }

      int execlp(const char *path, const char *arg, ...);

This patches everything up and creates a function that more or less
works. However, don't try explaining this to your coworkers unless you
know for certain that they've had several cups of coffee. If you really
want to elevate your guru status and increase your job security,
continue to the next section.

Varargs wrapping with libffi
---------------------------------

All of the previous examples have relied on features of SWIG that are
portable and which don't rely upon any low-level machine-level details.
In many ways, they have all dodged the real issue of variable length
arguments by recasting a varargs function into some weaker variation
with a fixed number of arguments of known types. In many cases, this
works perfectly fine. However, if you want more generality than this,
you need to bring out some bigger guns.

One way to do this is to use a special purpose library such as libffi
(http://www.sourceware.org/libffi/). libffi is a library that allows you
to dynamically construct call-stacks and invoke procedures in a
relatively platform independent manner. Details about the library can be
found in the libffi distribution and are not repeated here.

To illustrate the use of libffi, suppose that you *really* wanted to
create a wrapper for ``execlp()`` that accepted *any* number of
arguments. To do this, you might make a few adjustments to the previous
example. For example:

.. container:: code

   ::

      /* Take an arbitrary number of extra arguments and place into an array
         of strings */

      %typemap(in) (...) {
        char **argv;
        int    argc;
        int    i;

        argc = PyTuple_Size(varargs);
        argv = (char **) malloc(sizeof(char *)*(argc+1));
        for (i = 0; i < argc; i++) {
          PyObject *o = PyTuple_GetItem(varargs, i);
          if (!PyString_Check(o)) {
            free(argv);
            PyErr_SetString(PyExc_ValueError, "Expected a string");
            SWIG_fail;
          }
          argv[i] = PyString_AsString(o);
        }
        argv[i] = NULL;
        $1 = (void *) argv;
      }

      /* Rewrite the function call, using libffi */    

      %feature("action") execlp {
        int       i, vc;
        ffi_cif   cif;
        ffi_type  **types;
        void      **values;
        char      **args;

        vc = PyTuple_Size(varargs);
        types  = (ffi_type **) malloc((vc+3)*sizeof(ffi_type *));
        values = (void **) malloc((vc+3)*sizeof(void *));
        args   = (char **) arg3;

        /* Set up path parameter */
        types[0] = &ffi_type_pointer;
        values[0] = &arg1;
        
        /* Set up first argument */
        types[1] = &ffi_type_pointer;
        values[1] = &arg2;

        /* Set up rest of parameters */
        for (i = 0; i <= vc; i++) {
          types[2+i] = &ffi_type_pointer;
          values[2+i] = &args[i];
        }
        if (ffi_prep_cif(&cif, FFI_DEFAULT_ABI, vc+3,
                         &ffi_type_uint, types) == FFI_OK) {
          ffi_call(&cif, (void (*)()) execlp, &result, values);
        } else {
          free(types);
          free(values);
          free(arg3);
          PyErr_SetString(PyExc_RuntimeError, "Whoa!!!!!");
          SWIG_fail;
        }
        free(types);
        free(values);
        free(arg3);
      }

      /* Declare the function. Whew! */
      int execlp(const char *path, const char *arg1, ...);

Looking at this example, you may start to wonder if SWIG is making life
any easier. Given the amount of code involved, you might also wonder why
you didn't just write a hand-crafted wrapper! Either that or you're
wondering "why in the hell am I trying to wrap this varargs function in
the first place?!?" Obviously, those are questions you'll have to answer
for yourself.

As a more extreme example of libffi, here is some code that attempts to
wrap ``printf()``,

.. container:: code

   ::

      /* A wrapper for printf() using libffi */

      %{
      /* Structure for holding passed arguments after conversion */
        typedef struct {
          int type;
          union {
            int    ivalue;
            double dvalue;
            void   *pvalue;
          } val;
        } vtype;
        enum { VT_INT, VT_DOUBLE, VT_POINTER };
      %}

      %typemap(in) (const char *fmt, ...) {
        vtype *argv;
        int    argc;
        int    i;

        /* Format string */
        $1 = PyString_AsString($input);

        /* Variable length arguments */
        argc = PyTuple_Size(varargs);
        argv = (vtype *) malloc(argc*sizeof(vtype));
        for (i = 0; i < argc; i++) {
          PyObject *o = PyTuple_GetItem(varargs, i);
          if (PyInt_Check(o)) {
            argv[i].type = VT_INT;
            argv[i].val.ivalue = PyInt_AsLong(o);
          } else if (PyFloat_Check(o)) {
            argv[i].type = VT_DOUBLE;
            argv[i].val.dvalue = PyFloat_AsDouble(o);
          } else if (PyString_Check(o)) {
            argv[i].type = VT_POINTER;
            argv[i].val.pvalue = (void *) PyString_AsString(o);
          } else {
            free(argv);
            PyErr_SetString(PyExc_ValueError, "Unsupported argument type");
            return NULL;
          }
        }
        $2 = (void *) argv;
      }

      /* Rewrite the function call using libffi */    
      %feature("action") printf {
        int       i, vc;
        ffi_cif   cif;
        ffi_type  **types;
        void      **values;
        vtype     *args;

        vc = PyTuple_Size(varargs);
        types  = (ffi_type **) malloc((vc+1)*sizeof(ffi_type *));
        values = (void **) malloc((vc+1)*sizeof(void *));
        args   = (vtype *) arg2;

        /* Set up fmt parameter */
        types[0] = &ffi_type_pointer;
        values[0] = &arg1;

        /* Set up rest of parameters */
        for (i = 0; i < vc; i++) {
          switch(args[i].type) {
          case VT_INT:
            types[1+i] = &ffi_type_uint;
            values[1+i] = &args[i].val.ivalue;
            break;
          case VT_DOUBLE:
            types[1+i] = &ffi_type_double;
            values[1+i] = &args[i].val.dvalue;
            break;
          case VT_POINTER:
            types[1+i] = &ffi_type_pointer;
            values[1+i] = &args[i].val.pvalue;
            break;
          default:
            abort();    /* Whoa! We're seriously hosed */
            break;   
          }
        }
        if (ffi_prep_cif(&cif, FFI_DEFAULT_ABI, vc+1,
                         &ffi_type_uint, types) == FFI_OK) {
          ffi_call(&cif, (void (*)()) printf, &result, values);
        } else {
          free(types);
          free(values);
          free(args);
          PyErr_SetString(PyExc_RuntimeError, "Whoa!!!!!");
          SWIG_fail;
        }
        free(types);
        free(values);
        free(args);
      }

      /* The function */
      int printf(const char *fmt, ...);

Much to your amazement, it even seems to work if you try it:

.. container:: targetlang

   ::

      >>> import example
      >>> example.printf("Grade: %s   %d/60 = %0.2f%%\n", "Dave", 47, 47.0*100/60)
      Grade: Dave   47/60 = 78.33%
      >>>

Of course, there are still some limitations to consider:

.. container:: targetlang

   ::

      >>> example.printf("la de da de da %s", 42)
      Segmentation fault (core dumped)

And, on this note, we leave further exploration of libffi to the reader
as an exercise. Although Python has been used as an example, most of the
techniques in this section can be extrapolated to other language modules
with a bit of work. The only details you need to know is how the extra
arguments are accessed in each target language. For example, in the
Python module, we used the special ``varargs`` variable to get these
arguments. Modules such as Tcl8 and Perl5 simply provide an argument
number for the first extra argument. This can be used to index into an
array of passed arguments to get values. Please consult the chapter on
each language module for more details.

Wrapping of va_list
------------------------

Closely related to variable length argument wrapping, you may encounter
functions that accept a parameter of type ``va_list``. For example:

.. container:: code

   ::

      int vprintf(const char *fmt, va_list ap);

As far as we know, there is no obvious way to wrap these functions with
SWIG. This is because there is no documented way to assemble the proper
va_list structure (there are no C library functions to do it and the
contents of va_list are opaque). Not only that, the contents of a
``va_list`` structure are closely tied to the underlying call-stack.
It's not clear that exporting a ``va_list`` would have any use or that
it would work at all.

A workaround can be implemented by writing a simple varargs C wrapper
and then using the techniques discussed earlier in this chapter for
varargs. Below is a simple wrapper for ``vprintf`` renamed so that it
can still be called as ``vprintf`` from your target language. The
``%varargs`` used in the example restricts the function to taking one
string argument.

.. container:: code

   ::

      %{
      int vprintf(const char *fmt, va_list ap);
      %}

      %varargs(const char *) my_vprintf;
      %rename(vprintf) my_vprintf;

      %inline %{
      int my_vprintf(const char *fmt, ...) {
        va_list ap;
        int result;

        va_start(ap, fmt);
        result = vprintf(fmt, ap);
        va_end(ap);
        return result;
      }
      %}

C++ Issues
---------------

Wrapping of C++ member functions that accept a variable number of
arguments presents a number of challenges. By far, the easiest way to
handle this is to use the ``%varargs`` directive. This is portable and
it fully supports classes much like the ``%rename`` directive. For
example:

.. container:: code

   ::

      %varargs (10, char * = NULL) Foo::bar;

      class Foo {
      public:
        virtual void bar(char *arg, ...);   // gets varargs above
      };

      class Spam: public Foo {
      public:
        virtual void bar(char *arg, ...);   // gets varargs above
      };

``%varargs`` also works with constructors, operators, and any other C++
programming construct that accepts variable arguments.

Doing anything more advanced than this is likely to involve a serious
world of pain. In order to use a library like libffi, you will need to
know the underlying calling conventions and details of the C++ ABI. For
instance, the details of how ``this`` is passed to member functions as
well as any hidden arguments that might be used to pass additional
information. These details are implementation specific and may differ
between compilers and even different versions of the same compiler.
Also, be aware that invoking a member function is further complicated if
it is a virtual method. In this case, invocation might require a table
lookup to obtain the proper function address (although you might be able
to obtain an address by casting a bound pointer to a pointer to function
as described in the C++ ARM section 18.3.4).

If you do decide to change the underlying action code, be aware that
SWIG always places the ``this`` pointer in ``arg1``. Other arguments are
placed in ``arg2``, ``arg3``, and so forth. For example:

.. container:: code

   ::

      %feature("action") Foo::bar {
        ...
        result = arg1->bar(arg2, arg3, etc.);
        ...
      }

Given the potential to shoot yourself in the foot, it is probably easier
to reconsider your design or to provide an alternative interface using a
helper function than it is to create a fully general wrapper to a
varargs C++ member function.

Discussion
---------------

This chapter has provided a number of techniques that can be used to
address the problem of variable length argument wrapping. If you care
about portability and ease of use, the ``%varargs`` directive is
probably the easiest way to tackle the problem. However, using typemaps,
it is possible to do some very advanced kinds of wrapping.

One point of discussion concerns the structure of the libffi examples in
the previous section. Looking at that code, it is not at all clear that
this is the easiest way to solve the problem. However, there are a
number of subtle aspects of the solution to consider--mostly concerning
the way in which the problem has been decomposed. First, the example is
structured in a way that tries to maintain separation between
wrapper-specific information and the declaration of the function itself.
The idea here is that you might structure your interface like this:

.. container:: code

   ::

      %typemap(const char *fmt, ...) {
        ...
      }
      %feature("action") traceprintf {
        ...
      }

      /* Include some header file with traceprintf in it */
      %include "someheader.h"

Second, careful scrutiny will reveal that the typemaps involving
``(...)`` have nothing whatsoever to do with the libffi library. In
fact, they are generic with respect to the way in which the function is
actually called. This decoupling means that it will be much easier to
consider other library alternatives for making the function call. For
instance, if libffi wasn't supported on a certain platform, you might be
able to use something else instead. You could use conditional
compilation to control this:

.. container:: code

   ::

      #ifdef USE_LIBFFI
      %feature("action") printf {
        ...
      }
      #endif
      #ifdef USE_OTHERFFI
      %feature("action") printf {
      ...
      }
      #endif

Finally, even though you might be inclined to just write a hand-written
wrapper for varargs functions, the techniques used in the previous
section have the advantage of being compatible with all other features
of SWIG such as exception handling.

As a final word, some C programmers seem to have the assumption that the
wrapping of variable length argument functions is an easily solved
problem. However, this section has hopefully dispelled some of these
myths. All things being equal, you are better off avoiding variable
length arguments if you can. If you can't avoid them, please consider
some of the simple solutions first. If you can't live with a simple
solution, proceed with caution. At the very least, make sure you
carefully read the section "A7.3.2 Function Calls" in Kernighan and
Ritchie and make sure you fully understand the parameter passing
conventions used for varargs. Also, be aware of the platform
dependencies and reliability issues that this will introduce. Good luck.
