/* This is a rather sophisticated example that illustrates exception handling,
   templates, and shadow classes. 

   (i) The %exception directive is used to attach exception handlers
       to specific methods.

   (ii) Exception classes are automatically converted to shadow class
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
   simply write a handler each method individually.

   Note: the *::enqueue syntax means that we simply define
   the handler for any class with this method defined.
*/

%exception *::enqueue {
   try {
      $action
   } catch(FullError e) {
      FullError *ecopy = new FullError(e);
      PyObject *err = SWIG_NewPointerObj(ecopy, SWIGTYPE_p_FullError, 1);
      PyErr_SetObject((PyObject *) SWIGTYPE_p_FullError->clientdata, err);
      return NULL;
   }
}

/* Some notes about the code above:

   (0) $action gets replaced with the actual method call.

   (1) We are going to return a copy of the exception object (FullError)
       to pass back to the Python interpreter.  This is why the copy
       constructor is being called.

   (2) The SWIG_NewPointerObj() call automatically wraps the exception object
       into a shadow class.  The SWIGTYPE_p_FullError is the type-descriptor
       used for type checking.  The "1" indicates that Python will have
       ownership of the resulting object.

   (3) The PyErr_SetObject call sets the Python exception.  However,
       the SWIGTYPE_p_FullError->clientdata reference may not be
       obvious.  This is actually the Python shadow class object
       for FullError.  Recall that in Python, exceptions are defined
       as classes.  Therefore, this works perfectly as the argument to
       PyErr_SetObject()!   A neat trick perhaps.
*/

%exception *::dequeue {
   try {
      $action
   } catch(EmptyError e) {
      EmptyError *ecopy = new EmptyError(e);
      PyObject *err = SWIG_NewPointerObj(ecopy, SWIGTYPE_p_EmptyError, 1);
      PyErr_SetObject((PyObject *) SWIGTYPE_p_EmptyError->clientdata, err);
      return NULL;
   }
}

/* Grab the original header file */
%include "example.h"

/* Instantiate a few templates */

%template(intQueue) Queue<int>;
%template(doubleQueue) Queue<double>;





