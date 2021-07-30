%module template_class_reuse_name

// One parameter templates
%inline %{
namespace Space {
  template <bool B> struct Bool1        { void tt(){}; void ff(){}; };
  template <bool B = true> struct Bool2 { void tt(){}; void ff(){}; };
  template <bool B> struct Bool3        {};
  template <> struct Bool3<true>        { void tt(){}; };
  template <> struct Bool3<false>       { void ff(){}; };
  template <bool B = true> struct Bool4 { void tt(){}; };
  template <> struct Bool4<false>       { void ff(){}; };
}
%}

// Instantiated names are the same as C++ template name
%template(Bool1) Space::Bool1<true>;
%template(Bool2) Space::Bool2<true>;
%template(Bool3) Space::Bool3<true>;
%template(Bool4) Space::Bool4<true>;

// Instantiated names are not the same as C++ template name
%template(Bool1False) Space::Bool1<false>;
%template(Bool2False) Space::Bool2<false>;
%template(Bool3False) Space::Bool3<false>;
%template(Bool4False) Space::Bool4<false>;


// Forward declared templates
%inline %{
namespace Space {
  template <bool B> struct BoolForward1;
  template <bool B> struct BoolForward2;
  template <bool B> struct BoolForward3;
  template <bool B> struct BoolForward4;

  template <bool B> struct BoolForward1        { void tt(){}; void ff(){}; };
  template <bool B = true> struct BoolForward2 { void tt(){}; void ff(){}; };
  template <bool B> struct BoolForward3        {};
  template <> struct BoolForward3<true>        { void tt(){}; };
  template <> struct BoolForward3<false>       { void ff(){}; };
  template <bool B = true> struct BoolForward4 { void tt(){}; };
  template <> struct BoolForward4<false>       { void ff(){}; };
}
%}

// Instantiated names are the same as C++ template name
%template(BoolForward1) Space::BoolForward1<true>;
%template(BoolForward2) Space::BoolForward2<true>;
%template(BoolForward3) Space::BoolForward3<true>;
%template(BoolForward4) Space::BoolForward4<true>;

// Instantiated names are not the same as C++ template name
%template(BoolForward1False) Space::BoolForward1<false>;
%template(BoolForward2False) Space::BoolForward2<false>;
%template(BoolForward3False) Space::BoolForward3<false>;
%template(BoolForward4False) Space::BoolForward4<false>;


// Two parameter templates
%inline %{
namespace Space {
  template <int I, bool B> struct IntBool1        { void tt(){}; void ff(){}; };
  template <int I, bool B = true> struct IntBool2 { void tt(){}; void ff(){}; };
  template <int I, bool B> struct IntBool3        {};
  template <int I> struct IntBool3<I, true>       { void tt(){}; };
  template <int I> struct IntBool3<I, false>      { void ff(){}; };
  template <int I, bool B = true> struct IntBool4 { void tt(){}; };
  template <int I> struct IntBool4<I, false>      { void ff(){}; };
}
%}

// Instantiated names are the same as C++ template name
%template(IntBool1) Space::IntBool1<0, true>;
%template(IntBool2) Space::IntBool2<0, true>;
%template(IntBool3) Space::IntBool3<0, true>;
%template(IntBool4) Space::IntBool4<0, true>;

// Instantiated names are not the same as C++ template name
%template(IntBool1False) Space::IntBool1<0, false>;
%template(IntBool2False) Space::IntBool2<0, false>;
%template(IntBool3False) Space::IntBool3<0, false>;
%template(IntBool4False) Space::IntBool4<0, false>;


%{
namespace Space {
  template <bool B> struct Duplicate1 { void ff(){}; };
}
%}

%warnfilter(SWIGWARN_PARSE_REDEFINED) Space::Duplicate1;
namespace Space {
  template <bool B> struct Duplicate1 { void ff(){}; };
  template <bool B> struct Duplicate1 { void ff(){}; };
}


%warnfilter(SWIGWARN_PARSE_REDEFINED) Space::Duplicate2;
%inline %{
namespace Space {
  template <int I> struct Duplicate2 { void n(){}; };
}
%}
%template(Duplicate2_0) Space::Duplicate2<0>;
%template(Duplicate2_0) Space::Duplicate2<0>;


%warnfilter(SWIGWARN_PARSE_REDEFINED) Space::Duplicate3;
%inline %{
namespace Space {
  template <int I> struct Duplicate3 { void n(){}; };
}
%}
%template(Duplicate3) Space::Duplicate3<0>;
%template(Duplicate3) Space::Duplicate3<0>;


%{
namespace Space {
  template <bool B> struct Duplicate4 { void ff(){}; };
}
%}

%warnfilter(SWIGWARN_PARSE_REDEFINED) Space::Duplicate4;
namespace Space {
  template <bool B> struct Duplicate4 { void ff(){}; };
  template <bool B> struct Duplicate4 { void ff(){}; };
}
%template(Duplicate4) Space::Duplicate4<0>;
%template(Duplicate4) Space::Duplicate4<0>;

