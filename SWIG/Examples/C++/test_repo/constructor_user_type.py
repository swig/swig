# Copyright (C) 2000 Tal Shalif

execfile('../test_conf.py')
obj = cpptest("MyString")
if not type(obj) is types.InstanceType:
    raise "failed"

# constructor_user_type.py ends here
