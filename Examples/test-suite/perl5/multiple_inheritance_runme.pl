
use multiple_inheritance;

$fooBar = new multiple_inheritance::FooBar();
if ($fooBar->foo() != 2) {
  print "Runtime test1 failed\n";
  exit 1;
}

if ($fooBar->bar() != 1) {
  print "Runtime test2 failed\n";
  exit 1;
}

if ($fooBar->fooBar() != 3) {
  print "Runtime test3 failed\n";
  exit 1;
}
