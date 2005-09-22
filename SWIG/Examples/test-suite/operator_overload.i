/* File : operator_overload.i */
/*
This is a test of all the possible operator overloads

see bottom for a set of possible tests
*/
%module operator_overload

#if defined(SWIGPYTHON)
%warnfilter(362,389);
#endif

#if !defined(SWIGLUA)
%rename(Equal) operator =;
%rename(PlusEqual) operator +=;
%rename(MinusEqual) operator -=;
%rename(MultiplyEqual) operator *=;
%rename(DivideEqual) operator /=;
%rename(PercentEqual) operator %=;
%rename(Plus) operator +;
%rename(Minus) operator -;
%rename(Multiply) operator *;
%rename(Divide) operator /;
%rename(Percent) operator %;
%rename(Not) operator !;
%rename(IndexIntoConst) operator[](unsigned idx) const;
%rename(IndexInto) operator[](unsigned idx);
%rename(Functor) operator ();
%rename(EqualEqual) operator ==;
%rename(NotEqual) operator !=;
%rename(LessThan) operator <;
%rename(LessThanEqual) operator <=;
%rename(GreaterThan) operator >;
%rename(GreaterThanEqual) operator >=;
#endif

%inline %{

class Op{
public:
  int i;
  Op(int a=0):i(a)
  {}
  Op(const Op& o):i(o.i)
  {}
  Op &operator=(const Op& o) {
    i=o.i;
    return *this;
  }
  // +=,-=... are member fns
  void operator+=(const Op& o){ i+=o.i;}
  void operator-=(const Op& o){ i-=o.i;}
  void operator*=(const Op& o){ i*=o.i;}
  void operator/=(const Op& o){ i/=o.i;}
  void operator%=(const Op& o){ i%=o.i;}
  // the +,-,*,... are friends
  // (just to make life harder)
  friend Op operator+(const Op& a,const Op& b){return Op(a.i+b.i);}
  friend Op operator-(const Op& a,const Op& b){return Op(a.i-b.i);}
  friend Op operator*(const Op& a,const Op& b){return Op(a.i*b.i);}
  friend Op operator/(const Op& a,const Op& b){return Op(a.i/b.i);}
  friend Op operator%(const Op& a,const Op& b){return Op(a.i%b.i);}

  // unary operators
  Op operator-() const {return Op(-i);}
  bool operator!() const {return !(i);}

  // overloading the [] operator
  // need 2 versions: get & set
  // note: C++ can be a little mixed up upon which version it calls
  // most of the time it calls the second version
  int operator[](unsigned idx)const
  {	  if (idx==0) return i; return 0;}
  int& operator[](unsigned idx)
  {	  if (idx==0) return i; static int j;j=0; return j;}

  // overloading the () operator
  // this can have many parameters so we will test this
  int operator()(int a=0){return i+a;}
  int operator()(int a,int b){return i+a+b;}

  // TODO: ++,--,<<,<<=
};

// just to complicate matters
// we have a couple of non class operators
inline bool operator==(const Op& a,const Op& b){return a.i==b.i;}
inline bool operator!=(const Op& a,const Op& b){return a.i!=b.i;}
inline bool operator< (const Op& a,const Op& b){return a.i<b.i;}
inline bool operator<=(const Op& a,const Op& b){return a.i<=b.i;}
inline bool operator> (const Op& a,const Op& b){return a.i>b.i;}
inline bool operator>=(const Op& a,const Op& b){return a.i>=b.i;}

%}

// in order to wrapper this correctly
// we need to extend the class
// to make the friends & non members part of the class
%extend Op{
	Op operator+(const Op& b){return Op(self->i+b.i);}
	Op operator-(const Op& b){return Op(self->i-b.i);}
	Op operator*(const Op& b){return Op(self->i*b.i);}
	Op operator/(const Op& b){return Op(self->i/b.i);}
	Op operator%(const Op& b){return Op(self->i%b.i);}

	bool operator==(const Op& b){return self->i==b.i;}
	bool operator!=(const Op& b){return self->i!=b.i;}
	bool operator< (const Op& b){return self->i<b.i;}
	bool operator<=(const Op& b){return self->i<=b.i;}
	bool operator> (const Op& b){return self->i>b.i;}
	bool operator>=(const Op& b){return self->i>=b.i;}

	// we also add the __str__() fn to the class
	// this allows it to be converted to a string (so it can be printed)
	const char* __str__()
	{
		static char buffer[255];
		sprintf(buffer,"Op(%d)",self->i);
		return buffer;
	}
	// to get the [] operator working correctly we need to extend with two function
	// __getitem__ & __setitem__
	int __getitem__(unsigned i)
	{	return (*self)[i];	}
	void __setitem__(unsigned i,int v)
	{	(*self)[i]=v;	}
}

/*
Suggested list of operator overloads (mainly from python)

Operators overloaded with their C++ equivalent
__add__,__sub__,__mul__,__div__,__mod__	+,-,*,/,%
__iadd__,__isub__,__imul__,__idiv__,__imod__	+=,-=,*=,/=,%=

__eq__,__ne__,__lt__,__le__,__gt__,__ge__ ==,!=,<,<=,>,>=
__not__,__neg__	unary !, unary -
__and__,__or__,__xor__	logical and,logical or,logical xor
__rshift__,__lshift__ >>,<<

__getitem__,__setitem__ for operator[]

Operators overloaded without C++ equivilents
__pow__ for power operator
__str__ converts object to a string (should return a const char*)
__concat__ for contatenation (if language supports)

*/


/* Sample test code in C++

#include <assert.h>
#include <stdio.h>

int main(int argc,char** argv)
{
	// test routine:
	Op a;
	Op b=5;
	Op c=b;	// copy construct
	Op d=2;
        Op dd=d; // assignment operator

	// test equality
	assert(a!=b);
	assert(b==c);
	assert(a!=d);
        assert(d==dd);

	// test <
	assert(a<b);
	assert(a<=b);
	assert(b<=c);
	assert(b>=c);
	assert(b>d);
	assert(b>=d);

	// test +=
	Op e=3;
	e+=d;
	assert(e==b);
	e-=c;
	assert(e==a);
	e=Op(1);
	e*=b;
	assert(e==c);
	e/=d;
	assert(e==d);
	e%=c;
	assert(e==d);

	// test +
	Op f(1),g(1);
	assert(f+g==Op(2));
	assert(f-g==Op(0));
	assert(f*g==Op(1));
	assert(f/g==Op(1));
	assert(f%g==Op(0));

	// test unary operators
	assert(!a==true);
	assert(!b==false);
	assert(-a==a);
	assert(-b==Op(-5));

	// test []
	Op h=3;
	assert(h[0]==3);
	assert(h[1]==0);
	h[0]=2;	// set
	assert(h[0]==2);
	h[1]=2;	// ignored
	assert(h[0]==2);
	assert(h[1]==0);

	// test ()
	Op i=3;
	assert(i()==3);
	assert(i(1)==4);
	assert(i(1,2)==6);

	// plus add some code to check the __str__ fn
	//assert(str(Op(1))=="Op(1)");
	//assert(str(Op(-3))=="Op(-3)");

	printf("ok\n");
}
*/
