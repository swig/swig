%module xxx

%ignore Host::h_ignored;
%ignore Host::i_ignored() &&;
%ignore Host::j_ignored() const &&;

class Host {
public:
  void h1() &;
  void h2() const &;
  void h3() &&;
  void h4() const &&;

  void h() &;
  void h() const &;
  void h() &&;
  void h() const &&;

  void h_ignored() &&;
  void i_ignored() &&;
  void i_ignored() &&;
};

%feature("ignore", "0") Unignore::k_unignored() const &&;

struct Unignore {
  void k_unignored() const &&;
};
