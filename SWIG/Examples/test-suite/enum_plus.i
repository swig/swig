%module enum_plus
%inline %{
struct iFoo 
{ 
    enum { 
       Phoo = +50 
    }; 
}; 
%}
