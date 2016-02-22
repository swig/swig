from operator_overload import *

# first check all the operators are implemented correctly from pure C++ code
Op_sanity_check()

pop = Op(6)/Op(3)

# test routine:
a=Op()
b=Op(5)
c=Op(b) # copy construct
d=Op(2)
dd=d # assignment operator

# test equality
if not a!=b:
  raise RuntimeError("a!=b")
if not b==c:
  raise RuntimeError("b==c")
if not a!=d:
  raise RuntimeError("a!=d")
if not d==dd:
  raise RuntimeError("d==dd")

# test <
if not a<b:
  raise RuntimeError("a<b")
if not a<=b:
  raise RuntimeError("a<=b")
if not b<=c:
  raise RuntimeError("b<=c")
if not b>=c:
  raise RuntimeError("b>=c")
if not b>d:
  raise RuntimeError("b>d")
if not b>=d:
  raise RuntimeError("b>=d")

# test +=
e=Op(3)
e+=d
if not e==b:
  raise RuntimeError("e==b (%s==%s)" % (e.i, b.i))
e-=c
if not e==a:
  raise RuntimeError("e==a")
e=Op(1)
e*=b
if not e==c:
  raise RuntimeError("e==c")
e/=d
if not e==d:
  raise RuntimeError("e==d")
e%=c;
if not e==d:
  raise RuntimeError("e==d")

# test +
f=Op(1)
g=Op(1)
if not f+g==Op(2):
  raise RuntimeError("f+g==Op(2)")
if not f-g==Op(0):
  raise RuntimeError("f-g==Op(0)")
if not f*g==Op(1):
  raise RuntimeError("f*g==Op(1)")
if not f/g==Op(1):
  raise RuntimeError("f/g==Op(1)")
if not f%g==Op(0):
  raise RuntimeError("f%g==Op(0)")

# test unary operators
if not -a==a:
  raise RuntimeError("-a==a")
if not -b==Op(-5):
  raise RuntimeError("-b==Op(-5)")

"""
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

	// test equality
	assert(a!=b);
	assert(b==c);
	assert(a!=d);

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
"""
