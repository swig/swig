//
// octruninit.swg - Octave runtime initialisation code
//

// Forward declaration of module initialisation function
SWIGINTERN bool SWIG_Octave_InitUser(SwigOctType* module_ns);

////////// Define, register, and install unary and binary operator dispatch functions //////////

#define SWIG_Octave_UnaryOp(name) \
  SWIGINTERN octave_value SWIG_Octave_UnaryOp_##name(const octave_base_value &x) { \
    return SwigOctType::dispatch_unary_op(x,#name); \
  }
#define SWIG_Octave_BinaryOp(name) \
  SWIGINTERN octave_value SWIG_Octave_BinaryOp_##name(const octave_base_value&lhs,const octave_base_value &rhs) { \
    return SwigOctType::dispatch_binary_op(lhs,rhs,#name); \
  }

SWIG_Octave_UnaryOp(not);
SWIG_Octave_UnaryOp(uplus);
SWIG_Octave_UnaryOp(uminus);
SWIG_Octave_UnaryOp(transpose);
SWIG_Octave_UnaryOp(hermitian);
SWIG_Octave_UnaryOp(incr);
SWIG_Octave_UnaryOp(decr);

SWIG_Octave_BinaryOp(add);
SWIG_Octave_BinaryOp(sub);
SWIG_Octave_BinaryOp(mul);
SWIG_Octave_BinaryOp(div);
SWIG_Octave_BinaryOp(pow);
SWIG_Octave_BinaryOp(ldiv);
SWIG_Octave_BinaryOp(lshift);
SWIG_Octave_BinaryOp(rshift);
SWIG_Octave_BinaryOp(lt);
SWIG_Octave_BinaryOp(le);
SWIG_Octave_BinaryOp(eq);
SWIG_Octave_BinaryOp(ge);
SWIG_Octave_BinaryOp(gt);
SWIG_Octave_BinaryOp(ne);
SWIG_Octave_BinaryOp(el_mul);
SWIG_Octave_BinaryOp(el_div);
SWIG_Octave_BinaryOp(el_pow);
SWIG_Octave_BinaryOp(el_ldiv);
SWIG_Octave_BinaryOp(el_and);
SWIG_Octave_BinaryOp(el_or);

