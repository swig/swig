/* -----------------------------------------------------------------------------
 * carrays.i
 *
 * Author(s):  David Beazley (beazley@cs.uchicago.edu)
 *
 * This library file contains macros that can be used to manipulate simple
 * pointers as arrays.
 *
 * $Header$
 * ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
 * %array_functions(TYPE,NAME)
 *
 * Generates functions for creating and accessing elements of a C array
 * (as pointers).  Creates the following functions:
 *
 *        TYPE *new_NAME(int nelements, TYPE initvalue)
 *        void delete_NAME(TYPE *);
 *        TYPE NAME_getitem(TYPE *, int index);
 *        void NAME_setitem(TYPE *, int index, TYPE value);
 * 
 * ----------------------------------------------------------------------------- */

%define %array_functions(TYPE,NAME)
%{
static
TYPE *new_##NAME(int nelements, TYPE value) {
   TYPE *ary;
   int i;
#if __cplusplus
   ary = new TYPE[nelements];
#else
   ary = (TYPE *) malloc(sizeof(TYPE)*nelements);
#endif
   for (i = 0; i < nelements; i++) {
       ary[i] = value;
   }
   return ary;
}
static
void delete_##NAME(TYPE *ary) {
#if __cplusplus
    delete [] ary;
#else
    free(ary);
#endif
}

static
TYPE NAME##_getitem(TYPE *ary, int index) {
    return ary[index];
}
static
void NAME##_setitem(TYPE *ary, int index, TYPE value) {
    ary[index] = value;
}
%}

TYPE  *new_##NAME(int nelements, TYPE value=0);
void  delete_##NAME(TYPE *ary);
TYPE  NAME##_getitem(TYPE *ary, int index);
void  NAME##_setitem(TYPE *ary, int index, TYPE value);
%enddef


/* -----------------------------------------------------------------------------
 * %array_class(TYPE,NAME)
 *
 * Generates a class wrapper around a C array.  The class has the following
 * interface:
 *
 *          struct NAME {
 *              NAME(int nelements, TYPE value = 0);
 *             ~NAME();
 *              TYPE getitem(int index);
 *              void setitem(int index, TYPE value);
 *
 * ----------------------------------------------------------------------------- */

%define %array_class(TYPE,NAME)
%{
typedef TYPE NAME;
%}
typedef struct NAME {

    /* Put language specific enhancements here */

#if SWIGPYTHON
    %rename(__getitem__) getitem;
    %rename(__setitem__) setitem;
#endif

    %extend {
	NAME(int nelements, TYPE value=0) {
	    TYPE *self;
	    int   i;
#if __cplusplus
	    self = new TYPE[nelements];
#else
	    self = (TYPE *) malloc(sizeof(TYPE)*nelements);
#endif
	    for (i = 0; i < nelements; i++) {
		self[i] = value;
	    }
	    return self;
	}
	~NAME() {
#if __cplusplus
	    delete [] self;
#else
	    free(self);
#endif
	}
	TYPE getitem(int index) {
	    return self[index];
	}
	void setitem(int index, TYPE value) {
	    self[index] = value;
	}
	static NAME *FromPointer(TYPE *t) {
	    return (NAME *) t;
	}
    };
} NAME;
%types(NAME = TYPE);
%enddef
	    


    
     



