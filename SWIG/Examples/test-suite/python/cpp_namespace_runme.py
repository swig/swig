# Note: This example assumes that namespaces are flattened
import cpp_namespace

n = cpp_namespace.fact(4)
if n != 24:
    print "Bad return value!"

if cpp_namespace.cvar.Foo != 42:
    print "Bad variable value!"

t = cpp_namespace.Test()
if t.method() != "Test::method":
    print "Bad method return value!"

if cpp_namespace.do_method(t) != "Test::method":
    print "Bad return value!"

cpp_namespace.weird("hello", 4)

del t
