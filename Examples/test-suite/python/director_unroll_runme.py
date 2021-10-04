import director_unroll


class MyFoo(director_unroll.Foo):

    def ping(self):
        return "MyFoo::ping()"


a = MyFoo()

b = director_unroll.Bar()

b.set(a)
c = b.get()


if not (a.this == c.this):
    raise RuntimeError("{} {}".format(a, c))
