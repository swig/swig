%module foo
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

