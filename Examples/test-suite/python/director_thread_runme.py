from director_thread import Foo


class Derived(Foo):

    def __init__(self):
        Foo.__init__(self)

    def do_foo(self):
        self.val = self.val - 1


d = Derived()
d.run()

if d.val >= 0:
    raise RuntimeError("d.val: {}".format(d.val))

d.stop()
