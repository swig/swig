import ast
import cpp11_python_pyi_enumvalues as m
from swig_test_utils import swig_assert, swig_check

with open("cpp11_python_pyi_enumvalues.pyi") as source:
    tree = ast.parse(source.read())

def declarations(body):
    return {node.target.id: node for node in body
            if isinstance(node, ast.AnnAssign) and isinstance(node.target, ast.Name)}

constants = declarations(tree.body)
expected = {
    "ZERO": 0, "ONE": 1, "NEGATIVE": -7, "NEXT_NEGATIVE": -6,
    "HEX": 42, "OCTAL": 42, "SUFFIX": 42, "NEGATIVE_SUFFIX": -42,
    "NEGATIVE_HEX": -42, "NEGATIVE_OCTAL": -42, "LONG_SUFFIX": 42,
    "AFTER_HIDDEN": 101, "RENAMED": 102, "AFTER_OPT_OUT": 104,
    "RESET": 20, "AFTER_RESET": 21, "AFTER_HIDDEN_FIRST": 1,
    "RECOVER": 4, "AFTER_RECOVER": 5,
    "INT_MINIMUM": -2147483648, "NEGATIVE_HEX_LONG_LONG": -2147483648,
    "INT_MAXIMUM": 2147483647,
    "FirstScope_SHARED": 10, "FirstScope_NEXT": 11,
    "SecondScope_SHARED": 30, "SecondScope_NEXT": 31,
}
for name, value in expected.items():
    swig_check(ast.literal_eval(constants[name].value), value)
    swig_check(getattr(m, name), value)
for name in ("DEFAULT_ZERO", "DEFAULT_EXPLICIT", "OPT_OUT", "CONSTANT",
             "EXPRESSION", "AFTER_EXPRESSION", "CAST", "AFTER_CAST",
             "NEGATIVE_UNSIGNED", "AFTER_UNSIGNED", "TOO_LARGE",
             "LIMIT", "BOUNDARY_OVERFLOW", "AFTER_OVERFLOW", "ABOVE_INT_MAXIMUM", "HEX_UNSIGNED_MINUS",
             "AFTER_HEX_UNSIGNED_MINUS", "REFERENCE", "AFTER_REFERENCE"):
    swig_check(constants[name].value, None)
for name in ("HIDDEN", "HIDDEN_FIRST", "ORIGINAL"):
    swig_assert(name not in constants)
holder = next(node for node in tree.body if isinstance(node, ast.ClassDef) and node.name == "Holder")
members = declarations(holder.body)
for name, value in {"SHARED": 50, "NEXT": 51, "Scoped_SHARED": 70, "Scoped_NEXT": 71}.items():
    swig_check(ast.literal_eval(members[name].value), value)
    swig_check(getattr(m.Holder, name), value)
swig_check(members["NONENUM"].value, None)

with open("_cpp11_python_pyi_enumvalues.pyi") as source:
    lowlevel = declarations(ast.parse(source.read()).body)
swig_check(lowlevel["ZERO"].value, None)
