module cpp11_std_function_runme;

import cpp11_std_function.cpp11_std_function;

void main() {
  auto fn = pass_checker(420);

  // invoke functor via call method
  if (!fn.call(420, "Petka"))
    throw new Exception("Petka 420 should be true");

  if (fn.call(419, "Chapai"))
    throw new Exception("Chapai 419 should be false");

  // call wrapper
  if (!call_function(fn, 420, "Petka"))
    throw new Exception("Petka 420 should be true");

  if (call_function(fn, 419, "Chapai"))
    throw new Exception("Chapai 419 should be false");
}
