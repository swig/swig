%module(directors="1") virtual_poly

//
// Check this example with directors wherever is possible.  Python and
// ruby work fine with and without directors. In theory, Java may
// start to work with directors, but this is not tested yet (my Java
// installation is broken).
//
//%feature("director");

%newobject *::copy();


%inline %{  
  struct NNumber
  {
    virtual ~NNumber() {};
    virtual NNumber* copy() const = 0;
    virtual NNumber& ref_this() 
    {
      return *this;
    }
    
    
    NNumber* nnumber() 
    {
      return this;
    }
    

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

    virtual NInt& ref_this() 
    {
      return *this;
    }

    /* See below */
    static NInt* narrow(NNumber* nn);

    
  private:
    int val;
  };

  inline NInt& incr(NInt& i) {
    i = i.get() + 1;
    return i;
  }

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

    virtual NDouble& ref_this() 
    {
      return *this;
    }

    /* See below */
    static NDouble* narrow(NNumber* nn);
    
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
    
     However, since the objects provide their own downcasting
     mechanim, the narrow methods similar to the CORBA mechanism,
     in theory you should be able to recover the original object
     types, just as you can do it in the C++ side or in other
     languages.
  */
  inline NInt* NInt::narrow(NNumber* n) {
    // this is just a plain C++ dynamic_cast, but in theory the user
    // could use whatever he wants.
    return dynamic_cast<NInt*>(n);
  }  
  
  inline NDouble* NDouble::narrow(NNumber* n) {
    return dynamic_cast<NDouble*>(n);
  }
  
  /*
     but the narrow methods don't work either in Java (see the
     java/virtual_poly_runme.java file), because of the current way
     polymorphic classes are wrapped, the user cannot downcast the
     Java temporary object when the C++ class (and associated Java
     class) is a base class in a class hierarchy.
    
     The 'narrow' methods work currently fine in languages like
     python, but in there the polymorphic return type also works, so,
     you are not forced to use them everytime (see the
     python/virtual_poly_runme.py file).
  */
%}
