import python_moduleimport

# Test custom moduleimport in %module
if python_moduleimport.simple_function(99) != 99:
    raise RuntimeError("simple_function")

if python_moduleimport.extra_import_variable != "custom import of _python_moduleimport":
    raise RuntimeError("custom import")


# Test the swig runtime module contains the expected names/types
import importlib
swig_runtime_version = python_moduleimport.runtime_version()
swig_runtime_data = importlib.import_module("swig_runtime_data" + swig_runtime_version) # Equivalent to (for version 5): import swig_runtime_data5 as swig_runtime_data

names = dir(swig_runtime_data)
expected_names = ("SwigPyObject", "SwigPyPacked", "SwigVarLink")
for name in expected_names:
    if name not in names:
        raise RuntimeError("{} not in {}".format(name, names))

cvar_type = type(python_moduleimport.cvar)
if cvar_type.__name__ != "SwigVarLink":
    raise RuntimeError("cvar type name is incorrect: {}".format(cvar_type.__name__))
