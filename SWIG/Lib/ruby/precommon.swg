/*************************************************************** -*- c -*-
 * ruby/precommon.swg
 *
 * Rename all exported symbols from common.swg, to avoid symbol
 * clashes if multiple interpreters are included
 *
 ************************************************************************/

#define SWIG_TypeRegister    SWIG_Ruby_TypeRegister
#define SWIG_TypeCheck       SWIG_Ruby_TypeCheck
#define SWIG_TypeCast        SWIG_Ruby_TypeCast
#define SWIG_TypeDynamicCast SWIG_Ruby_TypeDynamicCast
#define SWIG_TypeName        SWIG_Ruby_TypeName
#define SWIG_TypeQuery       SWIG_Ruby_TypeQuery
#define SWIG_TypeClientData  SWIG_Ruby_TypeClientData

