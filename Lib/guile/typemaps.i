/* typemaps.i --- guile-specific typemaps
   Copyright (C) 2000 Matthias Koeppe <mkoeppe@saturn.Math.Uni-Magdeburg.DE>

   $Header$  */

#define MK_SIMPLE_MAP(f) $target = f ($source)

#define SIMPLE_IN_MAP_SET(op)                                           \
%typemap (guile, op) bool           { MK_SIMPLE_MAP (gh_scm2bool); }    \
%typemap (guile, op) char           { MK_SIMPLE_MAP (gh_scm2char); }    \
%typemap (guile, op) int            { MK_SIMPLE_MAP (gh_scm2int); }     \
%typemap (guile, op) short          { MK_SIMPLE_MAP (gh_scm2int); }     \
%typemap (guile, op) long           { MK_SIMPLE_MAP (gh_scm2long); }    \
%typemap (guile, op) unsigned int   { MK_SIMPLE_MAP (gh_scm2ulong); }   \
%typemap (guile, op) unsigned short { MK_SIMPLE_MAP (gh_scm2ulong); }   \
%typemap (guile, op) unsigned long  { MK_SIMPLE_MAP (gh_scm2ulong); }   \
%typemap (guile, op) float          { MK_SIMPLE_MAP (gh_scm2double); }  \
%typemap (guile, op) double         { MK_SIMPLE_MAP (gh_scm2double); }  \
%typemap (guile, op) char *         { MK_SIMPLE_MAP (GSWIG_scm2str); }

#define SIMPLE_OUT_MAP_SET(op)                                          \
%typemap (guile, op) bool           { MK_SIMPLE_MAP (gh_bool2scm); }    \
%typemap (guile, op) char           { MK_SIMPLE_MAP (gh_char2scm); }    \
%typemap (guile, op) int            { MK_SIMPLE_MAP (gh_int2scm); }     \
%typemap (guile, op) short          { MK_SIMPLE_MAP (gh_int2scm); }     \
%typemap (guile, op) long           { MK_SIMPLE_MAP (gh_long2scm); }    \
%typemap (guile, op) unsigned int   { MK_SIMPLE_MAP (gh_ulong2scm); }   \
%typemap (guile, op) unsigned short { MK_SIMPLE_MAP (gh_ulong2scm); }   \
%typemap (guile, op) unsigned long  { MK_SIMPLE_MAP (gh_ulong2scm); }   \
%typemap (guile, op) float          { MK_SIMPLE_MAP (gh_double2scm); }  \
%typemap (guile, op) double         { MK_SIMPLE_MAP (gh_double2scm); }  \
%typemap (guile, op) char *         { MK_SIMPLE_MAP (gh_str02scm); }

/*
 * Declaration start here
 */

SIMPLE_IN_MAP_SET (in)
SIMPLE_IN_MAP_SET (varin)

SIMPLE_OUT_MAP_SET (out)
SIMPLE_OUT_MAP_SET (varout)

/* typemaps.i ends here */
