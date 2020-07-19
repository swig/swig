SWIG Command Line Handling
==========================

| David M. Beazley
| dave-swig@dabeaz.com
| December, 2006

Introduction
------------

This document describes the functions related to the handling of command
line options passed to SWIG. These functions are defined in the header
file ``Source/Swig/swigopt.h``. This API is considered to be stable.

Initialization
--------------

Upon SWIG startup, the following function is called:

**``void Swig_init_args(int argc, char **argv_)``**

   Registers command line options with the SWIG core. This creates an
   internal array that is used by other functions to mark whether or not
   a particular command line option was used. This is ultimately used to
   issue error messages about unused or unknown command line options.
   This function is currently invoked in the SWIG main() function that
   is found in ``Source/Modules/swigmain.cxx``.

Argument Marking
----------------

As command line options are processed by language modules, the following
functions are used to mark the arguments as used:

**``void Swig_mark_arg(int n)``**

   Mark argument number ``n`` as used.

**``int Swig_check_marked(int n)``**

   Check to see if argument ``n`` has been marked. Returns 0 or 1.

Argument Checking
-----------------

The following function is used to check all of the command line options
after parsing. It looks at the marked list and issues an error message
if any unconsumed arguments are found.

**``void Swig_check_options()``**

   Checks all command line options to see if they have all been
   processed. If not, an error message is generated and execution
   terminates with a call to ``exit()``. This function is currently
   invoked in ``Source/Modules/main.cxx`` just before SWIG starts any
   processing of input files.

Utility Function
----------------

**``void Swig_arg_error())``**

   A generic function that issues an error message about being unable to
   parse command line options. SWIG is terminated by a call to
   ``exit()``.
