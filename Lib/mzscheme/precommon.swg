/*************************************************************** -*- c -*-
 * mzscheme/precommon.swg
 *
 * Rename all exported symbols from common.swg, to avoid symbol
 * clashes if multiple interpreters are included
 *
 ************************************************************************/

#define SWIG_TypeRegister    SWIG_MzScheme_TypeRegister
#define SWIG_TypeCheck       SWIG_MzScheme_TypeCheck
#define SWIG_TypeCast        SWIG_MzScheme_TypeCast
#define SWIG_TypeDynamicCast SWIG_MzScheme_TypeDynamicCast
#define SWIG_TypeName        SWIG_MzScheme_TypeName
#define SWIG_TypePrettyName  SWIG_MzScheme_TypePrettyName
#define SWIG_TypeQuery       SWIG_MzScheme_TypeQuery
#define SWIG_TypeClientData  SWIG_MzScheme_TypeClientData
#define SWIG_PackData        SWIG_MzScheme_PackData 
#define SWIG_UnpackData      SWIG_MzScheme_UnpackData 

