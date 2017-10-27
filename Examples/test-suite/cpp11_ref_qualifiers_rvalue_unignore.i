%module cpp11_ref_qualifiers_rvalue_unignore

// This is a minimal test that does not include any C++ headers to make sure the required
// <memory> header is generated from a fragment for the generated std::move call

// m1 and m2 are ignored by default, unignore them
%feature("ignore", "0") RefQualifier::m1() &&;
%feature("ignore", "0") RefQualifier::m2() const &&;

%inline %{
struct RefQualifier {
  void m1() && {}
  void m2() const && {}
};
%}
