import cpp11_directors
from swig_test_utils import swig_check

class MyFoo(cpp11_directors.Foo):
    def ping(self):
        return 1
    def pong(self):
        return 2
    def pang(self):
        return 3
    def peng(self):
        return 4
    def pung(self):
        return 5
    def pyng(self):
        return 6

class MyMoveNode(cpp11_directors.MoveOnlyNode):
    def rvalues_mo(self, o):
        pass
    def rvalues_mo_overload(self, *args):
        pass
    def rvalues_using(self, p1, p2):
        pass
    def rvalues_using2(self, p1, p2):
        pass

f = MyFoo()
swig_check(f.ping(), 1)
swig_check(f.pong(), 2)
swig_check(f.pang(), 3)
swig_check(f.peng(), 4)
swig_check(f.pung(), 5)
swig_check(f.pyng(), 6)

m = MyMoveNode()
m2 = MyMoveNode()
m.rvalues_mo(m2)
m2 = MyMoveNode()
m.rvalues_mo_overload(m2)
m2 = MyMoveNode()
m.rvalues_mo_overload(1, 2.5, m2)
