SWIG and Doxygen Translation
===============================

This chapter describes SWIG's support for translating Doxygen comments
found in interface and header files into a target language's normal
documentation language. Currently only Javadoc and Pydoc is supported.

Doxygen translation overview
---------------------------------

The Doxygen Translation module of SWIG adds an extra layer of
functionality to SWIG, allowing automated translation of
`Doxygen <http://www.doxygen.nl/manual/>`__ formatted comments from
input files into a documentation language more suited for the target
language. Currently this module only translates into Javadoc and Pydoc
for the SWIG Java and Python modules. Other extensions could be added at
a later date. The Doxygen Translation module originally started as a
`Google Summer of
Code <https://developers.google.com/open-source/gsoc/2008/>`__ proposal
from Summer 2008.

Preparations
-----------------

To make use of the comment translation system, your documentation
comments must be in properly formatted
`Doxygen. <http://www.doxygen.nl/manual/>`__ Doxygen comments can be
present in your main SWIG interface file or any header file that it
imports. You are advised to be validate that your comments compile
properly with Doxygen before you try to translate them. Doxygen itself
is a more comprehensive tool and can provide you better feedback for
correcting any syntax errors that may be present. Please look at
Doxygen's `Documenting the
code <http://www.doxygen.nl/manual/docblocks.html>`__ for the full
comment format specifications. However, SWIG's Doxygen parser will still
report many errors and warnings found in comments (like unterminated
strings or missing ending tags).

Currently, the whole subset of Doxygen comment styles is supported (See
`Documenting the code <http://www.doxygen.nl/manual/docblocks.html>`__).
Here they are:

.. container:: code

   ::

      /**
       * Javadoc style comment, multiline
       */
      /*!
       * QT-style comment, multiline
       */
      /**
       Any of the above, but without intermediate *'s
       */
      /// Single-line comment
      //! Another single-line comment

Also any of the above with '``<``' added after comment-starting symbol,
like ``/**<, /*!<, ///<,`` or ``//!<`` will be treated as a post-comment
and will be assigned to the code before the comment. Any number of
'``*``' or '``/``' within a Doxygen comment is considered to be a
separator and is not included in the final comment, so you may safely
use comments like ``/*********/`` or ``//////////``.

Please note, as SWIG parses the input file by itself with strict
grammar, there is only a limited support for various cases of comment
placement in the file.

Comments can be placed before C/C++ expressions on separate lines:

.. container:: code

   ::

      /**
       * Some comment
       */
      void someOtherFunction();
      /**
       * Some comment
       */
      void someFunction();

      class Shape {
        /*
         * Calculate the area in cm^2
         */
        int getArea();
      }

After C/C++ expressions at the end of the line:

.. container:: code

   ::

      int someVariable = 9; ///< This is a var holding magic number 9
      void doNothing(); ///< This does nothing, nop

and in some special cases, like function parameter comments:

.. container:: code

   ::

      void someFunction(
               int a ///< Some parameter 
           );

or enum element comments:

.. container:: code

   ::

      enum E_NUMBERS
      {
          EN_ZERO, ///< The first enum item, gets zero as it's value
          EN_ONE, ///< The second, EN_ONE=1
          EN_THREE
      };

Currently only comments directly before or after the code items are
supported. Doxygen also supports comments containing structural
commands, where the comments for a code item are not put directly before
or after the code item. These structural commands are stripped out by
SWIG and are not assigned to anything.

Enabling Doxygen translation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Doxygen comments translation is disabled by default and needs to be
explicitly enabled using the command line ``-doxygen`` option for the
languages that do support it (currently Java and Python).

Doxygen-specific %feature directives
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Translation of Doxygen comments is influenced by the following `%feature
directives <Customization.html#Customization_features>`__:

doxygen:notranslate
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Turns off translation of Doxygen comments to the target language syntax:
the original comment will be copied to the output unchanged. This is
useful if you want to use Doxygen itself to generate documentation for
the target language instead of the corresponding language tool
(``javadoc``, ``sphinx``, ...).

doxygen:alias:<command-name>
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Specify an alias for a Doxygen command with the given name. This can be
useful for custom Doxygen commands which can be defined using
``ALIASES`` option for Doxygen itself but which are unknown to SWIG.
``"command-name"`` is the name of the command in the Doxyfile, e.g. if
it contains

