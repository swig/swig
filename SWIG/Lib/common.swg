/***********************************************************************
 * common.swg
 *
 *     This file contains generic SWIG runtime support for pointer
 *     type checking as well as a few commonly used macros to control
 *     external linkage.
 *
 * Author : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (c) 1999-2000, The University of Chicago
 * 
 * This file may be freely redistributed without license or fee provided
 * this copyright message remains intact.
 ************************************************************************/


#if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#  if !defined(STATIC_LINKED)
#    define SWIGEXPORT(a) __declspec(dllexport) a
#  else
#    define SWIGEXPORT(a) a
#  endif
#else
#  define SWIGEXPORT(a) a
#endif

#ifdef __cplusplus
extern "C" {
#endif


/*************************************************************************/


/* The static type info list */

static swig_type_info *swig_type_list = 0;
static swig_type_info **swig_type_list_handle = &swig_type_list;
  

/* Register a type mapping with the type-checking */
static swig_type_info *
SWIG_TypeRegister(swig_type_info *ti) {
  return SWIG_TypeRegisterTL(swig_type_list_handle, ti);
}

/* Search for a swig_type_info structure */
static swig_type_info *
SWIG_TypeQuery(const char *name) {
  return SWIG_TypeQueryTL(*swig_type_list_handle, name);
}

/* Set the clientdata field for a type */
static void
SWIG_TypeClientData(swig_type_info *ti, void *clientdata) {
  SWIG_TypeClientDataTL(*swig_type_list_handle, ti, clientdata);
}

/* This function will propagate the clientdata field of type to
* any new swig_type_info structures that have been added into the list
* of equivalent types.  It is like calling
* SWIG_TypeClientData(type, clientdata) a second time.
*/
static void
SWIG_PropagateClientData(swig_type_info *type) {
  SWIG_PropagateClientDataTL(*swig_type_list_handle, type);
}

#ifdef __cplusplus
}
#endif
