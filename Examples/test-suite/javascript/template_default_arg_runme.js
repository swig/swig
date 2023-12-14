var template_default_arg = require("template_default_arg");


var helloInt = new template_default_arg.Hello_int();
helloInt.foo(template_default_arg.Hello_int.hi);


var x = new template_default_arg.X_int();
if (/* await */(x.meth(20, 200)) != 200) {
    throw new Error(("X_int test 1 failed"));
}
if (/* await */(x.meth(20)) != 0) {
    throw new Error(("X_int test 2 failed"));
}
if (/* await */(x.meth()) != 0) {
    throw new Error(("X_int test 3 failed"));
}


var y = new template_default_arg.Y_unsigned();
if (/* await */(y.meth(20.0, 200)) != 200) {
    throw new Error(("Y_unsigned test 1 failed"));
}
if (/* await */(y.meth(20)) != 0) {
    throw new Error(("Y_unsigned test 2 failed"));
}
if (/* await */(y.meth()) != 0) {
    throw new Error(("Y_unsigned test 3 failed"));
}


x = new template_default_arg.X_longlong();
x = new template_default_arg.X_longlong(20.0);
x = new template_default_arg.X_longlong(20.0, 200);


x = new template_default_arg.X_int();
x = new template_default_arg.X_int(20.0);
x = new template_default_arg.X_int(20.0, 200);


x = new template_default_arg.X_hello_unsigned();
x = new template_default_arg.X_hello_unsigned(20.0);
x = new template_default_arg.X_hello_unsigned(
    20.0, new template_default_arg.Hello_int());


y = new template_default_arg.Y_hello_unsigned();
/* await */(y.meth(20.0, new template_default_arg.Hello_int()));
/* await */(y.meth(new template_default_arg.Hello_int()));
/* await */(y.meth());


var fz = new template_default_arg.Foo_Z_8();
x = new template_default_arg.X_Foo_Z_8();
var fzc = /* await */(x.meth(fz));


// Templated functions

// plain function: int ott(Foo<int>)
if (/* await */(template_default_arg.ott(new template_default_arg.Foo_int())) != 30) {
    throw new Error(("ott test 1 failed"));
}

// %template(ott) ott<int, int>
if (/* await */(template_default_arg.ott()) != 10) {
    throw new Error(("ott test 2 failed"));
}
if (/* await */(template_default_arg.ott(1)) != 10) {
    throw new Error(("ott test 3 failed"));
}
if (/* await */(template_default_arg.ott(1, 1)) != 10) {
    throw new Error(("ott test 4 failed"));
}

if (/* await */(template_default_arg.ott("hi")) != 20) {
    throw new Error(("ott test 5 failed"));
}
if (/* await */(template_default_arg.ott("hi", 1)) != 20) {
    throw new Error(("ott test 6 failed"));
}
if (/* await */(template_default_arg.ott("hi", 1, 1)) != 20) {
    throw new Error(("ott test 7 failed"));
}

// %template(ott) ott<const char *>
if (/* await */(template_default_arg.ottstring(new template_default_arg.Hello_int(), "hi")) != 40) {
    throw new Error(("ott test 8 failed"));
}

if (/* await */(template_default_arg.ottstring(new template_default_arg.Hello_int())) != 40) {
    throw new Error(("ott test 9 failed"));
}

// %template(ott) ott<int>
if (/* await */(template_default_arg.ottint(new template_default_arg.Hello_int(), 1)) != 50) {
    throw new Error(("ott test 10 failed"));
}

if (/* await */(template_default_arg.ottint(new template_default_arg.Hello_int())) != 50) {
    throw new Error(("ott test 11 failed"));
}

// %template(ott) ott<double>
if (/* await */(template_default_arg.ott(new template_default_arg.Hello_int(), 1.0)) != 60) {
    throw new Error(("ott test 12 failed"));
}

if (/* await */(template_default_arg.ott(new template_default_arg.Hello_int())) != 60) {
    throw new Error(("ott test 13 failed"));
}
