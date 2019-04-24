open Swig
open Overload_template

let _ =
  assert (_foo '() as int = 3);
  assert (_maximum '(3, 4) as int = 4);
  assert (_maximum '(3.4, 5.2) as float > 5.);
  assert (_mix1 '("hi") as int = 101);
  assert (_mix1 '(1.0, 1.0) as int = 102);
  assert (_mix1 '(1.0) as int = 103);
  assert (_mix2 '("hi") as int = 101);
  assert (_mix2 '(1.0, 1.0) as int = 102);
  assert (_mix2 '(1.0) as int = 103);
  assert (_mix3 '("hi") as int = 101);
  assert (_mix3 '(1.0, 1.0) as int = 102);
  assert (_mix3 '(1.0) as int = 103);

  assert (_overtparams1 '(100) as int = 10);
  assert (_overtparams1 '(100.0, 100) as int = 20);
  assert (_overtparams2 '(100.0, 100) as int = 40);
  assert (_overloaded '() as int = 60);
  assert (_overloaded '(100.0, 100) as int = 70);
  assert (_overloadedagain '("hello") as int = 80);
  assert (_overloadedagain '() as int = 90);

  assert (_specialization '(10) as int = 202);
  assert (_specialization '(10.0) as int = 203);
  assert (_specialization '(10, 10) as int = 204);
  assert (_specialization '(10.0, 10.0) as int = 205);
  assert (_specialization '("hi", "hi") as int = 201);

  assert (_xyz '() = C_void);
  assert (_xyz_int '() = C_void);
  assert (_xyz_double '() = C_void);

  assert (_overload '("hi") as int = 0);
  assert (_overload '(1) as int = 10);
  assert (_overload '(1, 1) as int = 20);
  assert (_overload '(1, "hello") as int = 30);
  let k = new_Klass '() in
  assert (_overload '(k) as int = 10);
  assert (_overload '(k, k) as int = 20);
  assert (_overload '(k, "hello") as int = 30);
  assert (_overload '(10.0, "hi") as int = 40);
  assert (_overload '() as int = 50);

  assert (_nsoverload '("hi") as int = 1000);
  assert (_nsoverload '(1) as int = 1010);
  assert (_nsoverload '(1, 1) as int = 1020);
  assert (_nsoverload '(1, "hello") as int = 1030);
  assert (_nsoverload '(k) as int = 1010);
  assert (_nsoverload '(k, k) as int = 1020);
  assert (_nsoverload '(k, "hello") as int = 1030);
  assert (_nsoverload '(10.0, "hi") as int = 1040);
  assert (_nsoverload '() as int = 1050);

  assert (_A_foo '(1) = C_void);
  let b = new_B '() in
  assert (b -> foo(1) = C_void);
;;
