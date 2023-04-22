%module static_member_overload
%inline %{
class Foo { 
 public: 
  virtual ~Foo() {}
  int sum(int i, int j) { return i+j; }
  static int sum(int i, int j, int k) { return i+j+k; };
}; 
%}
