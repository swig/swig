import ast

import python_pyi

w = python_pyi.Widget(42)
if w.getId() != 42:
    raise RuntimeError("Widget.getId() returned the wrong value")
if python_pyi.Widget.create(7).getId() != 7:
    raise RuntimeError("Widget.create() returned the wrong value")

with open("python_pyi.pyi") as f:
    source = f.read()

# Must always be syntactically valid Python.
tree = ast.parse(source, filename="python_pyi.pyi")

names = set()
for node in ast.walk(tree):
    if isinstance(node, (ast.FunctionDef, ast.ClassDef)):
        names.add(node.name)
    elif isinstance(node, ast.AnnAssign) and isinstance(node.target, ast.Name):
        names.add(node.target.id)

# Everything expected from a -builtin class should appear in the stub.
expected = {"Widget", "__init__", "getId", "create", "id", "make_unwrapped", "SWIGTYPE_p_Unwrapped"}
missing = expected - names
if missing:
    raise RuntimeError("python_pyi.pyi is missing expected declarations: %s" % sorted(missing))

# TYPE_CHECKING is meaningless in a .pyi (it is never executed, only read by
# a type checker), so SWIGTYPE_p_Unwrapped must not be guarded by it there.
if "TYPE_CHECKING" in source:
    raise RuntimeError("python_pyi.pyi should not guard anything with typing.TYPE_CHECKING")

with open("python_pyi.py") as f:
    py_source = f.read()
py_tree = ast.parse(py_source, filename="python_pyi.py")

# Once -pyi is generating the same information, the .py shadow file's own
# annotations are dead weight (a type checker never looks at them once a
# .pyi exists for the same module), so they must be suppressed entirely.
for node in ast.walk(py_tree):
    if isinstance(node, ast.AnnAssign):
        raise RuntimeError("python_pyi.py should have no variable annotations when -pyi is used")
    if isinstance(node, ast.FunctionDef) and (node.returns is not None or any(a.annotation is not None for a in node.args.args)):
        raise RuntimeError("python_pyi.py should have no function annotations when -pyi is used")

# SWIGTYPE_p_Unwrapped must still exist in the .py file (guarded by
# TYPE_CHECKING there, since it must not exist at runtime).
if "SWIGTYPE_p_Unwrapped" not in py_source or "TYPE_CHECKING" not in py_source:
    raise RuntimeError("python_pyi.py is missing the TYPE_CHECKING-guarded SWIGTYPE_p_Unwrapped class")
