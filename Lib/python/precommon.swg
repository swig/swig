/*************************************************************** -*- c -*-
 * python/precommon.swg
 *
 * Rename all exported symbols from common.swg, to avoid symbol
 * clashes if multiple interpreters are included
 *
 ************************************************************************/

#define SWIG_TypeRegister    SWIG_Python_TypeRegister
#define SWIG_TypeCheck       SWIG_Python_TypeCheck
#define SWIG_TypeCast        SWIG_Python_TypeCast
#define SWIG_TypeDynamicCast SWIG_Python_TypeDynamicCast
#define SWIG_TypeName        SWIG_Python_TypeName
#define SWIG_TypePrettyName  SWIG_Python_TypePrettyName
#define SWIG_TypeQuery       SWIG_Python_TypeQuery
#define SWIG_TypeClientData  SWIG_Python_TypeClientData
#define SWIG_PackData        SWIG_Python_PackData 
#define SWIG_UnpackData      SWIG_Python_UnpackData 

