#include <escheme.h>

typedef struct swig_proxy {
    Scheme_Type type;
    void *object;
} swig_proxy;

static Scheme_Object *swig_make_c_pointer(void *c_pointer, char *type_name) {
    swig_proxy *new_proxy;
    new_proxy = (swig_proxy *) scheme_malloc(sizeof(swig_proxy));
    new_proxy->type = scheme_make_type(type_name);
    new_proxy->object = (void *) c_pointer;

    return (Scheme_Object *) new_proxy;
}

/* returns 1 on success, 0 otherwise */
static int swig_get_c_pointer(Scheme_Object *so, char *c_type, void **c_ptr) {
    Scheme_Type st = SCHEME_TYPE(so);
    char *type_name = scheme_get_type_name(st);
    int err = 1;
    if(strcmp(type_name, c_type))
	err = 0;
    else
	*c_ptr = ((swig_proxy *) so)->object;

    return err;
}

