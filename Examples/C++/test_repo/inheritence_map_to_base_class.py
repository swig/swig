# Copyright (C) 2000 Tal Shalif

execfile('../test_conf.py')
obj1 = cpptest("obj1")
obj2 = cpptest_base("obj2")
res1 = obj1.inBaseClass(obj1)
res2 = obj1.inBaseClass(obj2)

if res1 != "obj1" or  res2 != "obj2":
    raise "failed"

# inheritence_map_to_base_class.py ends here
