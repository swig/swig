/*************************************************************** -*- c -*-
 * perl5/precommon.swg
 *
 * Rename all exported symbols from common.swg, to avoid symbol
 * clashes if multiple interpreters are included
 *
 ************************************************************************/

#define SWIG_TypeRegister    SWIG_Perl_TypeRegister
#define SWIG_TypeCheck       SWIG_Perl_TypeCheck
#define SWIG_TypeCast        SWIG_Perl_TypeCast
#define SWIG_TypeDynamicCast SWIG_Perl_TypeDynamicCast
#define SWIG_TypeName        SWIG_Perl_TypeName
#define SWIG_TypePrettyName  SWIG_Perl_TypePrettyName
#define SWIG_TypeQuery       SWIG_Perl_TypeQuery
#define SWIG_TypeClientData  SWIG_Perl_TypeClientData
#define SWIG_PackData        SWIG_Perl_PackData 
#define SWIG_UnpackData      SWIG_Perl_UnpackData 

