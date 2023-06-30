/* -----------------------------------------------------------------------------
 * js_ctor:  template for wrapping a ctor.
 *   - $jswrapper:        wrapper of called ctor
 *   - $jsparent:         mangled name of parent (or SWIG_NAPI_ObjectWrap if none)
 *   - $jslocals:         locals part of wrapper
 *   - $jscode:           code part of wrapper
 *   - $jsargcount:       number of arguments
 *   - $jsargrequired:    minimum number of arguments
 *   - $jsmangledname:    mangled name of class
 *   - $jsmangledtype:    mangled type of class
 * ----------------------------------------------------------------------------- */

%fragment("js_ctor", "templates") %{
template <typename SWIG_OBJ_WRAP>
// js_ctor
// This is the main constructor
$jsmangledname_templ<SWIG_OBJ_WRAP>::$jsmangledname_templ(const Napi::CallbackInfo &info)
        : $jsparent_templ<SWIG_OBJ_WRAP>(true, info) {
  Napi::Env env = info.Env();

  this->info = SWIGTYPE_$jsmangledtype;
  if (info.Length() == 1 && info[0].IsExternal()) {
    // This constructor has been called internally from C++/SWIG
    // to wrap an already existing C++ object in JS
    this->self = info[0].As<Napi::External<void>>().Data();
    this->owned = false;
    return;
  }
  this->owned = true;

  $jslocals
  if(static_cast<int>(info.Length()) < $jsargrequired || static_cast<int>(info.Length()) > $jsargcount) {
    SWIG_Error(SWIG_ERROR, "Illegal number of arguments for $jswrapper.");
  }
  $jscode
  this->self = result;
  return;
  goto fail;
fail:
  return;
}

// This is the bypass constructor to be used from child classes
template <typename SWIG_OBJ_WRAP>
$jsmangledname_templ<SWIG_OBJ_WRAP>::$jsmangledname_templ(bool, const Napi::CallbackInfo &info)
        : $jsparent_templ<SWIG_OBJ_WRAP>(true, info) {}
%}


/* -----------------------------------------------------------------------------
 * js_veto_ctor:  a vetoing ctor for abstract classes
 *   - $jsmangledname:    mangled name of class
 *   - $jsparent:         mangled name of parent (or SWIG_NAPI_ObjectWrap if none)
 * ----------------------------------------------------------------------------- */
%fragment ("js_veto_ctor", "templates")
%{
// js_veto_ctor
template <typename SWIG_OBJ_WRAP>
$jsmangledname_templ<SWIG_OBJ_WRAP>::$jsmangledname_templ(const Napi::CallbackInfo &info)
        : $jsparent_templ<SWIG_OBJ_WRAP>(true, info) {
  Napi::Env env = info.Env();
  if (info.Length() == 1 && info[0].IsExternal()) {
    // This constructor has been called internally from C++/SWIG
    // to wrap an already existing C++ object in JS as its
    // base abstract class
    this->self = info[0].As<Napi::External<void>>().Data();
    this->owned = false;
    return;
  }
  SWIG_Error(SWIG_ERROR, "Class $jsname can not be instantiated");
  return;
  goto fail;
fail:
  return;
}

// This is the extendable constructor to be used from child classes
template <typename SWIG_OBJ_WRAP>
$jsmangledname_templ<SWIG_OBJ_WRAP>::$jsmangledname_templ(bool, const Napi::CallbackInfo &info)
        : $jsparent_templ<SWIG_OBJ_WRAP>(true, info) {
}
%}


/* -----------------------------------------------------------------------------
 * js_ctor_dispatcher:  dispatcher for overloaded constructors
 *   - $jsmangledname:    mangled name of class
 *   - $jsparent:         mangled name of parent (or SWIG_NAPI_ObjectWrap if none)
 *   - $jsdispatchcases:  part containing code for dispatching
 *   - $jsmangledtype:    mangled type of class
 * ----------------------------------------------------------------------------- */
