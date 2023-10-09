/* -----------------------------------------------------------------------------
 * carrays.i
 *
 * SWIG library file containing macros that can be used to manipulate simple
 * pointers as arrays.
 * ----------------------------------------------------------------------------- */

#ifndef __cplusplus
// C uses free/calloc/malloc
%include "swigfragments.swg"
%fragment("<stdlib.h>");
#endif

/* -----------------------------------------------------------------------------
 * %array_functions(TYPE,NAME)
 *
 * Generates functions for creating and accessing elements of a C array
 * (as pointers).  Creates the following functions:
 *
 *        TYPE *new_NAME(size_t nelements)
 *        void delete_NAME(TYPE *);
 *        TYPE NAME_getitem(TYPE *, size_t index);
 *        void NAME_setitem(TYPE *, size_t index, TYPE value);
 *
 * ----------------------------------------------------------------------------- */

%define %array_functions(TYPE,NAME)
%{
static TYPE *new_##NAME(size_t nelements) { %}
#ifdef __cplusplus
%{  return new TYPE[nelements](); %}
#else
%{  return (TYPE *) calloc(nelements,sizeof(TYPE)); %}
#endif
%{}

static void delete_##NAME(TYPE *ary) { %}
#ifdef __cplusplus
%{  delete [] ary; %}
#else
%{  free(ary); %}
#endif
%{}

static TYPE NAME##_getitem(TYPE *ary, size_t index) {
    return ary[index];
}
static void NAME##_setitem(TYPE *ary, size_t index, TYPE value) {
    ary[index] = value;
}
%}

TYPE *new_##NAME(size_t nelements);
void delete_##NAME(TYPE *ary);
TYPE NAME##_getitem(TYPE *ary, size_t index);
void NAME##_setitem(TYPE *ary, size_t index, TYPE value);

%enddef


/* -----------------------------------------------------------------------------
 * %array_class(TYPE,NAME)
 *
 * Generates a class wrapper around a C array.  The class has the following
 * interface:
 *
 *          struct NAME {
 *              NAME(size_t nelements);
 *             ~NAME();
 *              TYPE getitem(size_t index);
 *              void setitem(size_t index, TYPE value);
 *              TYPE * cast();
 *              static NAME *frompointer(TYPE *t);
 *          }
 *
 * ----------------------------------------------------------------------------- */

%define %array_class(TYPE,NAME)
%{
typedef TYPE NAME;
%}
typedef struct {
  /* Put language specific enhancements here */
} NAME;

%extend NAME {

#ifdef __cplusplus
NAME(size_t nelements) {
  return new TYPE[nelements]();
}
~NAME() {
  delete [] self;
}
#else
NAME(size_t nelements) {
  return (TYPE *) calloc(nelements,sizeof(TYPE));
}
~NAME() {
  free(self);
}
#endif

TYPE getitem(size_t index) {
  return self[index];
}
void setitem(size_t index, TYPE value) {
  self[index] = value;
}
TYPE * cast() {
  return self;
}
static NAME *frompointer(TYPE *t) {
  return (NAME *) t;
}

};

%types(NAME = TYPE);

%enddef

