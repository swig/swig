/* typemaps.i --- guile-specific typemaps
   Copyright (C) 2000 Matthias Koeppe <mkoeppe@saturn.Math.Uni-Magdeburg.DE>

   $Header$  */

#define MK_SIMPLE_MAP(f) $target = f ($source)

%typemap (guile, in) bool           { MK_SIMPLE_MAP (gh_scm2bool); }
%typemap (guile, in) char           { MK_SIMPLE_MAP (gh_scm2char); }
%typemap (guile, in) int            { MK_SIMPLE_MAP (gh_scm2int); }
%typemap (guile, in) short          { MK_SIMPLE_MAP (gh_scm2int); }
%typemap (guile, in) long           { MK_SIMPLE_MAP (gh_scm2long); }
%typemap (guile, in) unsigned int   { MK_SIMPLE_MAP (gh_scm2ulong); }
%typemap (guile, in) unsigned short { MK_SIMPLE_MAP (gh_scm2ulong); }
%typemap (guile, in) unsigned long  { MK_SIMPLE_MAP (gh_scm2ulong); }
%typemap (guile, in) float          { MK_SIMPLE_MAP (gh_scm2double); }
%typemap (guile, in) double         { MK_SIMPLE_MAP (gh_scm2double); }

%typemap (guile, out) bool           { MK_SIMPLE_MAP (gh_bool2scm); }
%typemap (guile, out) char           { MK_SIMPLE_MAP (gh_char2scm); }
%typemap (guile, out) int            { MK_SIMPLE_MAP (gh_int2scm); }
%typemap (guile, out) short          { MK_SIMPLE_MAP (gh_int2scm); }
%typemap (guile, out) long           { MK_SIMPLE_MAP (gh_long2scm); }
%typemap (guile, out) unsigned int   { MK_SIMPLE_MAP (gh_ulong2scm); }
%typemap (guile, out) unsigned short { MK_SIMPLE_MAP (gh_ulong2scm); }
%typemap (guile, out) unsigned long  { MK_SIMPLE_MAP (gh_ulong2scm); }
%typemap (guile, out) float          { MK_SIMPLE_MAP (gh_double2scm); }
%typemap (guile, out) double         { MK_SIMPLE_MAP (gh_double2scm); }

#undef MK_SIMPLE_MAP

/* typemaps.i ends here */
