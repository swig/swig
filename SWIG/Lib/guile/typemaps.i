/* typemaps.i --- INPUT/OUTPUT/BOTH typemaps
   Copyright (C) 2000 Matthias Koeppe <mkoeppe@saturn.Math.Uni-Magdeburg.DE>

   $Header$  */

%typemap(guile,out) double, float
{
    $target = gh_double2scm($source);
}

%typemap(guile,out) int, short
{
    $target = gh_int2scm($source);
}

%typemap(guile,out) long
{
    $target = gh_long2scm($source);
}

%typemap(guile,out) unsigned int, unsigned short, unsigned long
{
    $target = gh_ulong2scm($source);
}

%typemap(guile,out) unsigned char
{
    $target = gh_char2scm($source);
}

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
