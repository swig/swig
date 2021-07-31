from cpp_parameters import *

# Testing correct and incorrect parameter counts being passed (kwargs and non-kwargs)
# Note that the implementation depends a lot on whether zero, one, two or more args are being wrapped

def is_python_fastproxy():
    """Return True if SWIG is generating Python code using -fastproxy."""
    import cpp_parameters
    # Note: _swig_new_instance_method is only generated when using -fastproxy
    return hasattr(cpp_parameters, "_swig_new_instance_method")

# Zero parameters expected
x = Zero()
try:
    x = Zero(z=0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass
try:
    x = Zero(0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass

try:
    x.zero(z=0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass
try:
    x.zero(0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass

try:
    Zero.stat_zero(z=0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass
try:
    Zero.stat_zero(0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass

try:
    global_zero(z=0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass
try:
    global_zero(0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass

# One mandatory parameter expected
x = One(1)
try:
    x = One(a=1, z=0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass
try:
    x = One(1, 0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass

try:
    x.one(a=1, z=0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass
try:
    x.one(1, 0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass

try:
    One.stat_one(a=1, z=0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass
try:
    One.stat_one(1, 0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass

try:
    global_one(a=1, z=0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass
try:
    global_one(1, 0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass

# Two mandatory parameters expected
x = Two(1, 2)
try:
    x = Two(a=1, b=2, z=0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass
try:
    x = Two(1, 2, 0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass

try:
    x.two(a=1, b=2, z=0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass
try:
    x.two(1, 2, 0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass

try:
    Two.stat_two(a=1, b=2, z=0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass
try:
    Two.stat_two(1, 2, 0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass

try:
    global_two(a=1, b=2, z=0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass
try:
    global_two(1, 2, 0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass

# Single optional parameter expected
x = Single(1)
try:
    x = Single(a=1, z=0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass
try:
    x = Single(1, 0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass

try:
    x.single(a=1, z=0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass
try:
    x.single(1, 0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass

try:
    Single.stat_single(a=1, z=0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass
try:
    Single.stat_single(1, 0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass

try:
    global_single(a=1, z=0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass
try:
    global_single(1, 0)
    raise RuntimeError("Missed throw")
except TypeError:
    pass

# Test that -builtin option throws TypeError if kwargs are used even when they look like they should work, kwargs are not supported unless using -keyword.
# Also same for -fastproxy option except that kwargs are supported by default for constructors. TODO: Fix inconsistency.

if is_python_builtin() or is_python_fastproxy():
    # One mandatory parameter in API
    x = One(1)
    if is_python_fastproxy():
        x = One(a=1)
    else:
        try:
            x = One(a=1)
            raise RuntimeError("Missed throw")
        except TypeError:
            pass
    try:
        x.one(a=1)
        raise RuntimeError("Missed throw")
    except TypeError:
        pass
    try:
        One.stat_one(a=1)
        raise RuntimeError("Missed throw")
    except TypeError:
        pass
    try:
        global_one(a=1)
        raise RuntimeError("Missed throw")
    except TypeError:
        pass

    # Two mandatory parameters in API
    x = Two(1, 2)
    if is_python_fastproxy():
        x = Two(a=1, b=2)
    else:
        try:
            x = Two(a=1, b=2)
            raise RuntimeError("Missed throw")
        except TypeError:
            pass
    try:
        x.two(a=1, b=2)
        raise RuntimeError("Missed throw")
    except TypeError:
        pass
    try:
        Two.stat_two(a=1, b=2)
        raise RuntimeError("Missed throw")
    except TypeError:
        pass
    try:
        global_two(a=1, b=2)
        raise RuntimeError("Missed throw")
    except TypeError:
        pass

    # Single optional parameter in API
    x = Single(1)
    if is_python_fastproxy():
        x = Single(a=1)
    else:
        try:
            x = Single(a=1)
            raise RuntimeError("Missed throw")
        except TypeError:
            pass
    try:
        x.single(a=1)
        raise RuntimeError("Missed throw")
    except TypeError:
        pass
    try:
        Single.stat_single(a=1)
        raise RuntimeError("Missed throw")
    except TypeError:
        pass
    try:
        global_single(a=1)
        raise RuntimeError("Missed throw")
    except TypeError:
        pass

else:
    # Non-builtin should work as expected
    # One mandatory parameter in API
    x = One(a=1)
    x.one(a=1)
    One.stat_one(a=1)
    global_one(a=1)

    # Two mandatory parameters in API
    x = Two(a=1, b=2)
    x.two(a=1, b=2)
    Two.stat_two(a=1, b=2)
    global_two(a=1, b=2)

    # Single optional parameter in API
    x = Single(a=1)
    x.single(a=1)
    Single.stat_single(a=1)
    global_single(a=1)
