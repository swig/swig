# Copyright (C) 2000 Tal Shalif

execfile('../test_conf.py')
obj = cpptest("")
if not type(obj.getInt()) is types.IntType:
    raise "failed"
if not type(obj.getString()) is types.StringType:
    raise "failed"

# primitive_method.py ends here