.. container:: code

   ::

      ALIASES = "sideeffect=\par Side Effects:\n"

Then you could also specify the same expansion for SWIG with:

.. container:: code

   ::

      %feature("doxygen:alias:sideeffect") "\par Side Effects:\n"

Please note that command arguments are not currently supported with this
feature.

Notice that it is perfectly possible and potentially useful to define
the alias expansion differently depending on the target language, e.g.
with

.. container:: code

   ::

      #ifdef SWIGJAVA
      %feature("doxygen:alias:not_for_java") "This functionality is not available for Java"
      #else
      %feature("doxygen:alias:not_for_java") ""
      #endif

you could use ``@not_for_java`` in the documentation comments of all
functions which can't, for whatever reason, be currently exposed in Java
wrappers of the C++ API.

doxygen:ignore:<command-name>
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This feature makes it possible to just ignore an unknown Doxygen
command, instead of replacing it with the predefined text that
``doxygen:alias`` does. For example, you could use

.. container:: code

   ::

      %feature("doxygen:ignore:transferfull") Fantastic();
      /**
          A fantastic function.

          @transferfull Command ignored, but anything here is still included.
       */
      int * Fantastic();

if you use a custom Doxygen ``transferfull`` command to indicate that
the return value ownership is transferred to the caller, as this
information doesn't make much sense for the other languages without
explicit ownership management.

Doxygen syntax is rather rich and, in addition to simple commands such
as ``@transferfull``, it is also possible to define commands with
arguments. As explained in `Doxygen
documentation <http://www.doxygen.nl/manual/commands.html>`__, the
arguments can have a range of a single word, everything until the end of
line or everything until the end of the next paragraph. Currently, only
the "end of line" case is supported using the ``range="line"`` argument
of the feature directive:

.. container:: code

   ::

      // Ignore occurrences of
      //
      //    @compileroptions Some special C++ compiler options.
      //
      // in Doxygen comments as C++ options are not interesting for the target language
      // developers.
      %feature("doxygen:ignore:compileroptions", range="line") Amazing();

      /**
          An amazing function.

          @compileroptions This function must be compiled with /EHa when using MSVC.
       */
      void Amazing();

In addition, it is also possible to have custom pairs of begin/end tags,
similarly to the standard Doxygen ``@code/@endcode``, for example. Such
tags can also be ignored using the special value of ``range`` starting
with ``end`` to indicate that the range is an interval, for example:

.. container:: code

   ::

      %feature("doxygen:ignore:forcpponly", range="end"); // same as "end:endforcpponly"
      /**
          An incredible function.

          @forcpponly
          This is C++-specific.
          @endforcpponly
       */
      void Incredible();

would ignore everything between ``@forcpponly`` and ``@endforcpponly``
commands in Doxygen comments. By default, the name of the end command is
the same as of the start one with "end" prefix, following Doxygen
conventions, but this can be overridden by providing the end command
name after the colon.

This example shows how custom tags can be used to bracket anything
specific to C++ and prevent it from appearing in the target language
documentation. Conversely, another pair of custom tags could be used to
put target language specific information in the C++ comments. In this
case, only the custom tags themselves should be ignored, but their
contents should be parsed as usual and ``contents="parse"`` can be used
for this:

.. container:: code

   ::

      %feature("doxygen:ignore:beginPythonOnly", range="end:endPythonOnly", contents="parse");
      /**
          A splendid function.

          @beginPythonOnly
          This is specific to @b Python.
          @endPythonOnly
       */
      void Splendid();

Putting everything together, if these directives are in effect:

.. container:: code

   ::

      %feature("doxygen:ignore:transferfull");
      %feature("doxygen:ignore:compileroptions", range="line");
      %feature("doxygen:ignore:forcpponly", range="end");
      %feature("doxygen:ignore:beginPythonOnly", range="end:endPythonOnly", contents="parse");

then the following C++ Doxygen comment:

.. container:: code

   ::

      /**
          A contrived example of ignoring too many commands in one comment.

          @forcpponly
          This is C++-specific.
          @endforcpponly

          @beginPythonOnly
          This is specific to @b Python.
          @endPythonOnly

          @transferfull Command ignored, but anything here is still included.

          @compileroptions This function must be compiled with /EHa when using MSVC.
       */
      int * Contrived();

