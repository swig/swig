/* -----------------------------------------------------------------------------
 * cdata.i
 *
 * Author(s):  David Beazley (beazley@cs.uchicago.edu)
 *
 * This library file contains macros for manipulating raw C data as strings.
 *
 * $Header$
 * ----------------------------------------------------------------------------- */

%{
typedef struct SWIGCDATA {
    char *data;
    int   len;
} SWIGCDATA;
%}

/* -----------------------------------------------------------------------------
 * Typemaps for returning binary data
 * ----------------------------------------------------------------------------- */

#if SWIGPYTHON
%typemap(out) SWIGCDATA {
   $result = PyString_FromStringAndSize($1.data,$1.len);
}
%typemap(in) (const void *indata, int inlen) {
   $1 = (void *) PyString_AsString($input);
   $2 = PyString_Size($input);
}
#elif SWIGPERL
%typemap(out) SWIGCDATA {
   ST(argvi) = sv_newmortal();
   sv_setpvn((SV*)ST(argvi++),$1.data,$1.len);
}
%typemap(in) (const void *indata, int inlen) {
   unsigned int temp;
   $1 = (void *) SvPV($input,temp);
   $2 = temp;
}
#elif SWIGTCL
%typemap(out) SWIGCDATA {
   Tcl_SetObjResult(interp,Tcl_NewStringObj($1.data,$1.len));
}
%typemap(in) (const void *indata, int inlen) {
   $1 = (void *) Tcl_GetStringFromObj($input,&$2);
}
#elif SWIGRUBY
%typemap(out) SWIGCDATA {
   $result = rb_str_new($1.data,$1.len);
}
%typemap(in) (const void *indata, int inlen) {
   $1 = (void *) rb_str2cstr($input,&$2);
}
#else
%echo "cdata.i module not supported."
#endif


/* -----------------------------------------------------------------------------
 * %cdata(TYPE [, NAME]) 
 *
 * Convert raw C data to a binary string.
 * ----------------------------------------------------------------------------- */

%define %cdata(TYPE,...)

%insert("header") {
#if #__VA_ARGS__ == ""
static SWIGCDATA cdata_##TYPE(TYPE *ptr, int nelements) {
#else
static SWIGCDATA cdata_##__VA_ARGS__(TYPE *ptr, int nelements) {
#endif
   SWIGCDATA d;
   d.data = (char *) ptr;
#if #TYPE != "void"
   d.len  = nelements*sizeof(TYPE);
#else
   d.len  = nelements;
#endif
   return d;
}
}
#if #__VA_ARGS__ == ""
SWIGCDATA cdata_##TYPE(TYPE *ptr, int nelements = 1);
#else
SWIGCDATA cdata_##__VA_ARGS__(TYPE *ptr, int nelements = 1);
#endif
%enddef

%name(cdata)
%cdata(void);

/* Memory move function */
void memmove(void *data, const void *indata, int inlen);




