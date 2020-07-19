Preface
=========

Introduction
----------------

SWIG (Simplified Wrapper and Interface Generator) is a software
development tool for building scripting language interfaces to C and C++
programs. Originally developed in 1995, SWIG was first used by
scientists in the Theoretical Physics Division at Los Alamos National
Laboratory for building user interfaces to simulation codes running on
the Connection Machine 5 supercomputer. In this environment, scientists
needed to work with huge amounts of simulation data, complex hardware,
and a constantly changing code base. The use of a scripting language
interface provided a simple yet highly flexible foundation for solving
these types of problems. SWIG simplifies development by largely
automating the task of scripting language integration--allowing
developers and users to focus on more important problems.

Although SWIG was originally developed for scientific applications, it
has since evolved into a general purpose tool that is used in a wide
variety of applications--in fact almost anything where C/C++ programming
is involved.

SWIG Versions
-----------------

In the late 1990's, the most stable version of SWIG was release 1.1p5.
Versions 1.3.x were officially development versions and these were
released over a period of 10 years starting from the year 2000. The
final version in the 1.3.x series was 1.3.40, but in truth the 1.3.x
series had been stable for many years. An official stable version was
released along with the decision to make SWIG license changes and this
gave rise to version 2.0.0 in 2010. Version 3.0.0 was released in 2014
focusing on adding C++11 support and C++ nested classes. Version 4.0.0
was released in 2019 to add in Doxygen support. Some target languages
were disabled as part of a clean up and others were given a new status
of either 'Supported' or 'Experimental'.

SWIG License
----------------

The LICENSE file shipped with SWIG in the top level directory contains
the SWIG license. For further insight into the license including the
license of SWIG's output code, please visit the SWIG legal page -
http://www.swig.org/legal.html.

The license was clarified in version 2.0.0 so that the code that SWIG
generated could be distributed under license terms of the user's
choice/requirements and at the same time the SWIG source was placed
under the GNU General Public License version 3.

SWIG resources
------------------

The official location of SWIG related material is

.. container:: shell

   ::

      http://www.swig.org

This site contains the latest version of the software, users guide, and
information regarding bugs, installation problems, and implementation
tricks.

You can also subscribe to the swig-user mailing list by visiting the
page

.. container:: shell

   ::

      http://www.swig.org/mail.html

The mailing list often discusses some of the more technical aspects of
SWIG along with information about beta releases and future work.

Git and Subversion access to the latest version of SWIG is also
available. More information about this can be obtained at:

.. container:: shell

   ::

      SWIG Bleeding Edge

Prerequisites
-----------------

This manual assumes that you know how to write C/C++ programs and that
you have at least heard of scripting languages such as Tcl, Python, and
Perl. A detailed knowledge of these scripting languages is not required
although some familiarity won't hurt. No prior experience with building
C extensions to these languages is required---after all, this is what
SWIG does automatically. However, you should be reasonably familiar with
the use of compilers, linkers, and makefiles since making scripting
language extensions is somewhat more complicated than writing a normal C
program.

Over time SWIG releases have become significantly more capable in their
C++ handling--especially support for advanced features like namespaces,
overloaded operators, and templates. Whenever possible, this manual
tries to cover the technicalities of this interface. However, this isn't
meant to be a tutorial on C++ programming. For many of the gory details,
you will almost certainly want to consult a good C++ reference. If you
don't program in C++, you may just want to skip those parts of the
manual.

Organization of this manual
-------------------------------

The first few chapters of this manual describe SWIG in general and
provide an overview of its capabilities. The remaining chapters are
devoted to specific SWIG language modules and are self contained. Thus,
if you are using SWIG to build Python interfaces, you can probably skip
to that chapter and find almost everything you need to know.

How to avoid reading the manual
-----------------------------------

If you hate reading manuals, glance at the "Introduction" which contains
a few simple examples. These examples contain about 95% of everything
you need to know to use SWIG. After that, simply use the
language-specific chapters as a reference. The SWIG distribution also
comes with a large directory of examples that illustrate different
topics.

Backwards compatibility
---------------------------