%fragment ("js_ctor_dispatcher", "templates")
%{
// js_ctor_dispatcher
template <typename SWIG_OBJ_WRAP>
$jsmangledname_templ<SWIG_OBJ_WRAP>::$jsmangledname_templ(const Napi::CallbackInfo &info)
        : $jsparent_templ<SWIG_OBJ_WRAP>(true, info) {
  Napi::Env env = info.Env();
  Napi::Object self;
  NAPI_CHECK_RESULT(info.This().ToObject(), self);
  this->info = SWIGTYPE_$jsmangledtype;
  if (info.Length() == 1 && info[0].IsExternal()) {
    // This constructor has been called internally from C++/SWIG
    // to wrap an already existing C++ object in JS
    this->self = info[0].As<Napi::External<void>>().Data();
    this->owned = false;
    return;
  }

  // switch all cases by means of series of if-returns.
  $jsdispatchcases

  // default:
  SWIG_Error(SWIG_ERROR, "Illegal arguments for construction of $jsmangledname");

  goto fail;
fail:
  return;
}

// This is the extendable constructor to be used from child classes
template <typename SWIG_OBJ_WRAP>
$jsmangledname_templ<SWIG_OBJ_WRAP>::$jsmangledname_templ(bool, const Napi::CallbackInfo &info)
        : $jsparent_templ<SWIG_OBJ_WRAP>(true, info) {
}
%}


/* -----------------------------------------------------------------------------
 * js_overloaded_ctor:  template for wrapping a ctor.
 *   - $jswrapper:        wrapper of called ctor
 *   - $jslocals:         locals part of wrapper
 *   - $jscode:           code part of wrapper
 *   - $jsargcount:       number of arguments
 *   - $jsargrequired:    minimum number of arguments
 *   - $jsmangledtype:    mangled type of class
 * ----------------------------------------------------------------------------- */
%fragment("js_overloaded_ctor", "templates") %{
// js_overloaded_ctor
template <typename SWIG_OBJ_WRAP>
Napi::Value $jsmangledname_templ<SWIG_OBJ_WRAP>::$jswrapper(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
  Napi::Object self;
  $jslocals
  NAPI_CHECK_RESULT(info.This().ToObject(), self);
  this->owned = true;
  if(static_cast<int>(info.Length()) < $jsargrequired || static_cast<int>(info.Length()) > $jsargcount) {
    SWIG_Error(SWIG_ERROR, "Illegal number of arguments for $jswrapper.");
  }
  $jscode
  this->self = result;

  goto fail;
fail:
  return Napi::Value();
}
%}


/* -----------------------------------------------------------------------------
 * js_ctor_dispatch_case:  template for a dispatch case for calling an overloaded ctor.
 *   - $jsargcount:       number of arguments of called ctor
 *   - $jsargrequired:    minimum number of arguments
 *   - $jswrapper:        wrapper of called ctor
 *
 *  Note: a try-catch-like mechanism is used to switch cases
 * ----------------------------------------------------------------------------- */
%fragment ("js_ctor_dispatch_case", "templates")
%{
  // js_ctor_dispatch_case
  if(static_cast<int>(info.Length()) >= $jsargrequired && static_cast<int>(info.Length()) <= $jsargcount) {
#ifdef NAPI_CPP_EXCEPTIONS
    bool tryNext = false;
    try {
      $jswrapper(info);
    } catch (const Napi::TypeError &) {
      tryNext = true;
    } catch (const Napi::Error &e) {
      throw e;
    }
    if (!tryNext)
      return;
#else
    $jswrapper(info);
    if (env.IsExceptionPending()) {
      Napi::Error e = env.GetAndClearPendingException();
      Napi::Value typeErrorValue;
      bool isTypeError;
      Napi::Function typeErrorCons;
      // Yes, this is ugly
      // TODO: Fix this in Node.js when the core team grows up
      NAPI_CHECK_RESULT(env.Global().Get("TypeError"), typeErrorValue);
      typeErrorCons = typeErrorValue.As<Napi::Function>();
      NAPI_CHECK_RESULT(e.Value().InstanceOf(typeErrorCons), isTypeError);
      if (!isTypeError) {
        // This is not the error you are looking for
        e.ThrowAsJavaScriptException();
        SWIG_fail;
      }
    } else {
      return;
    }
#endif
  }
%}


