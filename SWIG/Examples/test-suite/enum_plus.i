%module enum_plus

%warnfilter(801) iFoo; /* Ruby, wrong constant name */

%inline %{
struct iFoo 
{ 
    enum { 
       Phoo = +50 
    }; 
}; 
%}
