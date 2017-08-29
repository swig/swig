%module cpp11_ref_qualifiers

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
};
struct ConversionOperators2 {
  virtual operator string() && { return std::move(string()); }
};
%}
