/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * typemaps.swg
 *
 * COM typemaps for input/output arguments
 * ----------------------------------------------------------------------------- */

/* INPUT typemaps */

%typemap(ctype) bool *INPUT, bool &INPUT                             "VARIANT_BOOL *"
%typemap(ctype) signed char *INPUT, signed char &INPUT               "signed char *"
%typemap(ctype) unsigned char *INPUT, unsigned char &INPUT           "unsigned char *"
%typemap(ctype) short *INPUT, short &INPUT                           "short *"
%typemap(ctype) unsigned short *INPUT, unsigned short &INPUT         "unsigned short *"
%typemap(ctype) int *INPUT, int &INPUT                               "int *"
%typemap(ctype) unsigned int *INPUT, unsigned int &INPUT             "unsigned int *"
%typemap(ctype) long *INPUT, long &INPUT                             "long *"
%typemap(ctype) unsigned long *INPUT, unsigned long &INPUT           "unsigned long *"
%typemap(ctype) long long *INPUT, long long &INPUT                   "long long *"
%typemap(ctype) unsigned long long *INPUT, unsigned long long &INPUT "unsigned long long *"
%typemap(ctype) float *INPUT, float &INPUT                           "float *"
%typemap(ctype) double *INPUT, double &INPUT                         "double *"

%typemap(comtype, attribute="in") bool *INPUT, bool &INPUT                             "VARIANT_BOOL *"
%typemap(comtype, attribute="in") signed char *INPUT, signed char &INPUT               "signed char *"
%typemap(comtype, attribute="in") unsigned char *INPUT, unsigned char &INPUT           "unsigned char *"
%typemap(comtype, attribute="in") short *INPUT, short &INPUT                           "short *"
%typemap(comtype, attribute="in") unsigned short *INPUT, unsigned short &INPUT         "unsigned short *"
%typemap(comtype, attribute="in") int *INPUT, int &INPUT                               "int *"
%typemap(comtype, attribute="in") unsigned int *INPUT, unsigned int &INPUT             "unsigned int *"
%typemap(comtype, attribute="in") long *INPUT, long &INPUT                             "long *"
%typemap(comtype, attribute="in") unsigned long *INPUT, unsigned long &INPUT           "unsigned long *"
%typemap(comtype, attribute="in") long long *INPUT, long long &INPUT                   "hyper *"
%typemap(comtype, attribute="in") unsigned long long *INPUT, unsigned long long &INPUT "unsigned hyper *"
%typemap(comtype, attribute="in") float *INPUT, float &INPUT                           "float *"
%typemap(comtype, attribute="in") double *INPUT, double &INPUT                         "double *"

%typemap(in) bool *INPUT ($*1_ltype temp), bool &INPUT ($*1_ltype temp)
%{ temp = *$input ? true : false; 
   $1 = &temp; %}

%typemap(in) signed char *INPUT, signed char &INPUT,
             unsigned char *INPUT, unsigned char &INPUT,
             short *INPUT, short &INPUT,
             unsigned short *INPUT, unsigned short &INPUT,
             int *INPUT, int &INPUT,
             unsigned int *INPUT, unsigned int &INPUT,
             long *INPUT, long &INPUT,
             unsigned long *INPUT, unsigned long &INPUT,
             long long *INPUT, long long &INPUT,
             unsigned long long *INPUT,  unsigned long long &INPUT,
             float *INPUT, float &INPUT,
             double *INPUT, double &INPUT
%{ $1 = ($1_ltype)&$input; %}

%typemap(freearg) bool *INPUT, bool &INPUT,
                  signed char *INPUT, signed char &INPUT,
                  unsigned char *INPUT, unsigned char &INPUT,
                  short *INPUT, short &INPUT,
                  unsigned short *INPUT, unsigned short &INPUT,
                  int *INPUT, int &INPUT,
                  unsigned int *INPUT, unsigned int &INPUT,
                  long *INPUT, long &INPUT,
                  unsigned long *INPUT, unsigned long &INPUT,
                  long long *INPUT, long long &INPUT,
                  unsigned long long *INPUT, unsigned long long &INPUT,
                  float *INPUT, float &INPUT,
                  double *INPUT, double &INPUT ""

%typemap(argout) bool *INPUT, bool &INPUT,
                 signed char *INPUT, signed char &INPUT,
                 unsigned char *INPUT, unsigned char &INPUT,
                 short *INPUT, short &INPUT,
                 unsigned short *INPUT, unsigned short &INPUT,
                 int *INPUT, int &INPUT,
                 unsigned int *INPUT, unsigned int &INPUT,
                 long *INPUT, long &INPUT,
                 unsigned long *INPUT, unsigned long &INPUT,
                 long long *INPUT, long long &INPUT,
                 unsigned long long *INPUT, unsigned long long &INPUT,
                 float *INPUT, float &INPUT,
                 double *INPUT, double &INPUT ""

/* OUTPUT typemaps */

