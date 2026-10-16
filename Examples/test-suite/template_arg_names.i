%module template_arg_names

// Template arguments with the same name as another template parameter

%inline %{
namespace Space {
  struct First {
    int value;
  };
  struct Second {
    int value;
  };

  template<typename First, typename Second> class Pair {
  public:
    First first;
    Second second;
    Pair *link;
    Pair() : first(), second(), link(0) {}
    First copy_first() { return first; }
    Pair *this_pair() { return this; }
  };

  template<typename First, typename Second> First pick_first(First f, Second) { return f; }

  int first_value(Pair<Second, int> *p) { return p->copy_first().value; }
  int swapped_value(Pair<Second, First> *p) { return p->first.value + p->second.value; }
}
%}

%template(PairSecond) Space::Pair<Space::Second, int>;
%template(PairSwap) Space::Pair<Space::Second, Space::First>;
%template(pick_first_second) Space::pick_first<Space::Second, int>;
