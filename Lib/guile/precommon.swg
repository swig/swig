/*************************************************************** -*- c -*-
 * guile/precommon.swg
 *
 * Rename all exported symbols from common.swg, to avoid symbol
 * clashes if multiple interpreters are included
 *
 ************************************************************************/

#define SWIG_TypeRegister    SWIG_Guile_TypeRegister
#define SWIG_TypeCheck       SWIG_Guile_TypeCheck
#define SWIG_TypeCast        SWIG_Guile_TypeCast
#define SWIG_TypeDynamicCast SWIG_Guile_TypeDynamicCast
#define SWIG_TypeName        SWIG_Guile_TypeName
#define SWIG_TypePrettyName  SWIG_Guile_TypePrettyName
#define SWIG_TypeQuery       SWIG_Guile_TypeQuery
#define SWIG_TypeClientData  SWIG_Guile_TypeClientData
#define SWIG_PackData        SWIG_Guile_PackData 
#define SWIG_UnpackData      SWIG_Guile_UnpackData 

