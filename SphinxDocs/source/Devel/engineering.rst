SWIG Engineering Manual
=======================

**David Beazley**

(Note : This is a work in progress.)


Introduction
---------------

The purpose of this document is to describe various coding conventions
and organizational aspects for SWIG developers. The idea for this
document is largely borrowed from John Ousterhout's Tcl/Tk Engineering
Manual. It is not my intent to overly managerial about matters--rather
I'm hoping to make life a little less chaotic for everyone.

First a little background: SWIG was started in 1995 as a one-person
project and continued in this mode of operation until about 1998. Most
of this development was driven by ideas submitted by early SWIG users as
opposed to being motivated by a grand design. As a result, the code
ended up being a pretty horrible C++ coding disaster. A mostly working
disaster perhaps, but a disaster nonetheless.

With that said, the primary goal of future SWIG development is to
reengineer the original system, fix most of its inherent design flaws,
and to produce what I hope will become a highly extensible and modular
interface compiler framework. To this do this, there are a few critical
areas of work. First, I want to restructure SWIG as a collection of
loosely coupled modules written in either ANSI C or an scripting
language. Second, I want the system to be minimalistic in its use of
data structures and interconnections. The primary reason for this is
that the fewer data structures there are, the less users will have to
remember. This will also make the system more accessible to non-experts.
Finally, I want to reevaluate the whole idea of a SWIG module is and
expand the definition to include just about anything from parsers,
preprocessors, optimizers, interface editors, and code generators.

The rest of this document outlines a few general rules of how code
should be developed within the SWIG project. These rules are primarily
drawn from my own experience developing software and observing the
practices of other successful projects. ` <#i2>`__

Programming Languages and Libraries
--------------------------------------

All SWIG modules must be written in either ANSI C or one of the
scripting languages for which SWIG can generate an interface (e.g.,
Perl, Python, or Tcl). C++ is currently being used to write SWIG
modules, but it is only being utilized to avoid working with a lot of
pointers to functions. **Advanced C++ features like namespaces,
templates, and overloading should not be used.**.

Module writers should make every attempt to use only those functions
described in the POSIX.1 standard. This includes most of the functions
contained the Kernighan and Ritchie C programming book. Use of operating
system dependent functionality such as socket libraries should always be
included inside a conditional compilation block so that it can be
omitted on problematic platforms. If you are unsure about a library
call, check the man page or contact Dave. ` <#i3>`__

The Source Directory and Module Names
----------------------------------------

All SWIG modules are contained within the "Source" directory. Within
this directory, each module is placed into its own subdirectory. The
name of this subdirectory should exactly match the name of the module.
For example, if you are creating a module called "Tcl", all of your
files should be placed in a directory "Tcl".

When choosing a module name, please pick a name that is not currently in
use. As a general convention, the first letter of a module name is
capitalized such as "Perl". Alternatives such as "perl" or "PERL" should
be avoided. In certain instances, the first two letters may be
capitalized as in "CParse." The exact usage of this is somewhat
inconsistent and isn't terribly important--just make sure the first
letter is capitalized. Also, module names should not start with numbers,
include underscores or any other special non-alphanumeric characters.
` <#i5>`__

File Structure
-----------------

Each file in a module should be given a filename that is all lowercase
letters such as "parser.c", not "Parser.c" or "PARSER.c". Please note
that filenames are case-insensitive on Windows so this convention will
prevent you from inadvertently creating two files that differ in
case-only.

Each file should include a short abstract and license information like
this:

   ::

      /* -----------------------------------------------------------------------------
       * This file is part of SWIG, which is licensed as a whole under version 3 
       * (or any later version) of the GNU General Public License. Some additional
       * terms also apply to certain portions of SWIG. The full details of the SWIG
       * license and copyrights can be found in the LICENSE and COPYRIGHT files
       * included with the SWIG source code as distributed by the SWIG developers
       * and at http://www.swig.org/legal.html.
       *
       * xxx.c
       *
       * This file defines ...
       * ----------------------------------------------------------------------------- */

      #include "swig.h"

      /* Declarations */
      typedef struct {
         int x, y;
      } Foo;

      ...

      /* Private Declarations (used only in this file) */
      static int  avariable;

      ...

      /* Functions */
      ... 

As a general rule, files start to get unmanageable once they exceed
about 2000 lines. Files larger than this should be broken up into
multiple files. Similarly, you should avoid the temptation to create
many small files as this increases compilation time and makes the
directory structure too complicated. ` <#i6>`__

Bottom-Up Design
-------------------

Within each source file, the preferred organization is to use what is
known as "bottom-up" design. Under this scheme, lower-level functions
appear first and the highest level function appears last. The easy way
to remember is that the "main" function of your module should always
appear last in the source file. For example:

   ::

      /* Simple bottom-up program */
      #include <stdio.h>

      int foo(int x, int y) {
          /* Implement foo */
          ...
      }

      int bar() {
          ...
          foo(i,j);
          ...
      }

      ...
      int main(int argc, char **argv) {
          ...
          bar();   
          ...
      }

