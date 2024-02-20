from director_string import *


class B(A):

    def __init__(self, string):
        A.__init__(self, string)

    def get_first(self):
        return A.get_first(self) + " world!"

    def process_text(self, string):
        A.process_text(self, string)
        self.smem = "hello"


b = B("hello")

if b.get(0) != "hello":
    raise RuntimeError("b.get(0): {}".format(b.get(0)))

if b.get_first() != "hello world!":
    raise RuntimeError("b.get_first(): {}".format(b.get_first()))

if b.call_get_first() != "hello world!":
    raise RuntimeError("b.call_get_first(): {}".format(b.call_get_first()))

b.call_process_func()

if b.smem != "hello":
    raise RuntimeError("smem: {}".format(smem))
