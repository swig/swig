import gc
import sys
from swig_test_utils import swig_assert, swig_check
import python_type_refcount

def check_type_refcount(make):
    t = type(make())
    gc.collect()
    before = sys.getrefcount(t)
    for i in range(10):
        o = make()
        del o
    gc.collect()
    after = sys.getrefcount(t)
    swig_assert(after == before, "{} refcount changed from {} to {}".format(t.__name__, before, after))

def check_type_call_refcount(t):
    # Calling the type uses PyType_GenericAlloc(), whose reference is only released from Python 3.8
    if sys.version_info >= (3, 8):
        try:
            t()
        except TypeError:
            return  # SWIG_NO_HEAPTYPES: a static type cannot be instantiated
        check_type_refcount(t)

class SubItem(python_type_refcount.Item):
    pass

try:
    class SubPtr(type(python_type_refcount.get_int_ptr())):
        pass
except TypeError:
    SubPtr = None  # SWIG_NO_HEAPTYPES: a static type cannot be subclassed

# SwigPyObject
check_type_refcount(python_type_refcount.get_int_ptr)
# SwigPyPacked
check_type_refcount(python_type_refcount.get_method)
# Proxy class or -builtin class, made by its constructor and returned from C++
# Before Python 3.8 the reference taken by PyType_GenericAlloc() for a -builtin class constructor is not released
if not (python_type_refcount.is_python_builtin() and sys.version_info < (3, 8)):
    check_type_refcount(python_type_refcount.Item)
check_type_refcount(python_type_refcount.make_item)
# Python subclass of a proxy class or of a -builtin class
check_type_refcount(SubItem)
# Python subclass of SwigPyObject
if SubPtr is not None:
    check_type_refcount(SubPtr)
# SwigVarLink, the type of cvar
check_type_call_refcount(type(python_type_refcount.cvar))
# SwigPyStaticVar, the descriptor of a static member variable with -builtin
if python_type_refcount.is_python_builtin():
    check_type_call_refcount(type(python_type_refcount.Item.__dict__["static_member"]))
# Static member variable, read and written through its SwigPyStaticVar descriptor with -builtin and through cvar otherwise
if python_type_refcount.is_python_builtin():
    descr = python_type_refcount.Item.__dict__["static_member"]
    before = sys.getrefcount(descr)
    for i in range(10):
        python_type_refcount.Item.static_member = i
        swig_check(python_type_refcount.get_static_member(), i)
        swig_check(python_type_refcount.Item.static_member, i)
        swig_check(python_type_refcount.Item().static_member, i)
    swig_check(sys.getrefcount(descr), before)
else:
    for i in range(10):
        python_type_refcount.cvar.Item_static_member = i
        swig_check(python_type_refcount.get_static_member(), i)
        swig_check(python_type_refcount.cvar.Item_static_member, i)