#define SWIG_Octave_RegisterUnaryOp(name) \
  if (!octave_value_typeinfo::lookup_unary_op(octave_value::op_##name,tid)) \
    octave_value_typeinfo::register_unary_op(octave_value::op_##name,tid,SWIG_Octave_UnaryOp_##name);
#define SWIG_Octave_RegisterBinaryOp(name) \
  if (!octave_value_typeinfo::lookup_binary_op(octave_value::op_##name,tid1,tid2)) \
    octave_value_typeinfo::register_binary_op(octave_value::op_##name,tid1,tid2,SWIG_Octave_BinaryOp_##name);

SWIGINTERN void SWIG_Octave_InstallUnaryOps(int tid)
{
  SWIG_Octave_RegisterUnaryOp(not);
  SWIG_Octave_RegisterUnaryOp(uplus);
  SWIG_Octave_RegisterUnaryOp(uminus);
  SWIG_Octave_RegisterUnaryOp(transpose);
  SWIG_Octave_RegisterUnaryOp(hermitian);
  SWIG_Octave_RegisterUnaryOp(incr);
  SWIG_Octave_RegisterUnaryOp(decr);
}

SWIGINTERN void SWIG_Octave_InstallBinaryOps(int tid1, int tid2)
{
  SWIG_Octave_RegisterBinaryOp(add);
  SWIG_Octave_RegisterBinaryOp(sub);
  SWIG_Octave_RegisterBinaryOp(mul);
  SWIG_Octave_RegisterBinaryOp(div);
  SWIG_Octave_RegisterBinaryOp(pow);
  SWIG_Octave_RegisterBinaryOp(ldiv);
  SWIG_Octave_RegisterBinaryOp(lshift);
  SWIG_Octave_RegisterBinaryOp(rshift);
  SWIG_Octave_RegisterBinaryOp(lt);
  SWIG_Octave_RegisterBinaryOp(le);
  SWIG_Octave_RegisterBinaryOp(eq);
  SWIG_Octave_RegisterBinaryOp(ge);
  SWIG_Octave_RegisterBinaryOp(gt);
  SWIG_Octave_RegisterBinaryOp(ne);
  SWIG_Octave_RegisterBinaryOp(el_mul);
  SWIG_Octave_RegisterBinaryOp(el_div);
  SWIG_Octave_RegisterBinaryOp(el_pow);
  SWIG_Octave_RegisterBinaryOp(el_ldiv);
  SWIG_Octave_RegisterBinaryOp(el_and);
  SWIG_Octave_RegisterBinaryOp(el_or);
}

SWIGINTERN void SWIG_Octave_InstallOps(int tid)
{
  // here we assume that tid are conseq integers increasing from zero, and
  // that our tid is the last one. might be better to have explicit string
  // list of types we should bind to, and use lookup_type to resolve their tid.
  SWIG_Octave_InstallUnaryOps(tid);
  SWIG_Octave_InstallBinaryOps(tid, tid);
  for (int j = 0; j < tid; ++j) {
    SWIG_Octave_InstallBinaryOps(j, tid);
    SWIG_Octave_InstallBinaryOps(tid, j);
  }
}

////////// Internal functions for loading/installing modules //////////

SWIGINTERN bool SWIG_Octave_LoadModule(std::string name)
{
  bool retn;
  {
#if !SWIG_OCTAVE_PREREQ(3,3,50)
    unwind_protect::begin_frame("SWIG_Octave_LoadModule");
    unwind_protect_int(error_state);
    unwind_protect_int(warning_state);
    unwind_protect_bool(discard_error_messages);
    unwind_protect_bool(discard_warning_messages);
#else
    unwind_protect frame;
    frame.protect_var(error_state);
    frame.protect_var(warning_state);
    frame.protect_var(discard_error_messages);
    frame.protect_var(discard_warning_messages);
#endif
    error_state = 0;
    warning_state = 0;
    discard_error_messages = true;
    discard_warning_messages = true;
    feval(name, octave_value_list(), 0);
    retn = (error_state == 0);
#if !SWIG_OCTAVE_PREREQ(3,3,50)
    unwind_protect::run_frame("SWIG_Octave_LoadModule");
#endif
  }
  if (!retn) {
    error(SWIG_name_d ": could not load module `%s'", name.c_str());
  }
  return retn;
}

SWIGINTERN bool SWIG_Octave_InstallFunction(octave_function* octloadfcn, std::string name)
{
  bool retn;
  {
#if !SWIG_OCTAVE_PREREQ(3,3,50)
    unwind_protect::begin_frame("SWIG_Octave_InstallFunction");
    unwind_protect_int(error_state);
    unwind_protect_int(warning_state);
    unwind_protect_bool(discard_error_messages);
    unwind_protect_bool(discard_warning_messages);
#else
    unwind_protect frame;
    frame.protect_var(error_state);
    frame.protect_var(warning_state);
    frame.protect_var(discard_error_messages);
    frame.protect_var(discard_warning_messages);
#endif
    error_state = 0;
    warning_state = 0;
    discard_error_messages = true;
    discard_warning_messages = true;
    octave_value_list args;
    args.append(name);
    args.append(octloadfcn->fcn_file_name());
    error_state = 0;
    feval("autoload", args, 0);
    retn = (error_state == 0);
#if !SWIG_OCTAVE_PREREQ(3,3,50)
    unwind_protect::run_frame("SWIG_Octave_InstallFunction");
#endif
  }
  if (!retn) {
    error(SWIG_name_d ": could not load function `%s'", name.c_str());
  }
  return retn;
}

////////// Public module function: swig_type() //////////

static const char* const swig_type_usage = "-*- texinfo -*- \n\
@deftypefn {Loadable Function} {} swig_type(@var{swigref})\n\
Return the underlying C/C++ type name of a SWIG-wrapped object.\n\
@end deftypefn";

DEFUN_DLD(swig_type, args, nargout, swig_type_usage)
{
  if (args.length() != 1) {
    error("swig_type: must be called with only a single object");
    return octave_value_list();
  }
  SwigOctType* ost = SWIG_Octave_ValueDeref(args(0));
  if (!ost) {
    error("swig_type: object is not a swig_ref");
    return octave_value_list();
  }
  return octave_value(ost->swig_type_name());
}

////////// Public module function: swig_typequery() //////////

static const char* const swig_typequery_usage = "-*- texinfo -*- \n\
@deftypefn {Loadable Function} {} swig_typequery(@var{string})\n\
Return @var{string} if it is a recognised SWIG-wrapped C/C++ type name;\n\
otherwise return `<unknown>'.\n\
@end deftypefn";

DEFUN_DLD(swig_typequery, args, nargout, swig_typequery_usage)
{
  if (args.length() != 1 || !args(0).is_string()) {
    error("swig_typequery: must be called with single string argument");
    return octave_value_list();
  }
  swig_module_info* module = SWIG_GetModule(0);
  swig_type_info* type = SWIG_TypeQueryModule(module, module, args(0).string_value().c_str());
  if (!type) {
    return octave_value("<unknown>");
  }
  return octave_value(type->name);
}

////////// Public module function: swig_this() //////////

static const char* const swig_this_usage = "-*- texinfo -*- \n\
@deftypefn {Loadable Function} {} swig_this(@var{swigref})\n\
Return the underlying C/C++ pointer of a SWIG-wrapped object.\n\
@end deftypefn";

DEFUN_DLD(swig_this, args, nargout, swig_this_usage)
{
  if (args.length() != 1) {
    error("swig_this: must be called with only a single object");
    return octave_value_list();
  }
  if (args(0).is_matrix_type() && args(0).rows() == 0 && args(0).columns() == 0) {
    return octave_value(octave_uint64(0));
  }
  SwigOctType* ost = SWIG_Octave_ValueDeref(args(0));
  if (!ost) {
    error("swig_this: object is not a swig_ref");
    return octave_value_list();
  }
  return octave_value(octave_uint64((unsigned long long) ost->swig_this()));
}

////////// Public module function: subclass() //////////

static const char* const subclass_usage = "-*- texinfo -*- \n\
@deftypefn {Loadable Function} {} subclass()\n\
@deftypefnx{Loadable Function} {} subclass(@var{swigclass}, @var{name}, @var{fcn}, @dots{})\n\
Subclass a C++ class from within Octave, and provide implementations of its virtual methods.\n\
\n\
See the SWIG manual for usage examples.\n\
@end deftypefn";

DEFUN_DLD(subclass, args, nargout, subclass_usage)
{
  SwigOctType* top = new SwigOctType;
  for (int j = 0; j < args.length(); ++j) {
    if (args(j).type_id() == SwigOctRef::static_type_id()) {
      SwigOctRef* osr = static_cast < SwigOctRef*>(args(j).internal_rep());
      SwigOctType* ost = osr->get_ptr();
      if (!ost->is_owned()) {
        error("subclass: cannot subclass object not constructed on octave side");
        return octave_value_list();
      }
      top->merge(*ost);
    } else if (args(j).is_function_handle()) {
      top->assign(args(j).fcn_handle_value()->fcn_name(), args(j));
    } else if (args(j).is_string()) {
      if (j + 1 >= args.length()) {
        error("subclass: member assignments must be of string,value form");
        return octave_value_list();
      }
      top->assign(args(j).string_value(), args(j + 1));
      ++j;
    } else {
      error("subclass: invalid arguments to subclass()");
      return octave_value_list();
    }
  }
  return octave_value(SWIG_Octave_ValueRef(top));
}

////////// Public function which loads the Octave module //////////

static const char* const SWIG_name_usage = "-*- texinfo -*- \n\
@deftypefn {Loadable Module} {} " SWIG_name_d "\n\
Loads the SWIG-generated module `" SWIG_name_d "'.\n\
@end deftypefn";

DEFUN_DLD(SWIG_name, args, nargout, SWIG_name_usage)
{

  static SwigOctType* module_ns = 0;

  // workaround to prevent octave seg-faulting on exit: set Octave exit function
  // octave_exit to _Exit, which exits immediately without trying to cleanup memory.
  // definitely affects version 3.2.*, not sure about 3.3.*, seems to be fixed in
  // version 3.4.* and above. can be turned off with macro definition.
#ifndef SWIG_OCTAVE_NO_SEGFAULT_HACK
#if !SWIG_OCTAVE_PREREQ(3,4,1)
  octave_exit = ::_Exit;
#endif
#endif

  // check for no input and output args
  if (args.length() != 0 || nargout != 0) {
    print_usage();
    return octave_value_list();
  }

  // create module on first function call
  if (!module_ns) {

    // workaround bug in octave where installing global variable of custom type and then
    // exiting without explicitly clearing the variable causes octave to segfault.
    octave_value_list eval_args;
    eval_args.append("base");
    eval_args.append("function __swig_atexit__; "
                     "  if mislocked() "
                     "    clear -all; "
                     "  else "
                     "    mlock(); "
                     "  endif; "
                     "endfunction; "
                     "__swig_atexit__; "
                     "atexit(\"__swig_atexit__\", false); "
                     "atexit(\"__swig_atexit__\")");
    feval("evalin", eval_args, 0);

    SwigOctRef::register_type();
    SwigOctPacked::register_type();
    SWIG_InitializeModule(0);
    SWIG_PropagateClientData();

    octave_function* me = octave_call_stack::current();

    if (!SWIG_Octave_InstallFunction(me, "swig_type")) {
      return octave_value_list();
    }
    if (!SWIG_Octave_InstallFunction(me, "swig_typequery")) {
      return octave_value_list();
    }
    if (!SWIG_Octave_InstallFunction(me, "swig_this")) {
      return octave_value_list();
    }
    if (!SWIG_Octave_InstallFunction(me, "subclass")) {
      return octave_value_list();
    }

    SwigOctType* cvar_ns = 0;
    if (std::string(SWIG_global_name) != ".") {
      cvar_ns = new SwigOctType;
      for (int j = 0; swig_globals[j].name; ++j)
        if (swig_globals[j].get_method) {
          cvar_ns->assign(swig_globals[j].name, &swig_globals[j]);
        }
    }

    module_ns = new SwigOctType(0, 0, 0, true);
    if (std::string(SWIG_global_name) != ".") {
      module_ns->assign(SWIG_global_name, SWIG_Octave_ValueRef(cvar_ns));
    } else {
      for (int j = 0; swig_globals[j].name; ++j)
        if (swig_globals[j].get_method) {
          module_ns->assign(swig_globals[j].name, &swig_globals[j]);
        }
    }
    for (int j = 0; swig_globals[j].name; ++j)
      if (swig_globals[j].method) {
        module_ns->assign(swig_globals[j].name, &swig_globals[j]);
      }

    // * need better solution here; swig_type -> octave_class mapping is
    // * really n-to-1, in some cases such as template partial spec, etc.
    // * see failing tests.
    for (int j = 0; swig_types[j]; ++j)
      if (swig_types[j]->clientdata) {
        SwigOctClass* c = (SwigOctClass*) swig_types[j]->clientdata;
        module_ns->assign(c->name,
                          SWIG_Octave_ValueRef
                          (new SwigOctType(0, swig_types[j])));
      }

    if (!SWIG_Octave_InitUser(module_ns)) {
      delete module_ns;
      module_ns = 0;
      return octave_value_list();
    }

    SWIG_Octave_InstallOps(SwigOctRef::static_type_id());

    SwigOctType::swig_member_const_iterator mb;
    for (mb = module_ns->swig_members_begin(); mb != module_ns->swig_members_end(); ++mb) {
      if (mb->second.first && mb->second.first->method) {
        if (!SWIG_Octave_InstallFunction(me, mb->first)) {
          return octave_value_list();
        }
      }
    }

    mlock();

  }

  SwigOctType::swig_member_const_iterator mb;
  for (mb = module_ns->swig_members_begin(); mb != module_ns->swig_members_end(); ++mb) {
    if (mb->second.second.is_defined()) {
      SWIG_Octave_SetGlobalValue(mb->first, mb->second.second);
      SWIG_Octave_LinkGlobalValue(mb->first);
    }
  }

  SWIG_Octave_SetGlobalValue(SWIG_name_d, module_ns->as_value());
  SWIG_Octave_LinkGlobalValue(SWIG_name_d);

  return octave_value_list();

}
