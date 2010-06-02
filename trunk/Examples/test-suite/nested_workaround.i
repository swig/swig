%module nested_workaround
// Similar to "Nested classes" documentation example.

class Inner {
    int val;
  public:
    Inner(int v = 0) : val(v) {}
    void setValue(int v) { val = v; }
    int getValue() const { return val; }
};
%nestedworkaround Outer::Inner;

%inline %{
class Outer {
public:
  class Inner {
      int val;
    public:
      Inner(int v = 0) : val(v) {}
      void setValue(int v) { val = v; }
      int getValue() const { return val; }
  };
  Inner createInner(int v) const { return Inner(v); }
  int getInnerValue(const Inner& i) const { return i.getValue(); }
  Inner doubleInnerValue(Inner inner) { 
    inner.setValue(inner.getValue() * 2); 
    return inner;
  }
};
%}

// We've fooled SWIG into thinking that Inner is a global class, so now we need
// to trick the C++ compiler into understanding this apparent global type.
%{
typedef Outer::Inner Inner;
%}


