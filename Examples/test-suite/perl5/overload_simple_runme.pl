use overload_simple;

$f = new overload_simple::Foo();
$b = new overload_simple::Bar();
$v = overload_simple::malloc_void(32);

if (overload_simple::foo(3) != "foo:int") {
    die("foo(int)");
}

if (overload_simple::foo(3.0) != "foo:double") {
    die("foo(double)");
}

if (overload_simple::foo("hello") != "foo:char *") {
    die("foo(char *)");
}

if (overload_simple::foo($f) != "foo:Foo *") {
    die("foo(Foo *)");
}

if (overload_simple::foo($b) != "foo:Bar *") {
    die("foo(Bar *)");
}

if (overload_simple::foo($v) != "foo:void *") {
    die("foo(void *)");
}

if (overload_simple::blah(3) != "blah:double") {
    die("blah(double)");
}

if (overload_simple::blah("hello") != "blah:char *") {
    die("blah(char *)");
}

$s = new overload_simple::Spam();

if ($s->foo(3) != "foo:int") {
    die("Spam::foo(int)");
}

if ($s->foo(3.0) != "foo:double") {
    die("Spam::foo(double)");
}

if ($s->foo("hello") != "foo:char *") {
    die("Spam::foo(char *)");
}

if ($s->foo($f) != "foo:Foo *") {
    die("Spam::foo(Foo *)");
}

if ($s->foo($b) != "foo:Bar *") {
    die("Spam::foo(Bar *)");
}

if ($s->foo($v) != "foo:void *") {
    die("Spam::foo(void *)");
}

if (overload_simple::Spam::bar(3) != "bar:int") {
    die("Spam::bar(int)");
}

if (overload_simple::Spam::bar(3.0) != "bar:double") {
    die("Spam::bar(double)");
}

if (overload_simple::Spam::bar("hello") != "bar:char *") {
    die("Spam::bar(char *)");
}

if (overload_simple::Spam::bar($f) != "bar:Foo *") {
    die("Spam::bar(Foo *)");
}

if (overload_simple::Spam::bar($b) != "bar:Bar *") {
    die("Spam::bar(Bar *)");
}

if (overload_simple::Spam::bar($v) != "bar:void *") {
    die("Spam::bar(void *)");
}

# Test constructors

$s = new overload_simple::Spam();
if ($s->{type} != "none") {
    die("Spam()");
}

$s = new overload_simple::Spam(3);
if ($s->{type} != "int") {
    die("Spam(int)");
}

$s = new overload_simple::Spam(3.0);
if ($s->{type} != "double") {
    die("Spam(double)");
}

$s = new overload_simple::Spam("hello");
if ($s->{type} != "char *") {
    die("Spam(char *)");
}

$s = new overload_simple::Spam($f);
if ($s->{type} != "Foo *") {
    die("Spam(Foo *)");
}

$s = new overload_simple::Spam($b);
if ($s->{type} != "Bar *") {
    die("Spam(Bar *)");
}

$s = new overload_simple::Spam($v);
if ($s->{type} != "void *") {
    die("Spam(void *)");
}




