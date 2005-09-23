use inherit;

$der = new inherit::CDerived();
$str = $der->Foo();

if ($str != "CBase::Foo") {
  die "test failed";
}

