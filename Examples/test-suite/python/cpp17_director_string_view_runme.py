from cpp17_director_string_view import *


class B(A):

    def __init__(self, string):
        A.__init__(self, string)

    def get_first(self):
        # Since std::string_view contains a pointer into a string, the string
        # cannot be a temporary in order to avoid undefined behaviour.
        self.cached_string = A.get_first(self) + " world!"
        return self.cached_string

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
