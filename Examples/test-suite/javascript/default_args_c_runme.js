var default_args_c = require("default_args_c");

if (/* await */(default_args_c.foo1()) != 1) {
  throw new Error("failed");
}
if (/* await */(default_args_c.foo43()) != 43) {
  throw new Error("failed");
}

var f = new default_args_c.FooStruct();
/* await */(f.no_arg());
/* await */(f.one_req(null));
/* await */(f.one_opt());
/* await */(f.one_opt(null));
/* await */(f.two_arg(null));
/* await */(f.two_arg(null, null));

/* await */(default_args_c.StaticStruct.no_arg());
/* await */(default_args_c.StaticStruct.one_req(null));
/* await */(default_args_c.StaticStruct.one_opt());
/* await */(default_args_c.StaticStruct.one_opt(null));
/* await */(default_args_c.StaticStruct.two_arg(null));
/* await */(default_args_c.StaticStruct.two_arg(null, null));

/* await */(default_args_c.global_opts1());
/* await */(default_args_c.global_opts1(null));
/* await */(default_args_c.global_opts2(null));
/* await */(default_args_c.global_opts2(null, null));
