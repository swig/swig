var cpp11_std_function = require('cpp11_std_function')

var fn = /* await */(cpp11_std_function.pass_checker(420));

// invoke functor via call method
var result = /* await */fn.call(420, "Petka");
if (!result)
  throw new Error("Petka 420 should be true");

var result = /* await */fn.call(419, "Chapai");
if (result)
  throw new Error("Petka 419 should be false");

 // call wrapper
var result = /* await */cpp11_std_function.call_function(fn, 420, "Petka");
if (!result)
  throw new Error("Petka 420 should be true");

var result = /* await */cpp11_std_function.call_function(fn, 419, "Chapai");
if (result)
  throw new Error("Petka 419 should be false");

// NULL handling
var passed = false;
try {
  /* await */cpp11_std_function.call_function(null, 420, "Petka");
} catch {
  passed = true;
}
if (!passed) throw new Error("call_function accepted invalid argument");

// Invalid argument
var passed = false;
try {
  /* await */cpp11_std_function.call_function("invalid", 420, "Petka");
} catch {
  passed = true;
}
if (!passed) throw new Error("call_function accepted invalid argument");