would be translated to this comment in Python:

.. container:: code

   ::

      def func():
          r"""
          A contrived example of ignoring too many commands in one comment.

          This is specific to **Python**.

          Command ignored, but anything here is still included.
          """
          ...

doxygen:nolinktranslate
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Turn off automatic link-objects translation. This is only applicable to
Java at the moment.

doxygen:nostripparams
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Turn off stripping of ``@param`` and ``@tparam`` Doxygen commands if the
parameter is not found in the function signature. This is only
applicable to Java at the moment.

Additional command line options
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ALSO TO BE ADDED (Javadoc auto brief?)

Doxygen to Javadoc
-----------------------

If translation is enabled, Javadoc formatted comments should be
automatically placed in the correct locations in the resulting module
and proxy files.

Basic example
~~~~~~~~~~~~~~~~~~~~

Here is an example segment from an included header file

.. container:: code

   ::

      /*! This is describing class Shape
       \author Bob
       */

      class Shape {
      public:
        Shape() {
          nshapes++;
        }
        virtual ~Shape() {
          nshapes--;
        };
        double  x, y; /*!< Important Variables */
        void    move(double dx, double dy); /*!< Moves the Shape */
        virtual double area(void) = 0; /*!< \return the area */
        virtual double perimeter(void) = 0; /*!< \return the perimeter */
        static  int nshapes;
      };

Simply running SWIG should result in the following code being present in
Shapes.java

.. container:: targetlang

   ::


      /**
       * This is describing class Shape 
       * @author Bob 
       * 
       */

      public class Shape {

      ...

      /**
       * Important Variables 
       */
        public void setX(double value) {
          ShapesJNI.Shape_x_set(swigCPtr, this, value);
        }

      /**
       * Important Variables 
       */
        public double getX() {
          return ShapesJNI.Shape_x_get(swigCPtr, this);
        }

      /**
       * Moves the Shape 
       */
        public void move(double dx, double dy) {
          ShapesJNI.Shape_move(swigCPtr, this, dx, dy);
        }

      /**
       * @return the area 
       */
        public double area() {
          return ShapesJNI.Shape_area(swigCPtr, this);
        }

      /**
       * @return the perimeter 
       */
        public double perimeter() {
          return ShapesJNI.Shape_perimeter(swigCPtr, this);
        }
      }

The code Java-wise should be identical to what would have been generated
without the doxygen functionality enabled. When the Doxygen Translator
module encounters a comment that contains nothing useful or a doxygen
comment that it cannot parse, it will not affect the functionality of
the SWIG generated code.

The Javadoc translator will handle most of the tags conversions (see the
table below). It will also automatically translate link-objects params,
in \\see and \\link...\\endlink commands. For example,
'someFunction(std::string)' will be converted to 'someFunction(String)'.
If you don't want such behaviour, you could turn this off by using the
'doxygen:nolinktranslate' feature. Also all '\\param' and '\\tparam'
commands are stripped out, if the specified parameter is not present in
the function. Use 'doxygen:nostripparams' to avoid.

Javadoc translator features summary (see `%feature
directives <Customization.html#Customization_features>`__):

Javadoc tags
~~~~~~~~~~~~~~~~~~~

Here is the list of all Doxygen tags and the description of how they are
translated to Javadoc

