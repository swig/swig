%module cpp11_ref_qualifiers_typemaps

%typemap(in) SWIGTYPE (CLASS::*) %{
  _this_will_fail_to_compile_if_used_
%}

// typemaps to completely ignore the input parm and override it
%typemap(in) short (Funcs::*ff)(bool) const   %{ $1 = &Funcs::FFF2; %}
%typemap(in) short (Funcs::*cc)(bool) &       %{ $1 = &Funcs::CCC5; %}
%typemap(in) short (Funcs::*gg)(bool) const & %{ $1 = &Funcs::GGG8; %}
%typemap(in) short (Funcs::*hh)(bool) &&      %{ $1 = &Funcs::HHH11; %}

%typemap(in) short (Funcs::*)(bool) const   %{ $1 = &Funcs::FFF3; %}
%typemap(in) short (Funcs::*)(bool) &       %{ $1 = &Funcs::CCC6; %}
%typemap(in) short (Funcs::*)(bool) const & %{ $1 = &Funcs::GGG9; %}
%typemap(in) short (Funcs::*)(bool) &&      %{ $1 = &Funcs::HHH12; %}

%inline %{
struct Funcs {
  short FFF1(bool) const { return 1; }
  short FFF2(bool) const { return 2; }
  short FFF3(bool) const { return 3; }
  short CCC4(bool) & { return 4; }
  short CCC5(bool) & { return 5; }
  short CCC6(bool) & { return 6; }
  short GGG7(bool) const & { return 7; }
  short GGG8(bool) const & { return 8; }
  short GGG9(bool) const & { return 9; }
  short HHH10(bool) && { return 10; }
  short HHH11(bool) && { return 11; }
  short HHH12(bool) && { return 12; }
};
struct TypemapsNamedParms
{
  short fff(short (Funcs::*ff)(bool) const) {
    Funcs funcs;
    return (funcs.*ff)(true);
  }
  short ccc(short (Funcs::*cc)(bool) &) {
    Funcs funcs;
    return (funcs.*cc)(true);
  }
  short ggg(short (Funcs::*gg)(bool) const &) {
    Funcs funcs;
    return (funcs.*gg)(true);
  }
  short hhh(short (Funcs::*hh)(bool) &&) {
    return (Funcs().*hh)(true);
  }
};
struct TypemapsUnnamedParms
{
  short fff(short (Funcs::*f)(bool) const) {
    Funcs funcs;
    return (funcs.*f)(true);
  }
  short ccc(short (Funcs::*c)(bool) &) {
    Funcs funcs;
    return (funcs.*c)(true);
  }
  short ggg(short (Funcs::*g)(bool) const &) {
    Funcs funcs;
    return (funcs.*g)(true);
  }
  short hhh(short (Funcs::*h)(bool) &&) {
    return (Funcs().*h)(true);
  }
};
%}

%constant short (Funcs::*FF1_MFP)(bool) const = &Funcs::FFF1;
%constant short (Funcs::*CC4_MFP)(bool) & = &Funcs::CCC4;
%constant short (Funcs::*GG7_MFP)(bool) const & = &Funcs::GGG7;
%constant short (Funcs::*HH10_MFP)(bool) && = &Funcs::HHH10;
