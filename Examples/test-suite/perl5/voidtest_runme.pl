use voidtest;

if (1) {
    $f = new voidtest::Foo();
    $v1 = voidtest::vfunc1($f);
    $v2 = voidtest::vfunc2($f);
    $v3 = voidtest::vfunc3($v1);
    $v4 = voidtest::vfunc4($f);
}