This choice of design is somewhat arbitrary however it has a number of
benefits particular to C. In particular, a bottom-up design generally
eliminates the need to include forward references--resulting in cleaner
code and fewer compilation errors. ` <#i7>`__

Functions
------------

All functions should have a function header that gives the function name
and a short description like this:

   ::

      /* -------------------------------------------------------------------------
       * Swig_add_directory()
       *
       * Adds a directory to the SWIG search path.
       * ------------------------------------------------------------------------- */

      void 
      Swig_add_directory(DOH *dirname) {
      ...

      }

In the function declaration, the return type and any specifiers (extern
or static) should appear on a separate line followed by the function
name and arguments as shown above. The left curly brace should appear on
the same line as the function name.

Function declarations should **NOT** use the pre-ANSI function
declaration syntax. The ANSI standard has been around long enough for
this to be a non-issue. ` <#i8>`__

Naming Conventions
---------------------

The following conventions are used to name various objects throughout
SWIG.

.. _functions-1:

Functions
^^^^^^^^^

Functions should consist of the module name and the function name
separated by an underscore like this:

   ::

      Preprocessor_define()
      Swig_add_directory()

In general, the module name should match the name of the module
subdirectory and the function name should be in all lowercase with words
separated by underscores.

Structures and Types
^^^^^^^^^^^^^^^^^^^^

If your module defines new structures, the structure name should include
the name of the module and the name of the structure appended together
like this:

   ::

      typedef struct SwigScanner {
         ...
      } SwigScanner;

      typedef struct LParseType {
         ...
      } LParseType;

In this case, both the name of the module and the type should be
capitalized. Also, whenever possible, you should use the "typedef struct
Name { ... } Name" form when defining new data structures.

Global Variables
^^^^^^^^^^^^^^^^

Global variables should be avoided if at all possible. However, if you
must use a global variable, please prepend the module name and use the
same naming scheme as for functions.

Constants
^^^^^^^^^

Constants should be created using #define and should be in all caps like
this:

   ::

      #define   SWIG_TOKEN_LPAREN  1

Separate words in a constant should be separated by underscores as with
functions.

Structure members
^^^^^^^^^^^^^^^^^

Structure members should be in all lower-case and follow the same
word-separation convention as for function names. However, the module
name does not have to be included. For example:

   ::

      typedef struct SwigScanner {
        DOH           *text;           /* Current token value */
        DOH           *scanobjs;       /* Objects being scanned */
        DOH           *str;            /* Current object being scanned */
        char          *idstart;        /* Optional identifier start characters */
        int            next_token;     /* Next token to be returned */
        int            start_line;     /* Starting line of certain declarations */
        int            yylen;          /* Length of text pushed into text */
        DOH           *file;           /* Current file name */
      } SwigScanner;

Static Functions and Variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Static declarations are free to use any naming convention that is
appropriate. However, most existing parts of SWIG use lower-case names
and follow the same convention as described for functions. ` <#i9>`__

Visibility
-------------

Modules should keep the following rules in mind when exposing their
internals:

-  Only publicly accessible functions should be included in the module
   header file.

-  All non-static declarations must be prepended with some form of the
   module name to avoid potential linker namespace conflicts with other
   modules.

-  Modules should not expose global variables or use global variables in
   their public interface.

-  Similarly, modules should discourage the direct manipulation of data
   contained within data structures in favor of using function calls
   instead. For example, instead of providing a user with a structure
   like this:

      ::

         typedef struct Foo {
            int line;
         } Foo;

   It is better to hide the implementation of Foo and provide an
   function-call interface like this:

      ::

         typedef struct Foo Foo;
         extern int  Foo_getline(Foo *f);
         extern void Foo_setline(Foo *f, int line);

   Although this results in worse performance, there are many practical
   reasons for doing this. The most important reason is that it allows
   you to change the internal representation of Foo without breaking all
   of the other modules or having to recompile the entire universe after
   making your changes.

` <#i10>`__

Miscellaneous Coding Guidelines
-----------------------------------

These are largely covered in the main documentation in the
Extending.html file. ` <#i11>`__

Git Tagging Conventions
---------------------------

Use ``git tag`` to declare some set of file revisions as related in some
symbolic way. This eases reference, retrieval and manipulation of these
files later. At the moment (2001/01/16 14:02:53), the conventions are
very simple; let's hope they stay that way!

There are two types of tags, internal (aka personal) and external.
Internal tags are used by SWIG developers primarily, whereas external
tags are used when communicating with people w/ anonymous git access.

-  Internal tags should start with the developer name and a hyphen.
-  External tags should start with "rel-".

That's all there is to it. Some example tags:

-  ttn-pre-xml-patch
-  ttn-post-xml-patch
-  ttn-going-on-vacation-so-dutifully-tagging-now
-  rel-1.3.40
-  rel-2.0.9

--------------

Copyright (C) 1999-2004 SWIG Development Team.
