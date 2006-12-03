%module template_enum_typedef

%warnfilter(SWIGWARN_RUBY_WRONG_NAME) oss::etraits; /* Ruby, wrong class name */

%inline %{
 
  namespace oss
  {
    enum Polarization { UnaryPolarization, BinaryPolarization };
 
    template <Polarization P>
    struct Interface
    {
    };
 
    struct etraits
    {
      static const Polarization  pmode = UnaryPolarization;
    };
 
 
    template <class Traits>
    struct Module
    {
      typedef Traits traits;
      static const Polarization P = traits::pmode;
 
      void get(Interface<P> arg) { };   // Here P is only replace by traits::pmode
 
    };
  }
 
%}
 
namespace oss
{
  %template(Interface_UP) Interface<UnaryPolarization>;
  %template(Module_UP) Module<etraits>;
}                                                                 
