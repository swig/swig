%module cpp11_ref_qualifiers

%inline %{
class Host {
public:
  void h1() & {}
  void h2() const & {}
  void h3() && {}
  void h4() const && {}

  void h() & {}
  void h() const & {}
  void h() && {}
  void h() const && {}
};
%}