%typemap(ctype) bool *OUTPUT, bool &OUTPUT                             "VARIANT_BOOL *"
%typemap(ctype) signed char *OUTPUT, signed char &OUTPUT               "signed char *"
%typemap(ctype) unsigned char *OUTPUT, unsigned char &OUTPUT           "unsigned char *"
%typemap(ctype) short *OUTPUT, short &OUTPUT                           "short *"
%typemap(ctype) unsigned short *OUTPUT, unsigned short &OUTPUT         "unsigned short *"
%typemap(ctype) int *OUTPUT, int &OUTPUT                               "int *"
%typemap(ctype) unsigned int *OUTPUT, unsigned int &OUTPUT             "unsigned int *"
%typemap(ctype) long *OUTPUT, long &OUTPUT                             "long *"
%typemap(ctype) unsigned long *OUTPUT, unsigned long &OUTPUT           "unsigned long *"
%typemap(ctype) long long *OUTPUT, long long &OUTPUT                   "long long *"
%typemap(ctype) unsigned long long *OUTPUT, unsigned long long &OUTPUT "unsigned long long *"
%typemap(ctype) float *OUTPUT, float &OUTPUT                           "float *"
%typemap(ctype) double *OUTPUT, double &OUTPUT                         "double *"

%typemap(comtype, attribute="out") bool *OUTPUT, bool &OUTPUT                             "VARIANT_BOOL *"
%typemap(comtype, attribute="out") signed char *OUTPUT, signed char &OUTPUT               "signed char *"
%typemap(comtype, attribute="out") unsigned char *OUTPUT, unsigned char &OUTPUT           "unsigned char *"
%typemap(comtype, attribute="out") short *OUTPUT, short &OUTPUT                           "short *"
%typemap(comtype, attribute="out") unsigned short *OUTPUT, unsigned short &OUTPUT         "unsigned short *"
%typemap(comtype, attribute="out") int *OUTPUT, int &OUTPUT                               "int *"
%typemap(comtype, attribute="out") unsigned int *OUTPUT, unsigned int &OUTPUT             "unsigned int *"
%typemap(comtype, attribute="out") long *OUTPUT, long &OUTPUT                             "long *"
%typemap(comtype, attribute="out") unsigned long *OUTPUT, unsigned long &OUTPUT           "unsigned long *"
%typemap(comtype, attribute="out") long long *OUTPUT, long long &OUTPUT                   "hyper *"
%typemap(comtype, attribute="out") unsigned long long *OUTPUT, unsigned long long &OUTPUT "unsigned hyper *"
%typemap(comtype, attribute="out") float *OUTPUT, float &OUTPUT                           "float *"
%typemap(comtype, attribute="out") double *OUTPUT, double &OUTPUT                         "double *"

%typemap(in) bool *OUTPUT ($*1_ltype temp), bool &OUTPUT ($*1_ltype temp)
%{ temp = *$input ? true : false; 
   $1 = &temp; %}

%typemap(in) signed char *OUTPUT, signed char &OUTPUT,
             unsigned char *OUTPUT, unsigned char &OUTPUT,
             short *OUTPUT, short &OUTPUT,
             unsigned short *OUTPUT, unsigned short &OUTPUT,
             int *OUTPUT, int &OUTPUT,
             unsigned int *OUTPUT, unsigned int &OUTPUT,
             long *OUTPUT, long &OUTPUT,
             unsigned long *OUTPUT, unsigned long &OUTPUT,
             long long *OUTPUT, long long &OUTPUT,
             unsigned long long *OUTPUT,  unsigned long long &OUTPUT,
             float *OUTPUT, float &OUTPUT,
             double *OUTPUT, double &OUTPUT
%{ $1 = ($1_ltype)&$input; %}

%typemap(freearg) bool *OUTPUT, bool &OUTPUT,
                  signed char *OUTPUT, signed char &OUTPUT,
                  unsigned char *OUTPUT, unsigned char &OUTPUT,
                  short *OUTPUT, short &OUTPUT,
                  unsigned short *OUTPUT, unsigned short &OUTPUT,
                  int *OUTPUT, int &OUTPUT,
                  unsigned int *OUTPUT, unsigned int &OUTPUT,
                  long *OUTPUT, long &OUTPUT,
                  unsigned long *OUTPUT, unsigned long &OUTPUT,
                  long long *OUTPUT, long long &OUTPUT,
                  unsigned long long *OUTPUT, unsigned long long &OUTPUT,
                  float *OUTPUT, float &OUTPUT,
                  double *OUTPUT, double &OUTPUT ""

%typemap(argout) bool *OUTPUT, bool &OUTPUT
%{ *$input = temp$argnum ? VARIANT_TRUE : VARIANT_FALSE; %}

%typemap(argout) signed char *OUTPUT, signed char &OUTPUT,
                 unsigned char *OUTPUT, unsigned char &OUTPUT,
                 short *OUTPUT, short &OUTPUT,
                 unsigned short *OUTPUT, unsigned short &OUTPUT,
                 int *OUTPUT, int &OUTPUT,
                 unsigned int *OUTPUT, unsigned int &OUTPUT,
                 long *OUTPUT, long &OUTPUT,
                 unsigned long *OUTPUT, unsigned long &OUTPUT,
                 long long *OUTPUT, long long &OUTPUT,
                 unsigned long long *OUTPUT, unsigned long long &OUTPUT,
                 float *OUTPUT, float &OUTPUT,
                 double *OUTPUT, double &OUTPUT ""

