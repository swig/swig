import typedef_scope

b = typedef_scope.Bar()
x = b.test1(42, "hello")
if x != 42:
    raise RuntimeError("Failed!!")

x = b.test2(42, "hello")
if x != "hello":
    raise RuntimeError("Failed!!")
