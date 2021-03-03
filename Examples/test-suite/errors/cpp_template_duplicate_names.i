%module xxx

// From test-suite/template_class_reuse.i test

%{
namespace Space {
  template <bool B> struct Duplicate1 { void f(){}; };
}
%}

// %warnfilter(SWIGWARN_PARSE_REDEFINED) Space::Duplicate1;
namespace Space {
  template <bool B> struct Duplicate1 { void f(){}; };
  template <bool B> struct Duplicate1 { void f(){}; };
}


// %warnfilter(SWIGWARN_PARSE_REDEFINED) Space::Duplicate2;
%inline %{
namespace Space {
  template <int I> struct Duplicate2 { void n(){}; };
}
%}
%template(Duplicate2_0) Space::Duplicate2<0>;
%template(Duplicate2_0) Space::Duplicate2<0>;


// %warnfilter(SWIGWARN_PARSE_REDEFINED) Space::Duplicate3;
%inline %{
namespace Space {
  template <int I> struct Duplicate3 { void n(){}; };
}
%}
%template(Duplicate3) Space::Duplicate3<0>;
%template(Duplicate3) Space::Duplicate3<0>;


%{
namespace Space {
  template <bool B> struct Duplicate4 { void f(){}; };
}
%}

// %warnfilter(SWIGWARN_PARSE_REDEFINED) Space::Duplicate4;
namespace Space {
  template <bool B> struct Duplicate4 { void f(){}; };
  template <bool B> struct Duplicate4 { void f(){}; };
}
%template(Duplicate4) Space::Duplicate4<0>;
%template(Duplicate4) Space::Duplicate4<0>;

