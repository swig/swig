"""
Test weave support for SWIG wrapped objects.

This example requires that one has weave installed.  Weave is
distributed as part of SciPy (http://www.scipy.org).  More information
on Weave may be had from here:

 http://www.scipy.org/documentation/weave

As of November 22, 2004, this only works with weave from CVS.  If
there is a more recent release of SciPy after this date, it should
work fine.

"""

import example
import weave
from weave import converters
from weave import swig2_spec

# Weave does not support swig2 by default (yet).  So add this to the
# list of default converters to test.
converters.default.insert(0, swig2_spec.swig2_converter())

def test():
    """ A simple test case for weave."""
    a = example.Foo()
    a.x = 1
    b = example.Bar()
    b.y = 2
    c = example.FooBar()
    c.x = 1
    c.y = 2
    c.z = 3
    v = example.VectorBar()
    v.append(b)
    v.append(c)
    d = v[0]
    e = v[1]
    v = example.VectorFoo()
    v.append(a)
    v.append(c)
    f = v[0]
    g = v[1]
    
    code = """
    std::cout << a->x << std::endl;
    assert(a->x == 1);
    std::cout << b->y << std::endl;
    assert(b->y == 2);
    std::cout << c->x << std::endl;
    std::cout << c->y << std::endl;
    std::cout << c->z << std::endl;
    assert(c->x == 1);
    assert(c->y == 2);
    assert(c->z == 3);
    std::cout << d->y << std::endl;
    assert(d->y == 2);
    std::cout << e->y << std::endl;
    assert(e->y == 2);
    std::cout << f->x << std::endl;
    assert(f->x == 1);
    std::cout << g->x << std::endl;
    assert(g->x == 1);
    """
    weave.inline(code, ['a', 'b', 'c', 'd', 'e', 'f', 'g'],
                 include_dirs=['.'], 
                 headers=['"example.h"'],
                 verbose=2)
    
if __name__ == "__main__":
    test()