.. list-table:: Java Doxygen Tags
    :widths: 20 80

    * - \\a
      - wrapped with <i> html tag

    * - \\arg
      - wrapped with <li> html tag

    * - \\author
      - translated to @author

    * - \\authors
      - translated to @author

    * - \\b
      - wrapped with <b> html tag

    * - \\c
      - wrapped with <code> html tag

    * - \\cite
      - wrapped with <i> html tag

    * - \\code
      - translated to {\@code ...}

    * - \\code{<ext>}
      - translated to {\@code ...}; code language extension is ignored

    * - \\cond
      - translated to 'Conditional comment: <condition>'

    * - \\copyright
      - replaced with 'Copyright:'

    * - \\deprecated
      - translated to @deprecated

    * - \\e
      - wrapped with <i> html tag

    * - \\else
      - replaced with '}Else:{'

    * - \\elseif
      - replaced with '}Else if: <condition>{'

    * - \\em
      - wrapped with <i> html tag

    * - \\endcode
      - see note for \\code

    * - \\endcond
      - replaced with 'End of conditional comment.'

    * - \\endif
      - replaced with '}'

    * - \\endlink
      - see note for \\link

    * - \\endverbatim
      - see note for \\verbatim

    * - \\exception
      - translated to @exception

    * - \\f$, \\f[, \\f], \\f{, \\f}
      - LateX formulas are left unchanged

    * - \\if
      - replaced with 'If: <condition> {'

    * - \\ifnot
      - replaced with 'If not: <condition> {'

    * - \\image
      - translated to <img/> html tag only if target=HTML

    * - \\li
      - wrapped with <li> html tag

    * - \\link
      - translated to {\@link ...}

    * - \\n
      - replaced with newline char

    * - \\note
      - replaced with 'Note:'

    * - \\overload
      - prints 'This is an overloaded ...' according to Doxygen docs

    * - \\p
      - wrapped with <code> html tag

    * - \\par
      - replaced with <p alt='title'>...</p>

    * - \\param
      - translated to @param

    * - \\param[<dir>]
      - translated to @param; parameter direction ('in'; 'out'; or 'in,out') is ignored

    * - \\remark
      - replaced with 'Remarks:'

    * - \\remarks
      - replaced with 'Remarks:'

    * - \\result
      - translated to @return

    * - \\return
      - translated to @return

    * - \\returns
      - translated to @return

    * - \\sa
      - translated to @see

    * - \\see
      - translated to @see

    * - \\since
      - translated to @since

    * - \\throw
      - translated to @throws

    * - \\throws
      - translated to @throws

    * - \\todo
      - replaced with 'TODO:'

    * - \\tparam
      - translated to @param

    * - \\verbatim
      - translated to {\@literal ...}

    * - \\version
      - translated to @version

    * - \\warning
      - translated to 'Warning:'

    * - \\$
      - prints $ char

    * - \\@
      - prints @ char

    * - ``\\``
      - prints \\ char

    * - \\&
      - prints & char

    * - \\~
      - prints ~ char

    * - \\<
      - prints < char

    * - \\>
      - prints > char

    * - \\#
      - prints # char

    * - \\%
      - prints % char

    * - \\"
      - prints " char

    * - \\.
      - prints . char

    * - \\\:\:
      - prints \:\:


Unsupported tags
~~~~~~~~~~~~~~~~~~~~~~~

Doxygen has a wealth of tags such as @latexonly that have no equivalent
in Javadoc (all supported tags are listed in `Javadoc
documentation <https://docs.oracle.com/javase/7/docs/technotes/tools/windows/javadoc.html>`__).
As a result several tags have no translation or particular use, such as
some linking and section tags. These are suppressed with their content
just printed out (if the tag has any sense, typically text content).
Here is the list of these tags:

.. container:: diagram

   **Unsupported Doxygen tags**

   -  \\addindex
   -  \\addtogroup
   -  \\anchor
   -  \\attention
   -  \\brief
   -  \\bug
   -  \\callergraph
   -  \\callgraph
   -  \\category
   -  \\class
   -  \\copybrief
   -  \\copydetails
   -  \\copydoc
   -  \\date
   -  \\def
   -  \\defgroup
   -  \\details
   -  \\dir
   -  \\dontinclude
   -  \\dot
   -  \\dotfile
   -  \\enddot
   -  \\endhtmlonly
   -  \\endinternal
   -  \\endlatexonly
   -  \\endmanonly
   -  \\endmsc
   -  \\endrtfonly
   -  \\endxmlonly
   -  \\enum
   -  \\example
   -  \\extends
   -  \\file
   -  \\fn
   -  \\headerfile
   -  \\hideinitializer
   -  \\htmlinclude
   -  \\htmlonly
   -  \\implements
   -  \\include
   -  \\includelineno
   -  \\ingroup
   -  \\interface
   -  \\internal
   -  \\invariant
   -  \\latexonly
   -  \\line
   -  \\mainpage
   -  \\manonly
   -  \\memberof
   -  \\msc
   -  \\mscfile
   -  \\name
   -  \\namespace
   -  \\nosubgrouping
   -  \\package
   -  \\page
   -  \\paragraph
   -  \\post
   -  \\pre
   -  \\private
   -  \\privatesection
   -  \\property
   -  \\protected
   -  \\protectedsection
   -  \\protocol
   -  \\public
   -  \\publicsection
   -  \\ref
   -  \\related
   -  \\relatedalso
   -  \\relates
   -  \\relatesalso
   -  \\retval
   -  \\rtfonly
   -  \\section
   -  \\short
   -  \\showinitializer
   -  \\skip
   -  \\skipline
   -  \\snippet
   -  \\struct
   -  \\subpage
   -  \\subsection
   -  \\subsubsection
   -  \\tableofcontents
   -  \\test
   -  \\typedef
   -  \\union
   -  \\until
   -  \\var
   -  \\verbinclude
   -  \\weakgroup
   -  \\xmlonly
   -  \\xrefitem

