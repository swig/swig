%module fortran_onlywrapped

%ignore Unloved;
%ignore UnlovedTemplate;
%ignore Unknown;

%fortranonlywrapped should_not_be_wrapped;
%fortranonlywrapped overloaded;
%fortranonlywrapped also_overloaded;
%fortranonlywrapped nowrap_also;
%fortranonlywrapped HasUnloved::sad_pointer;
%fortranonlywrapped WeHaveOverloads::WeHaveOverloads;

%typemap(in) SWIGTYPE *nowrap {
%#error "$1_type shouldn't be wrapped"
}
%typemap(out) SWIGTYPE *should_not_be_wrapped {
%#error "$1_type shouldn't be wrapped"
}
%apply SWIGTYPE *nowrap { Unloved **nowrap };

%{
struct Unknown;
%}

%inline %{

struct Normal;

struct Unloved {};
struct Normal {};
struct ForwardDeclared;
template<class T> struct UnlovedTemplate {};

Unloved* should_not_be_wrapped() { return NULL; }
Unloved* should_be_wrapped() { return NULL; }

void overloaded(Unloved *nowrap) {(void)sizeof(nowrap);}
void overloaded(Normal*) {}
void overloaded(ForwardDeclared *nowrap) {(void)sizeof(nowrap);}
void overloaded(int) {}

void also_overloaded(Unloved *nowrap) {(void)sizeof(nowrap);}
void also_overloaded(Normal*) {}

void nowrap_also(Unloved **nowrap) {(void)sizeof(nowrap);}

void nowrap_also(Unknown *nowrap) {(void)sizeof(nowrap);}

struct HasUnloved {
  int an_integer;
  Unloved* sad_pointer;
};

class WeHaveOverloads {
 public:
  void overloaded(Unloved *nowrap) {(void)sizeof(nowrap);}
  void overloaded(UnlovedTemplate<int> *nowrap) {(void)sizeof(nowrap);}
  void overloaded(Normal*) {}
  void overloaded(ForwardDeclared *nowrap) {(void)sizeof(nowrap);}
  void overloaded(int) {}

  WeHaveOverloads(Unloved *nowrap) {(void)sizeof(nowrap);}
  WeHaveOverloads(int) {}
};

%}
