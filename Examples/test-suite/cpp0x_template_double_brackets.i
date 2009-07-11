/* This interface checks whether Swig supports the new double angled brackets
   in the template syntax without having a space inbetween. This feature was
   introduced in new C++0x standard.
*/
%module cpp0x_template_double_brackets
%inline %{
#include <map>
std::map<int,std::map<int, double>> m;
std::map< int,std::map<int, double> > n;

class ABC {
public:
        int a;
        int operator>>(ABC &);
        int operator<<(ABC &);
};

template<class T>
class ABC2 {
public:
        int a;

        template<typename U>
        U operator>>(ABC &);

        template<typename U>
        U operator<<(ABC &);
};
%}