/* -----------------------------------------------------------------------------
 * js_check_arg:  template for checking if an argument exists
 *   - $jsarg: number of argument
 * ----------------------------------------------------------------------------- */
%fragment ("js_check_arg", "templates")
%{if(info.Length() > $jsarg)%}


/* -----------------------------------------------------------------------------
 * js_dtor:  template for a destructor wrapper
 *   - $jsmangledname:  mangled class name
 *   - $jstype:         class type
 * ----------------------------------------------------------------------------- */
%fragment ("js_dtor", "templates")
%{
// js_dtor
template <typename SWIG_OBJ_WRAP>
$jsmangledname_templ<SWIG_OBJ_WRAP>::~$jsmangledname_templ() {
}
%}


/* -----------------------------------------------------------------------------
 * js_dtoroverride:  template for a destructor wrapper
 *   - ${classname_mangled}:  mangled class name
 *   - $jstype:         class type
 *   - ${destructor_action}: The custom destructor action to invoke.
 * ----------------------------------------------------------------------------- */
%fragment ("js_dtoroverride", "templates")
%{
// js_dtoroverride
template <typename SWIG_OBJ_WRAP>
${classname_mangled}_templ<SWIG_OBJ_WRAP>::~${classname_mangled}_templ() {
  auto arg1 = reinterpret_cast<$jstype>(this->self);
  if (this->owned && arg1) {
    ${destructor_action}
    this->self = nullptr;
  }
}
%}

/* -----------------------------------------------------------------------------
 * js_global_getter:  template for global getter function wrappers
 *   - $jswrapper:      wrapper function name
 *   - $jslocals:       locals part of wrapper
 *   - $jscode:         code part of wrapper
 * ----------------------------------------------------------------------------- */
%fragment("js_global_getter", "templates")
%{
// js_global_getter
Napi::Value $jswrapper(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
  Napi::Value jsresult;
  $jslocals
  $jscode
  return jsresult;

  goto fail;
fail:
  return Napi::Value();
}
%}


/* -----------------------------------------------------------------------------
 * js_global_setter:  template for global setter function wrappers
 *   - $jswrapper:      wrapper function name
 *   - $jslocals:       locals part of wrapper
 *   - $jscode:         code part of wrapper
 * ----------------------------------------------------------------------------- */
%fragment("js_global_setter", "templates")
%{
// js_global_setter
void $jswrapper(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
  Napi::Value value = info.Length() > 0 ? info[0] : Napi::Value();
  Napi::Value jsresult;
  $jslocals
  $jscode
  return;

  goto fail;
fail:
  return;
}
%}


/* -----------------------------------------------------------------------------
 * jsnapi_register_global_variable:  template for a statement that registers a global variable
 *   - $jsname:         variable name
 *   - $jsparent:       parent namespace
 *   - $jsgetter:       wrapper of the getter function
 *   - $jssetter:       wrapper of the setter function
 *
 * Note: this template is also used for global variables.
 * ----------------------------------------------------------------------------- */
%fragment("jsnapi_register_global_variable", "templates")
%{
  // jsnapi_register_global_variable
  do {
    Napi::PropertyDescriptor pd = Napi::PropertyDescriptor::Accessor<$jsgetter, $jssetter>("$jsname");
    NAPI_CHECK_MAYBE($jsparent.DefineProperties({pd}));
  } while (0);
%}


/* -----------------------------------------------------------------------------
 * js_global_function:  template for function wrappers
 *   - $jswrapper:     wrapper function name
 *   - $jslocals:      locals part of wrapper
 *   - $jsargcount:    number of arguments
 *   - $jsargrequired: minimum number of arguments
 *   - $jscode:        code part of wrapper
 * ----------------------------------------------------------------------------- */
%fragment("js_global_function", "templates")
%{
// js_global_function
Napi::Value $jswrapper(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
  Napi::Value jsresult;
  $jslocals
  if(static_cast<int>(info.Length()) < $jsargrequired || static_cast<int>(info.Length()) > $jsargcount) {
    SWIG_Error(SWIG_ERROR, "Illegal number of arguments for $jswrapper.");
  }

  $jscode
  return jsresult;

  goto fail;
fail:
  return Napi::Value();
}
%}


