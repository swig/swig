# Copyright (C) 2000 Tal Shalif

execfile('../test_conf.py')
obj = cpptest("")

res = obj.getMyString("string")
if not type(res) is types.StringType or not "string" == res:
    raise "failed"

# primitive_method_user_type.py ends here
