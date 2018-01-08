%module import_fragments

// Check %fragments forced inclusion does not result in code generation when using %import
%import "import_fragments_a.i"

%{
template<typename T>
struct TemplateA4 {};
%}

%template(TemplateA4Int) TemplateA4<int>;

%inline %{
int getImport4() {
  // Requires the ImportA4 fragment to be generated in order to compile
  return ImportA4;
}
%}
