/* -*- mode: c -*- */

%module swigrun

#ifdef SWIGGUILE_SCM

/* The runtime type system from common.swg */

typedef struct swig_type_info swig_type_info;

const char *
SWIG_TypeName(const swig_type_info *type);

const char *
SWIG_TypePrettyName(const swig_type_info *type);

swig_type_info *
SWIG_TypeQuery(const char *);

/* Language-specific stuff */

%apply bool { int };

int
SWIG_IsPointer(SCM object);

int
SWIG_IsPointerOfType(SCM object, swig_type_info *type);

unsigned long
SWIG_PointerAddress(SCM object);

swig_type_info *
SWIG_PointerType(SCM object);

#endif
