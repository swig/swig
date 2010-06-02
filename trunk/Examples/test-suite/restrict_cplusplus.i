%module restrict_cplusplus

%inline %{
struct Foo {
    int restrict;
};
%}
