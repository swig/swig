use template_default_arg;

{
  $helloInt = new template_default_arg::Hello_int();
  $helloInt->foo(0);
}
{
  $x = new template_default_arg::X_int();
  if ($x->meth(20.0, 200) != 200) {
    die "X_int test 1 failed";
  }
  if ($x->meth(20) != 20) {
    die "X_int test 2 failed";
  }
  if ($x->meth() != 0) {
    die "X_int test 3 failed";
  }
}

{
  $y = new template_default_arg::Y_unsigned();
  if ($y->meth(20.0, 200) != 200) {
    die "Y_unsigned test 1 failed";
  }
  if ($y->meth(20) != 20) {
    die "Y_unsigned test 2 failed";
  }
  if ($y->meth() != 0) {
    die "Y_unsigned test 3 failed";
  }
}

{
  $x = new template_default_arg::X_longlong();
  $x = new template_default_arg::X_longlong(20.0);
  $x = new template_default_arg::X_longlong(20.0, 200);
}
{
  $x = new template_default_arg::X_int();
  $x = new template_default_arg::X_int(20.0);
  $x = new template_default_arg::X_int(20.0, 200);
}
{
  $x = new template_default_arg::X_hello_unsigned();
  $x = new template_default_arg::X_hello_unsigned(20.0);
  $x = new template_default_arg::X_hello_unsigned(20.0, new template_default_arg::Hello_int());
}
{
  $y = new template_default_arg::Y_hello_unsigned();
  $y->meth(20.0, new template_default_arg::Hello_int());
  $y->meth(new template_default_arg::Hello_int());
  $y->meth();
}

{
  $fz = new template_default_arg::Foo_Z_8();
  $x = new template_default_arg::X_Foo_Z_8();
  $fzc = $x->meth($fz);
}

# Templated functions
{
  # plain function: int ott(Foo<int>)
  if (template_default_arg::ott(new template_default_arg::Foo_int()) != 30) {
    die "ott test 1 failed";
  }

  # %template(ott) ott<int, int>;
  if (template_default_arg::ott() != 10) {
    die "ott test 2 failed";
  }
  if (template_default_arg::ott(1) != 10) {
    die "ott test 3 failed";
  }
  if (template_default_arg::ott(1, 1) != 10) {
    die "ott test 4 failed";
  }

  if (template_default_arg::ott("hi") != 20) {
    die "ott test 5 failed";
  }
  if (template_default_arg::ott("hi", 1) != 20) {
    die "ott test 6 failed";
  }
  if (template_default_arg::ott("hi", 1, 1) != 20) {
    die "ott test 7 failed";
  }

  # %template(ott) ott<const char *>;
  if (template_default_arg::ottstring(new template_default_arg::Hello_int(), "hi") != 40) {
    die "ott test 8 failed";
  }

  if (template_default_arg::ottstring(new template_default_arg::Hello_int()) != 40) {
    die "ott test 9 failed";
  }

  # %template(ott) ott<int>;
  if (template_default_arg::ottint(new template_default_arg::Hello_int(), 1) != 50) {
    die "ott test 10 failed";
  }

  if (template_default_arg::ottint(new template_default_arg::Hello_int()) != 50) {
    die "ott test 11 failed";
  }

  # %template(ott) ott<double>;
  if (template_default_arg::ott(new template_default_arg::Hello_int(), 1.0) != 60) {
    die "ott test 12 failed";
  }

  if (template_default_arg::ott(new template_default_arg::Hello_int()) != 60) {
    die "ott test 13 failed";
  }
}
