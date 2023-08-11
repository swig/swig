%module template_using_member_default_arg

%inline %{
template<typename T1, typename T2 = short>
struct ThingA {
  ThingA() {}
protected:
  void describeA() {}
};
template<typename T1, typename T2 = short>
struct ThingB {
  ThingB() {}
protected:
  void describeB() {}
};
%}

%inline %{
template<typename T1>
struct ThingADerived : ThingA<T1> {
  using ThingA<T1>::describeA;
};
template<typename T1>
struct ThingBDerived : ThingB<T1> {
  using ThingB<T1>::describeB;
};
%}

%template(ThingAInt) ThingA<int>; // was okay
%template(ThingADerivedInt) ThingADerived<int>;

%template(ThingBInt) ThingB<int, short>; // was failing - using directive in this template was not found
%template(ThingBDerivedInt) ThingBDerived<int>;
