# Copyright (C) 2000 Tal Shalif

execfile('../test_conf.py')
obj = cpptest("")
obj2 = obj.getObject()
obj3 = obj.getObject2("string")
if not type(obj2) is types.InstanceType or not type(obj3) is types.InstanceType:
    raise "failed"

# object_method.py ends here
