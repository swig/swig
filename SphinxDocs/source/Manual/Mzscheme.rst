SWIG and MzScheme/Racket
===========================

This section contains information on SWIG's support of Racket, formally
known as MzScheme.

Creating native structures
-------------------------------

Example interface file:

.. container:: code

   ::

      /* define a macro for the struct creation */
      %define handle_ptr(TYPE, NAME)
      %typemap(argout) TYPE *NAME{
        Scheme_Object *o = SWIG_NewStructFromPtr($1, $*1_mangle);
        SWIG_APPEND_VALUE(o);
      }

      %typemap(in, numinputs=0) TYPE *NAME (TYPE temp) {
        $1 = &temp;
      }
      %enddef

      /* setup the typemaps for the pointer to an output parameter cntrs */
      handle_ptr(struct diag_cntrs, cntrs);

Then in scheme, you can use regular struct access procedures like

.. container:: code

   ::

              ; suppose a function created a struct foo as
              ; (define foo (make-diag-cntrs (#x1 #x2 #x3) (make-inspector))
              ; Then you can do
              (format "0x~x" (diag-cntrs-field1 foo))
              (format "0x~x" (diag-cntrs-field2 foo))
              ;etc...

Simple example
-------------------

A few examples are available in the Examples/mzscheme directory. The
code and log of a session using SWIG below should help getting started.

C header file:

.. container:: code

   ::

      // example.h
      int fact(int n);

C source code:

.. container:: code

   ::

      // File: example.c
      #include "example.h"

      int fact(int n) {
        if (n < 0) { /* This should probably return an error, but this is simpler */
          return 0;
        }
        if (n == 0) {
          return 1;
        }
        else {
          /* testing for overflow would be a good idea here */
          return n * fact(n-1);
        }
      }

SWIG interface file:

.. container:: code

   ::

      /* File: example.i */
      %module example

      %{
      #include "example.h"
      %}

      int fact(int n);

The session below using the above files is on an OS X machine, but the
points to be made are more general. On OS X, libtool is the tool which
creates libraries, which are named .dylib, rather than .so on other
unixes, or .dll on Windows.

.. container:: shell

   ::

      % swig -mzscheme -declaremodule example.i
      % gcc -c -m32 -o example.o example.c # force 32-bit object file (mzscheme is 32-bit only)
      % libtool -dynamic -o libexample.dylib example.o # make it into a library
      % ls # what've we got so far?
      example.c example.o
      example.h example_wrap.c
      example.i libexample.dylib*
      % mzc --cgc --cc example_wrap.c # compile the wrapping code
      % LDFLAGS="-L. -lexample" mzc --ld example_wrap.dylib example_wrap.o # ...and link it
      % mzscheme -e '(path->string (build-path "compiled" "native" (system-library-subpath)))'
      "compiled/native/i386-macosx/3m"
      % mkdir -p compiled/native/i386-macosx/3m # move the extension library to a magic place
      % mv example_wrap.dylib compiled/native/i386-macosx/3m/example_ss.dylib
      % mzscheme
      Welcome to MzScheme v4.2.4 [3m], Copyright (c) 2004-2010 PLT Scheme Inc.
      > (require "example.ss")
      > (fact 5)
      120
      > ^D
      % echo 'It works!'

Some points of interest:

-  This is on a 64-bit machine, so we have to include the -m32 option
   when building the object file
-  If you want to declare a scheme module (and you probably do), it's
   important that you include the -declaremodule option to swig (if you
   miss this out, it'll appear to work, but fail later).
-  Use mzc to compile and then link the wrapped code. You'll probably
   need to adjust the link flags to refer to the library you're wrapping
   (you can either do this with an LDFLAGS declaration, as here, or with
   multiple ++ldf options to mzc).
-  Create the directory with path (build-path "compiled" "native"
   (system-library-subpath)) and move the freshly-generated .dylib to
   there, changing its name to module-name_ss.dylib. After that, you can
   REQUIRE the new module with (require "module-name.ss").
-  The above requests mzc to create an extension using the CGC
   garbage-collector. The alternative -- the 3m collector -- has
   generally better performance, but work is still required for SWIG to
   emit code which is compatible with it.

External documentation
---------------------------

See the `C API <https://docs.racket-lang.org/inside/index.html>`__ for
more description of using the mechanism for adding extensions. The main
documentation is `here <https://docs.racket-lang.org/>`__.

Tip: mzc's --vv option is very useful for debugging the inevitable
library problems you'll encounter.
