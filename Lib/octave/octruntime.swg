%insert(runtime) %{
#include <iostream>
#include <octave/oct.h>
#include <octave/parse.h>
#include <octave/ov-fcn-handle.h>
#include <octave/Cell.h>
#include <octave/oct-map.h>
#include <octave/toplev.h>
%}

%insert(runtime) "swigrun.swg";
%insert(runtime) "swigerrors.swg";
%insert(runtime) "octrun.swg";

%insert(initbeforefunc) "swiginit.swg"

%insert(initbeforefunc) %{

static void SWIG_init_user(octave_swig_type* module_ns);

#if OCTAVE_API_VERSION_NUMBER>=37
octave_value_list SWIG_atexit_func(const octave_value_list &args, int nargout);
#endif

DEFUN_DLD (SWIG_name,args,nargout,SWIG_name_d) {

  // determine if module is already loaded
  bool already_load;
#if OCTAVE_API_VERSION_NUMBER<37
  {
    symbol_record *rec = curr_sym_tab->lookup(SWIG_name_d);
    already_load = (rec && rec->is_linked_to_global());
  }
#else
  already_load = symbol_table::is_global(SWIG_name_d);
#endif
  if (!already_load) {

    // parse command line
    const char* usage="usage: " SWIG_name_d " [-global|-noglobal] [-globals {<name>|.}]";
    bool global_load=SWIG_global_load;
    std::string global_name=SWIG_global_name;
    for (int j=0;j<args.length();++j)
      if (args(j).is_string()) {
        if (args(j).string_value()=="-help") {
          std::cout << usage << std::endl;
          return octave_value_list();
        } else if (args(j).string_value()=="-global") {
          global_load = true;
        } else if (args(j).string_value()=="-noglobal") {
          global_load = false;
        } else if (args(j).string_value()=="-globals") {
          if (j+1<args.length()&&args(j+1).is_string()) {
            global_name = args(j+1).string_value();
            ++j;
          } else {
            std::cerr << "error: " SWIG_name_d ": option '-globals' requires an argument." << std::endl;
            std::cerr << usage << std::endl;
            return octave_value_list();
          }
        } else {
          std::cerr << "error: " SWIG_name_d ": unrecognised argument '" << args(j).string_value() << "'." << std::endl;
          std::cerr << usage << std::endl;
          return octave_value_list();
        }
      } else {
        std::cerr << "error: " SWIG_name_d ": unrecognised non-string argument." << std::endl;
        std::cerr << usage << std::endl;
        return octave_value_list();
      }
  
    if (global_name != "." && !valid_identifier(global_name)) {
      std::cerr << "error: " SWIG_name_d ": '" << global_name << "' is not a valid Octave identifier." << std::endl;
      return octave_value_list();
    }
  
    // load module in base frame
#if OCTAVE_API_VERSION_NUMBER<37
    symbol_table *prev_sym_tab = curr_sym_tab;
    curr_sym_tab = top_level_sym_tab;
#else
    octave_call_stack::goto_base_frame();
#endif
  
    octave_swig_ref::register_type();
    octave_swig_packed::register_type();
    SWIG_InitializeModule(0);
    SWIG_PropagateClientData();
    
    install_builtin_function(swig_type,"swig_type",std::string());
    install_builtin_function(swig_typequery,"swig_typequery",std::string());
    install_builtin_function(swig_this,"swig_this",std::string());
    install_builtin_function(swig_subclass,"subclass",std::string());
  
    octave_swig_type* cvar_ns=0;
    if (global_name != ".") {
      cvar_ns=new octave_swig_type;
      for (int j=0;swig_globals[j].name;++j)
        if (swig_globals[j].get_method)
          cvar_ns->assign(swig_globals[j].name,&swig_globals[j]);
    }
  
    octave_swig_type* module_ns=new octave_swig_type(0, 0, 0, true);
    if (global_name != ".") {
      module_ns->assign(global_name,Swig::swig_value_ref(cvar_ns));
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
  
    // the incref is necessary so install_global doesn't destroy module_ns,
    // as it would if it installed something with the same name as the module.
    module_ns->incref();
    module_ns->install_global(global_load);
    module_ns->decref();
  
    // create global variable containing module
    set_global_value(SWIG_name_d,Swig::swig_value_ref(module_ns));
  
#if OCTAVE_API_VERSION_NUMBER>=37
    install_builtin_function(SWIG_atexit_func,"__swig_atexit_" SWIG_name_d "__",std::string());
    octave_add_atexit_function("__swig_atexit_" SWIG_name_d "__");
    octave_remove_atexit_function("__finish__");
#endif

    // return from base frame
#if OCTAVE_API_VERSION_NUMBER<37
    curr_sym_tab = prev_sym_tab;
#else
    octave_call_stack::pop();
#endif
  
#if OCTAVE_API_VERSION_NUMBER>=37
    mlock();
#endif

  } // !already_load
  
  // link variable to module in current context
#if OCTAVE_API_VERSION_NUMBER<37
  link_to_global_variable(curr_sym_tab->lookup(SWIG_name_d,true));
#else
  symbol_table::varref(SWIG_name_d);
  symbol_table::mark_global(SWIG_name_d);
#endif

  return octave_value_list();
}

// workaround bug in octave where installing global variable of custom type and then
// exiting without explicitly clearing the variable causes octave to segfault.
#if OCTAVE_API_VERSION_NUMBER>=37
octave_value_list SWIG_atexit_func(const octave_value_list &args, int nargout) {
  string_vector vars = symbol_table::global_variable_names();
  for (int i = 0; i < vars.length(); i++)
    symbol_table::clear_global(vars[i]);
  symbol_table::clear_functions();
  return octave_value();
}
#endif

%}