If you are a previous user of SWIG, don't expect SWIG to provide
complete backwards compatibility. Although the developers strive to the
utmost to keep backwards compatibility, this isn't always possible as
the primary goal over time is to make SWIG better---a process that would
simply be impossible if the developers are constantly bogged down with
backwards compatibility issues. Potential incompatibilities are clearly
marked in the detailed `release notes <#Preface_release_notes>`__.

If you need to work with different versions of SWIG and backwards
compatibility is an issue, you can use the SWIG_VERSION preprocessor
symbol which holds the version of SWIG being executed. SWIG_VERSION is a
hexadecimal integer such as 0x010311 (corresponding to SWIG-1.3.11).
This can be used in an interface file to define different typemaps, take
advantage of different features etc:

.. container:: code

   ::

      #if SWIG_VERSION >= 0x010311
      /* Use some fancy new feature */
      #endif

Note: The version symbol is not defined in the generated SWIG wrapper
file. The SWIG preprocessor has defined SWIG_VERSION since SWIG-1.3.11.

Release notes
-----------------

The CHANGES.current, CHANGES and RELEASENOTES files shipped with SWIG in
the top level directory contain, respectively, detailed release notes
for the current version, detailed release notes for previous releases
and summary release notes from SWIG-1.3.22 onwards.

Credits
------------

SWIG is an unfunded project that would not be possible without the
contributions of many people working in their spare time. If you have
benefitted from using SWIG, please consider `Donating to
SWIG <http://www.swig.org/donate.html>`__ to keep development going.
There have been a large varied number of people who have made
contributions at all levels over time. Contributors are mentioned either
in the COPYRIGHT file or CHANGES files shipped with SWIG or in submitted
bugs.

Bug reports
----------------

Although every attempt has been made to make SWIG bug-free, we are also
trying to make feature improvements that may introduce bugs. To report a
bug, either send mail to the SWIG developer list at the `swig-devel
mailing list <http://www.swig.org/mail.html>`__ or report a bug at the
`SWIG bug tracker <http://www.swig.org/bugs.html>`__. In your report, be
as specific as possible, including (if applicable), error messages,
tracebacks (if a core dump occurred), corresponding portions of the SWIG
interface file used, and any important pieces of the SWIG generated
wrapper code. We can only fix bugs if we know about them.

Installation
-----------------

Windows installation
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Please see the dedicated `Windows chapter <Windows.html#Windows>`__ for
instructions on installing SWIG on Windows and running the examples. The
Windows distribution is called swigwin and includes a prebuilt SWIG
executable, swig.exe, included in the top level directory. Otherwise it
is exactly the same as the main SWIG distribution. There is no need to
download anything else.

Unix installation
~~~~~~~~~~~~~~~~~~~~~~~~

These installation instructions are for using the distributed tarball,
for example, ``swig-3.0.8.tar.gz``. If you wish to build and install
from source on Github, extra steps are required. Please see the
`Bleeding Edge <http://swig.org/svn.html>`__ page on the SWIG website.

You must use `GNU make <http://www.gnu.org/software/make/>`__ to build
and install SWIG.

`PCRE <http://www.pcre.org/>`__ needs to be installed on your system to
build SWIG, in particular pcre-config must be available. If you have
PCRE headers and libraries but not pcre-config itself or, alternatively,
wish to override the compiler or linker flags returned by pcre-config,
you may set PCRE_LIBS and PCRE_CFLAGS variables to be used instead. And
if you don't have PCRE at all, the configure script will provide
instructions for obtaining it.

To build and install SWIG, simply type the following:

.. container:: shell

   ::

      $ ./configure
      $ make
      $ make install

By default SWIG installs itself in /usr/local. If you need to install
SWIG in a different location or in your home directory, use the
``--prefix`` option to ``./configure``. For example:

.. container:: shell

   ::

      $ ./configure --prefix=/home/yourname/projects
      $ make
      $ make install

Note: the directory given to ``--prefix`` must be an absolute pathname.
Do **not** use the ~ shell-escape to refer to your home directory. SWIG
won't work properly if you do this.

The INSTALL file shipped in the top level directory details more about
using configure. Also try

