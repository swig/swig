/* -*-c-*- */

/* SWIG pointer structure */

#ifdef __cplusplus
extern "C" {
#endif

#define C_bool 0
#define C_char 1
#define C_uchar 2
#define C_short 3
#define C_ushort 4
#define C_int 5
#define C_uint 6
#define C_int32 7
#define C_int64 8
#define C_float 9
#define C_double 10
#define C_ptr 11
#define C_array 12
#define C_list 13
#define C_obj 14
#define C_string 15
#define C_enum 16

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

/* Cast a pointer if possible; returns 1 if successful */
    
    static int
    SWIG_Cast (void *source, swig_type_info *source_type,
	       void **ptr, swig_type_info *dest_type)
    {
	if (dest_type != source_type) {
	    /* We have a type mismatch.  Will have to look through our type
	       mapping table to figure out whether or not we can accept this
	       datatype.  */
	    if( !dest_type || !source_type ) {
		*ptr = source;
		return 0;
	    } else {
		swig_type_info *tc = 
		    SWIG_TypeCheck( (char *)source_type->name, dest_type );
		if( tc ) {
		    *ptr = SWIG_TypeCast( tc, source );
		    return 0;
		} else
		    return -1;
	    }
	} else {
	    *ptr = source;
	    return 0;
	}
    }

/* Return 0 if successful. */
    SWIGSTATIC int
    SWIG_GetPtr(void *inptr, void **outptr, 
		swig_type_info *intype, swig_type_info *outtype) {
	CAMLparam0();
	if (intype) {
	    return !SWIG_Cast(inptr, intype,
			      outptr, outtype);
	} else {
	    *outptr = inptr;
	    return 0;
	}
    }

    static void caml_print_list( value v );

    static void caml_print_val( value v ) {
	switch( Tag_val(v) ) {
	case C_bool:
	    if( Bool_val(Field(v,0)) ) fprintf( stderr, "true " );
	    else fprintf( stderr, "false " );
	    break;
	case C_char:
	case C_uchar:
	    fprintf( stderr, "'%c' (\\%03d) ", 
		     (Int_val(Field(v,0)) >= ' ' &&
		      Int_val(Field(v,0)) < 127) ? Int_val(Field(v,0)) : '.',
		     Int_val(Field(v,0)) );
	    break;
	case C_short:
	case C_ushort:
	case C_int:
	    fprintf( stderr, "%d ", (int)caml_long_val(v) );
	    break;

	case C_uint:
	case C_int32:
	    fprintf( stderr, "%ud ", (unsigned int)caml_long_val(v) );
	    break;
	case C_int64:
	    fprintf( stderr, "%ld ", caml_long_val(v) );
	    break;
	case C_float:
	case C_double:
	    fprintf( stderr, "%f ", caml_double_val(v) );
	    break;

	case C_ptr:
	    fprintf( stderr, "PTR(%p) ", caml_ptr_val(v,0) );
	    break;
	case C_array:
	{
	    unsigned int i;
	    for( i = 0; i < Wosize_val( Field(v,0) ); i++ ) 
		caml_print_val( Field(Field(v,0),i) );
	}
	    break;
	case C_list:
	    caml_print_list( Field(v,0) );
	    break;
	case C_obj:
	    fprintf( stderr, "OBJ(%p) ", (void *)Field(v,0) );
	    break;
	case C_string:
	    fprintf( stderr, "'%s' ", (char *)caml_ptr_val(v,0) );
	    break;
	}
    }

    static void caml_print_list( value v ) {
	CAMLparam1(v);
	while( v && Is_block(v) ) {
	    fprintf( stderr, "[ " );
	    caml_print_val( Field(v,0) );
	    fprintf( stderr, "]\n" );
	    v = Field(v,1);
	}
    }

static value caml_list_nth( value lst, int n ) {
    CAMLparam1(lst);
    int i = 0;
    while( i < n && lst && Is_block(lst) ) {
	i++; lst = Field(lst,1);
    }
    if( lst == Val_unit ) CAMLreturn(Val_unit);
    else CAMLreturn(Field(lst,0));
}
    
static value caml_list_append( value lst, value elt ) {
    CAMLparam2(lst,elt);
    CAMLlocal3(v,vt,lh);
    lh = Val_unit;
    v = Val_unit;

    /* Appending C_void should have no effect */
    if( !Is_block(elt) ) return lst;

    while( lst && Is_block(lst) ) {
	if( v && v != Val_unit ) {
	    vt = alloc_tuple(2);
	    Store_field(v,1,vt);
	    v = vt;
	} else {
	    v = lh = alloc_tuple(2);
	}
	Store_field(v,0,Field(lst,0));
	lst = Field(lst,1);
    }

    if( v && Is_block(v) ) {
	vt = alloc_tuple(2);
	Store_field(v,1,vt);
	v = vt;
    } else {
	v = lh = alloc_tuple(2);
    }
    Store_field(v,0,elt);
    Store_field(v,1,Val_unit);

    CAMLreturn(lh);
}

static int caml_list_length( value lst ) {
    CAMLparam1(lst);
    int i = 0;
    while( lst && Is_block(lst) ) { i++; lst = Field(lst,1); }
    CAMLreturn(i);
}

#ifdef __cplusplus
    namespace caml {
	extern "C"
#endif 
	    value alloc(int,int);
#ifdef __cplusplus
    };
#endif

#ifdef __cplusplus
	extern "C"
#endif 
     value caml_swig_alloc(int x,int y) {
#ifdef __cplusplus
	using namespace caml;
#endif
	return alloc(x,y);
    }

    static value caml_val_bool( int b ) {
	CAMLparam0();
	CAMLlocal1(bv);
	bv = caml_swig_alloc(1,C_bool);
	Store_field(bv,0,Val_bool(b));
	CAMLreturn(bv);
    }

    static value caml_val_char( char c ) {
	CAMLparam0();
	CAMLlocal1(cv);
	cv = caml_swig_alloc(1,C_char);
	Store_field(cv,0,Val_int(c));
	CAMLreturn(cv);
    }

    static value caml_val_uchar( unsigned char uc ) {
	CAMLparam0();
	CAMLlocal1(ucv);
	ucv = caml_swig_alloc(1,C_uchar);
	Store_field(ucv,0,Val_int(uc));
	CAMLreturn(ucv);
    }

    static value caml_val_short( short s ) {
	CAMLparam0();
	CAMLlocal1(sv);
	sv = caml_swig_alloc(1,C_short);
	Store_field(sv,0,Val_int(s));
	CAMLreturn(sv);
    }

    static value caml_val_ushort( unsigned short us ) {
	CAMLparam0();
	CAMLlocal1(usv);
	usv = caml_swig_alloc(1,C_ushort);
	Store_field(usv,0,Val_int(us));
	CAMLreturn(usv);
    }

    static value caml_val_int( int i ) {
	CAMLparam0();
	CAMLlocal1(iv);
	iv = caml_swig_alloc(1,C_int);
	Store_field(iv,0,Val_int(i));
	CAMLreturn(iv);
    }

    static value caml_val_uint( unsigned int ui ) {
	CAMLparam0();
	CAMLlocal1(uiv);
	uiv = caml_swig_alloc(1,C_int);
	Store_field(uiv,0,Val_int(ui));
	CAMLreturn(uiv);
    }

    static value caml_val_long( long l ) {
	CAMLparam0();
	CAMLlocal1(lv);
	lv = caml_swig_alloc(1,C_int64);
	Store_field(lv,0,copy_int64(l));
	CAMLreturn(lv);
    }

    static value caml_val_ulong( unsigned long ul ) {
	CAMLparam0();
	CAMLlocal1(ulv);
	ulv = caml_swig_alloc(1,C_int64);
	Store_field(ulv,0,copy_int64(ul));
	CAMLreturn(ulv);
    }

    static value caml_val_float( float f ) {
	CAMLparam0();
	CAMLlocal1(fv);
	fv = caml_swig_alloc(1,C_float);
	Store_field(fv,0,copy_double(f));
	CAMLreturn(fv);
    }

    static value caml_val_double( double d ) {
	CAMLparam0();
	CAMLlocal1(fv);
	fv = caml_swig_alloc(1,C_double);
	Store_field(fv,0,copy_double(d));
	CAMLreturn(fv);
    }

    static value caml_val_ptr( void *p, swig_type_info *info ) {
	CAMLparam0();
	CAMLlocal1(vv);
	vv = caml_swig_alloc(2,C_ptr);
	Store_field(vv,0,copy_int64((long)p));
	Store_field(vv,1,copy_int64((long)info));
	CAMLreturn(vv);
    }

    static value caml_val_string( char *p ) {
	CAMLparam0();
	CAMLlocal1(vv);
	if( !p ) CAMLreturn(caml_val_ptr( (void *)p, 0 ));
	vv = caml_swig_alloc(1,C_string);
	Store_field(vv,0,copy_string(p));
	CAMLreturn(vv);
    }

    static value caml_val_string_len( char *p, int len ) {
	CAMLparam0();
	CAMLlocal1(vv);
	if( !p || len < 0 ) CAMLreturn(caml_val_ptr( (void *)p, 0 ));
	vv = caml_swig_alloc(1,C_string);
	Store_field(vv,0,alloc_string(len));
	memcpy(String_val(Field(vv,0)),p,len);
	CAMLreturn(vv);
    }

    static value caml_val_obj( void *v, char *object_type ) {
	CAMLparam0();
	CAMLreturn(callback2(*caml_named_value("caml_create_object_fn"),
			     caml_val_ptr(v,SWIG_TypeQuery(object_type)),
			     copy_string(object_type)));
    }

    static long caml_long_val_full( value v, char *name ) {
	CAMLparam1(v);
	if( !Is_block(v) ) return 0;

	switch( Tag_val(v) ) {
	case C_bool:
	case C_char:
	case C_uchar:
	case C_short:
	case C_ushort:
	case C_int:
	    CAMLreturn(Int_val(Field(v,0)));
	case C_uint:
	case C_int32:
	    CAMLreturn(Int32_val(Field(v,0)));
	case C_int64:
	    CAMLreturn((long)Int64_val(Field(v,0)));
	case C_float:
	case C_double:
	    CAMLreturn((long)Double_val(Field(v,0)));
	case C_string:
	    CAMLreturn((long)String_val(Field(v,0)));
	case C_ptr:
	    CAMLreturn((long)Int64_val(Field(Field(v,0),0)));
	case C_enum: {
	    CAMLlocal1(ret);
	    value *enum_to_int = caml_named_value(SWIG_MODULE "_enum_to_int");
	    if( !name ) failwith( "Not an enum conversion" );
	    ret = callback2(*enum_to_int,*caml_named_value(name),v);
	    CAMLreturn(caml_long_val(ret));
	}
	default:
	    failwith("No conversion to int");
	}
    }

    static long caml_long_val( value v ) {
	return caml_long_val_full(v,0);
    }

    static double caml_double_val( value v ) {
	CAMLparam1(v);
	if( !Is_block(v) ) return 0.0;
	switch( Tag_val(v) ) {
	case C_bool:
	case C_char:
	case C_uchar:
	case C_short:
	case C_ushort:
	case C_int:
	    CAMLreturn(Int_val(Field(v,0)));
	case C_uint:
	case C_int32:
	    CAMLreturn(Int32_val(Field(v,0)));
	case C_int64:
	    CAMLreturn(Int64_val(Field(v,0)));
	case C_float:
	case C_double:
	    CAMLreturn(Double_val(Field(v,0)));
	default:
	    fprintf( stderr, "Unknown block tag %d\n", Tag_val(v) );
	    failwith("No conversion to double");
	}
    }

    static int caml_ptr_val_internal( value v, void **out, 
				      swig_type_info *descriptor ) {
	CAMLparam1(v);
	void *outptr = NULL;
        swig_type_info *outdescr = NULL;

	if( !Is_block(v) ) return -1;
	switch( Tag_val(v) ) {
	case C_obj:
	    return caml_ptr_val_internal
		(callback(*caml_named_value("caml_obj_ptr"),v),out,descriptor);
	case C_string:
	    outptr = (void *)String_val(Field(v,0));
	    break;
	case C_ptr:
	    outptr = (void *)(long)Int64_val(Field(v,0));
            outdescr = (swig_type_info *)(long)Int64_val(Field(v,1));
	    break;
	default:
	    outptr = (void *)caml_long_val(v);
	    break;
	}
	
	CAMLreturn(SWIG_GetPtr(outptr,out,descriptor,outdescr));
    }

    static void *caml_ptr_val( value v, swig_type_info *descriptor ) {
	CAMLparam0();
	void *out = NULL;
	if( !caml_ptr_val_internal( v, &out, descriptor ) )
	    CAMLreturn(out);
	else
	    failwith( "No appropriate conversion found." );
    }

    static char *caml_string_val( value v ) {
	return (char *)caml_ptr_val( v, 0 );
    }

    static int caml_bool_check( value v ) {
	CAMLparam1(v);
	
	if( !Is_block(v) ) return 0;
	
	switch( Tag_val(v) ) {
	case C_bool:
	case C_ptr:
	case C_string:
	    CAMLreturn(1);
	default:
	    CAMLreturn(0);
	}
    }

    static int caml_int_check( value v ) {
	CAMLparam1(v);
	
	if( !Is_block(v) ) return 0;
	
	switch( Tag_val(v) ) {
	case C_char:
	case C_uchar:
	case C_short:
	case C_ushort:
	case C_int:
	case C_uint:
	case C_int32:
	case C_int64:
	    CAMLreturn(1);

	default:
	    CAMLreturn(0);
	}
    }

    static int caml_float_check( value v ) {
	CAMLparam1(v);
	if( !Is_block(v) ) return 0;

	switch( Tag_val(v) ) {
	case C_float:
	case C_double:
	    CAMLreturn(1);

	default:
	    CAMLreturn(0);
	}	
    }

    static int caml_ptr_check( value v ) {
	CAMLparam1(v);
	if( !Is_block(v) ) return 0;

	switch( Tag_val(v) ) {
	case C_string:
	case C_ptr:
	case C_int64:
	    CAMLreturn(1);

	default:
	    CAMLreturn(0);
	}	
    }

#ifdef __cplusplus
}
#endif
