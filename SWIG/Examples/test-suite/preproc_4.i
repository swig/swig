%module preproc_4

%{
  int hello0()
  {
    return 0;
  }

  int hello1()
  {
    return 1;
  }

  int hello2()
  {
    return 2;
  }  
  int f(int min) { return min; }
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

#define min(x,y) ((x) < (y)) ? (x) : (y) 
int f(int min);

