%module template_default
%inline %{
template <class T1, class T2 = T1>
class A
{
};
 %}

%template(A_ii) A<int, int>;       
%template(A_d) A<double>;
