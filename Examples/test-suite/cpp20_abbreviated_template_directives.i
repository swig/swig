%module cpp20_abbreviated_template_directives

// Directives naming one instantiation of an abbreviated function template, as they name one of an explicitly written template.

%include <std_string.i>

%{
std::string LastCalled;
%}
%inline %{
std::string getLastCalled() {
  std::string last = LastCalled;
  LastCalled = "<none>";
  return last;
}
%}

// An explicitly written template, for comparison.
%exception fell %{
  LastCalled = "fell: $fulldecl";
  $action;
%}

%exception fell(std::string) %{
  LastCalled = "fell[string]: $fulldecl";
  $action;
%}

%exception fell<int>(int) %{
  LastCalled = "fell[int]: $fulldecl";
  $action;
%}

%inline %{
template<typename T> void fell(T i) { }
%}

%template(fell_int) fell<int>;
%template(fell_string) fell<std::string>;
%template(fell_bool) fell<bool>;

// The abbreviated equivalent.
%exception climbed %{
  LastCalled = "climbed: $fulldecl";
  $action;
%}

%exception climbed(int) %{
  LastCalled = "climbed[int]: $fulldecl";
  $action;
%}

%exception climbed<std::string>(std::string) %{
  LastCalled = "climbed[string]: $fulldecl";
  $action;
%}

%inline %{
void climbed(auto i) { }
%}

%template(climbed_int) climbed<int>;
%template(climbed_string) climbed<std::string>;
%template(climbed_bool) climbed<bool>;

%exception;

// %ignore and %rename select one instantiation each.
%ignore picked<int>(int);
%rename(picked_renamed) picked<double>(double);

%inline %{
int picked(auto x) { return int(x) * 2; }
%}

%template(picked_int) picked<int>;
%template(picked_double) picked<double>;
%template(picked_short) picked<short>;

// With overloaded templates the parameter list picks one, and takes precedence over a %rename without it whatever the order.
%rename(bumped_one) bumped<int>(int);
%rename(bumped_all) bumped<int>;

%inline %{
int bumped(auto x) { return x + 1; }
int bumped(auto x, int step) { return x + step; }
%}

%template(bumped) bumped<int>;

// A pack followed by another template parameter is named with the pack's arguments only, as C++ names it.
%rename(pack_then_one_renamed) pack_then_one<int, int>(int, int, double);

%inline %{
int pack_then_one(auto... values, auto last) { return (values + ... + 0) + int(last); }
%}

%template(pack_then_one_iid) pack_then_one<int, int, double>;

// The call names every template argument, so it reaches this explicit specialization rather than the primary template.
%inline %{
const char *specialized(auto x) { return "primary"; }
template<> const char *specialized<const int>(const int x) { return "const int"; }
%}

%template(specialized_const_int) specialized<const int>;
