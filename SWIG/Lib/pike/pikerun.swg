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

#define SWIG_ConvertPtr SWIG_Pike_ConvertPtr
#define SWIG_NewPointerObj SWIG_Pike_NewPointerObj

/* Convert a pointer value */
static int
SWIG_Pike_ConvertPtr(struct object *obj, void **ptr, swig_type_info *ty, int flags) {
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
static struct object *
SWIG_Pike_NewPointerObj(void *ptr, swig_type_info *type, int own) {
    return 0;
}
