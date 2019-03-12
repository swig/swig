%module template_parameters_global_scope

%inline %{
namespace Alloc {
  template<typename T> struct Rebind {
    typedef int Integer;
  };
}
%}

%inline %{
struct Bucket_ {};
typedef Bucket_ TDBucket;
typedef ::Bucket_ TDGlobalBucket;
%}

// Check 1: %template no unary scope operator
%template(RebindBucket) Alloc::Rebind< Bucket_ >;

%inline %{
Alloc::Rebind< Bucket_ >::Integer Bucket1() { return 1; }
Alloc::Rebind< ::Bucket_ >::Integer Bucket2() { return 2; }
Alloc::Rebind< TDBucket >::Integer Bucket3() { return 3; }
Alloc::Rebind< ::TDBucket >::Integer Bucket4() { return 4; }
Alloc::Rebind< TDGlobalBucket >::Integer Bucket5() { return 5; }
Alloc::Rebind< ::TDGlobalBucket >::Integer Bucket6() { return 6; }
%}

// Check 2: %template with unary scope operator
%inline %{
struct Spade {};
typedef Spade TDSpade;
typedef ::Spade TDGlobalSpade;
%}
%template(RebindSpade) Alloc::Rebind< ::Spade >;

%inline %{
Alloc::Rebind< Spade >::Integer Spade1() { return 1; }
Alloc::Rebind< ::Spade >::Integer Spade2() { return 2; }
Alloc::Rebind< TDSpade >::Integer Spade3() { return 3; }
Alloc::Rebind< ::TDSpade >::Integer Spade4() { return 4; }
Alloc::Rebind< TDGlobalSpade >::Integer Spade5() { return 5; }
Alloc::Rebind< ::TDGlobalSpade >::Integer Spade6() { return 6; }
%}

// Check 3: %template typedef no unary scope operator
%inline %{
struct Ball {};
typedef Ball TDBall;
typedef ::Ball TDGlobalBall;
%}
%template(RebindBall) Alloc::Rebind< TDBall >;

%inline %{
Alloc::Rebind< Ball >::Integer Ball1() { return 1; }
Alloc::Rebind< ::Ball >::Integer Ball2() { return 2; }
Alloc::Rebind< TDBall >::Integer Ball3() { return 3; }
Alloc::Rebind< ::TDBall >::Integer Ball4() { return 4; }
Alloc::Rebind< TDGlobalBall >::Integer Ball5() { return 5; }
Alloc::Rebind< ::TDGlobalBall >::Integer Ball6() { return 6; }
%}

// Check 4: %template typedef with unary scope operator
%inline %{
struct Bat {};
typedef Bat TDBat;
typedef ::Bat TDGlobalBat;
%}
%template(RebindBat) Alloc::Rebind< ::TDBat >;

%inline %{
Alloc::Rebind< Bat >::Integer Bat1() { return 1; }
Alloc::Rebind< ::Bat >::Integer Bat2() { return 2; }
Alloc::Rebind< TDBat >::Integer Bat3() { return 3; }
Alloc::Rebind< ::TDBat >::Integer Bat4() { return 4; }
Alloc::Rebind< TDGlobalBat >::Integer Bat5() { return 5; }
Alloc::Rebind< ::TDGlobalBat >::Integer Bat6() { return 6; }
%}

// Check 5: %template double typedef no unary scope operator
%inline %{
struct Chair {};
typedef Chair TDChair;
typedef ::Chair TDGlobalChair;
%}
%template(RebindChair) Alloc::Rebind< TDGlobalChair >;

%inline %{
Alloc::Rebind< Chair >::Integer Chair1() { return 1; }
Alloc::Rebind< ::Chair >::Integer Chair2() { return 2; }
Alloc::Rebind< TDChair >::Integer Chair3() { return 3; }
Alloc::Rebind< ::TDChair >::Integer Chair4() { return 4; }
Alloc::Rebind< TDGlobalChair >::Integer Chair5() { return 5; }
Alloc::Rebind< ::TDGlobalChair >::Integer Chair6() { return 6; }
%}

// Check 6: %template double typedef with unary scope operator
%inline %{
struct Table {};
typedef Table TDTable;
typedef ::Table TDGlobalTable;
%}
%template(RebindTable) Alloc::Rebind< ::TDGlobalTable >;

%inline %{
Alloc::Rebind< Table >::Integer Table1() { return 1; }
Alloc::Rebind< ::Table >::Integer Table2() { return 2; }
Alloc::Rebind< TDTable >::Integer Table3() { return 3; }
Alloc::Rebind< ::TDTable >::Integer Table4() { return 4; }
Alloc::Rebind< TDGlobalTable >::Integer Table5() { return 5; }
Alloc::Rebind< ::TDGlobalTable >::Integer Table6() { return 6; }
%}

#if 0
%inline %{
namespace Alloc {
  template<typename T=::Spade/*, typename T2=TDSpade, typename T3=::TDSpade, typename T4=TDGlobalSpade, typename T5=::TDGlobalSpade*/> struct Rejig {
    typedef int Integer;
  };
}
%}

%template(RejigSpade) Alloc::Rejig<::Spade>;

%inline %{
Alloc::Rejig<>::Integer rejig1() { return 1; }
Alloc::Rejig< ::Spade >::Integer rejig2() { return 2; }
Alloc::Rejig< ::TDSpade >::Integer rejig3() { return 3; }
Alloc::Rejig< ::TDSpade >::Integer rejig4() { return 4; }
Alloc::Rejig< TDGlobalSpade >::Integer rejig5() { return 5; }
Alloc::Rejig< ::TDGlobalSpade >::Integer rejig6() { return 6; }
%}
#endif
