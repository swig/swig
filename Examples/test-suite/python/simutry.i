%module simutry

%include "std_vector.i"

%inline
{
#include <iostream>

namespace simuPOP
{
  // some simple pop class
  struct pop {
    int m_a;
    pop(int a):m_a(a){}
  };

  // base operator, output pop.m_a
  template<class Pop>
  struct Operator
  {
    Pop m_pop;
    Operator(int a):m_pop(a){}
    virtual void func() const 
    { std::cout << m_pop.m_a << std::endl; }
  };

  // derived operator, output double of pop.m_a
  template<class Pop>
  struct DerivedOperator: public Operator<Pop>
  {
    DerivedOperator(int a):Operator<Pop>(a){}
    virtual void func() const 
    { std::cout << 2*this->m_pop.m_a << std::endl; }
  };
}
}

namespace simuPOP
{
 %template(baseOperator)        Operator< pop >;
 %template(derivedOperator)     DerivedOperator< pop >;
}



namespace std
{
  %template(vectorop)   vector< simuPOP::Operator<simuPOP::pop> * >;
}

%inline
{
namespace simuPOP
{
  // test function, use of a vector of Operator*
  void test( const std::vector< Operator<pop>*>& para)
  {
    for( size_t i =0; i < para.size(); ++i)
    para[i]->func();
  }
}
}


