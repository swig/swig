Getting started on Windows
============================

This chapter describes SWIG usage on Microsoft Windows. Installing SWIG
and running the examples is covered as well as building the SWIG
executable. Usage within the Unix like environments MinGW and Cygwin is
also detailed.

Installation on Windows
---------------------------

SWIG does not come with the usual Windows type installation program,
however it is quite easy to get started. The main steps are:

-  Download the swigwin zip package from the `SWIG
   website <http://www.swig.org>`__ and unzip into a directory. This is
   all that needs downloading for the Windows platform.
-  Set environment variables as described in the `SWIG Windows
   Examples <#Windows_examples>`__ section in order to run examples
   using Visual C++.

Windows Executable
~~~~~~~~~~~~~~~~~~~~~~~~

The swigwin distribution contains the SWIG Windows 32-bit executable,
swig.exe, which will run on both 32-bit and 64-bit versions of Windows.
If you want to build your own swig.exe have a look at `Building swig.exe
on Windows <#Windows_swig_exe>`__.

SWIG Windows Examples
-------------------------

Using Microsoft Visual C++ is the most common approach to compiling and
linking SWIG's output. The Examples directory has a few Visual C++
project files (.dsp files). These were produced by Visual C++ 6. Newer
versions of Visual Studio should be able to open and convert these
project files. Each C# example comes with a Visual Studio 2005 solution
and associated project files instead of Visual C++ 6 project files. The
project files have been set up to execute SWIG in a custom build rule
for the SWIG interface (.i) file. Alternatively run the `examples using
Cygwin <#Windows_examples_cygwin>`__.

More information on each of the examples is available with the examples
distributed with SWIG (Examples/index.html).

Instructions for using the Examples with Visual Studio
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Ensure the SWIG executable is as supplied in the SWIG root directory in
order for the examples to work. Most languages require some environment
variables to be set **before** running Visual C++. Note that Visual C++
must be re-started to pick up any changes in environment variables. Open
up an example .dsp file, Visual C++ will create a workspace for you
(.dsw file). Ensure the Release build is selected then do a Rebuild All
from the Build menu. The required environment variables are displayed
with their current values.

The list of required environment variables for each module language is
also listed below. They are usually set from the Control Panel and
System properties, but this depends on which flavour of Windows you are
running. If you don't want to use environment variables then change all
occurrences of the environment variables in the .dsp files with hard
coded values. If you are interested in how the project files are set up
there is explanatory information in some of the language module's
documentation.

C#
^^^^^^^^^^

The C# examples do not require any environment variables to be set as a
C# project file is included. Just open up the .sln solution file in
Visual Studio .NET 2003 or later, select Release Build, and do a Rebuild
All from the Build menu. The accompanying C# and C++ project files are
automatically used by the solution file.

Java
^^^^^^^^^^^^

| **``JAVA_INCLUDE``** : Set this to the directory containing jni.h
| **``JAVA_BIN``** : Set this to the bin directory containing javac.exe

| Example using JDK1.3:
| ``JAVA_INCLUDE: D:\jdk1.3\include JAVA_BIN: D:\jdk1.3\bin``

Perl
^^^^^^^^^^^^

| **``PERL5_INCLUDE``** : Set this to the directory containing perl.h
| **``PERL5_LIB``** : Set this to the Perl library including path for
  linking

Example using nsPerl 5.004_04:

``PERL5_INCLUDE: D:\nsPerl5.004_04\lib\CORE PERL5_LIB: D:\nsPerl5.004_04\lib\CORE\perl.lib``

Python
^^^^^^^^^^^^^^

| **``PYTHON_INCLUDE``** : Set this to the directory that contains
  Python.h
| **``PYTHON_LIB``** : Set this to the Python library including path for
  linking

| Example using Python 2.1.1:
| ``PYTHON_INCLUDE: D:\python21\include PYTHON_LIB: D:\python21\libs\python21.lib``

TCL
^^^^^^^^^^^

| **``TCL_INCLUDE``** : Set this to the directory containing tcl.h
| **``TCL_LIB``** : Set this to the TCL library including path for
  linking

| Example using ActiveTcl 8.3.3.3
| ``TCL_INCLUDE: D:\tcl\include TCL_LIB: D:\tcl\lib\tcl83.lib``

