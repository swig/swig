%module julia_inheritance
%inline %{
struct Left {
  int left;
  Left() : left(19) {}
  int read_left() const { return left; }
};
struct Right {
  int right;
  Right() : right(73) {}
  int read_right() const { return right; }
};
struct Derived : Left, Right {
  int read_left() const { return 41; }
};
int read_base(const Right& value) { return value.right; }
%}
