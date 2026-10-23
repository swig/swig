import python_nondynamic_import_b

d = python_nondynamic_import_b.Derived()
d.a = 1
d.b = 2
if d.a != 1 or d.b != 2:
    raise RuntimeError("Derived members not set correctly")

try:
    d.c = 3
    raise RuntimeError("Derived is not static")
except AttributeError:
    pass

# Only the non-builtin classes prevent this, see python_nondynamic_runme.py.
if not python_nondynamic_import_b.is_python_builtin():
    try:
        python_nondynamic_import_b.Derived.a = 10
        raise RuntimeError("Derived should not allow adding a class variable by setting it as an instance variable")
    except AttributeError:
        pass
