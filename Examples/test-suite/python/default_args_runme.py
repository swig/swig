import default_args 


if default_args.Statics.staticmethod() != 60:
  raise RuntimeError
  
if default_args.cfunc1(1) != 2:
  raise RuntimeError

if default_args.cfunc2(1) != 3:
  raise RuntimeError

if default_args.cfunc3(1) != 4:
  raise RuntimeError



