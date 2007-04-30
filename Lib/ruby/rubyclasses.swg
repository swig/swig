#ifdef __cplusplus

/*
  GC_VALUE is used as a replacement of VALUE.
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

   or as a input/output value (not much use for this, thou):

     GC_VALUE func(GC_VALUE obj) { 
       GC_VALUE out = rb_obj_classname(obj);
       return out;
     }


   GC_VALUE is 'visible' at the wrapped side, so you can do:

      %template(RubyVector) std::vector<swig::GC_VALUE>;

   and all the proper typemaps will be used.
   
*/

namespace swig {
  %ignore GC_VALUE;
  struct GC_VALUE {};
  // %apply VALUE   {GC_VALUE};
  // %apply VALUE   const& {GC_VALUE const&};

  /* For output */
  %typemap(out,noblock=1)  GC_VALUE {
    $result = (VALUE  )$1;
  }
  
  %typemap(out,noblock=1)  GC_VALUE const & {
    $result = (VALUE  )*$1;
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
    }

    GC_VALUE(const GC_VALUE& item) : _obj(item._obj)
    {
      GC_register();
    }
    
    GC_VALUE(VALUE obj) :_obj(obj)
    {
      GC_register();
    }
    
    GC_VALUE & operator=(const GC_VALUE& item) 
    {
      GC_unregister();
      _obj = item._obj;
      GC_register();
      return *this;      
    }

    void GC_register()
    {
      if ( _obj != Qnil )
	rb_gc_register_address( &_obj );
    }

    void GC_unregister()
    {
      if ( _obj != Qnil )
	rb_gc_unregister_address( &_obj );
    }
    
    ~GC_VALUE() 
    {
      GC_unregister();
    }
    
    operator VALUE() const
    {
      return _obj;
    }

  };
}
%}


#endif
