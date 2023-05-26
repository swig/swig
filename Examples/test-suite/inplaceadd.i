%module inplaceadd
%{
#include <iostream>
%}

#if defined(SWIGJAVASCRIPT)
%rename(addTo) operator +=;
%rename(subFrom) operator -=;
%rename(mulTo) operator *=;
#endif

%inline %{
  struct A 
  {
    int val;
    
    A(int v): val(v)
    {
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
