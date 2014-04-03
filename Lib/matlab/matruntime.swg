%insert(runtime) %{
#include <cstdlib>
#include <iostream>
#include <matlab/mat.h>
#include <matlab/Cell.h>
#include <matlab/dynamic-ld.h>
#include <matlab/mat-env.h>
#include <matlab/mat-map.h>
#include <matlab/ov-fcn-handle.h>
#include <matlab/parse.h>
#include <matlab/toplev.h>
#include <matlab/unwind-prot.h>
%}

%insert(runtime) "swigrun.swg";
%insert(runtime) "swigerrors.swg";
%insert(runtime) "matrun.swg";

%insert(initbeforefunc) "swiginit.swg"

%insert(initbeforefunc) %{

static bool SWIG_init_user(matlab_swig_type* module_ns);

SWIGINTERN bool SWIG_Octave_LoadModule(std::string name) {
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
    feval(name, matlab_value_list(), 0);
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

SWIGINTERN bool SWIG_Octave_InstallFunction(matlab_function *matloadfcn, std::string name) {
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
    matlab_value_list args;
    args.append(name);
    args.append(matloadfcn->fcn_file_name());
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

static const char *const subclass_usage = "-*- texinfo -*- \n\
@deftypefn {Loadable Function} {} subclass()\n\
@deftypefnx{Loadable Function} {} subclass(@var{swigclass}, @var{name}, @var{fcn}, @dots{})\n\
Subclass a C++ class from within Octave, and provide implementations of its virtual methods.\n\
\n\
See the SWIG manual for usage examples.\n\
@end deftypefn";

DEFUN_DLD( subclass, args, nargout, subclass_usage ) {
  matlab_swig_type *top = new matlab_swig_type;
  for (int j = 0; j < args.length(); ++j) {
    if (args(j).type_id() == matlab_swig_ref::static_type_id()) {
      matlab_swig_ref *osr = static_cast < matlab_swig_ref *>(args(j).internal_rep());
      matlab_swig_type *ost = osr->get_ptr();
      if (!ost->is_owned()) {
        error("subclass: cannot subclass object not constructed on matlab side");
        return matlab_value_list();
      }
      top->merge(*ost);
    } else if (args(j).is_function_handle()) {
      top->assign(args(j).fcn_handle_value()->fcn_name(), args(j));
    } else if (args(j).is_string()) {
      if (j + 1 >= args.length()) {
        error("subclass: member assignments must be of string,value form");
        return matlab_value_list();
      }
      top->assign(args(j).string_value(), args(j + 1));
      ++j;
    } else {
      error("subclass: invalid arguments to subclass()");
      return matlab_value_list();
    }
  }
  return matlab_value(Swig::swig_value_ref(top));
}

static const char *const swig_type_usage = "-*- texinfo -*- \n\
@deftypefn {Loadable Function} {} swig_type(@var{swigref})\n\
Return the underlying C/C++ type name of a SWIG-wrapped object.\n\
@end deftypefn";

DEFUN_DLD( swig_type, args, nargout, swig_type_usage ) {
  if (args.length() != 1) {
    error("swig_type: must be called with only a single object");
    return matlab_value_list();
  }
  matlab_swig_type *ost = Swig::swig_value_deref(args(0));
  if (!ost) {
    error("swig_type: object is not a swig_ref");
    return matlab_value_list();
  }
  return matlab_value(ost->swig_type_name());
}

static const char *const swig_typequery_usage = "-*- texinfo -*- \n\
@deftypefn {Loadable Function} {} swig_typequery(@var{string})\n\
Return @var{string} if it is a recognised SWIG-wrapped C/C++ type name;\n\
otherwise return `<unknown>'.\n\
@end deftypefn";

DEFUN_DLD( swig_typequery, args, nargout, swig_typequery_usage ) {
  if (args.length() != 1 || !args(0).is_string()) {
    error("swig_typequery: must be called with single string argument");
    return matlab_value_list();
  }
  swig_module_info *module = SWIG_GetModule(0);
  swig_type_info *type = SWIG_TypeQueryModule(module, module, args(0).string_value().c_str());
  if (!type)
    return matlab_value("<unknown>");
  return matlab_value(type->name);
}

static const char *const swig_this_usage = "-*- texinfo -*- \n\
@deftypefn {Loadable Function} {} swig_this(@var{swigref})\n\
Return the underlying C/C++ pointer of a SWIG-wrapped object.\n\
@end deftypefn";

DEFUN_DLD( swig_this, args, nargout, swig_this_usage ) {
  if (args.length() != 1) {
    error("swig_this: must be called with only a single object");
    return matlab_value_list();
  }
  if (args(0).is_matrix_type() && args(0).rows() == 0 && args(0).columns() == 0)
    return matlab_value(matlab_uint64(0));
  matlab_swig_type *ost = Swig::swig_value_deref(args(0));
  if (!ost) {
    error("swig_this: object is not a swig_ref");
    return matlab_value_list();
  }
  return matlab_value(matlab_uint64((unsigned long long) ost->swig_this()));
}

static const char *const SWIG_name_usage = "-*- texinfo -*- \n\
@deftypefn {Loadable Module} {} " SWIG_name_d "\n\
Loads the SWIG-generated module `" SWIG_name_d "'.\n\
@end deftypefn";

DEFUN_DLD( SWIG_name, args, nargout, SWIG_name_usage ) {

  static matlab_swig_type* module_ns = 0;

  // workaround to prevent matlab seg-faulting on exit: set Octave exit function
  // matlab_exit to _Exit, which exits immediately without trying to cleanup memory.
  // definitely affects version 3.2.*, not sure about 3.3.*, seems to be fixed in
  // version 3.4.* and above. can be turned off with macro definition.
#ifndef SWIG_OCTAVE_NO_SEGFAULT_HACK
#if SWIG_OCTAVE_PREREQ(3,2,0) && !SWIG_OCTAVE_PREREQ(3,4,1)
  matlab_exit = ::_Exit;
#endif
#endif

  // check for no input and output args
  if (args.length() != 0 || nargout != 0) {
    print_usage();
    return matlab_value_list();
  }

  // create module on first function call
  if (!module_ns) {

    // workaround bug in matlab where installing global variable of custom type and then
    // exiting without explicitly clearing the variable causes matlab to segfault.
#if SWIG_OCTAVE_PREREQ(3,2,0)
    matlab_value_list eval_args;
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
#endif

    matlab_swig_ref::register_type();
    matlab_swig_packed::register_type();
    SWIG_InitializeModule(0);
    SWIG_PropagateClientData();

    matlab_function *me = matlab_call_stack::current();

    if (!SWIG_Octave_InstallFunction(me, "swig_type")) {
      return matlab_value_list();
    }
    if (!SWIG_Octave_InstallFunction(me, "swig_typequery")) {
      return matlab_value_list();
    }
    if (!SWIG_Octave_InstallFunction(me, "swig_this")) {
      return matlab_value_list();
    }
    if (!SWIG_Octave_InstallFunction(me, "subclass")) {
      return matlab_value_list();
    }

    matlab_swig_type* cvar_ns=0;
    if (std::string(SWIG_global_name) != ".") {
      cvar_ns=new matlab_swig_type;
      for (int j=0;swig_globals[j].name;++j)
        if (swig_globals[j].get_method)
          cvar_ns->assign(swig_globals[j].name,&swig_globals[j]);
    }

    module_ns=new matlab_swig_type(0, 0, 0, true);
    if (std::string(SWIG_global_name) != ".") {
      module_ns->assign(SWIG_global_name,Swig::swig_value_ref(cvar_ns));
    }
    else {
      for (int j=0;swig_globals[j].name;++j)
        if (swig_globals[j].get_method)
          module_ns->assign(swig_globals[j].name,&swig_globals[j]);
    }
    for (int j=0;swig_globals[j].name;++j)
      if (swig_globals[j].method)
        module_ns->assign(swig_globals[j].name,&swig_globals[j]);

    // * need better solution here; swig_type -> matlab_class mapping is
    // * really n-to-1, in some cases such as template partial spec, etc.
    // * see failing tests.
    for (int j=0;swig_types[j];++j)
      if (swig_types[j]->clientdata) {
        swig_matlab_class* c=(swig_matlab_class*)swig_types[j]->clientdata;
        module_ns->assign(c->name,
                        Swig::swig_value_ref
                        (new matlab_swig_type(0,swig_types[j])));
      }

    if (!SWIG_init_user(module_ns)) {
      delete module_ns;
      module_ns=0;
      return matlab_value_list();
    }

    SWIG_InstallOps(matlab_swig_ref::static_type_id());

    matlab_swig_type::swig_member_const_iterator mb;
    for (mb = module_ns->swig_members_begin(); mb != module_ns->swig_members_end(); ++mb) {
      if (mb->second.first && mb->second.first->method) {
        if (!SWIG_Octave_InstallFunction(me, mb->first)) {
          return matlab_value_list();
        }
      }
    }

#if !SWIG_OCTAVE_PREREQ(3,2,0)
    mlock(me->name());
#else
    mlock();
#endif

  }

  matlab_swig_type::swig_member_const_iterator mb;
  for (mb = module_ns->swig_members_begin(); mb != module_ns->swig_members_end(); ++mb) {
    if (mb->second.second.is_defined()) {
      SWIG_Octave_SetGlobalValue(mb->first, mb->second.second);
      SWIG_Octave_LinkGlobalValue(mb->first);
    }
  }

  SWIG_Octave_SetGlobalValue(SWIG_name_d, module_ns->as_value());
  SWIG_Octave_LinkGlobalValue(SWIG_name_d);

  return matlab_value_list();

}

%}
