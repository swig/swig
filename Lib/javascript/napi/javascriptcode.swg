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
// js_ctor
void $jsmangledname_construct(SWIG_NAPI_ObjectWrapBase *swig_this, const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();

  $jslocals
  if(static_cast<int>(info.Length()) < $jsargrequired || static_cast<int>(info.Length()) > $jsargcount) {
    SWIG_Error(SWIG_ERROR, "Illegal number of arguments for $jswrapper.");
  }
  $jscode
  swig_this->self = result;
  return;
  goto fail;
fail:
  return;
}
%}


/* -----------------------------------------------------------------------------
 * js_veto_ctor:  a vetoing ctor for abstract classes
 *   - $jsmangledname:    mangled name of class
 *   - $jsparent:         mangled name of parent (or SWIG_NAPI_ObjectWrap if none)
 * ----------------------------------------------------------------------------- */
%fragment ("js_veto_ctor", "templates")
%{
// js_veto_ctor
void $jsmangledname_construct(SWIG_NAPI_ObjectWrapBase *, const Napi::CallbackInfo &info) {
  SWIG_NAPI_Raise(info.Env(), "Class $jsname can not be instantiated");
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
void $jsmangledname_construct(SWIG_NAPI_ObjectWrapBase *swig_this, const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
  Napi::Object self;
  NAPI_CHECK_RESULT(info.This().ToObject(), self);

  // switch all cases by means of series of if-returns.
  $jsdispatchcases

  // default:
  SWIG_Error(SWIG_ERROR, "Illegal arguments for construction of $jsmangledname");

  goto fail;
fail:
  return;
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
void $jswrapper(SWIG_NAPI_ObjectWrapBase *swig_this, const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
  Napi::Object self;
  $jslocals
  NAPI_CHECK_RESULT(info.This().ToObject(), self);
  if(static_cast<int>(info.Length()) < $jsargrequired || static_cast<int>(info.Length()) > $jsargcount) {
    SWIG_Error(SWIG_ERROR, "Illegal number of arguments for $jswrapper.");
  }
  $jscode
  swig_this->self = result;
  return;

  goto fail;
fail:
  return;
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
      $jswrapper(swig_this, info);
    } catch (const Napi::TypeError &) {
      tryNext = true;
    } catch (const Napi::Error &e) {
      throw e;
    }
    if (!tryNext)
      return;
#else
    $jswrapper(swig_this, info);
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
void $jsmangledname_destruct(SWIG_NAPI_ObjectWrapBase *) {
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
void ${classname_mangled}_destruct(SWIG_NAPI_ObjectWrapBase *swig_this) {
  auto arg1 = reinterpret_cast<$jstype>(swig_this->self);
  if (swig_this->owned && arg1) {
    ${destructor_action}
    swig_this->self = nullptr;
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
template <typename SWIG_NAPI_Tag>
Napi::Value SWIG_NAPI_ObjectWrap_templ<SWIG_NAPI_Tag>::$jswrapper(const Napi::CallbackInfo &info) {
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
template <typename SWIG_NAPI_Tag>
void SWIG_NAPI_ObjectWrap_templ<SWIG_NAPI_Tag>::$jswrapper(const Napi::CallbackInfo &info, const Napi::Value &value) {
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
template <typename SWIG_NAPI_Tag>
Napi::Value SWIG_NAPI_ObjectWrap_templ<SWIG_NAPI_Tag>::$jswrapper(const Napi::CallbackInfo &info) {
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
template <typename SWIG_NAPI_Tag>
Napi::Value SWIG_NAPI_ObjectWrap_templ<SWIG_NAPI_Tag>::$jswrapper(const Napi::CallbackInfo &info) {
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
template <typename SWIG_NAPI_Tag>
Napi::Value SWIG_NAPI_ObjectWrap_templ<SWIG_NAPI_Tag>::$jswrapper(const Napi::CallbackInfo &info) {
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
  void $jsmangledname_construct(SWIG_NAPI_ObjectWrapBase *, const Napi::CallbackInfo &);
  void $jsmangledname_destruct(SWIG_NAPI_ObjectWrapBase *);
  void $jsmangledname_GetMembers(
    Napi::Env,
    std::map<std::string, napi_property_descriptor> &,
    std::map<std::string, napi_property_descriptor> &
  );
  Napi::Function $jsmangledname_GetClass(Napi::Env);
%}


/* -----------------------------------------------------------------------------
 * jsnapi_class_dtor_declaration:  template for a class destructor declaration
 *   - $jsmangledname:  mangled class name
 * ----------------------------------------------------------------------------- */
%fragment("jsnapi_class_dtor_declaration", "templates")
%{
    // jsnapi_class_dtor_declaration
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
%fragment("jsnapi_class_ctor_declaration", "templates")
%{
  // jsnapi_class_ctor_declaration
  void $jswrapper(SWIG_NAPI_ObjectWrapBase *, const Napi::CallbackInfo &);
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
%}


/* -----------------------------------------------------------------------------
 * jsnapi_class_instance:  template for a class declaration instance
 *   - $jsmangledname:  mangled class name
 * ----------------------------------------------------------------------------- */
%fragment("jsnapi_declare_class_instance", "templates")
%{
  // jsnapi_class_instance
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
  void $jsmangledname_construct(SWIG_NAPI_ObjectWrapBase *, const Napi::CallbackInfo &);
  void $jsmangledname_destruct(SWIG_NAPI_ObjectWrapBase *);
  void $jsmangledname_GetMembers(
    Napi::Env,
    std::map<std::string, napi_property_descriptor> &,
    std::map<std::string, napi_property_descriptor> &
  );
  Napi::Function $jsmangledname_GetClass(Napi::Env);
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
Napi::Function $jsmangledname_GetClass(Napi::Env env) {
  std::map<std::string, napi_property_descriptor> members, staticMembers;
  $jsmangledname_GetMembers(env, members, staticMembers);

  std::vector<SWIG_NAPI_ObjectWrap_inst::PropertyDescriptor> symbolTable;
  symbolTable.reserve(members.size() + staticMembers.size());
  for (auto it = members.begin(); it != members.end(); it++)
    symbolTable.push_back(it->second);
  for (auto it = staticMembers.begin(); it != staticMembers.end(); it++)
    symbolTable.push_back(it->second);

  static SWIG_NAPI_ClassData klass{
    SWIGTYPE_$jsmangledtype,
    &$jsmangledname_construct,
    $jsdestruct
  };

  return SWIG_NAPI_ObjectWrap_inst::DefineClass(env, "$jsname", symbolTable, &klass);
}

void $jsmangledname_GetMembers(
        Napi::Env env,
        std::map<std::string, napi_property_descriptor> &members,
        std::map<std::string, napi_property_descriptor> &staticMembers
) {
    std::map<std::string, napi_property_descriptor> baseMembers, baseStaticMembers;
    $jsparent_GetMembers(env, baseMembers, baseStaticMembers);
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
  Napi::Function $jsmangledname_ctor = $jsmangledname_GetClass(env);
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
        SWIG_NAPI_ObjectWrap_inst::InstanceMethod("$jsname",
                &SWIG_NAPI_ObjectWrap_inst::$jswrapper,
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
        SWIG_NAPI_ObjectWrap_inst::InstanceAccessor("$jsname",
                &SWIG_NAPI_ObjectWrap_inst::$jsgetter,
                &SWIG_NAPI_ObjectWrap_inst::$jssetter,
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
        SWIG_NAPI_ObjectWrap_inst::StaticMethod("$jsname",
                &SWIG_NAPI_ObjectWrap_inst::$jswrapper,
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
        SWIG_NAPI_ObjectWrap_inst::StaticAccessor("$jsname",
                &SWIG_NAPI_ObjectWrap_inst::$jsgetter,
                &SWIG_NAPI_ObjectWrap_inst::$jssetter,
                static_cast<napi_property_attributes>(napi_writable | napi_enumerable | napi_configurable))
        });
%}


/* -----------------------------------------------------------------------------
 * jsnapi_wrappers_class:  the class containing all the generated wrappers
 *   - $jswrapperdeclarations:  declarations of all the wrapper functions
 *
 * The wrappers don't use anything from the object they're called on, taking
 * everything they need from the Napi::CallbackInfo, so they are all members of
 * this single class instead of being instantiated once per wrapped class,
 * which would take a lot of time and memory to compile for the bigger modules.
 *
 * The wrapped object data is inherited virtually because the class templates
 * used for the wrapper classes inherit it too and both of them are bases of
 * every wrapper class.
 * ----------------------------------------------------------------------------- */
%fragment("jsnapi_wrappers_class", "templates")
%{
  // jsnapi_wrappers_class
  //
  // The single class wrapping the objects of all the wrapped classes: which
  // one it is is determined by the data DefineClass() was called with.
  //
  // It is a template only in order to make its Napi::ObjectWrap<> base
  // dependent: the names of the members of the latter, such as Value(), would
  // otherwise hide the global names of the same name used in the bodies of the
  // wrappers, which are generated without knowing anything about the class
  // containing them. It is instantiated exactly once, so this doesn't cost
  // anything, and keeping the wrappers members of this class, rather than of a
  // base of it, avoids adjusting the object pointer at every call.
  template <typename SWIG_NAPI_Tag>
  class SWIG_NAPI_ObjectWrap_templ
    : public Napi::ObjectWrap<SWIG_NAPI_ObjectWrap_templ<SWIG_NAPI_Tag>>,
      public SWIG_NAPI_ObjectWrapBase {
    public:
      SWIG_NAPI_ObjectWrap_templ(const Napi::CallbackInfo &info);
      virtual ~SWIG_NAPI_ObjectWrap_templ();

      Napi::Value ToString(const Napi::CallbackInfo &info);

      static Napi::Function GetClass(Napi::Env);

      static void JS_veto_set_static_variable(const Napi::CallbackInfo &info, const Napi::Value &) {
        SWIG_NAPI_Raise(info.Env(), "Tried to write read-only variable.");
      }
      void JS_veto_set_variable(const Napi::CallbackInfo &info, const Napi::Value &) {
        SWIG_NAPI_Raise(info.Env(), "Tried to write read-only variable.");
      }

$jswrapperdeclarations

    private:
      const SWIG_NAPI_ClassData *klass;
  };

  template <typename SWIG_NAPI_Tag>
  SWIG_NAPI_ObjectWrap_templ<SWIG_NAPI_Tag>::SWIG_NAPI_ObjectWrap_templ(const Napi::CallbackInfo &info) :
        Napi::ObjectWrap<SWIG_NAPI_ObjectWrap_templ<SWIG_NAPI_Tag>>(info),
        klass(static_cast<const SWIG_NAPI_ClassData *>(info.Data())) {
    Napi::Env env = info.Env();

    if (klass != nullptr)
      this->info = klass->type;

    if (info.Length() == 1 && info[0].IsExternal()) {
      // This constructor has been called internally from C++/SWIG
      // to wrap an already existing C++ object in JS
      this->self = info[0].As<Napi::External<void>>().Data();
      this->owned = false;
      return;
    }

    if (klass == nullptr || klass->construct == nullptr) {
      SWIG_NAPI_Raise(env, "This constructor is not accessible from JS");
      return;
    }

    klass->construct(this, info);
  }

  template <typename SWIG_NAPI_Tag>
  SWIG_NAPI_ObjectWrap_templ<SWIG_NAPI_Tag>::~SWIG_NAPI_ObjectWrap_templ() {
    if (klass != nullptr && klass->destruct != nullptr)
      klass->destruct(this);
  }

  template <typename SWIG_NAPI_Tag>
  Napi::Value SWIG_NAPI_ObjectWrap_templ<SWIG_NAPI_Tag>::ToString(const Napi::CallbackInfo &info) {
    Napi::Env env = info.Env();
    static char repr[128];
    const char *name = SWIG_TypePrettyName(this->info);
    snprintf(repr, sizeof(repr), "{SwigObject %s (%s) at %p %s}",
      this->info ? this->info->name : "unknown",
      name ? name : "unknown",
      this->self,
      this->owned ? "[owned]" : "[copy]");
    return Napi::String::New(env, repr);
  }

  void SWIG_NAPI_ObjectWrap_GetMembers(
          Napi::Env env,
          std::map<std::string, napi_property_descriptor> &members,
          std::map<std::string, napi_property_descriptor> &
  ) {
    members.erase("toString");
    members.insert({"toString", SWIG_NAPI_ObjectWrap_inst::InstanceMethod("toString", &SWIG_NAPI_ObjectWrap_inst::ToString)});
  }

  template <typename SWIG_NAPI_Tag>
  Napi::Function SWIG_NAPI_ObjectWrap_templ<SWIG_NAPI_Tag>::GetClass(Napi::Env env) {
    return SWIG_NAPI_ObjectWrap_inst::DefineClass(env, "SwigObject", {});
  }

  SWIGRUNTIME void SWIG_NAPI_SetPackedSize(Napi::Object objRef, size_t size) {
    Napi::ObjectWrap<SWIG_NAPI_ObjectWrap_inst>::Unwrap(objRef)->size = size;
  }

SWIGRUNTIME int SWIG_NAPI_ConvertInstancePtr(Napi::Object objRef, void **ptr, swig_type_info *info, int flags) {
  SWIG_NAPI_ObjectWrap_inst *ow;
  Napi::Env env = objRef.Env();
  if(!objRef.IsObject()) return SWIG_ERROR;

  // Check if this is a SWIG wrapper
  Napi::FunctionReference *ctor = env.GetInstanceData<EnvInstanceData>()->SWIG_NAPI_ObjectWrapCtor;
  bool instanceOf;
  NAPI_CHECK_RESULT(objRef.InstanceOf(ctor->Value()), instanceOf);
  if (!instanceOf) {
    return SWIG_TypeError;
  }

  ow = Napi::ObjectWrap<SWIG_NAPI_ObjectWrap_inst>::Unwrap(objRef);

  // Now check if the SWIG type is compatible unless the types match exactly or the type is unknown
  if(info && ow->info != info && ow->info != nullptr) {
    swig_cast_info *tc = SWIG_TypeCheckStruct(ow->info, info);
    if (!tc && ow->info->name) {
      tc = SWIG_TypeCheck(ow->info->name, info);
    }
    bool type_valid = tc != 0;
    if(!type_valid) {
      return SWIG_TypeError;
    }
    int newmemory = 0;
    *ptr = SWIG_TypeCast(tc, ow->self, &newmemory);
    assert(!newmemory); /* newmemory handling not yet implemented */
  } else {
    *ptr = ow->self;
  }

  if (((flags & SWIG_POINTER_RELEASE) == SWIG_POINTER_RELEASE) && !ow->owned) {
    return SWIG_ERROR_RELEASE_NOT_OWNED;
  } else {
    if (flags & SWIG_POINTER_DISOWN) {
      ow->owned = false;
    }
    if (flags & SWIG_POINTER_CLEAR) {
      ow->self = nullptr;
    }
  }
  return SWIG_OK;
  goto fail;
fail:
  return SWIG_ERROR;
}


SWIGRUNTIME int SWIG_NAPI_GetInstancePtr(Napi::Value valRef, void **ptr) {
  SWIG_NAPI_ObjectWrap_inst *ow;
  if(!valRef.IsObject()) {
    return SWIG_TypeError;
  }
  Napi::Object objRef;
  NAPI_CHECK_RESULT(valRef.ToObject(), objRef);
  ow = Napi::ObjectWrap<SWIG_NAPI_ObjectWrap_inst>::Unwrap(objRef);

  if(ow->self == nullptr) {
    return SWIG_ERROR;
  }

  *ptr = ow->self;
  return SWIG_OK;
  goto fail;
fail:
  return SWIG_ERROR;
}


SWIGRUNTIME int SWIG_NAPI_ConvertPtr(Napi::Value valRef, void **ptr, swig_type_info *info, int flags) {
  // special case: JavaScript null => C NULL pointer
  if (valRef.IsNull()) {
    *ptr=0;
    return (flags & SWIG_POINTER_NO_NULL) ? SWIG_NullReferenceError : SWIG_OK;
  }

  if (!valRef.IsObject()) {
    return SWIG_TypeError;
  }

  Napi::Object objRef;
  NAPI_CHECK_RESULT(valRef.ToObject(), objRef);
  return SWIG_NAPI_ConvertInstancePtr(objRef, ptr, info, flags);
  goto fail;
fail:
  return SWIG_ERROR;
}

SWIGRUNTIME Napi::Value SWIG_NAPI_NewPointerObj(Napi::Env env, void *ptr, swig_type_info *info, int flags) {
  Napi::External<void> native;
  Napi::FunctionReference *ctor;

  if (ptr == nullptr) {
    return env.Null();
  }
  native = Napi::External<void>::New(env, ptr);

  size_t *idx = info != nullptr ?
        reinterpret_cast<SWIG_NAPI_ClientData *>(info->clientdata) :
        nullptr;
  if (idx == nullptr) {
    // This type does not have a dedicated wrapper
    ctor = env.GetInstanceData<EnvInstanceData>()->SWIG_NAPI_ObjectWrapCtor;
  } else {
    ctor = env.GetInstanceData<EnvInstanceData>()->ctor[*idx];
  }

  Napi::Value wrapped;
  NAPI_CHECK_RESULT(ctor->New({native}), wrapped);

  // Preserve the type even if using the generic wrapper
  if (idx == nullptr && info != nullptr) {
    Napi::Object obj;
    NAPI_CHECK_RESULT(wrapped.ToObject(), obj);
    Napi::ObjectWrap<SWIG_NAPI_ObjectWrap_inst>::Unwrap(obj)->info = info;
  }

  if ((flags & SWIG_POINTER_OWN) == SWIG_POINTER_OWN) {
    Napi::Object obj;
    NAPI_CHECK_RESULT(wrapped.ToObject(), obj);
    Napi::ObjectWrap<SWIG_NAPI_ObjectWrap_inst>::Unwrap(obj)->owned = true;
  }

  return wrapped;
  goto fail;
fail:
  return Napi::Value();
}

%}
