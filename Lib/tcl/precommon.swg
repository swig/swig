/*************************************************************** -*- c -*-
 * Tcl/precommon.swg
 *
 * Rename all exported symbols from common.swg, to avoid symbol
 * clashes if multiple interpreters are included
 *
 ************************************************************************/

#define SWIG_TypeRegister    SWIG_Tcl_TypeRegister
#define SWIG_TypeCheck       SWIG_Tcl_TypeCheck
#define SWIG_TypeCast        SWIG_Tcl_TypeCast
#define SWIG_TypeDynamicCast SWIG_Tcl_TypeDynamicCast
#define SWIG_TypeName        SWIG_Tcl_TypeName
#define SWIG_TypeQuery       SWIG_Tcl_TypeQuery
#define SWIG_TypeClientData  SWIG_Tcl_TypeClientData

