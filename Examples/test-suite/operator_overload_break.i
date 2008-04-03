%module operator_overload_break

%{
#include <iostream>
using namespace std;
%}

%inline %{

class Op
{
public:
    Op(int n) {k = n;}
    Op(const Op& other) {
      std::cerr << "COPY: "<< other.k << std::endl;
      k = other.k;
    }

    bool operator==(const Op& rhs) {
       std::cerr << "Op: " << k << std::endl;
       std::cerr << "obj: " << rhs.k << std::endl;
       return (k == rhs.k);
    }
    bool operator==(int i) {
       std::cerr << "Op: " << k << std::endl;
       std::cerr << "other: " << i << std::endl;
       return (k == i);
    }

    Op operator+(const Op& rhs) {return Op(k + rhs.k);}
    Op operator+(int rhs) {return Op(k + rhs);}

    Op operator-(const Op& rhs) {return Op(k - rhs.k);}
    Op operator-(int rhs) {
      std::cerr << "sub: " << rhs << std::endl;
      return Op(k - rhs);
    }

    Op __rsub__(int lhs) {
      std::cerr << "sub: " << lhs << std::endl;
      return Op(lhs - k);
    }

    Op& operator++() {k++; return *this;}

    void Print() {std::cerr << k << std::endl;}

    int k;
};

%}