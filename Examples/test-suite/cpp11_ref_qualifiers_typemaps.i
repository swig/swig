%module cpp11_ref_qualifiers_typemaps

%typemap(in) SWIGTYPE (CLASS::*) %{
  _this_will_fail_to_compile_if_used_
%}

// typemaps to completely ignore the input parm and override it
%typemap(in) short (Funcs::*ff)(bool) const   %{ $1 = &Funcs::FF2; %}
%typemap(in) short (Funcs::*cc)(bool) &       %{ $1 = &Funcs::CC5; %}
%typemap(in) short (Funcs::*gg)(bool) const & %{ $1 = &Funcs::GG8; %}
%typemap(in) short (Funcs::*hh)(bool) &&      %{ $1 = &Funcs::HH11; %}

%typemap(in) short (Funcs::*)(bool) const   %{ $1 = &Funcs::FF3; %}
%typemap(in) short (Funcs::*)(bool) &       %{ $1 = &Funcs::CC6; %}
%typemap(in) short (Funcs::*)(bool) const & %{ $1 = &Funcs::GG9; %}
%typemap(in) short (Funcs::*)(bool) &&      %{ $1 = &Funcs::HH12; %}

%inline %{
struct Funcs {
  short FF1(bool) const { return 1; }
  short FF2(bool) const { return 2; }
  short FF3(bool) const { return 3; }
  short CC4(bool) & { return 4; }
  short CC5(bool) & { return 5; }
  short CC6(bool) & { return 6; }
  short GG7(bool) const & { return 7; }
  short GG8(bool) const & { return 8; }
  short GG9(bool) const & { return 9; }
  short HH10(bool) && { return 10; }
  short HH11(bool) && { return 11; }
  short HH12(bool) && { return 12; }
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

%constant short (Funcs::*FF1_MFP)(bool) const = &Funcs::FF1;
%constant short (Funcs::*CC4_MFP)(bool) & = &Funcs::CC4;
%constant short (Funcs::*GG7_MFP)(bool) const & = &Funcs::GG7;
%constant short (Funcs::*HH10_MFP)(bool) && = &Funcs::HH10;
