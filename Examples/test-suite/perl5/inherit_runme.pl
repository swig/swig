use inherit;

$der = new inherit::CDerived();
$str = $der->Foo();

if ($str ne "CBase::Foo") {
  die "test failed";
}

