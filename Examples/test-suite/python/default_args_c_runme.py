import default_args_c

if default_args_c.foo1() != 1:
  raise RuntimeError("failed")
if default_args_c.foo43() != 43:
  raise RuntimeError("failed")

f = default_args_c.FooStruct()
f.no_arg()
f.one_req(None)
f.one_opt()
f.one_opt(None)
f.two_arg(None)
f.two_arg(None, None)

default_args_c.StaticStruct.no_arg()
default_args_c.StaticStruct.one_req(None)
default_args_c.StaticStruct.one_opt()
default_args_c.StaticStruct.one_opt(None)
default_args_c.StaticStruct.two_arg(None)
default_args_c.StaticStruct.two_arg(None, None)

default_args_c.global_opts1()
default_args_c.global_opts1(None)
default_args_c.global_opts2(None)
default_args_c.global_opts2(None, None)
