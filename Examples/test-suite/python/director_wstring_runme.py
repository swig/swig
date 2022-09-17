from director_wstring import *


class B(A):

    def __init__(self, string):
        A.__init__(self, string)

    def get_first(self):
        return A.get_first(self) + " world!"

    def process_text(self, s):
        self.smem = s

    def process_wstring_text(self, s):
        self.smem = s + " (wstring)"

    def process_wstring_ref_text(self, s):
        self.smem = s + " (wstring ref)"


b = B("hello")

b.get(0)
if b.get_first() != "hello world!":
    raise RuntimeError("b.get_first(): {}".format(b.get_first()))


b.call_process_func()

if b.smem != "hello":
    raise RuntimeError("smem: {}".format(smem))

b.call_process_wstring_func()

if b.smem != "hello (wstring)":
    raise RuntimeError("smem: {}".format(smem))

b.call_process_wstring_ref_func()

if b.smem != "hello (wstring ref)":
    raise RuntimeError("smem: {}".format(smem))
