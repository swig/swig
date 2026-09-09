%module swift_inherit
// Swift-specific test: single inheritance with virtual dispatch (no directors).
%inline %{
struct Animal {
  virtual ~Animal() {}
  virtual int legs() const { return 0; }
  int describe() const { return legs(); }
};
struct Dog : public Animal {
  virtual int legs() const { return 4; }
};
struct Bird : public Animal {
  virtual int legs() const { return 2; }
};
%}
