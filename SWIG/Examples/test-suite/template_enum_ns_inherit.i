%module template_enum_ns_inherit
%inline %{
 
  namespace oss
  {
    enum Polarization { UnaryPolarization, BinaryPolarization };
 
    template <Polarization P>
    struct Interface
    {
    };

    template <Polarization P, class C>
    struct Module
    {
    };

  }
 
%}                                                 
 
namespace oss
{
  %template(Interface_UP) Interface<UnaryPolarization>;
  %template(Module_UPIUP) Module<UnaryPolarization,Interface<UnaryPolarization> >;
}
 
%inline %{
  namespace oss
  {
    namespace hello
    {
      struct HInterface1 :
           Interface<oss::UnaryPolarization>  // this works (with fullns qualification)
      {
      };
 
      struct HInterface2 :
          Interface<UnaryPolarization>       // this doesn't work
      {
      };
 
     struct HModule1 : Module<UnaryPolarization, Interface<UnaryPolarization> > {
 };

    }
  }
%}                                   