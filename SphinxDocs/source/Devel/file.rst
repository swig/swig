SWIG File Handling
==================

| David M. Beazley
| dave-swig@dabeaz.com
| December, 2006

Introduction
------------

This document describes the functions related to file and filename
handling in the SWIG core. These functions are defined in the header
file ``Source/Swig/swigfile.h``. This API is considered to be stable.

File Search Path
----------------

These functions manipulate the search path for locating files.

**``List *Swig_add_directory(const String_or_char *dirname)``**

   Adds a new directory to the system search path. The directory is
   appended to the end of the search path. Returns a list containing the
   current system search path.

**``void Swig_push_directory(const String_or_char *dirname)``**

   Pushes a temporary directory onto the search path. This directory is
   searched before directories added with ``Swig_add_directory()``
   except when including a system file explicitly (either using #include
   <file> or calling ``Swig_include_sys()``). This function is normally
   used by the preprocessor to add temporary directories when processing
   #include statements.

**``void Swig_pop_directory()``**

   Pops off the last pushed directory with ``Swig_push_directory()``

**``int Swig_get_push_dir()``**

   Returns a flag that indicates whether directory pushing is enabled or
   not.

**``void Swig_set_push_dir(int dopush)``**

   Enables or disables directory pushing. By default, it is turned on.
   However, the ``-I-`` command line option to SWIG disables it.

**``List *Swig_search_path()``**

   Returns the current search path.

File access functions
---------------------

**``FILE *Swig_open(const String_or_char *name)``**

   Opens a file, using the applicable search paths, and returns an open
   ``FILE *`` object if found. Returns NULL if the file is not found.

**``String *Swig_read_file(FILE *f)``**

   Reads all of the data from an open file into a string which is
   returned.

**``String *Swig_include(const String_or_char *name)``**

   Searches for an include file ``name`` and returns its contents as a
   string if found. Returns NULL if not found. All of the applicable
   search paths are searched when trying to locate the file.

**``String *Swig_include_sys(const String_or_char *name)``**

   Searches for an include file ``name`` and returns its contents as a
   string if found. Returns NULL if not found. All of the applicable
   search paths are searched when trying to locate the file, but
   preference is given to system paths first. This mimics the behavior
   of ``#include <file>`` in the preprocessor.

**``int Swig_insert_file(const String_or_char *name, File *outfile)``**

   Searches for a file ``name`` and dumps its contents to ``outfile`` if
   found. Returns 0 on success, -1 if the file couldn't be found.

Query functions
---------------

**``String *Swig_last_file()``**

   Returns the full pathname of the file last opened or included.

Named files
-----------

**``void *Swig_register_filebyname(const String_or_char *filename, File *outfile)``**

   Registers a file object ``outfile`` with a specific name
   ``filename``. This function is used to implement the SWIG %insert
   directive and to manage different sections of the output file such as
   "runtime","header","wrapper","init", etc. Different language modules
   may add their own sections for generating Python code, Perl code,
   etc.

**``File *Swig_filebyname(const String_or_char *filename)``**

   This looks up a file object previously registered using
   ``Swig_register_filebyname()``. This is used to implement the %insert
   directive.

Filename utilities
------------------

**``char *Swig_file_suffix(const String_or_char *filename)``**

   Returns the suffix of a filename. For instance, if the filename is
   "foo.txt", it returns ".txt".

**``char *Swig_file_basename(const String_or_char *filename)``**

   Returns the filename without the suffix attached to it. For instance,
   if the filename is "foo.txt", it returns "foo". The result is stored
   in a static variable. If you need to save it, make your own copy.

**``char *Swig_file_filename(const String_or_char *filename)``**

   Returns the filename without any leading directories. For instance,
   if the filename is "/bar/spam/foo.txt", it returns "foo.txt". This
   function is aware of local naming conventions on the machine (e.g.,
   forward versus back slashes on Unix and Windows). The result is
   stored in a static variable. If you need to save the value, make a
   copy.

**``char *Swig_file_dirname(const String_or_char *filename)``**

   Returns the directory name (if any). For instance, if the filename is
   "/bar/spam/foo.txt", it returns "/bar/spam/". This function is aware
   of local naming conventions on the machine (e.g., forward versus back
   slashes on Unix and Windows). The result is stored in a static
   variable. If you need to save the value, make a copy.

**``SWIG_FILE_DELIMITER``**

   This macro contains the file delimiter string for the local machine.
   On Unix it is "/", on Windows it is "\\".
