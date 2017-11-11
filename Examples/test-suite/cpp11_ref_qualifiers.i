%module cpp11_ref_qualifiers

%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK_MSG) ccextra2;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK_MSG) ccextra3;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK_MSG) cc2;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK_MSG) cc3;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK_MSG) cc5;

%include <std_string.i>

%ignore Host::h() const &;

// Basic testing
%inline %{
using std::string;
class Host {
  string s;
public:
  string h1() & { return string(); }
  string h2() const & { return string(); }
  string h3() && { return std::move(string()); }
  string h4() const && { return std::move(string()); }
  string h5() const { return string(); }
  string h6() volatile const & { return string(); }
  string h7() const volatile & { return string(); }
  string h8() volatile const && { return std::move(string()); }
  string h9() const volatile && { return std::move(string()); }

  string h() & { return string(); }
  string h() const & { return string(); }
  string h() && { return std::move(string()); }
  string h() const && { return std::move(string()); }
};
%}

// %feature testing
%feature("except") F1() & %{ result = "F1"; %}
%feature("except") F2 %{ result = "F2"; %}
%feature("except") F3 %{ result = "F3"; %}
%feature("except") F3() %{ _should_not_be_used_ %}

%feature("except") C1(int i) const & %{ result = "C1"; %}
%feature("except") C2 %{ result = "C2"; %}
%feature("except") C3 %{ result = "C3"; %}
%feature("except") C3(int i) %{ _should_not_be_used_ %}

%inline %{
struct Features {
  string F1() & { return string(); }
  string F2() & { return string(); }
  string F3() & { return string(); }

  string C1(int i) const & { return string(); }
  string C2(int i) const & { return string(); }
  string C3(int i) const & { return string(); }
};
%}

// %rename testing
%rename(RR1) R1;
%rename(RR2) R2() &;
%rename(RR3) R3;
%rename(RR3Bad) R3();

%rename(SS1) S1;
%rename(SS2) S2(int i) const &;
%rename(SS3) S3;
%rename(SS3Bad) S3(int i);
%rename(SS3BadConst) S3(int i) const;
%rename(SS3BadLValue) S3(int i) &;

%inline %{
struct Renames {
  string R1() & { return string(); }
  string R2() & { return string(); }
  string R3() & { return string(); }

  string S1(int i) const & { return string(); }
  string S2(int i) const & { return string(); }
  string S3(int i) const & { return string(); }
};
%}

// Conversion operators
%rename(StringConvertCopy) operator string() &;
%rename(StringConvertMove) operator string() &&;
%feature("ignore", "0") operator string() &&; // unignore as it is ignored by default

%inline %{
struct ConversionOperators {
  virtual operator string() & { return string(); }
  virtual operator string() && { return std::move(string()); }
  virtual ~ConversionOperators() {}
};
struct ConversionOperators2 {
  virtual operator string() && { return std::move(string()); }
  virtual ~ConversionOperators2() {}
};
%}

