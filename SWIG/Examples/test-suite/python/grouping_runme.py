import grouping

x = grouping.test1(42)
if x != 42:
    raise RuntimeError

grouping.test2(42)
