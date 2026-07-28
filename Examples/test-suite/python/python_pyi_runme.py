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