/* -----------------------------------------------------------------------------
 * js_global_function_dispatcher:  template for a global function dispatcher for
 * global overloaded functions
 *   - $jswrapper:  wrapper function name
 *   - $jsname:     name of the wrapped function
 *   - $jslocals:   locals part of wrapper
 *   - $jscode:     code part of wrapper
 * ----------------------------------------------------------------------------- */
%fragment("js_global_function_dispatcher", "templates")
%{
// js_global_function_dispatcher
Napi::Value $jswrapper(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
  Napi::Value jsresult;
  $jscode

  SWIG_Error(SWIG_ERROR, "Illegal arguments for function $jsname.");

  goto fail;
fail:
  return Napi::Value();
}
%}


/* -----------------------------------------------------------------------------
 * jsnapi_register_global_function:  template for a statement that registers a global function
 *   - $jsname:         function name
 *   - $jsparent:       parent namespace
 *   - $jswrapper:      name of the JS wrapper
 *
 * Note: this template is also used for global variables.
 * ----------------------------------------------------------------------------- */
%fragment("jsnapi_register_global_function", "templates")
%{
  // jsnapi_register_global_function
  do {
    Napi::PropertyDescriptor pd = Napi::PropertyDescriptor::Function("$jsname", $jswrapper);
    NAPI_CHECK_MAYBE($jsparent.DefineProperties({pd}));
  } while (0);
%}


/* -----------------------------------------------------------------------------
 * js_getter:  template for getter function wrappers
 *   - $jsmangledname:  mangled class name
 *   - $jswrapper:      wrapper function name
 *   - $jslocals:       locals part of wrapper
 *   - $jscode:         code part of wrapper
 * ----------------------------------------------------------------------------- */
%fragment("js_getter", "templates")
%{
// js_getter
template <typename SWIG_OBJ_WRAP>
Napi::Value $jsmangledname_templ<SWIG_OBJ_WRAP>::$jswrapper(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
  Napi::Value jsresult;
  $jslocals
  $jscode
  return jsresult;

  goto fail;
fail:
  return Napi::Value();
}
%}


/* -----------------------------------------------------------------------------
 * js_setter:  template for setter function wrappers
 *   - $jsmangledname:  mangled class name
 *   - $jswrapper:      wrapper function name
 *   - $jslocals:       locals part of wrapper
 *   - $jscode:         code part of wrapper
 * ----------------------------------------------------------------------------- */
%fragment("js_setter", "templates")
%{
// js_setter
template <typename SWIG_OBJ_WRAP>
void $jsmangledname_templ<SWIG_OBJ_WRAP>::$jswrapper(const Napi::CallbackInfo &info, const Napi::Value &value) {
  Napi::Env env = info.Env();
  Napi::Value jsresult;
  $jslocals
  $jscode
  return;

  goto fail;
fail:
  return;
}
%}


/* -----------------------------------------------------------------------------
 * js_function:  template for function wrappers
 *   - $jsmangledname:  mangled class name
 *   - $jswrapper:      wrapper function name
 *   - $jsargcount:     minimum number of arguments
 *   - $jsargrequired:  minimum number of arguments
 *   - $jslocals:       locals part of wrapper
 *   - $jscode:         code part of wrapper
 * ----------------------------------------------------------------------------- */
%fragment("js_function", "templates")
%{
// js_function
template <typename SWIG_OBJ_WRAP>
Napi::Value $jsmangledname_templ<SWIG_OBJ_WRAP>::$jswrapper(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
  Napi::Value jsresult;
  $jslocals
  if(static_cast<int>(info.Length()) < $jsargrequired || static_cast<int>(info.Length()) > $jsargcount) {
    SWIG_Error(SWIG_ERROR, "Illegal number of arguments for $jswrapper.");
  }

  $jscode
  return jsresult;

  goto fail;
fail:
  return Napi::Value();
}
%}


