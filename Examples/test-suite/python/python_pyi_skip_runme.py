import ast
import python_pyi_skip as m
from swig_test_utils import swig_assert, swig_check

swig_check(m.hidden(3), 4)
swig_check(m.replaced(3), 6)
swig_check(m.visible(3), 3)
w = m.Widget(5)
swig_check(w.call(2), 7)
swig_check(w.call(2, 3), 10)
swig_check(m.Widget.twice(4), 8)
swig_check(w.ordinary(9), 9)
swig_check(w.internal(2), 3)

with open("python_pyi_skip.pyi") as f:
    tree = ast.parse(f.read())
functions = [node.name for node in tree.body if isinstance(node, ast.FunctionDef)]
swig_assert("hidden" not in functions, "Suppressed function was emitted")
swig_check(functions.count("replaced"), 1)
swig_assert("visible" in functions, "Unrelated function disappeared")
widget = next(node for node in tree.body if isinstance(node, ast.ClassDef) and node.name == "Widget")
swig_assert(not any(isinstance(node, ast.FunctionDef) and node.name == "internal" for node in widget.body), "Suppressed method was emitted")
for name in ("__init__", "call", "twice", "ordinary"):
    methods = [node for node in widget.body if isinstance(node, ast.FunctionDef) and node.name == name]
    swig_check(len(methods), 1)
method = next(node for node in widget.body if isinstance(node, ast.FunctionDef) and node.name == "call")
swig_assert(method.args.vararg is None, "Automatic overload catchall was not suppressed")
swig_check([arg.arg for arg in method.args.args], ["self", "__value", "__extra"])

with open("_python_pyi_skip.pyi") as f:
    lowlevel = ast.parse(f.read())
swig_assert(any(isinstance(node, ast.FunctionDef) and node.name == "hidden" for node in lowlevel.body), "Low-level exports must remain declared")
