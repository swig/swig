%module rename_scope

%inline 
%{ 
  namespace oss 
  { 
    enum Polarization { UnaryPolarization, BinaryPolarization }; 
 
    template <Polarization P> 
    struct Interface 
    { 
    };    
  } 
%} 
 
namespace oss 
{ 
  // Interface 
  %template(Interface_UP) Interface<UnaryPolarization>; 
  %template(Interface_BP) Interface<BinaryPolarization>; 
 
} 
%inline 
%{ 
  namespace oss 
  { 
    namespace interfaces 
    { 
      template <Polarization P> 
      struct Natural : Interface<P> 
      { 
           int test(void) { return 1; }
      };      
    } 
  } 
%} 
 
namespace oss 
{ 
  namespace interfaces 
  {    
    %rename(rtest) Natural<UnaryPolarization>::test;
    %rename(rtest) Natural<oss::BinaryPolarization>::test;
    
    // Natural 
    %template(Natural_UP) Natural<UnaryPolarization>; 
    %template(Natural_BP) Natural<BinaryPolarization>; 
  } 
} 
