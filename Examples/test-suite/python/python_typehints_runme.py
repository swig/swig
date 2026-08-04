from swig_test_utils import swig_annotations_in_stub, swig_get_annotations

import python_typehints
from python_typehints import *


def get_annotations(obj):
    return swig_get_annotations(obj, "python_typehints", is_python_fastproxy())


def check(anno, expected):
    if anno != expected:
        raise RuntimeError("annotations mismatch: {} (expected {})".format(anno, expected))


# -typehints defines SWIGPYTHON_TYPEHINTS
if is_typehints() != 1:
    raise RuntimeError("SWIGPYTHON_TYPEHINTS is not defined")

# Annotations are only added to the runtime objects for the default proxy classes,
# but with -pyi they are always available in the generated .pyi stub file
annotations_supported = swig_annotations_in_stub() or not(is_python_builtin() or is_python_fastproxy())

if annotations_supported:
    # PEP 484 type hints are on for the whole interface without using %feature("python:annotations", "typing")
    check(get_annotations(scale), {"value": "float", "factor": "int", "return": "float"})
    check(get_annotations(join), {"a": "str", "b": "typing.Optional[str]", "return": "str"})
    check(get_annotations(is_valid), {"w": "typing.Any", "return": "bool"})
    check(get_annotations(make_widget), {"id": "int", "return": "typing.Any"})
    check(get_annotations(no_return_value), {"i": "int", "return": "None"})
    check(get_annotations(next_colour), {"c": "int", "return": "int"})

    # Multiple output values are returned in a list and annotated as one
    check(get_annotations(divide), {
        "numerator": "int",
        "denominator": "int",
        "return": "typing.List[typing.Union[typing.Any, typing.Any]]",
    })

    # The return value is the first element of that list
    check(get_annotations(divide_checked), {
        "numerator": "int",
        "denominator": "int",
        "return": "typing.List[typing.Union[bool, typing.Any, typing.Any]]",
    })

    check(get_annotations(Widget.getId), {"return": "int"})
    check(get_annotations(Widget.describe), {"prefix": "str", "return": "str"})
    check(get_annotations(Widget.create), {"id": "int", "return": "typing.Any"})

    # %feature("python:annotations", "0") overrides -typehints for a single function
    check(get_annotations(no_typehints), {})

    # Member variables are annotated, except where overridden by %feature("python:annotations", "0") or turned off with %feature("python:annotations:novar")
    check(get_annotations(Widget), {"id": "int"})

    # Module level constants and enum values are annotated, except where turned off with %feature("python:annotations:novar")
    check(get_annotations(python_typehints), {
        "RED": "int",
        "GREEN": "int",
        "BLUE": "int",
        "A_CONSTANT": "int",
    })

# Check the annotated types match what is actually returned at runtime
if scale(2.0, 3) != 6.0:
    raise RuntimeError("scale is not a float")
if divide(7, 2) != [3, 1]:
    raise RuntimeError("divide does not return a list")
if divide_checked(7, 2) != [True, 3, 1]:
    raise RuntimeError("divide_checked does not return a list")
if join("a", "b") != "ab":
    raise RuntimeError("join is not a str")