%inline %{
struct Funcs {
  short FF(bool) { return 0; }
  short CC(bool) const & { return 0; }
};

class MemberFuncPtrs
{
public:
  // member ref-qualified function pointers, unnamed parameters
  int aaa1(short (Funcs::*)(bool) &) const;
  int aaa2(short (Funcs::* const *&)(bool) &) const;
  int aaa3(short (Funcs::* *&)(bool) &) const;
  int aaa4(short (Funcs::* *const&)(bool) &) const;
  int aaa5(short (Funcs::* &)(bool) &) const;
  int aaa6(short (Funcs::* const)(bool) &) const;
  int aaa7(short (Funcs::* const&)(bool) &) const;

  int aaa8(short (Funcs::* const&)(bool) &&) const;

  // member cv-qualified and ref-qualified function pointers, unnamed parameters
  int bbb1(short (Funcs::*)(bool) const &) const;
  int bbb2(short (Funcs::* const *&)(bool) const &) const;
  int bbb3(short (Funcs::* *&)(bool) const &) const;
  int bbb4(short (Funcs::* *const&)(bool) const &) const;
  int bbb5(short (Funcs::* &)(bool) const &) const;
  int bbb6(short (Funcs::* const)(bool) const &) const;
  int bbb7(short (Funcs::* const&)(bool) const &) const;

  int bbb8(short (Funcs::*)(bool) const &&) const;

  // member ref-qualified function pointers, named parameters
  int qqq1(short (Funcs::* qq1)(bool) &) const;
  int qqq2(short (Funcs::* const *& qq2)(bool) &) const;
  int qqq3(short (Funcs::* *& qq3)(bool) &) const;
  int qqq4(short (Funcs::* *const& qq4)(bool) &) const;
  int qqq5(short (Funcs::* & qq5)(bool) &) const;
  int qqq6(short (Funcs::* const qq6)(bool) &) const;
  int qqq7(short (Funcs::* const& qq7)(bool) &) const;

  int qqq8(short (Funcs::* const& qq8)(bool) &&) const;

  // member cv-qualified and ref-qualified function pointers, named parameters
  int rrr1(short (Funcs::* rr1)(bool) const &) const;
  int rrr2(short (Funcs::* const *& rr2)(bool) const &) const;
  int rrr3(short (Funcs::* *& rr3)(bool) const &) const;
  int rrr4(short (Funcs::* *const& rr4)(bool) const &) const;
  int rrr5(short (Funcs::* & rr5)(bool) const &) const;
  int rrr6(short (Funcs::* const rr6)(bool) const &) const;
  int rrr7(short (Funcs::* const& rr7)(bool) const &) const;

  int rrr8(short (Funcs::* rr1)(bool) const &&) const;
};

// member ref-qualified function pointers, unnamed parameters
int MemberFuncPtrs::aaa1(short (Funcs::*)(bool) &) const { return 0; }
int MemberFuncPtrs::aaa2(short (Funcs::* const *&)(bool) &) const { return 0; }
int MemberFuncPtrs::aaa3(short (Funcs::* *&)(bool) &) const { return 0; }
int MemberFuncPtrs::aaa4(short (Funcs::* *const&)(bool) &) const { return 0; }
int MemberFuncPtrs::aaa5(short (Funcs::* &)(bool) &) const { return 0; }
int MemberFuncPtrs::aaa6(short (Funcs::* const)(bool) &) const { return 0; }
int MemberFuncPtrs::aaa7(short (Funcs::* const&)(bool) &) const { return 0; }

int MemberFuncPtrs::aaa8(short (Funcs::* const&)(bool) &&) const { return 0; }

// member cv-qualified and ref-qualified function pointers, unnamed parameters
int MemberFuncPtrs::bbb1(short (Funcs::*)(bool) const &) const { return 0; }
int MemberFuncPtrs::bbb2(short (Funcs::* const *&)(bool) const &) const { return 0; }
int MemberFuncPtrs::bbb3(short (Funcs::* *&)(bool) const &) const { return 0; }
int MemberFuncPtrs::bbb4(short (Funcs::* *const&)(bool) const &) const { return 0; }
int MemberFuncPtrs::bbb5(short (Funcs::* &)(bool) const &) const { return 0; }
int MemberFuncPtrs::bbb6(short (Funcs::* const)(bool) const &) const { return 0; }
int MemberFuncPtrs::bbb7(short (Funcs::* const&)(bool) const &) const { return 0; }

int MemberFuncPtrs::bbb8(short (Funcs::*)(bool) const &&) const { return 0; }

// member ref-qualified function pointers, named parameters
int MemberFuncPtrs::qqq1(short (Funcs::* qq1)(bool) &) const { return 0; }
int MemberFuncPtrs::qqq2(short (Funcs::* const *& qq2)(bool) &) const { return 0; }
int MemberFuncPtrs::qqq3(short (Funcs::* *& qq3)(bool) &) const { return 0; }
int MemberFuncPtrs::qqq4(short (Funcs::* *const& qq4)(bool) &) const { return 0; }
int MemberFuncPtrs::qqq5(short (Funcs::* & qq5)(bool) &) const { return 0; }
int MemberFuncPtrs::qqq6(short (Funcs::* const qq6)(bool) &) const { return 0; }
int MemberFuncPtrs::qqq7(short (Funcs::* const& qq7)(bool) &) const { return 0; }

int MemberFuncPtrs::qqq8(short (Funcs::* const& qq8)(bool) &&) const { return 0; }

// member cv-qualified and ref-qualified function pointers, named parameters
int MemberFuncPtrs::rrr1(short (Funcs::* rr1)(bool) const &) const { return 0; }
int MemberFuncPtrs::rrr2(short (Funcs::* const *& rr2)(bool) const &) const { return 0; }
int MemberFuncPtrs::rrr3(short (Funcs::* *& rr3)(bool) const &) const { return 0; }
int MemberFuncPtrs::rrr4(short (Funcs::* *const& rr4)(bool) const &) const { return 0; }
int MemberFuncPtrs::rrr5(short (Funcs::* & rr5)(bool) const &) const { return 0; }
int MemberFuncPtrs::rrr6(short (Funcs::* const rr6)(bool) const &) const { return 0; }
int MemberFuncPtrs::rrr7(short (Funcs::* const& rr7)(bool) const &) const { return 0; }

int MemberFuncPtrs::rrr8(short (Funcs::* rr1)(bool) const &&) const { return 0; }

// member cv-qualified and ref-qualified pointer variables
short (Funcs::* cc1)(bool) const & = &Funcs::CC;

short (Funcs::* const * ccextra2)(bool) const & = &cc1;
short (Funcs::* * ccextra3)(bool) const & = &cc1;
short (Funcs::* *const ccextra4)(bool) const & = &cc1;

short (Funcs::* const *& cc2)(bool) const & = ccextra2;
short (Funcs::* *& cc3)(bool) const & = ccextra3;
short (Funcs::* *const& cc4)(bool) const & = ccextra4;
short (Funcs::* & cc5)(bool) const & = cc1;
short (Funcs::* const cc6)(bool) const & = &Funcs::CC;
short (Funcs::* const& cc7)(bool) const & = cc1;
%}

%inline %{

struct Funktions {
  int addByValue(const int &a, int b) const & { return a+b; }
  int * addByPointer(const int &a, int b) const & { static int val; val = a+b; return &val; }
  int & addByReference(const int &a, int b) const & { static int val; val = a+b; return val; }
};

int call1(int (Funktions::*d)(const int &, int) const &, int a, int b) { Funktions f; return (f.*d)(a, b); }
//int call2(int * (Funktions::*d)(const int &, int) const &, int a, int b) { Funktions f; return *(f.*d)(a, b); }
//int call3(int & (Funktions::*d)(const int &, int) const &, int a, int b) { Funktions f; return (f.*d)(a, b); }
%}
%constant int (Funktions::*ADD_BY_VALUE)(const int &, int) const & = &Funktions::addByValue;
