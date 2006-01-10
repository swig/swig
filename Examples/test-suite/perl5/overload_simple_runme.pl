use overload_simple;

$f = new overload_simple::Foo();
$b = new overload_simple::Bar();
$v = overload_simple::malloc_void(32);


#
# Silence warnings about bad types
#
BEGIN { $SIG{'__WARN__'} = sub { warn $_[0] if $DOWARN } }
#
#these tests should 'fail'
#
eval { overload_simple::fint("l") };
if (!$@) {
    die("fint(int)");
}

eval { overload_simple::fint("3.5") };
if (!$@) {
    die("fint(int)");
}

eval { overload_simple::fdouble("l") };
if (!$@) {
    die("fdouble(double)");
}

eval { overload_simple::fdouble("1.5/2.0") };
if (!$@) {
    die("fdouble(double)");
}

#
#enable the warnings again
#
$DOWARN =1;

#
# 'simple' dispatch (no overload) of int and double arguments
#

if (!(overload_simple::fint(3) eq "fint:int")) {
    die("fint(int)");
}

if (!(overload_simple::fint("1") eq "fint:int")) {
    die("fint(int)");
}

if (!(overload_simple::fint(3.0) eq "fint:int")) {
    die("fint(int)");
}

if (!(overload_simple::fint("3.0") eq "fint:int")) {
    die("fint(int)");
}

# old bad case that now works
$n = 3;
$n = $n + 1;
if (!(overload_simple::fint($n) eq "fint:int")) {
    die("fint(int)");
}

if (!(overload_simple::fint(4/2) eq "fint:int")) {
    die("fint(int)");
}

if (!(overload_simple::fint(4/2.0) eq "fint:int")) {
    die("fint(int)");
}

if (!(overload_simple::fdouble(3) eq "fdouble:double")) {
    die("fdouble(double)");
}

if (!(overload_simple::fdouble("3") eq "fdouble:double")) {
    die("fdouble(double)");
}

if (!(overload_simple::fdouble(3.0) eq "fdouble:double")) {
    die("fdouble(double)");
}

if (!(overload_simple::fdouble("3.0") eq "fdouble:double")) {
    die("fdouble(double)");
}
#
# Overload between int and double
#
if (!(overload_simple::num(3) eq "num:int")) {
    die("num(int)");
}

if (!(overload_simple::num("3") eq "num:int")) {
    die("num(int)");
}

if (!(overload_simple::num(3.0) eq "num:double")) {
    die("num(double)");
}

if (!(overload_simple::num("3.0") eq "num:double")) {
    die("num(double)");
}

#
# Overload between int, double, char * and many types.
#
if (!(overload_simple::foo(3) eq "foo:int")) {
    die("foo(int)");
}

if (!(overload_simple::foo(3.0) eq "foo:double")) {
    die("foo(double)");
}

if (!(overload_simple::foo("3") eq "foo:char *")) {
    die("foo(char *)");
}

if (!(overload_simple::foo("3.0") eq "foo:char *")) {
    die("foo(char *)");
}

if (!(overload_simple::foo("hello") eq "foo:char *")) {
    die("foo(char *)");
}

if (!(overload_simple::foo($f) eq "foo:Foo *")) {
    die("foo(Foo *)");
}

if (!(overload_simple::foo($b) eq "foo:Bar *")) {
    die("foo(Bar *)");
}

if (!(overload_simple::foo($v) eq "foo:void *")) {
    die("foo(void *)");
}

if (!(overload_simple::blah(3) eq "blah:double")) {
    die("blah(double)");
}

if (!(overload_simple::blah("hello") eq "blah:char *")) {
    die("blah(char *)");
}

$s = new overload_simple::Spam();

if (!($s->foo(3) eq "foo:int")) {
    die("Spam::foo(int)");
}

if (!($s->foo(3.0) eq "foo:double")) {
    die("Spam::foo(double)");
}

if (!($s->foo("hello") eq "foo:char *")) {
    $r = $s->foo("hello");
    print "res $r\n";
    die("Spam::foo(char *)");
}

if (!($s->foo($f) eq "foo:Foo *")) {
    die("Spam::foo(Foo *)");
}

if (!($s->foo($b) eq "foo:Bar *")) {
    die("Spam::foo(Bar *)");
}

if (!($s->foo($v) eq "foo:void *")) {
    die("Spam::foo(void *)");
}

if (!(overload_simple::Spam::bar(3) eq "bar:int")) {
    die("Spam::bar(int)");
}

if (!(overload_simple::Spam::bar(3.0) eq "bar:double")) {
    die("Spam::bar(double)");
}

if (!(overload_simple::Spam::bar("hello") eq "bar:char *")) {
    die("Spam::bar(char *)");
}

if (!(overload_simple::Spam::bar($f) eq "bar:Foo *")) {
    die("Spam::bar(Foo *)");
}

if (!(overload_simple::Spam::bar($b) eq "bar:Bar *")) {
    die("Spam::bar(Bar *)");
}

if (!(overload_simple::Spam::bar($v) eq "bar:void *")) {
    die("Spam::bar(void *)");
}

# Test constructors

$s = new overload_simple::Spam();
if (!($s->{type} eq "none")) {
    die("Spam()");
}

$s = new overload_simple::Spam(3);
if (!($s->{type} eq "int")) {
    die("Spam(int)");
}

$s = new overload_simple::Spam(3.0);
if (!($s->{type} eq "double")) {
    die("Spam(double)");
}

$s = new overload_simple::Spam("hello");
if (!($s->{type} eq "char *")) {
    die("Spam(char *)");
}

$s = new overload_simple::Spam($f);
if (!($s->{type} eq "Foo *")) {
    die("Spam(Foo *)");
}

$s = new overload_simple::Spam($b);
if (!($s->{type} eq "Bar *")) {
    die("Spam(Bar *)");
}

$s = new overload_simple::Spam($v);
if (!($s->{type} eq "void *")) {
    die("Spam(void *)");
}

#
# Combine dispatch
#


if (!(overload_simple::fid(3, 3.0) eq "fid:intdouble")) {
    die("fid(int,double)");
}

if (!(overload_simple::fid(3.0, 3) eq "fid:doubleint")) {
    die("fid(double,int)");
}

if (!(overload_simple::fid(3.0, 3.0) eq "fid:doubledouble")) {
    die("fid(double,double)");
}

if (!(overload_simple::fid(3, 3) eq "fid:intint")) {
    die("fid(int,int)");
}

# with strings now

if (!(overload_simple::fid(3, "3.0") eq "fid:intdouble")) {
    die("fid(int,double)");
}

if (!(overload_simple::fid("3", 3.0) eq "fid:intdouble")) {
    die("fid(int,double)");
}

if (!(overload_simple::fid("3", "3.0") eq "fid:intdouble")) {
    die("fid(int,double)");
}

if (!(overload_simple::fid(3.0, "3") eq "fid:doubleint")) {
    die("fid(double,int)");
}

if (!(overload_simple::fid("3.0", "3.0") eq "fid:doubledouble")) {
    $r  = overload_simple::fid("3.0", "3.0");
    print "$r \n";
    die("fid(double,double)");
}

if (!(overload_simple::fid("3", 3) eq "fid:intint")) {
    die("fid(int,int)");
}


if (!(overload_simple::fbool(0)) != overload_simple::fbool(1)) {
    die("fbool(bool)");
}

if (2 != overload_simple::fbool(2)) {
    die("fbool(int)");
}
