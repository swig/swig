/* This is a rather sophisticated example that illustrates exception handling,
   templates, and proxy classes. 

   (i) The %exception directive is used to attach exception handlers
       to specific methods.

   (ii) Exception classes are automatically converted to proxy class
       objects.

   (iii) The %template directive is used to expand the templates
*/

%module example

%{
#include "example.h"
%}

/* Define some exception handlers for specific methods.   In
   the header file, the enqueue method throws FullError and
   the dequeue method throws EmptyError.  Since we don't
   want to define an exception handler for everything, we
   simply write a handler for each method individually.

   Note: the *::enqueue syntax means that we simply define
   the handler for any class with this method defined.
*/

%exception *::enqueue {
   try {
      $action
   } catch(FullError& e) {
     FullError *ecopy = new FullError(e);
     PyObject *err = SWIG_NewPointerObj(ecopy, SWIGTYPE_p_FullError, 1);
     PyErr_SetObject(SWIG_Python_ExceptionType(SWIGTYPE_p_FullError), err);
     SWIG_fail;
   }
}

/* Some notes about the code above:

   (0) $action gets replaced with the actual method call.

   (1) We are going to return a copy of the exception object (FullError)
       to pass back to the Python interpreter.  This is why the copy
       constructor is being called.

   (2) The SWIG_NewPointerObj() call automatically wraps the exception object
       into a proxy class.  The SWIGTYPE_p_FullError is the type-descriptor
       used for type checking.  The "1" indicates that Python will have
       ownership of the resulting object.

   (3) The PyErr_SetObject call sets the Python exception.  However,
       the SWIGTYPE_p_FullError->clientdata reference may not be
       obvious.  This is actually the Python proxy class object
       for FullError.  Recall that in Python, exceptions are defined
       as classes.  Therefore, this works perfectly as the argument to
       PyErr_SetObject()!   A neat trick perhaps.
*/

/*
  Python classes that are used as exceptions need to be subclasses of the
  "Exception" class, and so SWIG needs to know which wrapped classes may be
  used in this way.  You can explicitly tell SWIG this by using
  %exceptionclass.  SWIG will implicitly set this feature for classes which
  appear in a throw declaration, but it's not a problem to explicitly
  mark such classes as well.

  This is a Python requirement - if you fail to mark such classes with
  %exceptionclass you may see 'interesting' behaviour on the Python side.
*/
%exceptionclass EmptyError;
%exceptionclass FullError;

%exception *::dequeue {
   try {
      $action
   } catch(EmptyError& e) {
      EmptyError *ecopy = new EmptyError(e);
      PyObject *err = SWIG_NewPointerObj(ecopy, SWIGTYPE_p_EmptyError, 1);
      PyErr_SetObject(SWIG_Python_ExceptionType(SWIGTYPE_p_EmptyError), err);
      SWIG_fail;
   }
}

/* Grab the original header file */
%include "example.h"

/* Instantiate a few templates */

%template(intQueue) Queue<int>;
%template(doubleQueue) Queue<double>;


%inline %{
// The -builtin SWIG option results in SWIGPYTHON_BUILTIN being defined
#ifdef SWIGPYTHON_BUILTIN
bool is_python_builtin() { return true; }
#else
bool is_python_builtin() { return false; }
#endif
%}

