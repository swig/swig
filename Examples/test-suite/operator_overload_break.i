%module operator_overload_break

#if defined(SWIGPYTHON) || defined(SWIGD)
%warnfilter(SWIGWARN_IGNORE_OPERATOR_PLUSPLUS);
#endif

#if !defined(SWIGLUA) && !defined(SWIGR) && !defined(SWIGPERL)
%rename(Plus) operator +;
%rename(Minus) operator -;
%rename(EqualEqual) operator ==;
%rename(PlusPlusPrefix) operator++();
%rename(PlusPlusPostfix) operator++(int);
#endif

%ignore operator new (size_t);
%ignore operator delete (void *);
%ignore operator delete[] (void *);

%{
#include <iostream>
#include <stdlib.h>
using namespace std;
%}

%inline %{

class Op
{
public:
    Op(int n) {k = n;}
    Op(const Op& other) {
      k = other.k;
    }

    bool operator==(const Op& rhs) {
       return (k == rhs.k);
    }
    bool operator==(int i) {
       return (k == i);
    }

    Op operator+(const Op& rhs) {return Op(k + rhs.k);}
    Op operator+(int rhs) {return Op(k + rhs);}

    Op operator-(const Op& rhs) {return Op(k - rhs.k);}
    Op operator-(int rhs) {
      return Op(k - rhs);
    }

    Op __rsub__(int lhs) {
      return Op(lhs - k);
    }

    Op& operator++() {k++; return *this;}


    int k;
};

struct Op2 {
    void *operator new
         (size_t); // definition split over two lines was giving syntax error
    void operator delete /* comment here did not work */ (void *);
    void operator
         delete[] (void *);
};

void *Op2::operator new(size_t) { return malloc(sizeof(Op)); }
void Op2::operator delete(void *p) { free(p); }
void Op2::operator delete[] (void *) {}

%}
