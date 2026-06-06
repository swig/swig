var default_args_c = require("default_args_c");

if (default_args_c.foo1() != 1) {
  throw new Error("failed");
}
if (default_args_c.foo43() != 43) {
  throw new Error("failed");
}

f = new default_args_c.FooStruct();
f.no_arg();
f.one_req(null);
f.one_opt();
f.one_opt(null);
f.two_arg(null);
f.two_arg(null, null);

default_args_c.StaticStruct.no_arg();
default_args_c.StaticStruct.one_req(null);
default_args_c.StaticStruct.one_opt();
default_args_c.StaticStruct.one_opt(null);
default_args_c.StaticStruct.two_arg(null);
default_args_c.StaticStruct.two_arg(null, null);

default_args_c.global_opts1();
default_args_c.global_opts1(null);
default_args_c.global_opts2(null);
default_args_c.global_opts2(null, null);
