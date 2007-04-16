%module restrict_cplusplus

%inline %{
struct foo {
    int restrict;
};
%}
