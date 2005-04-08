from director_thread import Foo

class Derived(Foo) :
    def __init__(self):
        Foo.__init__(self)
        print "too"
    def do_foo(self):
        print "at drived class"

d = Derived()
d.run()
