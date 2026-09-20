import ast
import python_pyi_readonly
from swig_test_utils import swig_assert, swig_assert_raises, swig_check

w = python_pyi_readonly.Widget(42)
swig_check(w.readonly_value, 43)
swig_check(w.constant_value, 44)
for name in ("readonly_value", "constant_value"):
    with swig_assert_raises(AttributeError):
        setattr(w, name, 0)
w.writable = 5
swig_check(w.writable, 5)
swig_check(python_pyi_readonly.Untyped().value, 7)

with open("python_pyi_readonly.pyi") as stub_file:
    tree = ast.parse(stub_file.read())
classes = {node.name: node for node in tree.body if isinstance(node, ast.ClassDef)}
widget = classes["Widget"]
for name in ("readonly_value", "constant_value"):
    prop = next(node for node in widget.body if isinstance(node, ast.FunctionDef) and node.name == name)
    swig_check([decorator.id for decorator in prop.decorator_list], ["property"])
    swig_check(ast.literal_eval(prop.returns), "int")
    swig_assert(not any(isinstance(node, ast.AnnAssign) and node.target.id == name for node in widget.body))
prop = next(node for node in widget.body if getattr(node, "name", None) == "readonly_value")
swig_check(ast.get_docstring(prop), "A read only value.")
writable = next(node for node in widget.body if isinstance(node, ast.AnnAssign) and node.target.id == "writable")
swig_check(ast.literal_eval(writable.annotation), "typing.Union[int, float]")
prop = next(node for node in classes["Untyped"].body if getattr(node, "name", None) == "value")
swig_check([decorator.id for decorator in prop.decorator_list], ["property"])
swig_check(prop.returns.value.id, "typing")
swig_check(prop.returns.attr, "Any")