If one of the following Doxygen tags appears as the first tag in a
comment, the whole comment block is ignored:

.. container:: diagram

   **Ignored Doxygen tags**

   -  \\addtogroup
   -  \\callergraph
   -  \\callgraph
   -  \\category
   -  \\class
   -  \\def
   -  \\defgroup
   -  \\dir
   -  \\enum
   -  \\example
   -  \\file
   -  \\fn
   -  \\headerfile
   -  \\hideinitializer
   -  \\interface
   -  \\internal
   -  \\mainpage
   -  \\name
   -  \\namespace
   -  \\nosubgrouping
   -  \\overload
   -  \\package
   -  \\page
   -  \\property
   -  \\protocol
   -  \\relates
   -  \\relatesalso
   -  \\showinitializer
   -  \\struct
   -  \\typedef
   -  \\union
   -  \\var
   -  \\weakgroup

Further details
~~~~~~~~~~~~~~~~~~~~~~

TO BE ADDED.

Doxygen to Pydoc
---------------------

If translation is enabled, Pydoc formatted comments should be
automatically placed in the correct locations in the resulting module
and proxy files. The problem is that Pydoc has no tag mechanism like
Doxygen or Javadoc, so most of Doxygen commands are translated by merely
copying the appropriate command text.

.. _basic-example-1:

Basic example
~~~~~~~~~~~~~~~~~~~~

Here is an example segment from an included header file

.. container:: code

   ::

      /*! This is describing class Shape
       \author Bob
       */

      class Shape {
      public:
        Shape() {
          nshapes++;
        }
        virtual ~Shape() {
          nshapes--;
        };
        double  x, y; /*!< Important Variables */
        void    move(double dx, double dy); /*!< Moves the Shape */
        virtual double area(void) = 0; /*!< \return the area */
        virtual double perimeter(void) = 0; /*!< \return the perimeter */
        static  int nshapes;
      };

Simply running SWIG should result in the following code being present in
Shapes.py

.. container:: targetlang

   ::


      ...

      class Shape(_object):
          """
          This is describing class Shape 
          Authors:
          Bob 

          """
          
          ...
          
          def move(self, *args):
              """
              Moves the Shape 
              """
              return _Shapes.Shape_move(self, *args)

          def area(self):
              """
              Return:
              the area 
              """
              return _Shapes.Shape_area(self)

          def perimeter(self):
              """
              Return:
              the perimeter 
              """
              return _Shapes.Shape_perimeter(self)

If any parameters of a function or a method are documented in the
Doxygen comment, their description is copied into the generated output
using `Sphinx <http://sphinx-doc.org/>`__ documentation conventions. For
example

.. container:: code

   ::

      /**
          Set a breakpoint at the given location.

          @param filename The full path to the file.
          @param line_number The line number in the file.
       */
      bool SetBreakpoint(const char* filename, int line_number);

would be translated to

.. container:: targetlang

   ::

      def SetBreakpoint(filename, line_number):
          r"""
          Set a breakpoint at the given location.

          :type filename: string
          :param filename: The full path to the file.
          :type line_number: int
          :param line_number: The line number in the file.
          """

The types used for the parameter documentation come from the "doctype"
typemap which is defined for all the primitive types and a few others
(e.g. ``std::string`` and ``shared_ptr<T>``) but for non-primitive types
is taken to be just the C++ name of the type with namespace scope
delimiters (``::``) replaced with a dot. To change this, you can define
your own typemaps for the custom types, e.g:

.. container:: code

   ::

      %typemap(doctype) MyDate "datetime.date";

Currently Doxygen comments assigned to global variables and static
member variables are not present in generated code, so they have no
comment translated for them.

