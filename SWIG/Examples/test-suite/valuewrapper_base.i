%module valuewrapper_base
%inline 
%{ 
  namespace oss 
  { 
    enum Polarization { UnaryPolarization, BinaryPolarization }; 
 
    struct Base 
    { 
    };    
 
    template <Polarization P> 
    struct Interface : Base 
    { 
      Interface(const Base& b) { }; 
    }; 
    
    template <class Result> 
    Result make() { return Result(*new Base()); }
  } 
%} 
 
namespace oss 
{ 
  // Interface 
  %template(Interface_BP) Interface<BinaryPolarization>; 
  %template(make_Interface_BP) make<Interface<BinaryPolarization> >; 
} 
