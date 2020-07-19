SWIG and R
=============

R is a GPL'ed open source statistical and plotting environment.
Information about R can be found at
`www.r-project.org <http://www.r-project.org/>`__.

The R bindings are under active development. They have been used to
compile and run an R interface to QuantLib running on Mandriva Linux
with gcc. They are also used to create the SimpleITK R package, which
runs on Linux and MacOS. SWIG is used to create all wrapper interfaces
to `SimpleITK <http://http://www.simpleitk.org/>`__. The R bindings also
work on Microsoft Windows using Visual C++.

Bugs
---------

Currently the following features are not implemented or broken:

-  Garbage collection of some created objects. Finalizers are available
   for wrapped C++ classes and are called by the garbage collection
   system.
-  C Array wrappings

Using R and SWIG
---------------------

To use R and SWIG in C mode, execute the following commands where
example.c is the name of the file with the functions in them

.. container:: shell

   ::

      swig -r example.i
      R CMD SHLIB example_wrap.c example.c

The corresponding options for C++ mode are

.. container:: shell

   ::

      swig -c++ -r -o example_wrap.cpp example.i
      R CMD SHLIB example_wrap.cpp example.cpp

Note that R is sensitive to the names of the files. The name of the
wrapper file must be the name of the library unless you use the -o
option to R when building the library, for example:

.. container:: shell

   ::

      swig -c++ -r -o example_wrap.cpp example.i
      R CMD SHLIB -o example.so example_wrap.cpp example.cpp

R is also sensitive to the name of the file extension in C and C++ mode.
In C++ mode, the file extension must be .cpp rather than .cxx for the R
compile command to recognize it. If your C++ code is in a file using
something other than a .cpp extension, then it may still work using
PKG_LIBS:

.. container:: shell

   ::

      swig -c++ -r -o example_wrap.cpp example.i
      PKG_LIBS="example.cxx" R CMD SHLIB -o example example_wrap.cpp

The commands produces two files. A dynamic shared object file called
example.so, or example.dll, and an R wrapper file called example.R. To
load these files, start up R and type in the following commands

.. container:: shell

   ::

      dyn.load(paste("example", .Platform$dynlib.ext, sep=""))
      source("example.R")
      cacheMetaData(1)

The cacheMetaData(1) will cause R to refresh its object tables. Without
it, inheritance of wrapped objects may fail. These two files can be
loaded in any order.

If you are compiling code yourself (not using R itself), there are a few
things to watch out for:

-  The output shared library name (to the left of the file extension)
   MUST match the module name, or alternatively, you can also set the
   -package NAME command line argument. See swig -r -help for more
   information
-  If you do not set the output file name appropriately, you might see
   errors like

   .. container:: shell

      ::

         > fact(4)
         Error in .Call("R_swig_fact", s_arg1, as.logical(.copy), PACKAGE = "example") :
           "R_swig_fact" not available for .Call() for package "example"

-  Make sure the architecture of the shared library(x64 for instance),
   matches the architecture of the R program you want to load your
   shared library into

Precompiling large R files
-------------------------------

In cases where the R file is large, one make save a lot of loading time
by precompiling the R wrapper. This can be done by creating the file
makeRData.R which contains the following

.. container:: code

   ::

      source('BigFile.R')
      save(list=ls(all=TRUE), file="BigFile.RData", compress=TRUE)
      q(save="no")

This will generate a compiled R file called BigFile.RData that will save
a large amount of loading time.

There is no need to precompile large R files if the SWIG-generated code
is being included in an R package. The package infrastructure provides
this service during package installation.

General policy
-------------------

The general policy of the module is to treat the C/C++ as a basic
wrapping over the underlying functions and rely on the R type system to
provide R syntax.

Language conventions
-------------------------

