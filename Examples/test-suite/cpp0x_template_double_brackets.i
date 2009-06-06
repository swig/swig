%module foo
#include <map>
std::map<int,std::map<int, double>> m;
std::map<int,std::map<int, double> > n;
std::map< std::map<(6>>1), double>, double> o;
//std::map< std::map<6>>1, double>, double> p; // fails as it should

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
        int operator>>(ABC &, U);

        template<typename U>
        int operator<<(ABC &, U);
};

