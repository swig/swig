%module not_c_keywords

%extend ComplexStruct {
void init() {
  $self->complex = 123;
}
}

%inline %{
struct ComplexStruct {
  int complex; /* complex as variable name */
};
%}
