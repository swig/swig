/* -----------------------------------------------------------------------------
 * perl5.swg
 *
 * Perl 5 configuration file
 * ----------------------------------------------------------------------------- */

%runtime "common.swg"         // common type checking code
%runtime "perlrun.swg"        // Perl runtime functions

/* Typemaps for input parameters */

%typemap(in)  int, unsigned short, short, unsigned short, long, unsigned long, signed char, unsigned char, bool, enum SWIGTYPE
       "$1 = ($1_ltype) SvIV($input);";

%typemap(in)  char
       "$1 = ($1_ltype) *SvPV($input,PL_na);\n";

%typemap(in)  float, double 
       "$1 = ($1_ltype) SvNV($input);\n";

%typemap(in) char *
       "if (!SvOK((SV*) $input)) $1 = 0;
        else $1 = ($1_ltype) SvPV($input, PL_na);";

%typemap(in) SWIGTYPE *, SWIGTYPE [], SWIGTYPE & {
	if (SWIG_ConvertPtr($input, (void **) &$1, $1_descriptor) < 0) {
            croak("Type error in argument $argnum of $symname. Expected %s", $1_descriptor->name);
        }
}

%typemap(in) void * {
	if (SWIG_ConvertPtr($input, (void **) &$1, 0) < 0) {
            croak("Type error in argument $argnum of $symname. Expected %s", $1_descriptor->name);
        }
}

/* Object passed by value. Convert to a pointer */
%typemap(in) SWIGTYPE {
    $&1_ltype argp;
    if (SWIG_ConvertPtr($input,(void **) &argp, $&1_descriptor) < 0) {
           croak("Type error in argument $argnum of $symname. Expected %s", $&1_descriptor->name);	
    }
    $1 = *argp;
}

/* Typemap for output values */

%typemap(out) int, unsigned int, short, unsigned short, long, unsigned long, signed char, unsigned char, bool, enum SWIGTYPE 
    "ST(argvi) = sv_newmortal();
     sv_setiv(ST(argvi++), (IV) $1);";

%typemap(out) float, double
    "ST(argvi) = sv_newmortal();
     sv_setnv(ST(argvi++), (double) $1);";

%typemap(out) char 
    "ST(argvi) = sv_newmortal();
     sv_setpvn((SV*)ST(argvi++), &$1, 1);";

%typemap(out) char *
    "ST(argvi) = sv_newmortal();
     sv_setpv((SV*)ST(argvi++), (char *) $1);";

%typemap(out) SWIGTYPE *, SWIGTYPE [], SWIGTYPE & 
    "ST(argvi) = sv_newmortal();
     SWIG_MakePtr(ST(argvi++), (void *) $1, $1_descriptor);";

%typemap(out) SWIGTYPE 
#ifdef __cplusplus
{
  $&1_ltype resultobj = new $1_ltype($1);
  ST(argvi) = sv_newmortal();
  SWIG_MakePtr(ST(argvi++), (void *) resultobj, $&1_descriptor);
}
#else
{
  $&1_ltype resultobj = ($&1_ltype) malloc(sizeof($1_type));
  memmove(resultobj, &$1, sizeof($1_type));
  ST(argvi) = sv_newmortal();
  SWIG_MakePtr(ST(argvi++), (void *) resultobj, $&1_descriptor);
}
#endif

%typemap(out) void "";

/* Typemap for character array returns */

%typemap(out) char [ANY] 
     "ST(argvi) = sv_newmortal();
      sv_setpv((SV*)ST(argvi++),(char *) $1);";



