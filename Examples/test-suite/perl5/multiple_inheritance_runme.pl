
use multiple_inheritance;

$fooBar = new multiple_inheritance::FooBar();
if ($fooBar->foo() != 2) {
  die "Runtime test1 failed\n";
}

if ($fooBar->bar() != 1) {
  die "Runtime test2 failed\n";
}

if ($fooBar->fooBar() != 3) {
  die "Runtime test3 failed\n";
}
