use default_args;

$true = 1;
$false = 0;

if (default_args::anonymous() != 7771) {
  die "anonymous (1) failed";
}
if (default_args::anonymous(1234) != 1234) {
  die "anonymous (2) failed";
}


if (default_args::booltest() != $true) {
  die "booltest (1) failed";
}
if (default_args::booltest($true) != $true) {
  die "booltest (2) failed";
}
if (default_args::booltest($false) != $false) {
  die "booltest (3) failed";
}

$ec = new default_args::EnumClass();
if ($ec->blah() != $true) {
  die "EnumClass failed";
}

if (default_args::casts1() != null) {
  die "casts1 failed";
}

if (default_args::casts2() ne "Hello") {
  die "casts2 failed";
}

if (default_args::casts1("Ciao") ne "Ciao") {
  die "casts1 not default failed";
}

if (default_args::chartest1() ne 'x') {
  die "chartest1 failed";
}

if (default_args::chartest2() != '\0') {
  die "chartest2 failed";
}

if (default_args::chartest1('y') ne 'y') {
  die "chartest1 not default failed";
}

if (default_args::chartest1('y') ne 'y') {
  die "chartest1 not default failed";
}

if (default_args::reftest1() != 42) {
  die "reftest1 failed";
}

if (default_args::reftest1(400) != 400) {
  die "reftest1 not default failed";
}

if (default_args::reftest2() ne "hello") {
  die "reftest2 failed";
}

# rename
$foo = new default_args::Foo();
$foo->newname(); 
$foo->newname(10); 
$foo->renamed3arg(10, 10.0); 
$foo->renamed2arg(10); 
$foo->renamed1arg(); 
 
# exception specifications
eval { default_args::exceptionspec() };
if (!$@) {
  die "exceptionspec 1 failed";
}
eval { default_args::exceptionspec(-1) };
if (!$@) {
  die "exceptionspec 2 failed";
}
eval { default_args::exceptionspec(100) };
if (!$@) {
  die "exceptionspec 3 failed";
}

$ex = new default_args::Except($false);
eval { $ex.exspec() };
if (!$@) {
  die "exspec 1 failed";
}
eval { $ex.exspec(-1) };
if (!$@) {
  die "exspec 2 failed";
}
eval { $ex.exspec(100) };
if (!$@) {
  die "exspec 3 failed";
}
eval { $ex = new default_args::Except($true) };
if (!$@) {
  die "Except constructor 1 failed";
}
eval { $ex = new default_args::Except($true, -2) };
if (!$@) {
  die "Except constructor 2 failed";
}

#Default parameters in static class methods
if (default_args::Statics::staticmethod() != 10+20+30) {
  die "staticmethod 1 failed";
}
if (default_args::Statics::staticmethod(100) != 100+20+30) {
  die "staticmethod 2 failed";
}
if (default_args::Statics::staticmethod(100,200,300) != 100+200+300) {
  die "staticmethod 3 failed";
}

$tricky = new default_args::Tricky();
if ($tricky->privatedefault() != 200) {
  die "privatedefault failed";
}
if ($tricky->protectedint() != 2000) {
  die "protectedint failed";
}
if ($tricky->protecteddouble() != 987.654) {
  die "protecteddouble failed";
}
if ($tricky->functiondefault() != 500) {
  die "functiondefault failed";
}
if ($tricky->contrived() ne 'X') {
  die "contrived failed";
}

if (default_args::constructorcall()->{val} != -1) {
  die "constructorcall test 1 failed";
}

if (default_args::constructorcall(new default_args::Klass(2222))->{val} != 2222) {
  die "constructorcall test 2 failed";
}

if (default_args::constructorcall(new default_args::Klass())->{val} != -1) {
  die "constructorcall test 3 failed";
}

# const methods 
$cm = new default_args::ConstMethods();
if ($cm->coo() != 20) {
  die "coo test 1 failed";
}
if ($cm->coo(1.0) != 20) {
  die "coo test 2 failed";
}

