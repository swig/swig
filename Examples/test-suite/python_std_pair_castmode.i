%module("castmode") python_std_pair_castmode

%include <std_pair.i>

%inline %{
struct Counted {
  static int live;
  Counted() { live++; }
  Counted(const Counted &) { live++; }
  ~Counted() { live--; }
};
int Counted::live = 0;
%}

%template(IntCounted) std::pair<int, Counted>;

%inline %{
int live_counted() { return Counted::live; }
int take_pair(const std::pair<int, Counted> &p) { return p.first; }
%}
