#ifdef __cplusplus

/*
  GC_VALUE is used as a replacement of Ruby's VALUE.
  GC_VALUE automatically handles registering and unregistering
  of the underlying ruby object with the GC.

  It can be used if you want to create STL containers of VALUEs, such as:
  
     std::vector< GC_VALUE >;

  or as a member variable:
  
     struct A {
       GC_VALUE obj;
       A(VALUE o) : _obj(o) {
       }
     };

   or as a input/output value (not much use for this, as VALUE works as
   well here, thou):

     GC_VALUE func(GC_VALUE obj) { 
       GC_VALUE out = rb_obj_classname(obj);
       return out;
     }


   GC_VALUE is 'visible' at the wrapped side, so you can do:

      %template(RubyVector) std::vector<swig::GC_VALUE>;

   and all the proper typemaps will be used.
   
*/

namespace swig {

  %nodirector GC_VALUE;

  // We ignore the constructor so that user can never create a GC_VALUE manually
  %ignore GC_VALUE::GC_VALUE;

  struct GC_VALUE {
    VALUE inspect() const;
    VALUE to_s() const;
    GC_VALUE();
  protected:
    GC_VALUE( const GC_VALUE& );
    ~GC_VALUE();
  };

  %exception GC_VALUE {};


  %apply VALUE   {GC_VALUE};

  // Make sure this is the last typecheck done
  %typecheck(999999,noblock=1) GC_VALUE, GC_VALUE&, 
    const GC_VALUE& { $1 = 1; };

  /* For input */
  %typemap(in,noblock=1) GC_VALUE* (GC_VALUE r), GC_VALUE& (GC_VALUE r)  {
     r = $input; $1 = &r;
   }

  /* For output */
  %typemap(out,noblock=1)  GC_VALUE {
    $result = (VALUE)$1;
  }
  
  %typemap(out,noblock=1)  GC_VALUE*, GC_VALUE const & {
    $result = (VALUE)*$1;
  }

  %ignore LANGUAGE_OBJ;
  typedef GC_VALUE LANGUAGE_OBJ;
}

%{
namespace swig {
  class GC_VALUE {
  protected:
    VALUE  _obj;

  public:
    GC_VALUE() :_obj( Qnil )
    {
      GC_register();
    }

    GC_VALUE(const GC_VALUE& item) : _obj(item._obj)
    {
      GC_register();
    }
    
    GC_VALUE(VALUE obj) :_obj(obj)
    {
      GC_register();
    }
    
    ~GC_VALUE() 
    {
      GC_unregister();
    }
    
    GC_VALUE & operator=(const GC_VALUE& item) 
    {
      _obj = item._obj;
      return *this;      
    }

    void GC_register()
    {
      rb_gc_register_address( &_obj );
    }

    void GC_unregister()
    {
      rb_gc_unregister_address( &_obj );
    }
    
    operator VALUE() const
    {
      return _obj;
    }

    VALUE inspect() const
    {
      return rb_inspect(_obj);
    }

    VALUE to_s() const
    {
      return rb_inspect(_obj);
    }

  };

  typedef GC_VALUE LANGUAGE_OBJ;
}


/**
 * std::less< GC_VALUE > functor so that STL containers will accept
 * GC_VALUE.
 * 
 */

namespace std {
  template <>
  struct less< swig::GC_VALUE >: public binary_function< swig::GC_VALUE, 
							 swig::GC_VALUE, bool >
  {
    static ID  cmp_id;
    static ID hash_id;


    static VALUE swig_protect_funcall( VALUE p )
    {
      swig::GC_VALUE* args = (swig::GC_VALUE*) p;
      return rb_funcall(VALUE(args[0]), cmp_id, 1, VALUE(args[1]));
    }

    bool
    operator()( const swig::GC_VALUE& v, const swig::GC_VALUE& w ) const
    { 
      // SWIG_RUBY_THREAD_BEGIN_BLOCK;

      VALUE ret = Qnil;

      // First, try to compare using the <=> operator if present
      if ( rb_respond_to( v, cmp_id ) == Qtrue )
	{
	  int status;
	  swig::GC_VALUE args[] = { v, w };
	  ret = rb_protect( PROTECTFUNC(swig_protect_funcall), VALUE(args), 
			    &status );
	}

      bool res;
      // If that fails, try to use the two object's hash function to compare.
      if ( ret == Qnil ) {
	VALUE a = rb_funcall( VALUE(v), hash_id, 0 );
	VALUE b = rb_funcall( VALUE(w), hash_id, 0 );
	res = a < b;  // as shifted integers
      }
      else
	{
	  res = NUM2INT( ret ) < 0;
	}
      // SWIG_RUBY_THREAD_END_BLOCK;
      return res;
    }
  };

  ID less< swig::GC_VALUE >::cmp_id  = rb_intern("<=>");
  ID less< swig::GC_VALUE >::hash_id = rb_intern("hash");
}
%}


//
// Fragment that contains traits to properly deal with GC_VALUE.
// These functions may be invoked as a need of the from(), asval(),
// asptr() and as() template functors, usually used in %typemaps.
//
%fragment(SWIG_Traits_frag(swig::GC_VALUE),"header",fragment="StdTraits") {
namespace swig {
  template <>  struct traits<GC_VALUE > {
    typedef value_category category;
    static const char* type_name() { return "GC_VALUE"; }
  };
  
  template <>  struct traits_from<GC_VALUE> {
    typedef GC_VALUE value_type;
    static VALUE from(const value_type& val) {
      return static_cast<VALUE>(val);
    }
  };
  
  template <> 
  struct traits_check<GC_VALUE, value_category> {
    static bool check(GC_VALUE) {
      return true;
    }
  };
  
  template <>  struct traits_asval<GC_VALUE > {   
    typedef GC_VALUE value_type;
    static int asval(VALUE obj, value_type *val) {
      if (val) *val = obj;
      return SWIG_OK;
    }
  };
} // swig
} // %fragment(traits for swig::GC_VALUE)


#endif  // __cplusplus