/* -----------------------------------------------------------------------------
 * js_function_dispatcher:  template for a function dispatcher for overloaded functions
 *   - $jsmangledname:  mangled class name
 *   - $jswrapper:      wrapper function name
 *   - $jsname:         name of the wrapped function
 *   - $jslocals:       locals part of wrapper
 *   - $jscode:         code part of wrapper
 * ----------------------------------------------------------------------------- */
%fragment("js_function_dispatcher", "templates")
%{
// js_function_dispatcher
template <typename SWIG_OBJ_WRAP>
Napi::Value $jsmangledname_templ<SWIG_OBJ_WRAP>::$jswrapper(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
  Napi::Value jsresult;
  $jscode

  SWIG_Error(SWIG_ERROR, "Illegal arguments for function $jsname.");

  goto fail;
fail:
  return Napi::Value();
}
%}


/* -----------------------------------------------------------------------------
 * js_overloaded_function:  template for a overloaded function
 *   - $jswrapper:  wrapper function name
 *   - $jslocals:   locals part of wrapper
 *   - $jscode:     code part of wrapper
 * ----------------------------------------------------------------------------- */
%fragment ("js_overloaded_function", "templates")
%{
// js_overloaded_function
template <typename SWIG_OBJ_WRAP>
Napi::Value $jsmangledname_templ<SWIG_OBJ_WRAP>::$jswrapper(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
  Napi::Value jsresult;
  $jslocals
  $jscode
  return jsresult;

  goto fail;
fail:
  return Napi::Value();
}
%}


/* -----------------------------------------------------------------------------
 * js_global_overloaded_function:  template for a global overloaded function
 *   - $jswrapper:      wrapper function name
 *   - $jslocals:       locals part of wrapper
 *   - $jscode:         code part of wrapper
 * ----------------------------------------------------------------------------- */
%fragment ("js_global_overloaded_function", "templates")
%{
// js_global_overloaded_function
Napi::Value $jswrapper(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
  Napi::Value jsresult;
  $jslocals
  $jscode
  return jsresult;

  goto fail;
fail:
  return Napi::Value();
}
%}


/* -----------------------------------------------------------------------------
 * js_function_dispatch_case:  template for a case used in the function dispatcher
 *   - $jswrapper:     wrapper function name
 *   - $jsargcount:    number of arguments of overloaded function
 *   - $jsargrequired: minimum number of arguments
 *   - $jscode:        code part of wrapper
 * ----------------------------------------------------------------------------- */
%fragment ("js_function_dispatch_case", "templates")
%{
  // js_function_dispatch_case
  if(static_cast<int>(info.Length()) >= $jsargrequired && static_cast<int>(info.Length()) <= $jsargcount) {
#ifdef NAPI_CPP_EXCEPTIONS
    bool tryNext = false;
    try {
      jsresult = $jswrapper(info);
    } catch (const Napi::TypeError &) {
      tryNext = true;
    } catch (const Napi::Error &e) {
      throw e;
    }
    if (!tryNext)
      return jsresult;
#else
    $jswrapper(info);
    if (env.IsExceptionPending()) {
      Napi::Error e = env.GetAndClearPendingException();
      Napi::Value typeErrorValue;
      bool isTypeError;
      Napi::Function typeErrorCons;
      // Yes, this is ugly
      // TODO: Fix this in Node.js when the core team grows up
      NAPI_CHECK_RESULT(env.Global().Get("TypeError"), typeErrorValue);
      typeErrorCons = typeErrorValue.As<Napi::Function>();
      NAPI_CHECK_RESULT(e.Value().InstanceOf(typeErrorCons), isTypeError);
      if (!isTypeError) {
        // This is not the error you are looking for
        e.ThrowAsJavaScriptException();
        SWIG_fail;
      }
    } else {
      return jsresult;
    }
#endif
  }
%}

/* -----------------------------------------------------------------------------
 * jsnapi_class_prologue_template:  template for a class prologue
 *   - $jsmangledname:  mangled class name
 *   - $jsparent:       mangled name of parent (or SWIG_NAPI_ObjectWrap if none)
 * ----------------------------------------------------------------------------- */
