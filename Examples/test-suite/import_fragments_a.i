#if !defined(SWIGGO)
// Prevent Go from generating a Go module import - this test is not set up as true multiple modules
%module import_fragments_a
#endif

%fragment("ImportA1", "header") %{
ImportA1_this_will_not_compile;
%}
%fragment("ImportA2", "header") %{
ImportA2_this_will_not_compile;
%}
%fragment("ImportA3", "header") %{
ImportA3_this_will_not_compile;
%}
%fragment("ImportA4", "header") %{
static int ImportA4 = 99;
%}
%fragment("ImportA5", "header") %{
ImportA5_this_will_not_compile;
%}

%fragment("ImportA1");

%{
Import_will_not_compile;
%}

struct StructA {
  %fragment("ImportA2");
};

template<typename T>
struct TemplateA3 {
  %fragment("ImportA3");
};

template<typename T>
struct TemplateA4 {
  %fragment("ImportA4");
};

template<typename T>
struct TemplateA5 {
  %fragment("ImportA5");
};
%template(TemplateA5Double) TemplateA5<double>;

%include "import_fragments_b.i"