**Whitespace and tables** Whitespace is preserved when translating
comments, so it makes sense to have Doxygen comments formatted in a
readable way. This includes tables, where tags <th>, <td> and </tr>are
translated to '|'. The line after line with <th> tags contains dashes.
If we take care about whitespace, comments in Python are much more
readable. Example:

.. container:: code

   ::

      /**
       * <table border = '1'>
       * <caption>Animals</caption>
       * <tr><th> Column 1 </th><th> Column 2 </th></tr>
       * <tr><td> cow      </td><td> dog      </td></tr>
       * <tr><td> cat      </td><td> mouse    </td></tr>
       * <tr><td> horse    </td><td> parrot   </td></tr>
       * </table>
       */

translates to Python as:

.. container:: diagram

   ::

        Animals
        | Column 1 | Column 2 |
        -----------------------
        | cow      | dog      |
        | cat      | mouse    |
        | horse    | parrot   |

**Overloaded functions** Since all the overloaded functions in c++ are
wrapped into one Python function, Pydoc translator will combine every
comment of every overloaded function and put it into the comment for the
one wrapper function.

If you intend to use resulting generated Python file with the Doxygen
docs generator, rather than Pydoc, you may want to turn off translation
completely (doxygen:notranslate feature). Then SWIG will just copy the
comments to the proxy file and reformat them if needed, but all the
comment content will be left as is. As Doxygen doesn't support special
commands in Python comments (see `Doxygen
docs <http://www.doxygen.nl/manual/docblocks.html#pythonblocks>`__), you
may want to use some tool like doxypy
(`doxypy <https://pypi.org/project/doxypy/>`__) to do the work.

Pydoc translator
~~~~~~~~~~~~~~~~~~~~~~~

Here is the list of all Doxygen tags and the description of how they are
translated to Pydoc