%fragment("jsnapi_class_prologue_template", "templates")
%{
  // jsnapi_class_prologue_template
  template <typename SWIG_OBJ_WRAP>
  class $jsmangledname_templ : public $jsparent_templ<SWIG_OBJ_WRAP> {
    public:
      $jsmangledname_templ(const Napi::CallbackInfo &);
      $jsmangledname_templ(bool, const Napi::CallbackInfo &);
%}


/* -----------------------------------------------------------------------------
 * jsnapi_class_dtor_declaration:  template for a class destructor declaration
 *   - $jsmangledname:  mangled class name
 * ----------------------------------------------------------------------------- */
%fragment("jsnapi_class_dtor_declaration", "templates")
%{
    virtual ~$jsmangledname_templ();
%}


/* -----------------------------------------------------------------------------
 * jsnapi_class_method_declaration:  template for a class method declaration
 *   - $jsmangledname:  mangled class name
 *   - $jswrapper:      method name
 *   - $jsstatic:       static modifier
 * ----------------------------------------------------------------------------- */
%fragment("jsnapi_class_method_declaration", "templates")
%{
    // jsnapi_class_method_declaration
    $jsstatic Napi::Value $jswrapper(const Napi::CallbackInfo &);
%}


/* -----------------------------------------------------------------------------
 * jsnapi_class_setter_declaration:  template for a class method declaration
 *   - $jsmangledname:  mangled class name
 *   - $jswrapper:      method name
 *   - $jsstatic:       static modifier
 * ----------------------------------------------------------------------------- */
%fragment("jsnapi_class_setter_declaration", "templates")
%{
    // jsnapi_class_setter_declaration
    $jsstatic void $jswrapper(const Napi::CallbackInfo &, const Napi::Value &);
%}



/* -----------------------------------------------------------------------------
 * jsnapi_class_epilogue_template:  template for a class epilogue
 *   - $jsmangledname:  mangled class name
 * ----------------------------------------------------------------------------- */
%fragment("jsnapi_class_epilogue_template", "templates")
%{
  // jsnapi_class_epilogue_template
  static void JS_veto_set_static_variable(const Napi::CallbackInfo &, const Napi::Value &);
  void JS_veto_set_variable(const Napi::CallbackInfo &, const Napi::Value &);
};

template <typename SWIG_OBJ_WRAP>
void $jsmangledname_templ<SWIG_OBJ_WRAP>::JS_veto_set_static_variable(const Napi::CallbackInfo &info, const Napi::Value &value) {
  SWIG_NAPI_Raise(info.Env(), "Tried to write read-only variable.");
}

template <typename SWIG_OBJ_WRAP>
void $jsmangledname_templ<SWIG_OBJ_WRAP>::JS_veto_set_variable(const Napi::CallbackInfo &info, const Napi::Value &value) {
  SWIG_NAPI_Raise(info.Env(), "Tried to write read-only variable.");
}
%}


/* -----------------------------------------------------------------------------
 * jsnapi_class_instance:  template for a class declaration instance
 *   - $jsmangledname:  mangled class name
 * ----------------------------------------------------------------------------- */
%fragment("jsnapi_declare_class_instance", "templates")
%{
  // jsnapi_class_instance
  class $jsmangledname_inst : public $jsmangledname_templ<$jsmangledname_inst> {
    public:
      using $jsmangledname_templ::$jsmangledname_templ;
      virtual ~$jsmangledname_inst() {};
      static void GetMembers(
        Napi::Env,
        std::map<std::string, $jsmangledname_templ::PropertyDescriptor> &,
        std::map<std::string, $jsmangledname_templ::PropertyDescriptor> &
      );
      static Napi::Function GetClass(Napi::Env);
  };
%}


/*
 * Inheritance is still not officially supported in NAPI
 * Refer to this for my workaround: 
 * https://mmomtchev.medium.com/c-class-inheritance-with-node-api-and-node-addon-api-c180334d9902
 */

/* -----------------------------------------------------------------------------
 * jsnapi_inherited_class_prologue_template:  template for a class prologue
 *   - $jsmangledname:  mangled class name
 *   - $jsparent:       mangled name of parent class
 * ----------------------------------------------------------------------------- */
