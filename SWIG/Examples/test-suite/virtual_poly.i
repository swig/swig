%module(directors="1") virtual_poly

%warnfilter(822, 842) copy; /* Java, C# covariant return types */
%warnfilter(822, 842) ref_this; /* Java, C# covariant return types */

//
// Check this example with directors wherever possible.
//
//%feature("director");

// This shouldn't get used.
// %newobject *::copy();

%newobject *::copy() const;


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
     NInt and NDouble are both NNumber derived classes, but they
     have more different than common attributes.
     
     In particular the function 'get', that is type dependent, can't
     be included in the NNumber abstract interface.

     For this reason, the virtual 'copy' method has a polymorphic (covariant)
     return type, since in most of the cases we don't want to lose the
     original object type, which is very very important.

     Using the polymorphic return type reduced greatly the need of
     using 'dynamic_cast' at the C++ side, and at the target languages
     that support it.
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
     Java and C# do not support the polymorphic (covariant) return types used
     in the copy method. So, they just emit 'plain' copy functions as if this is
     being wrapped instead:
    
      NNumber* NNumber::copy() const;
      NNumber* NInt::copy() const;  
      NNumber* NDouble::copy() const;
    
     However, since the objects provide their own downcasting
     mechanism, the narrow methods similar to the CORBA mechanism,
     could be used, otherwise use the Java/C# downcasts.
  */
  inline NInt* NInt::narrow(NNumber* n) {
    // this is just a plain C++ dynamic_cast, but in theory the user
    // could use whatever he wants.
    return dynamic_cast<NInt*>(n);
  }  
  
  inline NDouble* NDouble::narrow(NNumber* n) {
    return dynamic_cast<NDouble*>(n);
  }
%}
