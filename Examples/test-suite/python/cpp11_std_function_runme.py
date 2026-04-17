import cpp11_std_function

fn = cpp11_std_function.return_function(420)

r = cpp11_std_function.call_function(fn, 420, "Petka")
if r != "Petka passed the test":
    raise RuntimeError("failed function call")

# Functor not working as SWIG instantiates the primary template instead of the specialized template in std_function.i
# r = fn(420, "Petka")
# if r != "Petka passed the test":
#     raise RuntimeError("failed calling functor")

passed = False
try:
    cpp11_std_function.call_function("invalid", 420, "Petka")
except TypeError:
    passed = True
if not passed:
    raise RuntimeError("call_function accepted invalid argument")


passed = False
try:
    cpp11_std_function.call_function(fn, 419, "Chapai")
except RuntimeError:
    passed = True
if not passed:
    raise RuntimeError("call_function did not throw")
