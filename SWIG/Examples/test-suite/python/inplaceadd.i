%module inplaceadd
%{
#include <iostream>
%}


%inline %{
  struct A 
  {
    int val;
    
    A(int v): val(v)
    {
      int a = 2;
      a += (a +=1 ) = 5;
    }
    
    A& operator+=(int v) 
    {
      val += v;
      return *this;
    }

    A& operator+=(const A& a) 
    {
      val += a.val;
      return *this;
    }

    A& operator-=(int v) 
    {
      val -= v;
      return *this;
    }

    A& operator*=(int v) 
    {
      val *= v;
      return *this;
    }
  };
%}
