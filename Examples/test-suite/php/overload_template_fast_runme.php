<?php

require "tests.php";

$f = foo();

$a = maximum(3, 4);
$b = maximum(3.4, 5.2);

# mix 1
check::equal(mix1("hi"), 101, "mix1(const char*)");

check::equal(mix1(1.0, 1.0), 102, "mix1(double, const double &)");

check::equal(mix1(1.0), 103, "mix1(double)");

# mix 2
check::equal(mix2("hi"), 101, "mix2(const char*)");

check::equal(mix2(1.0, 1.0), 102, "mix2(double, const double &)");

check::equal(mix2(1.0), 103, "mix2(double)");

# mix 3
check::equal(mix3("hi"), 101, "mix3(const char*)");

check::equal(mix3(1.0, 1.0), 102, "mix3(double, const double &)");

check::equal(mix3(1.0), 103, "mix3(double)");

# Combination 1
check::equal(overtparams1(100), 10, "overtparams1(int)");

check::equal(overtparams1(100.0, 100), 20, "overtparams1(double, int)");

# Combination 2
check::equal(overtparams2(100.0, 100), 40, "overtparams2(double, int)");

# Combination 3
check::equal(overloaded(), 60, "overloaded()");

check::equal(overloaded(100.0, 100), 70, "overloaded(double, int)");

# Combination 4
check::equal(overloadedagain("hello"), 80, "overloadedagain(const char *)");

check::equal(overloadedagain(), 90, "overloadedagain(double)");

# specializations
check::equal(specialization(10), 202, "specialization(int)");

check::equal(specialization(10.0), 203, "specialization(double)");

check::equal(specialization(10, 10), 204, "specialization(int, int)");

check::equal(specialization(10.0, 10.0), 205, "specialization(double, double)");

check::equal(specialization("hi", "hi"), 201, "specialization(const char *, const char *)");

# simple specialization
xyz();
xyz_int();
xyz_double();

# a bit of everything
check::equal(overload("hi"), 0, "overload()");

check::equal(overload(1), 10, "overload(int t)");

check::equal(overload(1, 1), 20, "overload(int t, const int &)");

check::equal(overload(1, "hello"), 30, "overload(int t, const char *)");

$k = new Klass();
check::equal(overload($k), 10, "overload(Klass t)");

check::equal(overload($k, $k), 20, "overload(Klass t, const Klass &)");

check::equal(overload($k, "hello"), 30, "overload(Klass t, const char *)");

check::equal(overload(10.0, "hi"), 40, "overload(double t, const char *)");

check::equal(overload(), 50, "overload(const char *)");

# everything put in a namespace
check::equal(nsoverload("hi"), 1000, "nsoverload()");

check::equal(nsoverload(1), 1010, "nsoverload(int t)");

check::equal(nsoverload(1, 1), 1020, "nsoverload(int t, const int &)");

check::equal(nsoverload(1, "hello"), 1030, "nsoverload(int t, const char *)");

check::equal(nsoverload($k), 1010, "nsoverload(Klass t)");

check::equal(nsoverload($k, $k), 1020, "nsoverload(Klass t, const Klass &)");

check::equal(nsoverload($k, "hello"), 1030, "nsoverload(Klass t, const char *)");

check::equal(nsoverload(10.0, "hi"), 1040, "nsoverload(double t, const char *)");

check::equal(nsoverload(), 1050, "nsoverload(const char *)");


A::foo(1);
$b = new B();
$b->foo(1);


check::done();
