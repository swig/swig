/* -*-c-*- */

/* SWIG pointer structure */

#ifdef __cplusplus
extern "C" {
#endif

struct custom_block_contents {
    swig_type_info *type;
    void *object;
    char *delete_fn;
};

static void generic_delete_fn( value v ) {
    CAMLparam1(v);
    CAMLlocal1(x);
    struct custom_block_contents *new_proxy;
    value *deleter = NULL;

    new_proxy = (struct custom_block_contents *)(Data_custom_val(v));
    if( new_proxy->delete_fn ) 
	deleter = caml_named_value(new_proxy->delete_fn);
    if( *deleter ) 
	x = callback( *deleter, v );
    free( new_proxy->delete_fn );
    CAMLreturn0;
}

static struct custom_operations makeptr_custom_ops = {
    "SWIG-Wrapped Object",
    generic_delete_fn,
    custom_compare_default,
    custom_hash_default,
    custom_serialize_default,
    custom_deserialize_default
};

static value _wrap_delete_void( value v ) {
    CAMLparam0();
    CAMLreturn(Val_unit);
}

SWIGSTATIC value
SWIG_MakePtr(void *c_pointer, swig_type_info *type, 
	     char *delete_fn) {
    CAMLparam0();
    CAMLlocal1(v);
    struct custom_block_contents *new_proxy;

    v = alloc_custom(&makeptr_custom_ops,
		     sizeof( struct custom_block_contents ),0,1);
    new_proxy = (struct custom_block_contents *)(Data_custom_val(v));
    new_proxy->delete_fn = strdup( delete_fn );
    new_proxy->type = type;
    new_proxy->object = (void *) c_pointer;
    CAMLreturn(v);
}

SWIGSTATIC void *
SWIG_MustGetPtr (value s, swig_type_info *type)
{
    CAMLparam1(s);
    struct custom_block_contents *proxy = 
	(struct custom_block_contents *)(Data_custom_val(s));
    void *v = proxy->object;
    if( type && proxy->type ) {
	if( !SWIG_TypeDynamicCast(type,&v) ) {
	    static char staticbuf[1024];
	    snprintf( staticbuf, 1024, "Cound not cast %s to %s\n",
		      proxy->type->name, type->name );
	    failwith( staticbuf );
	}
    } 
    CAMLreturn(v);
}

#ifdef __cplusplus
}
#endif
