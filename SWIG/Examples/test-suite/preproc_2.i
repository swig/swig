/* This SWIG -*- c -*- interface is to test for some strange
   preprocessor bug.

   I get syntax errors unless I remove the apostrophe in the comment
   or the sharp-sign substitution.  (The apostrophe seems to disable
   sharp-sign substitution.)
*/

%module preproc_2;

%define TYPEMAP_LIST_VECTOR_INPUT_OUTPUT(SCM_TYPE)

     /* Don't check for NULL pointers (override checks). */

     %typemap(argout, doc="($arg <vector of <" #SCM_TYPE ">>)") 
          int *VECTORLENOUTPUT
     {
     }

%enddef

TYPEMAP_LIST_VECTOR_INPUT_OUTPUT(boolean)
