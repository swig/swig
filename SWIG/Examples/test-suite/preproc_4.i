%module preproc_4

%{
  inline int hello0()
  {
    return 0;
  }

  inline int hello1()
  {
    return 1;
  }

  inline int hello2()
  {
    return 2;
  }  
%}

#define ARITH_RTYPE(A1, A2) A2

#define HELLO_TYPE(A, B) ARITH_RTYPE(A, ARITH_RTYPE(A,B))


//
// These two work fine
//
int hello0();
ARITH_RTYPE(double,int) hello1();



//
// This doesn't work with 1.3.17+ ( but it was ok in 1.3.16 )
// it gets expanded as (using -E)
// 
//   ARITH_RTYPE(double,int) hello2();
//
HELLO_TYPE(double,int) hello2();
