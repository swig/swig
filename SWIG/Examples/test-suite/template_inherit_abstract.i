%module template_inherit_abstract

%warnfilter(801) oss::test; /* Ruby, wrong class name */

%inline %{ 
 
  namespace oss 
  { 
      template <class C> 
      struct Wrap 
      { 
      }; 
 
      struct ModuleBase 
      { 
          virtual ~ModuleBase(); 
          virtual int get() = 0; 
      };      
    
      template <class C> 
      struct Module : C, ModuleBase 
      { 
        protected: 
        Module(); 
      }; 
      
      template <class  C> 
      struct HModule : Module<Wrap<C> > 
      { 
       //  virtual int get();   // declaration here works 
   
      protected: 
    HModule(); 
      }; 
  } 
 
  struct B 
  { 
  }; 
  
%}                                                 
  
namespace oss 
{ 
  %template(Wrap_B) Wrap<B>; 
  %template(Module_B) Module<Wrap<B> >; 
  %template(HModule_B) HModule<B>; 
} 
  
%inline %{ 
  namespace oss 
  { 
    struct test : HModule<B> 
    { 
    virtual int get();   // declaration here breaks swig 
    }; 
  } 
%}  