/* INOUT typemaps */

%typemap(ctype) bool *INOUT, bool &INOUT                             "VARIANT_BOOL *"
%typemap(ctype) signed char *INOUT, signed char &INOUT               "signed char *"
%typemap(ctype) unsigned char *INOUT, unsigned char &INOUT           "unsigned char *"
%typemap(ctype) short *INOUT, short &INOUT                           "short *"
%typemap(ctype) unsigned short *INOUT, unsigned short &INOUT         "unsigned short *"
%typemap(ctype) int *INOUT, int &INOUT                               "int *"
%typemap(ctype) unsigned int *INOUT, unsigned int &INOUT             "unsigned int *"
%typemap(ctype) long *INOUT, long &INOUT                             "long *"
%typemap(ctype) unsigned long *INOUT, unsigned long &INOUT           "unsigned long *"
%typemap(ctype) long long *INOUT, long long &INOUT                   "long long *"
%typemap(ctype) unsigned long long *INOUT, unsigned long long &INOUT "unsigned long long *"
%typemap(ctype) float *INOUT, float &INOUT                           "float *"
%typemap(ctype) double *INOUT, double &INOUT                         "double *"

%typemap(comtype, attribute="in, out") bool *INOUT, bool &INOUT                             "VARIANT_BOOL *"
%typemap(comtype, attribute="in, out") signed char *INOUT, signed char &INOUT               "signed char *"
%typemap(comtype, attribute="in, out") unsigned char *INOUT, unsigned char &INOUT           "unsigned char *"
%typemap(comtype, attribute="in, out") short *INOUT, short &INOUT                           "short *"
%typemap(comtype, attribute="in, out") unsigned short *INOUT, unsigned short &INOUT         "unsigned short *"
%typemap(comtype, attribute="in, out") int *INOUT, int &INOUT                               "int *"
%typemap(comtype, attribute="in, out") unsigned int *INOUT, unsigned int &INOUT             "unsigned int *"
%typemap(comtype, attribute="in, out") long *INOUT, long &INOUT                             "long *"
%typemap(comtype, attribute="in, out") unsigned long *INOUT, unsigned long &INOUT           "unsigned long *"
%typemap(comtype, attribute="in, out") long long *INOUT, long long &INOUT                   "hyper *"
%typemap(comtype, attribute="in, out") unsigned long long *INOUT, unsigned long long &INOUT "unsigned hyper *"
%typemap(comtype, attribute="in, out") float *INOUT, float &INOUT                           "float *"
%typemap(comtype, attribute="in, out") double *INOUT, double &INOUT                         "double *"

%typemap(in) bool *INOUT ($*1_ltype temp), bool &INOUT ($*1_ltype temp)
%{ temp = *$input ? true : false; 
   $1 = &temp; %}

%typemap(in) signed char *INOUT, signed char &INOUT,
             unsigned char *INOUT, unsigned char &INOUT,
             short *INOUT, short &INOUT,
             unsigned short *INOUT, unsigned short &INOUT,
             int *INOUT, int &INOUT,
             unsigned int *INOUT, unsigned int &INOUT,
             long *INOUT, long &INOUT,
             unsigned long *INOUT, unsigned long &INOUT,
             long long *INOUT, long long &INOUT,
             unsigned long long *INOUT,  unsigned long long &INOUT,
             float *INOUT, float &INOUT,
             double *INOUT, double &INOUT
%{ $1 = ($1_ltype)&$input; %}

%typemap(freearg) bool *INOUT, bool &INOUT,
                  signed char *INOUT, signed char &INOUT,
                  unsigned char *INOUT, unsigned char &INOUT,
                  short *INOUT, short &INOUT,
                  unsigned short *INOUT, unsigned short &INOUT,
                  int *INOUT, int &INOUT,
                  unsigned int *INOUT, unsigned int &INOUT,
                  long *INOUT, long &INOUT,
                  unsigned long *INOUT, unsigned long &INOUT,
                  long long *INOUT, long long &INOUT,
                  unsigned long long *INOUT, unsigned long long &INOUT,
                  float *INOUT, float &INOUT,
                  double *INOUT, double &INOUT ""

%typemap(argout) bool *INOUT, bool &INOUT
%{ *$input = temp$argnum ? VARIANT_TRUE : VARIANT_FALSE; %}

%typemap(argout) signed char *INOUT, signed char &INOUT,
                 unsigned char *INOUT, unsigned char &INOUT,
                 short *INOUT, short &INOUT,
                 unsigned short *INOUT, unsigned short &INOUT,
                 int *INOUT, int &INOUT,
                 unsigned int *INOUT, unsigned int &INOUT,
                 long *INOUT, long &INOUT,
                 unsigned long *INOUT, unsigned long &INOUT,
                 long long *INOUT, long long &INOUT,
                 unsigned long long *INOUT, unsigned long long &INOUT,
                 float *INOUT, float &INOUT,
                 double *INOUT, double &INOUT ""

