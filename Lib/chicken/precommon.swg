/*************************************************************** -*- c -*-
 * chicken/precommon.swg
 *
 * Rename all exported symbols from common.swg, to avoid symbol
 * clashes if multiple interpreters are included
 *
 ************************************************************************/

#define SWIG_TypeRegister    SWIG_Chicken_TypeRegister
#define SWIG_TypeCheck       SWIG_Chicken_TypeCheck
#define SWIG_TypeCast        SWIG_Chicken_TypeCast
#define SWIG_TypeDynamicCast SWIG_Chicken_TypeDynamicCast
#define SWIG_TypeName        SWIG_Chicken_TypeName
#define SWIG_TypePrettyName  SWIG_Chicken_TypePrettyName
#define SWIG_TypeQuery       SWIG_Chicken_TypeQuery
#define SWIG_TypeClientData  SWIG_Chicken_TypeClientData
#define SWIG_PackData        SWIG_Chicken_PackData 
#define SWIG_UnpackData      SWIG_Chicken_UnpackData 

