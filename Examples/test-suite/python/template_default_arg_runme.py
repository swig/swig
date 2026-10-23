import template_default_arg
from swig_test_utils import swig_check


helloInt = template_default_arg.Hello_int()
helloInt.foo(template_default_arg.Hello_int.hi)


x = template_default_arg.X_int()
if (x.meth(20.0, 200) != 200):
    raise RuntimeError(("X_int test 1 failed"))
if (x.meth(20) != 20):
    raise RuntimeError(("X_int test 2 failed"))
if (x.meth() != 0):
    raise RuntimeError(("X_int test 3 failed"))


y = template_default_arg.Y_unsigned()
if (y.meth(20.0, 200) != 200):
    raise RuntimeError(("Y_unsigned test 1 failed"))
if (y.meth(20) != 20):
    raise RuntimeError(("Y_unsigned test 2 failed"))
if (y.meth() != 0):
    raise RuntimeError(("Y_unsigned test 3 failed"))


x = template_default_arg.X_longlong()
x = template_default_arg.X_longlong(20.0)
x = template_default_arg.X_longlong(20.0, 200)


x = template_default_arg.X_int()
x = template_default_arg.X_int(20.0)
x = template_default_arg.X_int(20.0, 200)


x = template_default_arg.X_hello_unsigned()
x = template_default_arg.X_hello_unsigned(20.0)
x = template_default_arg.X_hello_unsigned(
    20.0, template_default_arg.Hello_int())


y = template_default_arg.Y_hello_unsigned()
y.meth(20.0, template_default_arg.Hello_int())
y.meth(template_default_arg.Hello_int())
y.meth()


fz = template_default_arg.Foo_Z_8()
x = template_default_arg.X_Foo_Z_8()
fzc = x.meth(fz)


# Templated functions

# plain function: int ott(Foo<int>)
if (template_default_arg.ott(template_default_arg.Foo_int()) != 30):
    raise RuntimeError(("ott test 1 failed"))

# %template(ott) ott<int, int>
if (template_default_arg.ott() != 10):
    raise RuntimeError(("ott test 2 failed"))
if (template_default_arg.ott(1) != 10):
    raise RuntimeError(("ott test 3 failed"))
if (template_default_arg.ott(1, 1) != 10):
    raise RuntimeError(("ott test 4 failed"))

if (template_default_arg.ott("hi") != 20):
    raise RuntimeError(("ott test 5 failed"))
if (template_default_arg.ott("hi", 1) != 20):
    raise RuntimeError(("ott test 6 failed"))
if (template_default_arg.ott("hi", 1, 1) != 20):
    raise RuntimeError(("ott test 7 failed"))

# %template(ott) ott<const char *>
if (template_default_arg.ottstring(template_default_arg.Hello_int(), "hi") != 40):
    raise RuntimeError(("ott test 8 failed"))

if (template_default_arg.ottstring(template_default_arg.Hello_int()) != 40):
    raise RuntimeError(("ott test 9 failed"))

# %template(ott) ott<int>
if (template_default_arg.ottint(template_default_arg.Hello_int(), 1) != 50):
    raise RuntimeError(("ott test 10 failed"))

if (template_default_arg.ottint(template_default_arg.Hello_int()) != 50):
    raise RuntimeError(("ott test 11 failed"))

# %template(ott) ott<double>
if (template_default_arg.ott(template_default_arg.Hello_int(), 1.0) != 60):
    raise RuntimeError(("ott test 12 failed"))

if (template_default_arg.ott(template_default_arg.Hello_int()) != 60):
    raise RuntimeError(("ott test 13 failed"))

swig_check(template_default_arg.ArrayDefaultUShort().count(), 4)
swig_check(template_default_arg.ConstArrayDefaultShort().count(), 6)

# Pointer type-ids as the default of a type template parameter
pd = template_default_arg.PtrDefault_def()
swig_check(pd.deref(pd.t), 42)
swig_check(template_default_arg.deref_int_ptr(pd.t), 42)

pad = template_default_arg.PtrArrayDefault_def()
swig_check(pad.sum(pad.t), 30)

swig_check(template_default_arg.PtrConstDefault_def().deref(pd.t), 42)
swig_check(template_default_arg.PtrPtrDefault_def().deref(pad.t), 10)
swig_check(template_default_arg.PtrConstPtrDefault_def().deref(pad.t), 10)
swig_check(template_default_arg.RefDefault_def().deref(pd.t), 42)

pa2d = template_default_arg.PtrArray2dDefault_def()
swig_check(pa2d.get(pa2d.t), 6)

# Pointer to member and function pointer type-ids as the default of a type template parameter
mh = template_default_arg.MemberHolder()
mpd = template_default_arg.MemberPtrDefault_def()
swig_check(mpd.get(mh, mpd.t), 5)

mfpd = template_default_arg.MemberFuncPtrDefault_def()
swig_check(mfpd.call(mh, mfpd.t, 2), 7)

fpd = template_default_arg.FuncPtrDefault_def()
swig_check(fpd.call(fpd.t, 4), 12)
swig_check(template_default_arg.FuncPtrParmDefault_int().call(fpd.t, 5), 15)