.. container:: shell

   ::

      $ ./configure --help.

The configure script will attempt to locate various packages on your
machine including Tcl, Perl5, Python and all the other target languages
that SWIG supports. Don't panic if you get 'not found' messages -- SWIG
does not need these packages to compile or run. The configure script is
actually looking for these packages so that you can try out the SWIG
examples contained in the 'Examples' directory without having to hack
Makefiles. Note that the ``--without-xxx`` options, where xxx is a
target language, have minimal effect. All they do is reduce the amount
of testing done with 'make check'. The SWIG executable and library files
installed cannot currently be configured with a subset of target
languages.

SWIG used to include a set of runtime libraries for some languages for
working with multiple modules. These are no longer built during the
installation stage. However, users can build them just like any wrapper
module as described in the `Modules chapter <Modules.html#Modules>`__.
The CHANGES file shipped with SWIG in the top level directory also lists
some examples which build the runtime library.

Note:

-  If you checked the code out via Git, you will have to run
   ``./autogen.sh`` before ``./configure``. In addition, a full build of
   SWIG requires a number of packages to be installed. Full instructions
   at `SWIG bleeding edge <http://www.swig.org/svn.html>`__.

Macintosh OS X installation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SWIG is known to work on various flavors of OS X. Follow the Unix
installation instructions above. However, as of this writing, there is
still great deal of inconsistency with how shared libraries are handled
by various scripting languages on OS X.

Users of OS X should be aware that Darwin handles shared libraries and
linking in a radically different way than most Unix systems. In order to
test SWIG and run the examples, SWIG configures itself to use flat
namespaces and to allow undefined symbols
(``-flat_namespace -undefined suppress``). This mostly closely follows
the Unix model and makes it more likely that the SWIG examples will work
with whatever installation of software you might have. However, this is
generally not the recommended technique for building larger extension
modules. Instead, you should utilize Darwin's two-level namespaces. Some
details about this can be found here `Understanding Two-Level
Namespaces <https://developer.apple.com/library/mac/documentation/Porting/Conceptual/PortingUnix/compiling/compiling.html#//apple_ref/doc/uid/TP40002850-BCIHJBBF>`__.

Needless to say, you might have to experiment a bit to get things
working at first.

Testing
~~~~~~~~~~~~~~

If you want to test SWIG after building it, a check can be performed on
Unix operating systems. Type the following:

.. container:: shell

   ::

          $ make -k check

This step can be performed either before or after installation. The
check requires at least one of the target languages to be installed. If
it fails, it may mean that you have an uninstalled language module or
that the file 'Examples/Makefile' has been incorrectly configured. It
may also fail due to compiler issues such as a broken C++ compiler. Even
if the check fails, there is a pretty good chance SWIG still works
correctly --- you will just have to mess around with one of the examples
and some makefiles to get it to work. Some tests may also fail due to
missing dependency packages, eg PCRE or Boost, but this will require
careful analysis of the configure output done during configuration.

The test suite executed by the check is designed to stress-test many
parts of the implementation including obscure corner cases. If some of
these tests fail or generate warning messages, there is no reason for
alarm --- the test may be related to some new SWIG feature or a
difficult bug that we're trying to resolve. Chances are that SWIG will
work just fine for you. Note that if you have more than one CPU/core,
then you can use parallel make to speed up the check as it does take
quite some time to run, for example:

.. container:: shell

   ::

          $ make -j2 -k check

Also, SWIG's support for C++ is sufficiently advanced that certain tests
may fail on older C++ compilers (for instance if your compiler does not
support member templates). These errors are harmless if you don't intend
to use these features in your own programs.

Note: The test-suite currently contains over 600 tests. If you have many
different target languages installed and a slow machine, it might take
more than an hour to run the test-suite.

Examples
~~~~~~~~~~~~~~~

The Examples directory contains a variety of examples of using SWIG and
it has some browsable documentation. Simply point your browser to the
file "Example/index.html".

The Examples directory also includes Visual C++ project 6 (.dsp) files
for building some of the examples on Windows. Later versions of Visual
Studio will convert these old style project files into a current
solution file.
