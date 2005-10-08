%module(ruby_minherit="1") template_inherit_abstract

%warnfilter(801) oss::test;	/* Ruby, wrong class name */
%warnfilter(813,833,870) oss::Module;	/* C#, Java, Php4 multiple inheritance */

%inline %{ 
 
  namespace oss 
  { 
      template <class C> 
      struct Wrap 
      { 
      }; 
 
      struct ModuleBase 
      { 
          virtual ~ModuleBase() {}
          virtual int get() = 0; 
      };      
    
      template <class C> 
      struct Module : C, ModuleBase 
      { 
	virtual ~Module() {}

        protected: 
        Module() {}
      }; 
      
      template <class  C> 
      struct HModule : Module<Wrap<C> > 
      { 
       //  virtual int get();   // declaration here works 
   
      protected: 
        HModule() {}
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
#ifdef SWIGCSHARP
%ignore HModule<B>::get(); // Work around for lack of multiple inheritance support - base ModuleBase is ignored.
#endif
    struct test : HModule<B> 
    { 
    virtual int get() {return 0;}   // declaration here breaks swig 
    }; 
  } 
%}  