getitem and setitem use C++ conventions (i.e. zero based indices). [<-
and [ are overloaded to allow for R syntax (one based indices and
slices)

C++ classes
----------------

Wrapping of C++ classes for R works quite well. R has a special type,
known as an external reference, that can be used as a pointer to
arbitary things, including C++ classes. The proxy layers generated for
other classes are not required.

SWIG currently creates a custom hierarchy of R classes derived from the
external reference type and implements type checking and function
overloading in the R code it generates. In the future we hope to utilise
the built in R6 class structures.

The R interface has the following capabilities:

-  Destructor methods are registered and called automatically by the R
   garbage collector.
-  A range of std::vector types are converted automatically to R
   equivalents via the std_vector.i library.
-  The $ operator is used for method access.
-  Variable accessors are automatically generated and called via the $,
   [, [[, $<-, [<-, [[<- operators.

Examples
~~~~~~~~~~~~~~~

Consider the following simple example:

.. container:: code

   ::

      class Vehicle {
      private:
        int m_axles;

      public:
        int Axles() {
          return(m_axles);
        }

        bool Available;

        Vehicle() {
          Available=false;
          m_axles=2;
        }

        Vehicle(int ax) {
          Available=false;
          m_axles=ax;
        }
      };

The following options are available in R:

.. container:: code

   ::

      v1 <- Vehicle()
      v2 <- Vehicle(4)
      # access members
      v1$Axles()
      [1] 2
      v2$Axles
      [1] 4
      v1$Available
      [1] FALSE
      # Set availabilty
      v1$Available <- TRUE
      v1$Available
      [1] TRUE

A useful trick to determine the methods that are available is to query
the R method definition as follows:

.. container:: code

   ::

      # display the methods for the class
      getMethod("$", class(v1))
          
      Method Definition:

      function (x, name) 
      {
          accessorFuns = list(Axles = Vehicle_Axles, Available = Vehicle_Available_get)
          vaccessors = c("Available")
          idx = pmatch(name, names(accessorFuns))
          if (is.na(idx)) 
              return(callNextMethod(x, name))
          f = accessorFuns[[idx]]
          if (is.na(match(name, vaccessors))) 
              function(...) {
                  f(x, ...)
              }
          else f(x)
      }

      Signatures:
              x           
      target  "_p_Vehicle"
      defined "_p_Vehicle"

The names in the ``accessorFuns`` list correspond to class methods while
names in the ``vaccessors`` section correspond to variables that may be
modified.

Enumerations
-----------------

R doesn't have a native enumeration type. Enumerations are represented
as character strings in R, with calls to R functions that convert back
and forth between integers.

The details of enumeration names and contents are stored in hidden R
environments, which are named according the the enumeration name - for
example, an enumeration colour:

.. container:: code

   ::

      enum colour { red=-1, blue, green = 10 };

will be initialized by the following call in R:

.. container:: code

   ::

      defineEnumeration("_colour",
       .values=c("red" = .Call('R_swig_colour_red_get',FALSE, PACKAGE='enum_thorough'),
      "blue" = .Call('R_swig_colour_blue_get',FALSE, PACKAGE='enum_thorough'),
      "green" = .Call('R_swig_colour_green_get',FALSE, PACKAGE='enum_thorough')))

which will create an environment named ``.__E___colour``. The
enumeration values are initialised via calls to C/C++ code, allowing
complex values for enumerations to be used. Calls to the C/C++ code
require the compiled library to be loaded, so a ``delayedAssign`` is
employed within ``defineEnumeration`` in order to allow the code to be
easily used in R packages.

The user typically does not need to access the enumeration lookup
functions or know the name of the enumeration type used by R. Attributes
containing the type information are attached by swig to functions
requiring enumeration arguments or returning enumeration values, and
those attributes are used to identify and access the appropriate
environments and thus translate between characters and integers.

The relevant functions, for debugging purposes, are ``enumToInteger``
and ``enumFromInteger``.

Anonymous enumerations are ignored by the binding generation process,
leaving no way of accessing the value of anonymous enumerations from R
code.
