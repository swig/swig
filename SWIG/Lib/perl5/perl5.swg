/* -----------------------------------------------------------------------------
 * perl5.swg
 *
 * Perl 5 configuration file
 * ----------------------------------------------------------------------------- */

%runtime "common.swg"         // common type checking code
%runtime "perlrun.swg"        // Perl runtime functions

/* Typemaps for input parameters */

%typemap(in)  int, unsigned int, unsigned short, short, unsigned short, long, unsigned long, signed char, unsigned char, bool, enum SWIGTYPE
       "$1 = ($1_ltype) SvIV($input);";

%typemap(in)  char
       "$1 = ($1_ltype) *SvPV($input,PL_na);\n";

%typemap(in)  float, double 
       "$1 = ($1_ltype) SvNV($input);\n";

%typemap(in)  long long "$1 = (long long) strtoll(SvPV($input, PL_na), 0, 0);";
%typemap(in)  long long "$1 = (unsigned long long) strtoull(SvPV($input, PL_na), 0, 0);";

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

%typemap(out) long long {
    char temp[256];
    sprintf(temp,"%lld", $1);
    ST(argvi) = sv_newmortal();
    sv_setpv((SV*)ST(argvi++), temp);
}

%typemap(out) unsigned long long {
    char temp[256];
    sprintf(temp,"%llu", $1);
    ST(argvi) = sv_newmortal();
    sv_setpv((SV*)ST(argvi++), temp);
}

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


/* Variable input */
%typemap(varin) char *
#ifdef __cplusplus
{
  char *_a = (char *) SvPV(sv,PL_na);
  if ($1) delete [] $1;
  $1 = new char[strlen(_a)+1];
  strcpy((char *)$1,_a);
}
#else
{
  char *_a = (char *) SvPV(sv,PL_na);
  if ($1) free((char *) $1);
  $1 = (char *) malloc(strlen(_a)+1);
  strcpy((char *)$1,_a);
}
#endif

%typemap(varin,warning="Setting const char * variable may leak memory") const char *
#ifdef __cplusplus
{
  char *_a = (char *) SvPV(sv,PL_na);
  $1 = new char[strlen(_a)+1];
  strcpy((char *)$1,_a);
}
#else
{
  char *_a = (char *) SvPV(sv,PL_na);
  $1 = (char *) malloc(strlen(_a)+1);
  strcpy((char *)$1,_a);
}
#endif

%typemap(varin) char [ANY]
     "strncpy($1, (char *) SvPV(sv,PL_na), $1_dim0);";

%typemap(varin) SWIGTYPE [] "croak(\"Value is read-only.\");";


/* --- Typemaps for variable output --- */

%typemap(varout) int, unsigned int, short, unsigned short, long, unsigned long, signed char, unsigned char, bool, enum SWIGTYPE 
    "sv_setiv($result, (IV) $1);";

%typemap(varout) float, double
    "sv_setnv($result, (double) $1);";

%typemap(varout) char 
    "sv_setpvn((SV *) $result, &$1, 1);";

%typemap(varout) long long {
  char temp[256];
  sprintf(temp,"%lld",$1);
  sv_setpv((SV *) $result, temp);
}

%typemap(varout) unsigned long long {
  char temp[256];
  sprintf(temp,"%llu",$1);
  sv_setpv((SV *) $result, temp);
}

%typemap(varout) char *, char [ANY]
    "sv_setpv((SV *) $result, $1);";

%typemap(varout) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] 
    "SWIG_MakePtr($result, (void *) $1, $1_descriptor);";

%typemap(varout) SWIGTYPE
    "SWIG_MakePtr($result, (void *) &$1, $&1_descriptor);";


/* --- Typemaps for constants --- *

/* --- Constants --- */

%typemap(consttab) int, unsigned int, short, unsigned short, long, unsigned long, unsigned char, signed char, bool, enum SWIGTYPE
       { SWIG_INT,     (char *) SWIG_prefix "$symname", (long) $value, 0, 0, 0}

%typemap(consttab) float, double
       { SWIG_FLOAT,   (char *) SWIG_prefix "$symname", 0, (double) $value, 0, 0}

%typemap(consttab) char, char *
       { SWIG_STRING,  (char *) SWIG_prefix "$symname", 0, 0, (void *)"$value", 0}

%typemap(consttab) long long, unsigned long long
       { SWIG_STRING, (char *) SWIG_prefix "$symname", 0, 0, (void *) "$value", 0}

%typemap(consttab) SWIGTYPE *, SWIGTYPE &, SWIGTYPE []
       { SWIG_POINTER, (char *) SWIG_prefix "$symname", 0, 0, (void *)$value, &$1_descriptor}

%typemap(consttab) SWIGTYPE (CLASS::*) 
       { SWIG_BINARY,  (char *) SWIG_prefix "$symname", sizeof($type), 0, (void *)&$value, &$1_descriptor}


/* ------------------------------------------------------------
 * ANSI C typemaps
 * ------------------------------------------------------------ */

%apply long { size_t };


/* Export the SWIG initialization function */
%header %{
#ifdef __cplusplus
extern "C"
#endif
#ifndef PERL_OBJECT
#ifndef MULTIPLICITY
SWIGEXPORT(void) SWIG_init (CV* cv);
#else
SWIGEXPORT(void) SWIG_init (pTHXo_ CV* cv);
#endif
#else
SWIGEXPORT(void) SWIG_init (CV *cv, CPerlObj *);
#endif
%}

/* Module initialization function */

%init %{
#ifdef __cplusplus
extern "C"
#endif

XS(SWIG_init) {
    dXSARGS;
    int i;
    for (i = 0; swig_types_initial[i]; i++) {
	 swig_types[i] = SWIG_TypeRegister(swig_types_initial[i]);
    }	

    /* Install commands */
    for (i = 0; swig_commands[i].name; i++) {
      newXS((char*) swig_commands[i].name,swig_commands[i].wrapper, (char*)__FILE__);
    }

    /* Install variables */
    for (i = 0; swig_variables[i].name; i++) {
      SV *sv;
      sv = perl_get_sv((char*) swig_variables[i].name, TRUE | 0x2);
      sv_setiv(sv, (IV) 0);
      swig_create_magic(sv, (char *) swig_variables[i].name, swig_variables[i].set, swig_variables[i].get);
    }

    /* Install constant */
    for (i = 0; swig_constants[i].type; i++) {
      SV *sv;
      sv = perl_get_sv((char*)swig_constants[i].name, TRUE | 0x2);
      switch(swig_constants[i].type) {
      case SWIG_INT:
	sv_setiv(sv, (IV) swig_constants[i].lvalue);
	break;
      case SWIG_FLOAT:
	sv_setnv(sv, (double) swig_constants[i].dvalue);
	break;
      case SWIG_STRING:
	sv_setpv(sv, (char *) swig_constants[i].pvalue);
	break;
      case SWIG_POINTER:
	SWIG_MakePtr(sv, swig_constants[i].pvalue, *(swig_constants[i].ptype));
	break;
      case SWIG_BINARY:
	/*      obj = SWIG_NewPackedObj(swig_constants[i].pvalue, swig_constants[i].lvalue, *(swig_constants[i].ptype)); */
	break;
      default:
	break;
      }
      SvREADONLY_on(sv);
    }
%}