R
^^^^^^^^^

| **``R_INCLUDE``** : Set this to the directory containing R.h
| **``R_LIB``** : Set this to the R library (Rdll.lib) including path
  for linking. The library needs to be built as described in the R
  README.packages file (the pexports.exe approach is the easiest).

| Example using R 2.5.1:
| ``R_INCLUDE: C:\Program Files\R\R-2.5.1\include R_LIB: C:\Program Files\R\R-2.5.1\bin\Rdll.lib``

Ruby
^^^^^^^^^^^^

| **``RUBY_INCLUDE``** : Set this to the directory containing ruby.h
| **``RUBY_LIB``** : Set this to the ruby library including path for
  linking

| Example using Ruby 1.6.4:
| ``RUBY_INCLUDE: D:\ruby\lib\ruby\1.6\i586-mswin32 RUBY_LIB: D:\ruby\lib\mswin32-ruby16.lib``

Instructions for using the Examples with other compilers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you do not have access to Visual C++ you will have to set up project
files / Makefiles for your chosen compiler. There is a section in each
of the language modules detailing what needs setting up using Visual C++
which may be of some guidance. Alternatively you may want to use Cygwin
as described in the following section.

SWIG on Cygwin and MinGW
----------------------------

SWIG can also be compiled and run using
`Cygwin <http://www.cygwin.com>`__ or `MinGW <http://www.mingw.org>`__
which provides a Unix like front end to Windows and comes free with gcc,
an ISO C/C++ compiler. However, this is not a recommended approach as
the prebuilt executable is supplied.

Building swig.exe on Windows
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you want to replicate the build of swig.exe that comes with the
download, follow the MinGW instructions below. This is not necessary to
use the supplied swig.exe. This information is provided for those that
want to modify the SWIG source code in a Windows environment. Normally
this is not needed, so most people will want to ignore this section.

Building swig.exe using MinGW and MSYS
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The short abbreviated instructions follow...

-  Install MinGW and MSYS from the `MinGW <http://www.mingw.org>`__
   site. This provides a Unix environment on Windows.
-  Follow the usual Unix instructions in the README file in the SWIG
   root directory to build swig.exe from the MinGW command prompt.

The step by step instructions to download and install MinGW and MSYS,
then download and build the latest version of SWIG from Github follow...
Note that the instructions for obtaining SWIG from Github are also
online at `SWIG Bleeding Edge <http://www.swig.org/svn.html>`__.

**Pitfall note:** Execute the steps in the order shown and don't use
spaces in path names. In fact it is best to use the default installation
directories.

#. Download the following packages from the `MinGW download
   page <http://www.mingw.org/download.shtml>`__ or `MinGW SourceForge
   download page <https://sourceforge.net/projects/mingw/files/>`__.
   Note that at the time of writing, the majority of these are in the
   Current release list and some are in the Snapshot or Previous release
   list.

   -  MinGW-3.1.0-1.exe
   -  MSYS-1.0.11-2004.04.30-1.exe
   -  msysDTK-1.0.1.exe
   -  bison-2.0-MSYS.tar.gz
   -  msys-autoconf-2.59.tar.bz2
   -  msys-automake-1.8.2.tar.bz2

#. Install MinGW-3.1.0-1.exe (C:\MinGW is default location.)
#. Install MSYS-1.0.11-2004.04.30-1.exe. Make sure you install it on the
   same windows drive letter as MinGW (C:\msys\1.0 is default). In the
   post install script,

   -  Answer y to the "do you wish to continue with the post install?"
   -  Answer y to the "do you have MinGW installed?"
   -  Type in the folder in which you installed MinGW (C:/MinGW is
      default)

#. Install msysDTK-1.0.1.exe to the same folder that you installed MSYS
   (C:\msys\1.0 is default).
#. Copy the following to the MSYS install folder (C:\msys\1.0 is
   default):

   -  msys-automake-1.8.2.tar.bz2
   -  msys-autoconf-2.59.tar.bz2
   -  bison-2.0-MSYS.tar.gz

