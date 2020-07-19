SWIG Parameter Handling
=======================

| David M. Beazley
| dave-swig@dabeaz.com
| January 9, 2007

Introduction
------------

This document describes the functions related to management of function
parameters and parameter lists in the SWIG core. These functions are
declared in ``Source/Swig/swigparm.h``. This API is considered to be
stable.

Parameters
----------

The following utility functions are used to create and copy individual
parameters. In their most basic form, a parameter merely contains a
type, a name, and an optional default value.

**``Parm *NewParm(SwigType *type, const String_or_char *name)``**

   Creates a new parameter object with type ``type`` and name ``name``.
   The type is stored in the attribute "type" and the name is stored in
   the attribute "name".

**``Parm *CopyParm(Parm *p)``**

   Copies a parameter object. All string attributes are copied in the
   process of making the copy. However, no complex attributes (lists,
   hashes, etc.) are copied.

Parameter Lists
---------------

**``ParmList *CopyParmList(ParmList *p)``**

   Creates a copy of a parameter list. A parameter list is merely a
   linked list of parameters created by NewParm().

**``ParmList *CopyParmListMax(ParmList *p, int count)``**

   Copies at most ``count`` parameters from the parameter list ``p``.

**``int ParmList_len(ParmList *p)``**

   Returns the total number of parameters in a parameter list.

**``int ParmList_numrequired(ParmList *p)``**

   Returns the number of required parameters in a parameter list. This
   pertains to invoking a function/method in C/C++.

**``int ParmList_has_defaultargs(ParmList *p)``**

   Returns 1 if the parameter list has any default arguments. Otherwise
   returns 0.

Code Generation Functions
-------------------------

**``String *ParmList_str(ParmList *p)``**

   Creates a C prototype string of the parameters, but without any
   default values.

**``String *ParmList_str_defaultargs(ParmList *p)``**

   Creates a C prototype string of the parameters and includes the
   default values (if any).

**``String *ParmList_protostr(ParmList *p)``**

   Creates a C prototype string of the parameters.