.. list-table:: Python Doxygen tags
    :widths: 20 80

    * - \\a
      - wrapped with '*'

    * - \\arg
      - prepended with '* '

    * - \\author
      - prints 'Author:'

    * - \\authors
      - prints 'Authors:'

    * - \\b
      - wrapped with '**'

    * - \\c
      - wrapped with '``'

    * - \\cite
      - wrapped with single quotes

    * - \\code
      - replaced with '.. code-block:: c++'

    * - \\code{<ext>}
      - replaced with '.. code-block:: <lang>', where the following doxygen code languages are recognized: .c -> C, .py -> python, .java > java

    * - \\cond
      - translated to 'Conditional comment: <condition>'

    * - \\copyright
      - prints 'Copyright:'

    * - \\deprecated
      - prints 'Deprecated:'

    * - \\e
      - wrapped with '*'

    * - \\else
      - replaced with '}Else:{'

    * - \\elseif
      - replaced with '}Else if: <condition>{'

    * - \\em
      - wrapped with '*'

    * - \\endcond
      - replaced with 'End of conditional comment.'

    * - \\endif
      - replaced with '}'

    * - \\example
      - replaced with 'Example:'

    * - \\exception
      - replaced with ':raises:'

    * - \\f$
      - rendered using ':math:\`\`'

    * - \\f[
      - rendered using '.. math::'

    * - \\f{
      - rendered using '.. math::'

    * - \\if
      - replaced with 'If: <condition> {'

    * - \\ifnot
      - replaced with 'If not: <condition> {'

    * - \\li
      - prepended with '* '

    * - \\n
      - replaced with newline char

    * - \\note
      - replaced with 'Note:'

    * - \\overload
      - prints 'This is an overloaded ...' according to Doxygen docs

    * - \\p
      - wrapped with '``'

    * - \\par
      - replaced with 'Title: ...'

    * - \\param
      - add ':type:' and ':param:' directives

    * - \\param[<dir>]
      - same as \\param, but direction ('in'; 'out'; 'in,out') is included in ':type:' directive

    * - \\remark
      - replaced with 'Remarks:'

    * - \\remarks
      - replaced with 'Remarks:'

    * - \\result
      - add ':rtype:' and ':return:' directives

    * - \\return
      - add ':rtype:' and ':return:' directives

    * - \\returns
      - add ':rtype:' and ':return:' directives

    * - \\sa
      - replaced with 'See also:'

    * - \\see
      - replaced with 'See also:'

    * - \\since
      - replaced with 'Since:'

    * - \\throw
      - replaced with ':raises:'

    * - \\throws
      - replaced wih ':raises:'

    * - \\todo
      - replaced with 'TODO:'

    * - \\tparam
      - add ':type:' and ':param:' directives

    * - \\verbatim
      - content copied verbatim

    * - \\version
      - replaced with 'Version:'

    * - \\warning
      - translated to 'Warning:'

    * - \\$
      - prints $ char

    * - \\@
      - prints @ char

    * - ``\\``
      - prints \\ char

    * - \\&
      - prints & char

    * - \\~
      - prints ~ char

    * - \\<
      - prints < char

    * - \\>
      - prints > char

    * - \\#
      - prints # char

    * - \\%
      - prints % char

    * - \\"
      - prints " char

    * - \\.
      - prints . character

    * - \\\:\:
      - prints \:\:


.. _unsupported-tags-1:

Unsupported tags
~~~~~~~~~~~~~~~~~~~~~~~

Doxygen has a wealth of tags such as @latexonly that have no equivalent
in Pydoc. As a result several tags that have no translation (or
particular use, such as some linking and section tags) are suppressed
with their content just printed out (if it has any sense, typically text
content). Here is the list of these tags:

.. container:: diagram

   **Unsupported Python Doxygen tags**

   -  \\addindex
   -  \\addtogroup
   -  \\anchor
   -  \\attention
   -  \\brief
   -  \\bug
   -  \\callergraph
   -  \\callgraph
   -  \\category
   -  \\class
   -  \\copybrief
   -  \\copydetails
   -  \\copydoc
   -  \\date
   -  \\def
   -  \\defgroup
   -  \\details
   -  \\dir
   -  \\dontinclude
   -  \\dot
   -  \\dotfile
   -  \\enddot
   -  \\endhtmlonly
   -  \\endinternal
   -  \\endlatexonly
   -  \\endlink
   -  \\endmanonly
   -  \\endmsc
   -  \\endrtfonly
   -  \\endxmlonly
   -  \\enum
   -  \\extends
   -  \\file
   -  \\fn
   -  \\headerfile
   -  \\hideinitializer
   -  \\htmlinclude
   -  \\htmlonly
   -  \\image
   -  \\implements
   -  \\include
   -  \\includelineno
   -  \\ingroup
   -  \\interface
   -  \\internal
   -  \\invariant
   -  \\latexonly
   -  \\line
   -  \\link
   -  \\mainpage
   -  \\manonly
   -  \\memberof
   -  \\msc
   -  \\mscfile
   -  \\name
   -  \\namespace
   -  \\nosubgrouping
   -  \\package
   -  \\page
   -  \\paragraph
   -  \\post
   -  \\pre
   -  \\private
   -  \\privatesection
   -  \\property
   -  \\protected
   -  \\protectedsection
   -  \\protocol
   -  \\public
   -  \\publicsection
   -  \\ref
   -  \\related
   -  \\relatedalso
   -  \\relates
   -  \\relatesalso
   -  \\retval
   -  \\rtfonly
   -  \\section
   -  \\short
   -  \\showinitializer
   -  \\skip
   -  \\skipline
   -  \\snippet
   -  \\struct
   -  \\subpage
   -  \\subsection
   -  \\subsubsection
   -  \\tableofcontents
   -  \\test
   -  \\typedef
   -  \\union
   -  \\until
   -  \\var
   -  \\verbinclude
   -  \\weakgroup
   -  \\xmlonly
   -  \\xrefitem

.. _further-details-1:

Further details
~~~~~~~~~~~~~~~~~~~~~~

TO BE ADDED.

Troubleshooting
--------------------

When running SWIG with command line option ``-doxygen``, it may happen
that SWIG will fail to parse the code, which is valid C++ code and is
parsed without problems without the option. The problem is, that Doxygen
comments are not tokens (the C/C++ compiler actually never sees them)
and that they can appear anywhere in the code. That's why it is
practically impossible to handle all corner cases with the parser.
However, these problems can usually be avoided by minor changes in the
code or comment. Known problems and solutions are shown in this section.

Recommended approach is to first run SWIG without command line option
``-doxygen``. When it successfully processes the code, include the
option and fix problems with Doxygen comments.

Problem with conditional compilation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Inserting a conditional compilation preprocessor directive between a
Doxygen comment and a commented item may break parsing:

.. container:: code

   ::

      class A {
        /**
         * Some func.
         */
        #ifndef SWIG
        void myfunc()
        {
        }
        #endif
      };

The solution is to move the directive above the comment:

.. container:: code

   ::

      class A {
        #ifndef SWIG
        /**
         * Some func.
         */
        void myfunc()
        {
        }
        #endif
      };

Developer information
--------------------------

This section contains information for developers enhancing the Doxygen
translator.

Doxygen translator design
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If this functionality is turned on, SWIG places all comments found into
the SWIG parse tree. Nodes contain an additional attribute called
``doxygen`` when a comment is present. Individual nodes containing
Doxygen with Structural Indicators, such as @file, as their first
command, are also present in the parse tree. These individual "blobs" of
Doxygen such as :

.. container:: code

   ::

      /*! This is describing function Foo
       \param x some random variable
       \author Bob
       \return Foo
       */

are passed on individually to the Doxygen Translator module. This module
builds its own private parse tree and hands it to a separate class for
translation into the target documentation language. For example,
``JavaDocConverter`` is the Javadoc module class.

Debugging the Doxygen parser and translator
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There are two handy command line options, that enable lots of detailed
debug information printing.

.. container:: shell

   ::

        -debug-doxygen-parser     - Display Doxygen parser module debugging information
        -debug-doxygen-translator - Display Doxygen translator module debugging information

Tests
~~~~~~~~~~~~

Doxygen tests have been added to the regular SWIG test-suite. There are
a number of tests beginning ``doxygen_`` in the Examples/test-suite
sub-directory.

Like any other SWIG test case, the tests are included in
Examples/test-suite/common.mk and can be tested with commands like
``make check-test-suite`` or ``make check-python-test-suite``. To run
them individually, type ``make -s <testname>.cpptest`` in the
language-specific sub-directory in ``Examples/test-suite`` directory.
For example:

.. container:: shell

   ::

        Examples/test-suite/java $ make -s doxygen_parsing.cpptest

If the test fails, both expected and translated comments are printed to
std out, but also written to files *expected.txt* and *got.txt*. Since
it is often difficult to find a single character difference in several
lines of text, we can use some diff tool, for example:

.. container:: shell

   ::

        Examples/test-suite/java $ kdiff3 expected.txt got.txt

Runtime tests in Java are implemented using Javadoc doclets. To make
that work, you should have tools.jar from the JDK in your classpath. Or
you should have JAVA_HOME environment variable defined and pointing to
the JDK location.

The Java's comment parsing code (the testing part) is located in
commentParser.java. It checks the generated code. It is possible to run
this file as a stand-alone program, with
``java commentParser <some java package>``, and it will print the list
of comments found in the specified directory (in the format it has used
in the runtime tests). So, when you want to create a new Doxygen test
case, just copy an existing one and replace the actual comment content
(section of entries in form 'wantedComments.put(...)' with the output of
the above command.

Runtime tests in Python are just plain string comparisons of the
\__doc_\_ properties.

Extending to other languages
---------------------------------

In general, an extension to another language requires a fairly deep
understanding of the target language module, such as Modules/python.cxx
for Python. Searching for "doxygen" in the java.cxx module can give you
a good idea of the process for placing documentation comments into the
correct areas. The basic gist is that anywhere a comment may reside on a
node, there needs to be a catch for it in front of where that function,
class, or other object is written out to a target language file. The
other half of extension is building a target documentation language
comment generator that handles one blob at a time. However, this is
relatively simple and nowhere near as complex as the wrapper generating
modules in SWIG. See Source/Doxygen/javadoc.cxx for a good example. The
target language module passes the Doxygen Translator the blob to
translate, and receives back the translated text.

**What is given to the Doxygen Translator**

.. container:: code

   ::

      /*! This is describing function Foo
       \param x some random variable
       \author Bob
       \return Foo
       */

**What is received back by java.cxx**

.. container:: targetlang

   ::

      /** This is describing function Foo
       *
       * @param x some random variable
       * @author Bob
       * @return Foo
       */

Development of the comment translator itself is simplified by the fact
that the Doxygen Translator module can easily include a ``main``
function and thus be developed, compiled, and tested independently of
SWIG.
