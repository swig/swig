from cpp17_director_string_view import *


class B(A):

    def __init__(self, string):
        A.__init__(self, string)

    def get_first(self):
        # Given std::string_view is just a pointer into a string, the string
        # cannot be a temporary in order to avoid undefined behaviour
        self.cached_string = A.get_first(self) + " world!"
        return self.cached_string

    def process_text(self, string):
        A.process_text(self, string)
        self.smem = "hello"


b = B("hello")

b.get(0)
if b.get_first() != "hello world!":
    raise RuntimeError("b.get_first(): {}".format(b.get_first()))

if b.call_get_first() != "hello world!":
    raise RuntimeError("b.call_get_first(): {}".format(b.call_get_first()))

b.call_process_func()

if b.smem != "hello":
    raise RuntimeError("smem: {}".format(smem))
