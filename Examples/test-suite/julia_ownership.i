%module julia_ownership
%newobject make_owned;
%ignore Tracked::operator=;
%inline %{
class Tracked {
public:
  static int live;
  int value;
  Tracked(int n = 7) : value(n) { ++live; }
  Tracked(const Tracked& other) : value(other.value) { ++live; }
  Tracked& operator=(const Tracked& other) { value = other.value; return *this; }
  ~Tracked() { --live; }
  int get() const { return value; }
  Tracked* borrow() { return this; }
  Tracked& reference() { return *this; }
};
int Tracked::live = 0;
int live_count() { return Tracked::live; }
Tracked* make_owned() { return new Tracked(12); }
Tracked* null_pointer() { return 0; }
Tracked make_value() { return Tracked(18); }
%}

#ifdef SWIGJULIA
%typemap(jlparam) const Tracked& unchecked "Any"
#endif
%inline %{
int unchecked_get(const Tracked& unchecked) { return unchecked.get(); }
%}
