import typedef_funcptr

a = 100
b = 10

if typedef_funcptr.do_op(a,b,typedef_funcptr.addf) != 110:
  raise RuntimeError("addf failed")
if typedef_funcptr.do_op(a,b,typedef_funcptr.subf) != 90:
  raise RuntimeError("subf failed")

if typedef_funcptr.do_op_typedef_int(a,b,typedef_funcptr.addf) != 110:
  raise RuntimeError("addf failed")
if typedef_funcptr.do_op_typedef_int(a,b,typedef_funcptr.subf) != 90:
  raise RuntimeError("subf failed")

if typedef_funcptr.do_op_typedef_Integer(a,b,typedef_funcptr.addf) != 110:
  raise RuntimeError("addf failed")
if typedef_funcptr.do_op_typedef_Integer(a,b,typedef_funcptr.subf) != 90:
  raise RuntimeError("subf failed")

if typedef_funcptr.do_op(a,b,typedef_funcptr.get_op_typedef_int(0)) != 110:
  raise RuntimeError("get_op_typedef_int failed")
if typedef_funcptr.do_op(a,b,typedef_funcptr.get_op(1)) != 90:
  raise RuntimeError("get_op failed")

holder = typedef_funcptr.OpHolder()
if typedef_funcptr.do_op(a,b,holder.get_member_op()) != 110:
  raise RuntimeError("get_member_op failed")
if typedef_funcptr.do_op(a,b,holder.get_static_op()) != 90:
  raise RuntimeError("get_static_op failed")
holder.member_fn = typedef_funcptr.subf
if typedef_funcptr.do_op(a,b,holder.member_fn) != 90:
  raise RuntimeError("member_fn failed")

if typedef_funcptr.do_op(a,b,typedef_funcptr.cvar.static_op_const_ref) != 90:
  raise RuntimeError("static_op_const_ref failed")
if typedef_funcptr.do_op_const_ref(a,b,typedef_funcptr.get_op_const_ref()) != 90:
  raise RuntimeError("get_op_const_ref failed")

