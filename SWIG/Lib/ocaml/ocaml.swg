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
#define C_director_core 17

/* Cast a pointer if possible; returns 1 if successful */
    
    SWIGSTATIC int
    SWIG_Cast (void *source, swig_type_info *source_type,
	       void **ptr, swig_type_info *dest_type)
    {
	if( !source ) { // Special case for NULL.  This is a popular question
	    // for other modules on the list, so I want an easy way out...
	    *ptr = 0;
	    return 0;
	}

#ifdef TYPE_CAST_VERBOSE
	fprintf( stderr, "Trying to cast %s to %s\n", 
		 source_type ? source_type->str : "<none>",
		 dest_type ? dest_type->str : "<none>" );
#endif
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
#ifdef TYPE_CAST_VERBOSE
		fprintf( stderr, "Typecheck -> %s\n",
			 tc ? tc->str : "<none>" );
#endif
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
	if (intype) {
	    return SWIG_Cast(inptr, intype,
			     outptr, outtype) == -1;
	} else {
	    *outptr = inptr;
	    return 0;
	}
    }

    SWIGSTATIC void caml_print_list( CAML_VALUE v );

    SWIGSTATIC void caml_print_val( CAML_VALUE v ) {
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
	{
	    void *vout = 0;
	    swig_type_info *ty = (swig_type_info *)(long)Int64_val(Field(v,1));
	    caml_ptr_val_internal(v,&vout,0);
	    fprintf( stderr, "PTR(%p,%s) ", 
		     vout,
		     ty ? ty->name : "(null)" );
	}
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
	{
	    void *cout;
	    caml_ptr_val_internal(v,&cout,0);
	    fprintf( stderr, "'%s' ", (char *)cout );
	} 
	break;
	}
    }

    SWIGSTATIC void caml_print_list( CAML_VALUE v ) {
	CAMLparam1(v);
	while( v && Is_block(v) ) {
	    fprintf( stderr, "[ " );
	    caml_print_val( Field(v,0) );
	    fprintf( stderr, "]\n" );
	    v = Field(v,1);
	}
    }

    SWIGSTATIC CAML_VALUE caml_list_nth( CAML_VALUE lst, int n ) {
	CAMLparam1(lst);
	int i = 0;
	while( i < n && lst && Is_block(lst) ) {
	    i++; lst = Field(lst,1);
	}
	if( lst == Val_unit ) CAMLreturn(Val_unit);
	else CAMLreturn(Field(lst,0));
    }
    
    SWIGSTATIC CAML_VALUE caml_list_append( CAML_VALUE lst, CAML_VALUE elt ) {
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

    SWIGSTATIC int caml_list_length( CAML_VALUE lst ) {
	CAMLparam1(lst);
	int i = 0;
	while( lst && Is_block(lst) ) { i++; lst = Field(lst,1); }
	CAMLreturn(i);
    }

    SWIGSTATIC void caml_array_set( CAML_VALUE arr, int n, CAML_VALUE item ) {
	CAMLparam2(arr,item);
	Store_field(Field(arr,0),n,item);
	CAMLreturn0;
    }

    SWIGSTATIC value caml_array_nth( CAML_VALUE arr, int n ) {
	CAMLparam1(arr);
	if( Tag_val(arr) == C_array )
	    CAMLreturn(Field(Field(arr,0),n));
	else if( Tag_val(arr) == C_list )
	    CAMLreturn(caml_list_nth(arr,0));
	else
	    failwith("Need array or list");
    }

    SWIGSTATIC int caml_array_len( CAML_VALUE arr ) {
	CAMLparam1(arr);
	if( Tag_val(arr) == C_array )
	    CAMLreturn(Wosize_val(Field(arr,0)));
	else if( Tag_val(arr) == C_list )
	    CAMLreturn(caml_list_length(arr));
	else
	    failwith("Need array or list");
    }

#ifdef __cplusplus
    namespace caml {
	extern "C"
#endif 
	    CAML_VALUE alloc(int,int);
#ifdef __cplusplus
    };
#endif

    SWIGSTATIC CAML_VALUE caml_swig_alloc(int x,int y) {
#ifdef __cplusplus
	using namespace caml;
#endif
	return alloc(x,y);
    }

    SWIGSTATIC value caml_array_new( int n ) {
	CAMLparam0();
	CAMLlocal1(vv);
	vv = caml_swig_alloc(1,C_array);
	Store_field(vv,0,alloc_tuple(n));
	CAMLreturn(vv);
    }
    
    SWIGSTATIC CAML_VALUE caml_val_bool( int b ) {
	CAMLparam0();
	CAMLlocal1(bv);
	bv = caml_swig_alloc(1,C_bool);
	Store_field(bv,0,Val_bool(b));
	CAMLreturn(bv);
    }

    SWIGSTATIC CAML_VALUE caml_val_char( char c ) {
	CAMLparam0();
	CAMLlocal1(cv);
	cv = caml_swig_alloc(1,C_char);
	Store_field(cv,0,Val_int(c));
	CAMLreturn(cv);
    }

    SWIGSTATIC CAML_VALUE caml_val_uchar( unsigned char uc ) {
	CAMLparam0();
	CAMLlocal1(ucv);
	ucv = caml_swig_alloc(1,C_uchar);
	Store_field(ucv,0,Val_int(uc));
	CAMLreturn(ucv);
    }

    SWIGSTATIC CAML_VALUE caml_val_short( short s ) {
	CAMLparam0();
	CAMLlocal1(sv);
	sv = caml_swig_alloc(1,C_short);
	Store_field(sv,0,Val_int(s));
	CAMLreturn(sv);
    }

    SWIGSTATIC CAML_VALUE caml_val_ushort( unsigned short us ) {
	CAMLparam0();
	CAMLlocal1(usv);
	usv = caml_swig_alloc(1,C_ushort);
	Store_field(usv,0,Val_int(us));
	CAMLreturn(usv);
    }

    SWIGSTATIC CAML_VALUE caml_val_int( int i ) {
	CAMLparam0();
	CAMLlocal1(iv);
	iv = caml_swig_alloc(1,C_int);
	Store_field(iv,0,Val_int(i));
	CAMLreturn(iv);
    }

    SWIGSTATIC CAML_VALUE caml_val_uint( unsigned int ui ) {
	CAMLparam0();
	CAMLlocal1(uiv);
	uiv = caml_swig_alloc(1,C_int);
	Store_field(uiv,0,Val_int(ui));
	CAMLreturn(uiv);
    }

    SWIGSTATIC CAML_VALUE caml_val_long( long l ) {
	CAMLparam0();
	CAMLlocal1(lv);
	lv = caml_swig_alloc(1,C_int64);
	Store_field(lv,0,copy_int64(l));
	CAMLreturn(lv);
    }

    SWIGSTATIC CAML_VALUE caml_val_ulong( unsigned long ul ) {
	CAMLparam0();
	CAMLlocal1(ulv);
	ulv = caml_swig_alloc(1,C_int64);
	Store_field(ulv,0,copy_int64(ul));
	CAMLreturn(ulv);
    }

    SWIGSTATIC CAML_VALUE caml_val_float( float f ) {
	CAMLparam0();
	CAMLlocal1(fv);
	fv = caml_swig_alloc(1,C_float);
	Store_field(fv,0,copy_double(f));
	CAMLreturn(fv);
    }

    SWIGSTATIC CAML_VALUE caml_val_double( double d ) {
	CAMLparam0();
	CAMLlocal1(fv);
	fv = caml_swig_alloc(1,C_double);
	Store_field(fv,0,copy_double(d));
	CAMLreturn(fv);
    }

    SWIGSTATIC CAML_VALUE caml_val_ptr( void *p, swig_type_info *info ) {
	CAMLparam0();
	CAMLlocal1(vv);
	vv = caml_swig_alloc(2,C_ptr);
	Store_field(vv,0,copy_int64((long)p));
	Store_field(vv,1,copy_int64((long)info));
	CAMLreturn(vv);
    }

    SWIGSTATIC CAML_VALUE caml_val_string( const char *p ) {
	CAMLparam0();
	CAMLlocal1(vv);
	if( !p ) CAMLreturn(caml_val_ptr( (void *)p, 0 ));
	vv = caml_swig_alloc(1,C_string);
	Store_field(vv,0,copy_string(p));
	CAMLreturn(vv);
    }

    SWIGSTATIC CAML_VALUE caml_val_string_len( const char *p, int len ) {
	CAMLparam0();
	CAMLlocal1(vv);
	if( !p || len < 0 ) CAMLreturn(caml_val_ptr( (void *)p, 0 ));
	vv = caml_swig_alloc(1,C_string);
	Store_field(vv,0,alloc_string(len));
	memcpy(String_val(Field(vv,0)),p,len);
	CAMLreturn(vv);
    }

    SWIGSTATIC CAML_VALUE caml_val_obj( void *v, char *object_type ) {
	CAMLparam0();
	CAMLreturn(callback2(*caml_named_value("caml_create_object_fn"),
			     caml_val_ptr(v,SWIG_TypeQuery(object_type)),
			     copy_string(object_type)));
    }

    SWIGSTATIC long caml_long_val_full( CAML_VALUE v, char *name ) {
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
	    CAML_VALUE *enum_to_int = caml_named_value(SWIG_MODULE "_enum_to_int");
	    if( !name ) failwith( "Not an enum conversion" );
	    ret = callback2(*enum_to_int,*caml_named_value(name),v);
	    CAMLreturn(caml_long_val(ret));
	}
	default:
	    failwith("No conversion to int");
	}
    }

    SWIGSTATIC long caml_long_val( CAML_VALUE v ) {
	return caml_long_val_full(v,0);
    }

    SWIGSTATIC double caml_double_val( CAML_VALUE v ) {
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

    SWIGSTATIC int caml_ptr_val_internal( CAML_VALUE v, void **out, 
					  swig_type_info *descriptor ) {
	CAMLparam1(v);
	void *outptr = NULL;
        swig_type_info *outdescr = NULL;

	if( v == Val_unit ) {
	    *out = 0;
	    CAMLreturn(0);
	}
	if( !Is_block(v) ) return -1;
	switch( Tag_val(v) ) {
	case C_int:
	    if( !caml_long_val( v ) ) {
		*out = 0;
		CAMLreturn(0);
	    } else {
		*out = 0;
		CAMLreturn(1);
	    }
	    break;
	case C_obj:
	    CAMLreturn
		(caml_ptr_val_internal
		 (callback(*caml_named_value("caml_obj_ptr"),v),
		  out,descriptor));
	case C_string:
	    outptr = (void *)String_val(Field(v,0));
	    break;
	case C_ptr:
	    outptr = (void *)(long)Int64_val(Field(v,0));
            outdescr = (swig_type_info *)(long)Int64_val(Field(v,1));
	    break;
	default:
	    *out = 0;
	    CAMLreturn(1);
	    break;
	}
	
	CAMLreturn(SWIG_GetPtr(outptr,out,outdescr,descriptor));
    }

    SWIGSTATIC void *caml_ptr_val( CAML_VALUE v, swig_type_info *descriptor ) {
	CAMLparam0();
#ifdef TYPE_CAST_VERBOSE
	caml_print_val( v );
#endif
	void *out = NULL;
	if( !caml_ptr_val_internal( v, &out, descriptor ) )
	    CAMLreturn(out);
	else
	    failwith( "No appropriate conversion found." );
    }

    SWIGSTATIC char *caml_string_val( CAML_VALUE v ) {
	return (char *)caml_ptr_val( v, 0 );
    }

    SWIGSTATIC int caml_bool_check( CAML_VALUE v ) {
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

    SWIGSTATIC int caml_int_check( CAML_VALUE v ) {
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

    SWIGSTATIC int caml_float_check( CAML_VALUE v ) {
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

    SWIGSTATIC int caml_ptr_check( CAML_VALUE v ) {
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
