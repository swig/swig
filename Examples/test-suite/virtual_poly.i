%module virtual_poly


%inline %{  
  struct NNumber
  {
    virtual ~NNumber() {};
    virtual NNumber* copy() const = 0;
  };
  
  /* 
     NInt and NDouble are both NNumber derivated classes, but they
     have more different than common attributes.
     
     In particular the function 'get', that is type dependent, can't
     be included in the NNumber abstract interface.

     For this reason, the virtual 'copy' function has a polymorphic
     return type, since in most of the cases we don't want to lost the
     original object type, which is very very important.

     Using the polymorphic return type reduced greatly the need of
     using 'dynamic_cast' at the C++ side, and at the target languages
     that support it. Python is a target language that support
     this feature, Java and Csharp don't.
     
   */
  struct NInt : NNumber
  {
    NInt(int v) : val(v) 
    {
    }
    
    int get() const
    {
      return val;
    }
    
    virtual NInt* copy() const
    {
      return new NInt(val);
    }

  private:
    int val;
  };

  struct NDouble : NNumber
  {
    NDouble(double v) : val(v) 
    {
    }
    
    double get() const
    {
      return val;
    }
    
    virtual NDouble* copy() const
    {
      return new NDouble(val);
    }

  private:
    double val;
  };

  /*
     Java (and csharp) can not support the polymorphic return type for
     'copy'. So, it just emit 'plain' copy functions for all the cases:
    
      NNumber* NNumber::copy() const;
      NNumber* NInt::copy() const;  
      NNumber* NDouble::copy() const;
    
     In the last two cases, the original 'NInt' and 'NDouble' return
     types are lost in the target side. This seems to be a restriction
     of the language (strongly typed and 'by value' oriented), and
     there is not much that can be done to work it around.
    
     However, to improve the situation, and to be able to recover the
     original data types, we try adding 'dynamic_cast' interfaces in
     the target language sides. This is a natural mechanism since is
     exactly the same you will do in the C++ side if is needed.
  */
  inline NInt* NInt_dynamic_cast(NNumber* n) {
    return dynamic_cast<NInt*>(n);
  }  
  
  inline NDouble* NDouble_dynamic_cast(NNumber* n) {
    return dynamic_cast<NDouble*>(n);
  } 
  
  /*
     but they don't work either in Java (see the
     java/virtual_poly_runme.java file), because of the current way
     polymorphic types are wrapped. Using the wrapping method employed
     with directors (which are also polymorphic types) should allows
     to use the C++ dynamic_cast and recover the original types at the
     Java side.  And to do that, it is necessary to identify which
     classes are polymorphic (the "polymorphic" attribute does that)
     and apply the proper wrapping mechanism.
    
     The dynamic_cast interfaces added to this module, currently work
     great in languages like python, but in there the polymorphic
     return type also works, so, you are not forced to use them as a
     fixing mechanism (see the python/virtual_poly_runme.py file).
  */
%}