#. Start the MSYS command prompt and execute:

   .. container:: shell

      ::

         cd /
         tar -jxf msys-automake-1.8.2.tar.bz2
         tar -jxf msys-autoconf-2.59.tar.bz2
         tar -zxf bison-2.0-MSYS.tar.gz

#. The very latest development version of SWIG is available from `SWIG
   on Github <https://github.com/swig/swig>`__ and can be downloaded as
   a zip file or if you have Git installed, via Git. Either download the
   latest `Zip file <https://github.com/swig/swig/archive/master.zip>`__
   snapshot and unzip and rename the top level folder to /usr/src/swig.
   Otherwise if using Git, type in the following:

   .. container:: shell

      ::

         mkdir /usr/src
         cd /usr/src
         git clone https://github.com/swig/swig.git

   **Pitfall note:** If you want to place SWIG in a different folder to
   the proposed /usr/src/swig, do not use MSYS emulated windows drive
   letters, because the autotools will fail miserably on those.
#. The PCRE third party library needs to be built next. Download the
   latest PCRE source tarball, such as ``pcre-8.10.tar.bz2``, from
   `PCRE <http://www.pcre.org>`__ and place in the ``/usr/src/swig``
   directory. Build PCRE as a static library using the
   Tools/pcre-build.sh script as follows:

   .. container:: shell

      ::

         cd /usr/src/swig
         Tools/pcre-build.sh

#. You are now ready to build SWIG. Execute the following commands to
   build swig.exe:

   .. container:: shell

      ::

         cd /usr/src/swig
         ./autogen.sh
         ./configure
         make

Building swig.exe using Cygwin
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Note that SWIG can also be built using Cygwin. However, SWIG will then
require the Cygwin DLL when executing. Follow the Unix instructions in
the README file in the SWIG root directory. Note that the Cygwin
environment will also allow one to regenerate the autotool generated
files which are supplied with the release distribution. These files are
generated using the ``autogen.sh`` script and will only need
regenerating in circumstances such as changing the build system.

Building swig.exe alternatives
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If you don't want to install Cygwin or MinGW, use a different compiler
to build SWIG. For example, all the source code files can be added to a
Visual C++ project file in order to build swig.exe from the Visual C++
IDE.

Running the examples on Windows using Cygwin
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The examples and test-suite work as successfully on Cygwin as on any
other Unix operating system. The modules which are known to work are
Python, Tcl, Perl, Ruby, Java and C#. Follow the Unix instructions in
the README file in the SWIG root directory to build the examples.

Microsoft extensions and other Windows quirks
-------------------------------------------------

A common problem when using SWIG on Windows are the Microsoft function
calling conventions which are not in the C++ standard. SWIG parses ISO
C/C++ so cannot deal with proprietary conventions such as
``__declspec(dllimport)``, ``__stdcall`` etc. There is a Windows
interface file, ``windows.i``, to deal with these calling conventions
though. The file also contains typemaps for handling commonly used
Windows specific types such as ``__int64``, ``BOOL``, ``DWORD`` etc.
Include it like you would any other interface file, for example:

.. container:: code

   ::

      %include <windows.i>

      __declspec(dllexport) ULONG __stdcall foo(DWORD, __int32);

Note that if you follow Microsoft's recommendation of wrapping the
``__declspec`` calls in a preprocessor definition, you will need to make
sure that the definition is included by SWIG as well, by either defining
it manually or via a header. For example, if you have specified the
preprocessor definition in a header named ``export_lib.h`` and include
other headers which depend on it, you should use the ``%include``
directive to include the definition explicitly. For example, if you had
a header file, ``bar.h``, which depended on ``export_lib.h``, your SWIG
definition file might look like:

.. container:: code

   ::

      // bar.i
      %module bar
      %include <windows.i>
      %include "export_lib.h"
      %include "bar.h"

where export_lib.h may contain:

.. container:: code

   ::

      // export_lib.h
      #define BAR_API __declspec(dllexport)

and bar.h may look like:

.. container:: code

   ::

      // bar.h
      #include "export_lib.h"
      BAR_API void bar_function(int, double);

Using the preprocessor to remove BAR_API is a popular simpler solution:

.. container:: code

   ::

      // bar.i
      %module bar
      #define BAR_API
      %include "bar.h"
