
/* Export the SWIG initialization function */
%header %{
#ifdef __cplusplus
extern "C"
#endif
#ifndef PERL_OBJECT
#ifndef MULTIPLICITY
SWIGEXPORT void SWIG_init (CV* cv);
#else
SWIGEXPORT void SWIG_init (pTHXo_ CV* cv);
#endif
#else
SWIGEXPORT void SWIG_init (CV *cv, CPerlObj *);
#endif
%}

/* Module initialization function */

%insert(init) "swiginit.swg"

%init %{

#ifdef __cplusplus
extern "C"
#endif

XS(SWIG_init) {
    dXSARGS;
    int i;

    SWIG_InitializeModule(0);

    /* Install constant */
    for (i = 0; swig_constants[i].type; i++) {
      SV *sv;
      sv = get_sv(swig_constants[i].name, TRUE | 0x2 | GV_ADDMULTI);
      switch(swig_constants[i].type) {
      case SWIG_INT:
	sv_setiv(sv, (IV) swig_constants[i].lvalue);
	break;
      case SWIG_FLOAT:
	sv_setnv(sv, (double) swig_constants[i].dvalue);
	break;
      case SWIG_STRING:
	sv_setpv(sv, (const char *) swig_constants[i].pvalue);
	break;
      case SWIG_POINTER:
	SWIG_MakePtr(sv, swig_constants[i].pvalue, *(swig_constants[i].ptype),0);
	break;
      case SWIG_BINARY:
	SWIG_MakePackedObj(sv, swig_constants[i].pvalue, swig_constants[i].lvalue, *(swig_constants[i].ptype));
	break;
      default:
	break;
      }
      SvREADONLY_on(sv);
    }
%}
