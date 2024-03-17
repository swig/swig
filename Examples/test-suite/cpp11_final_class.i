%module cpp11_final_class

%warnfilter(SWIGWARN_PARSE_KEYWORD) final; // 'final' is a java keyword, renaming to '_final'
%warnfilter(SWIGWARN_PARSE_KEYWORD) override; // 'override' is a C# keyword, renaming to '_override'

%ignore Space1::final::operator=;
#if defined(SWIGPHP)
%rename(Space1_final) Space1::final::final;
#endif
#if defined(SWIGOCAML)
%rename(finale) BrokenSpace::FinalEnum1::final;
#endif

%inline %{
struct FinalBase {
  virtual ~FinalBase() {}
};

struct FinalClass1 final : FinalBase {
  void method1() {}
};

class FinalClass2 final : public FinalBase {
public:
  void method2() {}
};

struct FinalClass3 final {
  void method3() {}
};

struct FinalClass4 {
  void method4() {}
} final;

struct override final {
  void omethod() {}
};
%}

%rename(Space1_final) Space1::final;

%inline %{
namespace Space1 {
struct final final {
  void finalmethod() {}
  final() {}
  final(const final &other) = default;
  final& operator=(const final &other) = default;
};
struct FinalClass5 final {
  void method5() {}
  final final_member_var;
  final get_final_member() { return final_member_var; }
  Space1::final get_final_member2() { return final_member_var; }
};
struct FinalClass6 {
  void method6() {}
  virtual void final() final {}
  virtual ~FinalClass6() = default;
};
typedef final Space1_final_typedef1;
typedef struct final Space1_final_typedef2;
}
typedef Space1::final Space1_final_typedef3;
typedef struct Space1::final Space1_final_typedef4;
%}

%inline %{
namespace Space2 {
class Y {
public:
  Y(int i=0) {}
};

struct FinalVar1 {
    class Y notfinal;
//  class Y final; // SWIG (C++ only) fails to parse (same for struct and union)
};
struct FinalVar2 {
    class Y notfinal = {};
//  class Y final = {}; // SWIG (C++ only) fails to parse (same for struct and union)
};
struct FinalVar3 {
    class Y notfinal = Y();
//  class Y final = Y(); // SWIG (C++ only) fails to parse (same for struct and union)
};
struct FinalVar4 {
  class Y* final;
  FinalVar4() : final() {}
};
struct FinalVar5 {
  Y final;
};
struct FinalVar6 {
  Y final = {};
};
struct FinalVar7 {
  Y final = Y();
};
struct FinalVar8 {
  Y final{};
};
struct FinalVar9 {
  Y final{9};
};
struct FinalVar10 {
  void b10(Y final) {}
};
}
%}

// Unfortunately the use of final in BrokenSpace does not work with Visual C++
// so we limit testing to parsing these by SWIG and then ignoring it all.
%ignore BrokenSpace::FinalVar11;
%ignore BrokenSpace::FinalEnum1;
%ignore BrokenSpace::FinalEnum2;

namespace BrokenSpace {
using Space2::Y;
struct FinalVar11 {
  void a11(class Y final) {}
};
struct FinalEnum1 {
  enum Enum1 { one, two, final };
  void enum_in(Enum1 e) {}
};
struct FinalEnum2 {
  enum Enum2 { one, two, three, four };
  enum Enum2 final;
};
}

%rename(Space3_final) Space3::final;
%inline %{
namespace Space3 {
  typedef struct final {
    void fmethod() {}
  } final;
}
%}
