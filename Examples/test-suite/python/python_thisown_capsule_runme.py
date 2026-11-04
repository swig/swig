import gc
import sys
import python_thisown_capsule as m

def find_capsule():
    for name, mod in list(sys.modules.items()):
        if name.startswith("swig_runtime_data"):
            for attr in dir(mod):
                if attr.startswith("type_pointer_capsule"):
                    return getattr(mod, attr)
    raise RuntimeError("runtime data capsule not found")

def capsule_refs():
    gc.collect()
    return sys.getrefcount(find_capsule())

def check_wrapper_type(msg):
    # If the runtime data capsule has been released early, wrappers lose their proxy class
    t = type(m.make_item()).__name__
    if t != "Item":
        raise RuntimeError("%s: new wrapper is a %s, expected Item" % (msg, t))

def check_balanced(msg, func):
    before = capsule_refs()
    for i in range(100):
        func()
    after = capsule_refs()
    if after != before:
        raise RuntimeError("%s: runtime data capsule refcount changed from %d to %d" % (msg, before, after))
    check_wrapper_type(msg)

class PyFactory(m.Factory):
    def create(self):
        return m.Item()

def acquire_non_owning():
    a = m.make_item()
    a.thisown = 1
    del a

def toggle_ownership():
    a = m.make_item()
    a.thisown = 1
    a.thisown = 0
    a.thisown = 1
    del a
    b = m.Item()
    b.thisown = 0
    b.thisown = 1
    del b

def disown_then_acquire():
    a = m.Item()
    r = m.pass_through(a)
    if a.thisown:
        raise RuntimeError("DISOWN typemap did not clear ownership")
    del r
    a.thisown = 1
    del a

def director_return():
    m.create_and_delete(PyFactory())

check_wrapper_type("before")
check_balanced("acquire non-owning", acquire_non_owning)
check_balanced("toggle ownership", toggle_ownership)
check_balanced("DISOWN then acquire", disown_then_acquire)
check_balanced("director return", director_return)
