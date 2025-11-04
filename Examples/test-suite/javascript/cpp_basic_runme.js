// cpp_basic_runme.js
var cpp_basic = require("cpp_basic");
var cb=cpp_basic;

function check(v)
{
	if(!v) {
		throw Error();
	}
}

var f = new cb.Foo(4);

check(f.num==4);
f.num=-17;
check(f.num==-17);

var b = new cb.Bar();

b.fptr=f;
check(b.fptr.num==-17);
check(b.test(-3,b.fptr)==-5);
f.num=12;
check(b.fptr.num==12);

check(b.fref.num==-4);
check(b.test(12,b.fref)==23);

// references don't take ownership, so if we didn't define this here it might get garbage collected
var f2 = new cb.Foo(23);
b.fref=f2;
check(b.fref.num==23);
check(b.test(-3,b.fref)==35);

check(b.fval.num==15);
check(b.test(3,b.fval)==33);
b.fval = new cb.Foo(-15);  // this is safe as it is copied into the C++
check(b.fval.num==-15);
check(b.test(3,b.fval)==-27);

var f3 = b.testFoo(12,b.fref);
check(f3.num==32);

// now test global
var f4 = new cb.Foo(6);
cb.Bar.global_fptr=f4;
check(cb.Bar.global_fptr.num==6);
f4.num=8;
check(cb.Bar.global_fptr.num==8);

check(cb.Bar.global_fref.num==23);
cb.Bar.global_fref= new cb.Foo(-7); // this will set the value
check(cb.Bar.global_fref.num==-7);

check(cb.Bar.global_fval.num==3);
cb.Bar.global_fval= new cb.Foo(-34);
check(cb.Bar.global_fval.num==-34);

check(cb.Bar.global_cint == -4);

// Now test member function pointers
var func1_ptr=cb.get_func1_ptr();
var func2_ptr=cb.get_func2_ptr();
f.num=4;
check(f.func1(2)==16);
check(f.func2(2)==-8);

f.func_ptr=func1_ptr;
check(cb.test_func_ptr(f,2)==16);
f.func_ptr=func2_ptr;
check(cb.test_func_ptr(f,2)==-8);

// check the __str__ mapping into toString
var f2_name = f2.toString();

var f3 = new cb.FooSub();
var f3_name = f3.toString();

var f4 = new cb.FooSubSub();
var f4_name = f4.toString();

check( f2_name == "Foo" );
check( f3_name == "Foo" );
check( f4_name == "FooSubSub" );

// Test __eq implementation supplied by default
// eq_f1 and eq_f2 are different objects but
// they should be equal according to the SwigObject equals method
var eq_f1 = cb.Bar.global_fptr;
var eq_f2 = cb.Bar.global_fptr;
check( eq_f1 !== eq_f2 );
check( eq_f1.equals(eq_f2) );

