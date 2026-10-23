from swig_test_utils import swig_check
import cpp11_using_typedef_template_member as m


def check_member(c):
    # Inherited data member whose type uses the base template parameter (issue #1042).
    o = m.OwnersInt()
    o.value = 42
    c.owners = o
    swig_check(c.owners.value, 42)
    # Inherited member function whose parameter type uses the base template parameter (issue #1153).
    extra = m.OwnersInt()
    extra.value = 8
    swig_check(c.total(extra), 50)


# Members inherited via a using-declaration whose qualifier is a C++11 alias of the template base.
check_member(m.ClusterAliasInt())

# Members inherited via a using-declaration whose qualifier is a plain typedef of the template base.
check_member(m.ClusterTypedefInt())

# Control: members inherited via a using-declaration naming the template base directly.
check_member(m.ClusterDirectInt())
