module overload_template_runme;

import std.exception;
import overload_template.overload_template;
import overload_template.Klass;

void main() {
  int f = foo();

  f += maximum(3,4);
  double b = maximum(3.4,5.2);
  b++; // warning suppression

  // mix 1
  enforce(mix1("hi") == 101, "mix1(const char*)");
  enforce(mix1(1.0, 1.0) == 102, "mix1(double, const double &)");
  enforce(mix1(1.0) == 103, "mix1(double)");

  // mix 2
  enforce(mix2("hi") == 101, "mix2(const char*)");
  enforce(mix2(1.0, 1.0) == 102, "mix2(double, const double &)");
  enforce(mix2(1.0) == 103, "mix2(double)");

  // mix 3
  enforce(mix3("hi") == 101, "mix3(const char*)");
  enforce(mix3(1.0, 1.0) == 102, "mix3(double, const double &)");
  enforce(mix3(1.0) == 103, "mix3(double)");

  // Combination 1
  enforce(overtparams1(100) == 10, "overtparams1(int)");
  enforce(overtparams1(100.0, 100) == 20, "overtparams1(double, int)");

  // Combination 2
  enforce(overtparams2(100.0, 100) == 40, "overtparams2(double, int)");

  // Combination 3
  enforce(overloaded() == 60, "overloaded()");
  enforce(overloaded(100.0, 100) == 70, "overloaded(double, int)");

  // Combination 4
  enforce(overloadedagain("hello") == 80, "overloadedagain(const char *)");
  enforce(overloadedagain() == 90, "overloadedagain(double)");

  // specializations
  enforce(specialization(10) == 202, "specialization(int)");
  enforce(specialization(10.0) == 203, "specialization(double)");
  enforce(specialization(10, 10) == 204, "specialization(int, int)");
  enforce(specialization(10.0, 10.0) == 205, "specialization(double, double)");
  enforce(specialization("hi", "hi") == 201, "specialization(const char *, const char *)");

  // simple specialization
  xyz();
  xyz_int();
  xyz_double();

  // a bit of everything
  enforce(overload("hi") == 0, "overload()");
  enforce(overload(1) == 10, "overload(int t)");
  enforce(overload(1, 1) == 20, "overload(int t, const int &)");
  enforce(overload(1, "hello") == 30, "overload(int t, const char *)");

  auto k = new Klass();
  enforce(overload(k) == 10, "overload(Klass t)");
  enforce(overload(k, k) == 20, "overload(Klass t, const Klass &)");
  enforce(overload(k, "hello") == 30, "overload(Klass t, const char *)");
  enforce(overload(10.0, "hi") == 40, "overload(double t, const char *)");
  enforce(overload() == 50, "overload(const char *)");


  // everything put in a namespace
  enforce(nsoverload("hi") == 1000, "nsoverload()");
  enforce(nsoverload(1) == 1010, "nsoverload(int t)");
  enforce(nsoverload(1, 1) == 1020, "nsoverload(int t, const int &)");
  enforce(nsoverload(1, "hello") == 1030, "nsoverload(int t, const char *)");
  enforce(nsoverload(k) == 1010, "nsoverload(Klass t)");
  enforce(nsoverload(k, k) == 1020, "nsoverload(Klass t, const Klass &)");
  enforce(nsoverload(k, "hello") == 1030, "nsoverload(Klass t, const char *)");
  enforce(nsoverload(10.0, "hi") == 1040, "nsoverload(double t, const char *)");
  enforce(nsoverload() == 1050, "nsoverload(const char *)");
}
