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

/* INPUT/OUTPUT/BOTH typemaps */

%typemap(guile,in) double *INPUT(double temp)
{
    temp = gh_scm2double($source);
    $target = &temp;
}

%typemap(guile,in) float  *INPUT(float temp)
{
    temp = (float) gh_scm2double($source);
    $target = &temp;
}

%typemap(guile,in) int            *INPUT(int temp)
{
    temp = (int) gh_scm2int($source);
    $target = &temp;
}

%typemap(guile,in) short          *INPUT(short temp)
{
    temp = (short) gh_scm2int($source);
    $target = &temp;
}

%typemap(guile,in) long           *INPUT(long temp)
{
    temp = (long) gh_scm2long($source);
    $target = &temp;
}

%typemap(guile,in) unsigned int   *INPUT(unsigned int temp)
{
    temp = (unsigned int) gh_scm2ulong($source);
    $target = &temp;
}

%typemap(guile,in) unsigned short *INPUT(unsigned short temp)
{
    temp = (unsigned short) gh_scm2ulong($source);
    $target = &temp;
}

%typemap(guile,in) unsigned long  *INPUT(unsigned long temp)
{
    temp = (unsigned long) gh_scm2ulong($source);
    $target = &temp;
}
%typemap(guile,in) unsigned char  *INPUT(unsigned char temp)
{
    temp = (unsigned char) gh_scm2char($source);
    $target = &temp;
}

%typemap(guile,ignore) int            *OUTPUT(int temp),
                       short          *OUTPUT(short temp),
                       long           *OUTPUT(long temp),
                       unsigned int   *OUTPUT(unsigned int temp),
                       unsigned short *OUTPUT(unsigned short temp),
                       unsigned long  *OUTPUT(unsigned long temp),
                       unsigned char  *OUTPUT(unsigned char temp),
                       float          *OUTPUT(float temp),
                       double         *OUTPUT(double temp)
{
    $target = &temp;
}

%typemap(guile,argout) int            *OUTPUT,
                       short          *OUTPUT
{
    GUILE_APPEND_RESULT(gh_int2scm(*$target));
}

%typemap(guile,argout) long           *OUTPUT
{
    GUILE_APPEND_RESULT(gh_long2scm(*$target));
}

%typemap(guile,argout) unsigned int   *OUTPUT,
		       unsigned short *OUTPUT,
		       unsigned long  *OUTPUT
{
    GUILE_APPEND_RESULT(gh_ulong2scm(*$target));
}

%typemap(guile,argout) unsigned char  *OUTPUT
{
    GUILE_APPEND_RESULT(gh_char2scm(*$target));
}

%typemap(guile,argout) float    *OUTPUT,
                       double   *OUTPUT
{
    GUILE_APPEND_RESULT(gh_double2scm(*$target));
}

%typemap(guile,in) int *BOTH = int *INPUT;
%typemap(guile,in) short *BOTH = short *INPUT;
%typemap(guile,in) long *BOTH = long *INPUT;
%typemap(guile,in) unsigned *BOTH = unsigned *INPUT;
%typemap(guile,in) unsigned short *BOTH = unsigned short *INPUT;
%typemap(guile,in) unsigned long *BOTH = unsigned long *INPUT;
%typemap(guile,in) unsigned char *BOTH = unsigned char *INPUT;
%typemap(guile,in) float *BOTH = float *INPUT;
%typemap(guile,in) double *BOTH = double *INPUT;

%typemap(guile,argout) int *BOTH = int *OUTPUT;
%typemap(guile,argout) short *BOTH = short *OUTPUT;
%typemap(guile,argout) long *BOTH = long *OUTPUT;
%typemap(guile,argout) unsigned *BOTH = unsigned *OUTPUT;
%typemap(guile,argout) unsigned short *BOTH = unsigned short *OUTPUT;
%typemap(guile,argout) unsigned long *BOTH = unsigned long *OUTPUT;
%typemap(guile,argout) unsigned char *BOTH = unsigned char *OUTPUT;
%typemap(guile,argout) float *BOTH = float *OUTPUT;
%typemap(guile,argout) double *BOTH = double *OUTPUT;

/* typemaps.i ends here */
