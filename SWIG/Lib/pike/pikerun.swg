/***********************************************************************
 * pikerun.swg
 *
 *     This file contains the runtime support for Pike modules
 *     and includes code for managing global variables and pointer
 *     type checking.
 *
 * Author : Lyle Johnson (lyle@users.sourceforge.net)
 ************************************************************************/

#ifdef __cplusplus
extern "C" {
#endif
#include "object.h"
#include "program.h"
#ifdef __cplusplus
}
#endif

/* Stores information about a wrapped object */
typedef struct swig_object_wrapper {
    void *self;
} swig_object_wrapper;

#ifdef THIS
#undef THIS
#endif
#define THIS (((swig_object_wrapper *) Pike_fp->current_storage)->self)

#ifdef SWIG_NOINCLUDE

SWIGEXPORT(int)               SWIG_ConvertPtr(struct object *, void **, swig_type_info *, int);
SWIGEXPORT(struct object *)   SWIG_NewPointerObj(void *, swig_type_info *, int);

#else

/* Convert a pointer value */
SWIGRUNTIME(int)
SWIG_ConvertPtr(struct object *obj, void **ptr, swig_type_info *ty, int flags) {
    char *storage;
    struct program *pr;
    if (ty) {
        pr = (struct program *) ty->clientdata;
        storage = get_storage(obj, pr);
        if (storage) {
            *ptr = ((swig_object_wrapper *) storage)->self;
	    return 0;
        }
    }
    return -1;
}

/* Create a new pointer object */
SWIGRUNTIME(struct object *)
SWIG_NewPointerObj(void *ptr, swig_type_info *type, int own) {
    return 0;
}

#endif
