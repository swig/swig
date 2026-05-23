import cpp11_std_function

fn = cpp11_std_function.pass_checker(420)

# invoke functor via call method
result = fn.call(420, "Petka")
if not result:
  raise RuntimeError("Petka 420 should be true")

result = fn.call(419, "Chapai")
if result:
  raise RuntimeError("Chapai 419 should be false")

# call wrapper
result = cpp11_std_function.call_function(fn, 420, "Petka")
if not result:
    raise RuntimeError("Petka 420 should be true")

result = cpp11_std_function.call_function(fn, 419, "Chapai")
if result:
    raise RuntimeError("Petka 419 should be false")

# NULL handling
passed = False
try:
    cpp11_std_function.call_function(None, 420, "Petka")
except TypeError:
    passed = True
if not passed:
    raise RuntimeError("call_function accepted invalid argument")

# Invalid argument
passed = False
try:
    cpp11_std_function.call_function("invalid", 420, "Petka")
except TypeError:
    passed = True
if not passed:
    raise RuntimeError("call_function accepted invalid argument")
