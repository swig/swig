# Copyright (C) 2000 Tal Shalif

execfile('../test_conf.py')
obj = cpptest("")
obj2 = obj.getObject3("MyString")
if not type(obj2) is types.InstanceType:
    raise "failed"

# object_method_user_type.py ends here
