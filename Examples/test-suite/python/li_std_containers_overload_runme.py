from li_std_containers_overload import *

def check(got, expected):
    if got != expected:
        raise RuntimeError("Failed check. '{}' != '{}'".format(got, expected))

v = VectorX()
check(VectorOverload(v), "vector<X>")

v = VectorY()
check(VectorOverload(v), "vector<Y>")

v = VectorInt()
check(VectorOverload(v), "vector<int>")

v = VectorString()
check(VectorOverload(v), "vector<string>")

v = [X()]
check(VectorOverload(v), "vector<X>")

v = [Y()]
check(VectorOverload(v), "vector<Y>")

v = [1, 2, 3]
check(VectorOverload(v), "vector<int>")

v = ["aaa", "bbb", "ccc"]
check(VectorOverload(v), "vector<string>")
