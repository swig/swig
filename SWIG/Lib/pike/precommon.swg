/*************************************************************** -*- c -*-
 * pike/precommon.swg
 *
 * Rename all exported symbols from common.swg, to avoid symbol
 * clashes if multiple interpreters are included
 *
 ************************************************************************/

#define SWIG_TypeRegister    SWIG_Pike_TypeRegister
#define SWIG_TypeCheck       SWIG_Pike_TypeCheck
#define SWIG_TypeCast        SWIG_Pike_TypeCast
#define SWIG_TypeDynamicCast SWIG_Pike_TypeDynamicCast
#define SWIG_TypeName        SWIG_Pike_TypeName
#define SWIG_TypePrettyName  SWIG_Pike_TypePrettyName
#define SWIG_TypeQuery       SWIG_Pike_TypeQuery
#define SWIG_TypeClientData  SWIG_Pike_TypeClientData
#define SWIG_PackData        SWIG_Pike_PackData 
#define SWIG_UnpackData      SWIG_Pike_UnpackData 

