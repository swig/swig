# Copyright (C) 2000 Tal Shalif

execfile('../test_conf.py')
obj = cpptest_empty()
if not type(obj) is types.InstanceType:
    raise "failed"

# constructor.py ends here
