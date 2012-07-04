%insert(runtime) %{
#include <iostream>
#include <octave/oct.h>
#include <octave/Cell.h>
#include <octave/dynamic-ld.h>
#include <octave/oct-env.h>
#include <octave/oct-map.h>
#include <octave/ov-fcn-handle.h>
#include <octave/parse.h>
#include <octave/toplev.h>
#include <octave/unwind-prot.h>
%}

%insert(runtime) "swigrun.swg";
%insert(runtime) "swigerrors.swg";
%insert(runtime) "octrun.swg";

%insert(initbeforefunc) "swiginit.swg"

%insert(initbeforefunc) %{

static void SWIG_init_user(octave_swig_type* module_ns);

SWIGINTERN void SWIG_Octave_InstallFunction(octave_function *octloadfcn, std::string name) {
  octave_value_list args;
  args.append(name);
  args.append(octloadfcn->fcn_file_name());
  feval("autoload", args, 0);
}

static const char *const subclass_usage = "-*- texinfo -*- \n\
@deftypefn {Loadable Function} {} subclass()\n\
@deftypefnx{Loadable Function} {} subclass(@var{swigclass}, @var{name}, @var{fcn}, @dots{})\n\
Subclass a C++ class from within Octave, and provide implementations of its virtual methods.\n\
\n\
See the SWIG manual for usage examples.\n\
@end deftypefn";

DEFUN_DLD( subclass, args, nargout, subclass_usage ) {
  octave_swig_type *top = new octave_swig_type;
  for (int j = 0; j < args.length(); ++j) {
    if (args(j).type_id() == octave_swig_ref::static_type_id()) {
      octave_swig_ref *osr = static_cast < octave_swig_ref *>(args(j).internal_rep());
      octave_swig_type *ost = osr->get_ptr();
      if (!ost->is_owned()) {
        error("cannot subclass object not constructed on octave side");
        return octave_value_list();
      }
      top->merge(*ost);
    } else if (args(j).is_function_handle()) {
      top->assign(args(j).fcn_handle_value()->fcn_name(), args(j));
    } else if (args(j).is_string()) {
      if (j + 1 >= args.length()) {
        error("member assignments must be of string,value form");
        return octave_value_list();
      }
      top->assign(args(j).string_value(), args(j + 1));
      ++j;
    } else {
      error("invalid arguments to subclass()");
      return octave_value_list();
    }
  }
  return octave_value(Swig::swig_value_ref(top));
}

static const char *const swig_type_usage = "-*- texinfo -*- \n\
@deftypefn {Loadable Function} {} swig_type(@var{swigref})\n\
Return the underlying C/C++ type name of a SWIG-wrapped object.\n\
@end deftypefn";

DEFUN_DLD( swig_type, args, nargout, swig_type_usage ) {
  if (args.length() != 1) {
    error("swig_type() must be called with only a single object");
    return octave_value_list();
  }
  octave_swig_type *ost = Swig::swig_value_deref(args(0));
  if (!ost) {
    error("object is not a swig_ref");
    return octave_value_list();
  }
  return octave_value(ost->swig_type_name());
}

static const char *const swig_typequery_usage = "-*- texinfo -*- \n\
@deftypefn {Loadable Function} {} swig_typequery(@var{string})\n\
Return @var{string} if it is a recognised SWIG-wrapped C/C++ type name;\n\
otherwise return `<unknown>'.\n\
@end deftypefn";

DEFUN_DLD( swig_typequery, args, nargout, swig_typequery_usage ) {
  if (args.length() != 1 || !args(0).is_string()) {
    error("swig_typequery() must be called with single string argument");
    return octave_value_list();
  }
  swig_module_info *module = SWIG_GetModule(0);
  swig_type_info *type = SWIG_TypeQueryModule(module, module, args(0).string_value().c_str());
  if (!type)
    return octave_value("<unknown>");
  return octave_value(type->name);
}

static const char *const swig_this_usage = "-*- texinfo -*- \n\
@deftypefn {Loadable Function} {} swig_this(@var{swigref})\n\
Return the underlying C/C++ pointer of a SWIG-wrapped object.\n\
@end deftypefn";

DEFUN_DLD( swig_this, args, nargout, swig_this_usage ) {
  if (args.length() != 1) {
    error("swig_this() must be called with only a single object");
    return octave_value_list();
  }
  if (args(0).is_matrix_type() && args(0).rows() == 0 && args(0).columns() == 0)
    return octave_value(octave_uint64(0));
  octave_swig_type *ost = Swig::swig_value_deref(args(0));
  if (!ost) {
    error("object is not a swig_ref");
    return octave_value_list();
  }
  return octave_value(octave_uint64((unsigned long long) ost->swig_this()));
}

// workaround to prevent octave seg-faulting on exit: register at-exit
// function which exits octave immediately without trying to cleanup memory.
// definitely affects version 3.2.*, not sure about 3.3.*, seems to be
// fixed in version 3.4.* and above. can be turned on/off with macros.
#ifndef SWIG_OCTAVE_NO_SEGFAULT_HACK
#if 36 < OCTAVE_API_VERSION_NUMBER && OCTAVE_API_VERSION_NUMBER < 45
#define SWIG_OCTAVE_SEGFAULT_HACK
#endif
#endif
#ifdef SWIG_OCTAVE_SEGFAULT_HACK
#define _SWIG_OCT_SEGF_HACK_ATEXIT_FCN(NAME) SWIG_OCT_SEGF_HACK_ATEXIT_FCN_##NAME
#define SWIG_OCT_SEGF_HACK_ATEXIT_FCN(NAME) _SWIG_OCT_SEGF_HACK_ATEXIT_FCN(NAME)
void SWIG_OCT_SEGF_HACK_ATEXIT_FCN(SWIG_name)(void) {
  _exit(exit_status);
}
#endif

static const char *const SWIG_name_usage = "-*- texinfo -*- \n\
@deftypefn {Loadable Module} {} " SWIG_name_d "\n\
Loads the SWIG-generated module `" SWIG_name_d "'.\n\
\n\
To load the module into the global namespace:\n\
@example\n\
" SWIG_name_d ";\n\
@end example\n\
To access the module through a local variable, without loading it globally:\n\
@example\n\
" SWIG_name_d " = " SWIG_name_d ";\n\
@end example\n\
To access the module locally through a variable named, e.g. @var{modl}:\n\
@example\n\
@var{modl} = " SWIG_name_d ";\n\
@end example\n\
@end deftypefn";

DEFUN_DLD( SWIG_name, args, nargout, SWIG_name_usage ) {

  static octave_swig_type* module_ns = 0;
  octave_value_list retval;

  // create module on first function call
  if (!module_ns) {

#ifdef SWIG_OCTAVE_SEGFAULT_HACK
    atexit(SWIG_OCT_SEGF_HACK_ATEXIT_FCN(SWIG_name));
#endif

    // workaround bug in octave where installing global variable of custom type and then
    // exiting without explicitly clearing the variable causes octave to segfault.
#if OCTAVE_API_VERSION_NUMBER >= 37
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
#endif

    octave_swig_ref::register_type();
    octave_swig_packed::register_type();
    SWIG_InitializeModule(0);
    SWIG_PropagateClientData();

    octave_function *me = octave_call_stack::current();

    SWIG_Octave_InstallFunction(me, "swig_type");
    SWIG_Octave_InstallFunction(me, "swig_typequery");
    SWIG_Octave_InstallFunction(me, "swig_this");
    SWIG_Octave_InstallFunction(me, "subclass");

    octave_swig_type* cvar_ns=0;
    if (std::string(SWIG_global_name) != ".") {
      cvar_ns=new octave_swig_type;
      for (int j=0;swig_globals[j].name;++j)
        if (swig_globals[j].get_method)
          cvar_ns->assign(swig_globals[j].name,&swig_globals[j]);
    }

    module_ns=new octave_swig_type(0, 0, 0, true);
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

    // * need better solution here; swig_type -> octave_class mapping is
    // * really n-to-1, in some cases such as template partial spec, etc.
    // * see failing tests.
    for (int j=0;swig_types[j];++j)
      if (swig_types[j]->clientdata) {
        swig_octave_class* c=(swig_octave_class*)swig_types[j]->clientdata;
        module_ns->assign(c->name,
                        Swig::swig_value_ref
                        (new octave_swig_type(0,swig_types[j])));
      }

    SWIG_init_user(module_ns);

    SWIG_InstallOps(octave_swig_ref::static_type_id());

#if OCTAVE_API_VERSION_NUMBER < 37
    mlock(me->name());
#else
    mlock();
#endif

  }

  // return module if asked for
  if (args.length() == 0 && nargout == 1) {
    retval = octave_value(module_ns->as_value());
  }

  // if call with not output arguments, load globally
  else if (args.length() == 0 && nargout == 0) {

    octave_function *me = octave_call_stack::current();

    octave_swig_type::swig_member_const_iterator mb;
    for (mb = module_ns->swig_members_begin(); mb != module_ns->swig_members_end(); ++mb) {
      if (mb->second.first && mb->second.first->method) {
        SWIG_Octave_InstallFunction(me, mb->first);
      }
      else if (mb->second.second.is_defined()) {
        SWIG_Octave_SetGlobalValue(mb->first, mb->second.second);
        SWIG_Octave_LinkGlobalValue(mb->first);
      }
    }

    SWIG_Octave_SetGlobalValue(SWIG_name_d, module_ns->as_value());
    SWIG_Octave_LinkGlobalValue(SWIG_name_d);

  }

  // otherwise print usage
  else {
    print_usage();
  }

  return retval;

}

%}