%fragment("jsnapi_inherited_class_prologue_template", "templates")
%{
  // jsnapi_inherited_class_prologue_template
  SWIG_NAPI_ClientData $jsmangledname_clientData;
  template <typename SWIG_OBJ_WRAP>
  class $jsmangledname_templ : public $jsparent_templ<SWIG_OBJ_WRAP> {
    public:
      $jsmangledname_templ(const Napi::CallbackInfo& info);
%}


/* -----------------------------------------------------------------------------
 * jsnapi_getclass:  template for creating a class object
 *   - $jsname:         class name
 *   - $jsmangledname:  mangled class name
 *   - $jsfunctions:    member functions
 * ----------------------------------------------------------------------------- */
%fragment("jsnapi_getclass", "templates")
%{
  /* Class: $jsname ($jsmangledname) */
  // jsnapi_getclass
Napi::Function $jsmangledname_inst::GetClass(Napi::Env env) {
  std::map<std::string, $jsmangledname_templ::PropertyDescriptor> members, staticMembers;
  GetMembers(env, members, staticMembers);

  std::vector<$jsmangledname_inst::PropertyDescriptor> symbolTable;
  for (auto it = members.begin(); it != members.end(); it++)
    symbolTable.push_back(it->second);
  for (auto it = staticMembers.begin(); it != staticMembers.end(); it++)
    symbolTable.push_back(it->second);

  return Napi::ObjectWrap<$jsmangledname_inst>::DefineClass(env, "$jsname", symbolTable);
}

void $jsmangledname_inst::GetMembers(
        Napi::Env env,
        std::map<std::string, $jsmangledname_templ::PropertyDescriptor> &members,
        std::map<std::string, $jsmangledname_templ::PropertyDescriptor> &staticMembers
) {
    std::map<std::string, $jsparent_templ<$jsparent_inst>::PropertyDescriptor> baseMembers, baseStaticMembers;
    $jsparent_inst::GetMembers(env, baseMembers, baseStaticMembers);
    members.insert(baseMembers.begin(), baseMembers.end());
    staticMembers.insert(staticMembers.begin(), staticMembers.end());

    /* register wrapper functions */
    $jsnapiwrappers
    /* add static class functions and variables */
    $jsnapistaticwrappers
}
%}

/* -----------------------------------------------------------------------------
 * jsnapi_registerclass:  template for regsitering a class object
 *   - $jsname:         class name
 *   - $jsmangledname:  mangled class name
 *   - $jsparent:       parent namespace
 *   - $jsmangledtype:  mangled class type
 *   - $jsclassidx:     class index in the class table
 * ----------------------------------------------------------------------------- */
%fragment("jsnapi_registerclass", "templates")
%{

  /* Class: $jsname ($jsmangledname) */
  // jsnapi_registerclass
  Napi::Function $jsmangledname_ctor = $jsmangledname_inst::GetClass(env);
  $jsparent.Set("$jsname", $jsmangledname_ctor);
  if (SWIGTYPE_$jsmangledtype->clientdata == nullptr) {
    SWIGTYPE_$jsmangledtype->clientdata = new size_t($jsclassidx);
  }
  Napi::FunctionReference *$jsmangledname_ctor_ref = new Napi::FunctionReference();
  *$jsmangledname_ctor_ref = Napi::Persistent($jsmangledname_ctor);
  env.GetInstanceData<EnvInstanceData>()->ctor[$jsclassidx] = $jsmangledname_ctor_ref;
%}

/* -----------------------------------------------------------------------------
 * jsnapi_setup_inheritance:  setup inheritance between two classes
 *   - $jsname:         class name
 *   - $jsmangledname:  mangled class name
 *   - $jsparent:       mangled name of parent class
 * ----------------------------------------------------------------------------- */
%fragment("jsnapi_setup_inheritance", "templates")
%{
  // Inheritance for $jsmangledname ($jsname) <- $jsparent
  // jsnapi_setup_inheritance
  do {
    Napi::Value protoBase, protoSub;
    NAPI_CHECK_RESULT($jsmangledname_ctor.Get("prototype"), protoSub);
    NAPI_CHECK_RESULT($jsparent_ctor.Get("prototype"), protoBase);
    NAPI_CHECK_MAYBE(setProto.Call({$jsmangledname_ctor, $jsparent_ctor}));
    NAPI_CHECK_MAYBE(setProto.Call({protoSub, protoBase}));
  } while (0);
%}

/* -----------------------------------------------------------------------------
 * jsnapi_create_namespace:  template for a statement that creates a namespace object.
 *   - $jsmangledname:  mangled namespace name
 * ----------------------------------------------------------------------------- */
%fragment("jsnapi_create_namespace", "templates")
%{
  // jsnapi_create_namespace
  Napi::Object $jsmangledname = Napi::Object::New(env);
%}

/* -----------------------------------------------------------------------------
 * jsnapi_register_namespace:  template for a statement that registers a namespace in a parent namespace.
 *   - $jsname:         name of namespace
 *   - $jsmangledname:  mangled name of namespace
 *   - $jsparent:       mangled name of parent namespace
 * ----------------------------------------------------------------------------- */
%fragment("jsnapi_register_namespace", "templates")
%{
  // jsnapi_register_namespace
  NAPI_CHECK_MAYBE($jsparent.Set("$jsname", $jsmangledname));
%}

/* -----------------------------------------------------------------------------
 * jsnapi_member_function_descriptor:  template for a statement that registers a member function.
 *   - $jsmangledname:  mangled class name
 *   - $jsname:         name of the function
 *   - $jswrapper:      wrapper of the member function
 * ----------------------------------------------------------------------------- */
%fragment("jsnapi_register_member_function", "templates")
%{
  // jsnapi_member_function_descriptor
  members.erase("$jsname");
  members.insert({"$jsname",
        $jsmangledname_templ::InstanceMethod("$jsname",
                &$jsmangledname_templ::$jswrapper,
                static_cast<napi_property_attributes>(napi_writable | napi_configurable))
        });
%}

/* -----------------------------------------------------------------------------
 * jsnapi_register_member_variable:  template for a statement that registers a member variable.
 *   - $jsname:         name of the function
 *   - $jsmangledname:  mangled class name
 *   - $jsgetter:       wrapper of the getter function
 *   - $jssetter:       wrapper of the setter function
 * ----------------------------------------------------------------------------- */
%fragment("jsnapi_register_member_variable", "templates")
%{
  // jsnapi_register_member_variable
  members.erase("$jsname");
  members.insert({"$jsname",
        $jsmangledname_templ::InstanceAccessor("$jsname",
                &$jsmangledname_templ::$jsgetter,
                &$jsmangledname_templ::$jssetter,
                static_cast<napi_property_attributes>(napi_writable | napi_enumerable | napi_configurable))
        });
%}

/* -----------------------------------------------------------------------------
 * jsnapi_register_static_function:  template for a statement that registers a static class function.
 *   - $jsname:         function name
 *   - $jsmangledname:  mangled class name
 *   - $jswrapper:      wrapper of the function
 * ----------------------------------------------------------------------------- */
%fragment("jsnapi_register_static_function", "templates")
%{
  // jsnapi_register_static_function
  staticMembers.erase("$jsname");
  staticMembers.insert({"$jsname",
        StaticMethod("$jsname",
                &$jsmangledname_templ::$jswrapper,
                static_cast<napi_property_attributes>(napi_writable | napi_configurable))
        });
%}

/* -----------------------------------------------------------------------------
 * jsnapi_register_static_variable:  template for a statement that registers a static variable.
 *   - $jsname:         variable name
 *   - $jsmangledname:  mangled class name
 *   - $jsgetter:       wrapper of the getter function
 *   - $jssetter:       wrapper of the setter function
 * ----------------------------------------------------------------------------- */
%fragment("jsnapi_register_static_variable", "templates")
%{
  // jsnapi_register_static_variable
  staticMembers.erase("$jsname");
  staticMembers.insert({"$jsname",
        StaticAccessor("$jsname",
                &$jsmangledname_templ::$jsgetter,
                &$jsmangledname_templ::$jssetter,
                static_cast<napi_property_attributes>(napi_writable | napi_enumerable | napi_configurable))
        });
%}
