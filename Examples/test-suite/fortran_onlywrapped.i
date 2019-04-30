%module fortran_onlywrapped

%ignore Unloved;
%ignore Unknown;

%fortranonlywrapped should_not_be_wrapped;
%fortranonlywrapped overloaded;
%fortranonlywrapped also_overloaded;
%fortranonlywrapped nowrap_also;
%fortranonlywrapped HasUnloved::sad_pointer;

%typemap(in) SWIGTYPE *nowrap {
%#error "This shouldn't be wrapped"
}
%typemap(out) SWIGTYPE *should_not_be_wrapped {
%#error "This shouldn't be wrapped"
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

Unloved* should_not_be_wrapped() { return NULL; }
Unloved* should_be_wrapped() { return NULL; }

void overloaded(Unloved *nowrap) {(void)sizeof(nowrap);}
void overloaded(Normal*) {}
void overloaded(ForwardDeclared *nowrap) {(void)sizeof(nowrap);}
void overloaded(int) {}

void also_overloaded(Unloved *nowrap) {(void)sizeof(nowrap);}
void also_overloaded(Normal*) {}

void nowrap_also(Unloved **nowrap) {(void)sizeof(nowrap);}

#if 0
// NOTE: the following does *not* work because 'Unknown' isn't known to be a
// class.  It could be a typedef to `int` for all we know. The only way to know
// it's going to generate a SWIGTYPE_ placeholder class is if the typemaps
// resolve it to $fclassname.
void nowrap_also(Unknown *nowrap) {(void)sizeof(nowrap);}
#endif

struct HasUnloved {
  int an_integer;
  Unloved* sad_pointer;
};

%}
