#include <escheme.h>

typedef struct swig_proxy {
    Scheme_Type type;
    void *object;
} swig_proxy;

Scheme_Object *swig_make_c_pointer(void *, char*);
void *swig_get_c_pointer(Scheme_Object *, char *);

Scheme_Object *swig_make_c_pointer(void *c_pointer, char *type_name) {
    swig_proxy *new_proxy;
    new_proxy = (swig_proxy *) scheme_malloc(sizeof(swig_proxy));
    new_proxy->type = scheme_make_type(type_name);
    new_proxy->object = (void *) c_pointer;

    return (Scheme_Object *) new_proxy;
}

void *swig_get_c_pointer(Scheme_Object *so, char *c_type) {
    Scheme_Type st = SCHEME_TYPE(so);
    char *type_name = scheme_get_type_name(st);
    if(strcmp(type_name, c_type))
    scheme_signal_error("wrong type in foreign object %s", type_name);

    return (void *) ((swig_proxy *) so)->object;
}
