/*************************************************************** -*- c -*-
 * php4/precommon.swg
 *
 * Rename all exported symbols from common.swg, to avoid symbol
 * clashes if multiple interpreters are included
 *
 ************************************************************************/

#define SWIG_TypeRegister    SWIG_PHP4_TypeRegister
#define SWIG_TypeCheck       SWIG_PHP4_TypeCheck
#define SWIG_TypeCast        SWIG_PHP4_TypeCast
#define SWIG_TypeDynamicCast SWIG_PHP4_TypeDynamicCast
#define SWIG_TypeName        SWIG_PHP4_TypeName
#define SWIG_TypeQuery       SWIG_PHP4_TypeQuery
#define SWIG_TypeClientData  SWIG_PHP4_TypeClientData

