%module cpp0x_variadic_templates

%inline %{
template<typename... Values>
class tuple {
};

%}
