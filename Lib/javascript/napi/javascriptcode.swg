/* -----------------------------------------------------------------------------
 * js_ctor:  template for wrapping a ctor.
 *   - $jswrapper:        wrapper of called ctor
 *   - $jsparent:         mangled name of parent (or SwigNapiObjectWrap if none)
 *   - $jslocals:         locals part of wrapper
 *   - $jscode:           code part of wrapper
 *   - $jsargcount:       number of arguments
 *   - $jsmangledname:    mangled name of class
 * ----------------------------------------------------------------------------- */

%fragment("js_ctor", "templates") %{
template <class T>
// This is the main constructor
$jsmangledname_templ<T>::$jsmangledname_templ(const Napi::CallbackInfo &info)
        : $jsparent_templ<T>(true, info) {
  Napi::Env env = info.Env();
  this->owned = true;

  if (info.Length() == 1 && info[0].IsExternal()) {
    this->self = info[0].As<Napi::External<void>>().Data();
    return;
  }

  $jslocals
  if(info.Length() != $jsargcount) SWIG_Error(SWIG_ERROR, "Illegal number of arguments for $jswrapper.");
  $jscode
  this->self = result;
  goto fail;
fail:
  return;
}

// This is the extendable constructor to be used from child classes
template <class T>
$jsmangledname_templ<T>::$jsmangledname_templ(bool, const Napi::CallbackInfo &info)
        : $jsparent_templ<T>(true, info) {
}
%}


/* -----------------------------------------------------------------------------
 * js_veto_ctor:  a vetoing ctor for abstract classes
 *   - $jsmangledname:    mangled name of class
 *   - $jsparent:         mangled name of parent (or SwigNapiObjectWrap if none)
 * ----------------------------------------------------------------------------- */
%fragment ("js_veto_ctor", "templates")
%{
template <class T>
$jsmangledname_templ<T>::$jsmangledname_templ(const Napi::CallbackInfo &info)
        : SwigNapiObjectWrap_templ<T>(info) {
  Napi::Env env = info.Env();
  SWIG_Error(SWIG_ERROR, "Class $jsname can not be instantiated");
#ifndef NAPI_CPP_EXCEPTIONS
fail:
  return;
#endif
}

// This is the extendable constructor to be used from child classes
template <class T>
$jsmangledname_templ<T>::$jsmangledname_templ(bool, const Napi::CallbackInfo &info)
        : $jsparent_templ<T>(true, info) {
}
%}


/* -----------------------------------------------------------------------------
 * js_ctor_dispatcher:  dispatcher for overloaded constructors
 *   - $jsmangledname:    mangled name of class
 *   - $jsparent:         mangled name of parent (or SwigNapiObjectWrap if none)
 *   - $jsdispatchcases:  part containing code for dispatching
 * ----------------------------------------------------------------------------- */
%fragment ("js_ctor_dispatcher", "templates")
%{
template <class T>
$jsmangledname_templ<T>::$jsmangledname_templ(const Napi::CallbackInfo &info)
        : $jsparent_templ<T>(info) {
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

// This is the extendable constructor to be used from child classes
template <class T>
$jsmangledname_templ<T>::$jsmangledname_templ(bool, const Napi::CallbackInfo &info)
        : $jsparent_templ<T>(true, info) {
}
%}


/* -----------------------------------------------------------------------------
 * js_overloaded_ctor:  template for wrapping a ctor.
 *   - $jswrapper:        wrapper of called ctor
 *   - $jslocals:         locals part of wrapper
 *   - $jscode:           code part of wrapper
 *   - $jsargcount:       number of arguments
 *   - $jsmangledtype:    mangled type of class
 * ----------------------------------------------------------------------------- */
%fragment("js_overloaded_ctor", "templates") %{
template <class T>
Napi::Value $jsmangledname_templ<T>::$jswrapper(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
  Napi::Object self;
  $jslocals
  NAPI_CHECK_RESULT(info.This().ToObject(), self);
  this->owned = true;
  if(info.Length() != $jsargcount) SWIG_Error(SWIG_ERROR, "Illegal number of arguments for $jswrapper.");
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
 *   - $jswrapper:        wrapper of called ctor
 *
 *  Note: a try-catch-like mechanism is used to switch cases
 * ----------------------------------------------------------------------------- */
%fragment ("js_ctor_dispatch_case", "templates")
%{
  if(info.Length() == $jsargcount) {
    $jswrapper(info);
    return;
  }
%}


/* -----------------------------------------------------------------------------
 * js_dtor:  template for a destructor wrapper
 *   - $jsmangledname:  mangled class name
 *   - $jstype:         class type
 * ----------------------------------------------------------------------------- */
%fragment ("js_dtor", "templates")
%{
template <class T>
$jsmangledname_templ<T>::~$jsmangledname_templ() {
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
template <class T>
${classname_mangled}_templ<T>::~${classname_mangled}_templ() {
  auto arg1 = reinterpret_cast<$jstype>(this->self);
  if (arg1) {
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
void $jswrapper(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
  Napi::Value value = info.Length() > 1 ? info[0] : Napi::Value();
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
 *   - $jsgetter:       wrapper of the getter function
 *   - $jssetter:       wrapper of the setter function
 *
 * Note: this template is also used for global variables.
 * ----------------------------------------------------------------------------- */
%fragment("jsnapi_register_global_variable", "templates")
%{
  do {
    Napi::PropertyDescriptor pd = Napi::PropertyDescriptor::Accessor<$jsgetter, $jssetter>("$jsname");
    NAPI_CHECK_MAYBE(exports.DefineProperties({pd}));
  } while (0);
%}


/* -----------------------------------------------------------------------------
 * js_global_function:  template for function wrappers
 *   - $jswrapper:  wrapper function name
 *   - $jslocals:   locals part of wrapper
 *   - $jscode:     code part of wrapper
 * ----------------------------------------------------------------------------- */
%fragment("js_global_function", "templates")
%{
Napi::Value $jswrapper(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
  Napi::Value jsresult;
  $jslocals
  if(info.Length() != $jsargcount) SWIG_Error(SWIG_ERROR, "Illegal number of arguments for $jswrapper.");

  $jscode
  return jsresult;

  goto fail;
fail:
  return Napi::Value();
}
%}


/* -----------------------------------------------------------------------------
 * jsnapi_register_global_function:  template for a statement that registers a global function
 *   - $jsname:         function name
 *   - $jswrapper:      name of the JS wrapper
 *
 * Note: this template is also used for global variables.
 * ----------------------------------------------------------------------------- */
%fragment("jsnapi_register_global_function", "templates")
%{
  do {
    Napi::PropertyDescriptor pd = Napi::PropertyDescriptor::Function("$jsname", $jswrapper);
    NAPI_CHECK_MAYBE(exports.DefineProperties({pd}));
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
template <class T>
Napi::Value $jsmangledname_templ<T>::$jswrapper(const Napi::CallbackInfo &info) {
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
template <class T>
void $jsmangledname_templ<T>::$jswrapper(const Napi::CallbackInfo &info, const Napi::Value &value) {
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
 *   - $jswrapper:  wrapper function name
 *   - $jslocals:   locals part of wrapper
 *   - $jscode:     code part of wrapper
 * ----------------------------------------------------------------------------- */
%fragment("js_function", "templates")
%{
template <class T>
Napi::Value $jsmangledname_templ<T>::$jswrapper(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
  Napi::Value jsresult;
  $jslocals
  if(info.Length() != $jsargcount) SWIG_Error(SWIG_ERROR, "Illegal number of arguments for $jswrapper.");

  $jscode
  return jsresult;

  goto fail;
fail:
  return Napi::Value();
}
%}


/* -----------------------------------------------------------------------------
 * js_function_dispatcher:  template for a function dispatcher for overloaded functions
 *   - $jswrapper:  wrapper function name
 *   - $jsname:     name of the wrapped function
 *   - $jslocals:   locals part of wrapper
 *   - $jscode:     code part of wrapper
 * ----------------------------------------------------------------------------- */
%fragment("js_function_dispatcher", "templates")
%{
template <class T>
$jsmangledname_templ<T>::$jswrapper(const Napi::CallbackInfo &info) {
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
template <class T>
Napi::Value $jsmangledname_templ<T>::$jswrapper(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
  Napi::Value jsresult;
  $jslocals
  $jscode
  return jsresult;

  goto fail;
fail:
  Napi::Value();
}
%}


/* -----------------------------------------------------------------------------
 * js_function_dispatch_case:  template for a case used in the function dispatcher
 *   - $jswrapper:  wrapper function name
 *   - $jsargcount: number of arguments of overloaded function
 *   - $jscode:     code part of wrapper
 * ----------------------------------------------------------------------------- */
%fragment ("js_function_dispatch_case", "templates")
%{
  if(info.Length() == $jsargcount) {
    $jswrapper(info);
  }
%}

/* -----------------------------------------------------------------------------
 * jsnapi_class_prologue_template:  template for a class prologue
 *   - $jsmangledname:  mangled class name
 *   - $jsparent:       mangled name of parent (or SwigNapiObjectWrap if none)
 * ----------------------------------------------------------------------------- */
%fragment("jsnapi_class_prologue_template", "templates")
%{
  template <class T>
  class $jsmangledname_templ : public $jsparent_templ<T> {
    public:
      $jsmangledname_templ(const Napi::CallbackInfo &);
      $jsmangledname_templ(bool, const Napi::CallbackInfo &);
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
    $jsstatic void $jswrapper(const Napi::CallbackInfo &, const Napi::Value &);
%}



/* -----------------------------------------------------------------------------
 * jsnapi_class_epilogue_template:  template for a class epilogue
 *   - $jsmangledname:  mangled class name
 * ----------------------------------------------------------------------------- */
%fragment("jsnapi_class_epilogue_template", "templates")
%{
  };
%}


/* -----------------------------------------------------------------------------
 * jsnapi_class_instance:  template for a class declaration instance
 *   - $jsmangledname:  mangled class name
 * ----------------------------------------------------------------------------- */
%fragment("jsnapi_declare_class_instance", "templates")
%{
  class $jsmangledname_inst : public $jsmangledname_templ<$jsmangledname_inst> {
    public:
      using $jsmangledname_templ::$jsmangledname_templ;
      virtual ~$jsmangledname_inst() {};
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
  SWIGNAPI_ClientData $jsmangledname_clientData;
  template <class T>
  class $jsmangledname_templ : public $jsparent_templ<T> {
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
Napi::Function $jsmangledname_inst::GetClass(Napi::Env env) {
  return Napi::ObjectWrap<$jsmangledname_inst>::DefineClass(
    env,
    "$jsname",
    {
      /* register wrapper functions */
      $jsnapiwrappers
      /* add static class functions and variables */
      $jsnapistaticwrappers
    });
}
%}

/* -----------------------------------------------------------------------------
 * jsnapi_registerclass:  template for regsitering a class object
 *   - $jsname:         class name
 *   - $jsmangledname:  mangled class name
 *   - $jsparent:       parent namespace
 *   - $jsmangledtype:  mangled class type
 * ----------------------------------------------------------------------------- */
%fragment("jsnapi_registerclass", "templates")
%{
  /* Class: $jsname ($jsmangledname) */
  Napi::Function $jsmangledname_ctor = $jsmangledname_inst::GetClass(env);
  $jsparent.Set("$jsname", $jsmangledname_ctor);
  if (SWIGTYPE_$jsmangledtype->clientdata == 0) {
    Napi::FunctionReference *f = new Napi::FunctionReference();
    *f = Napi::Persistent($jsmangledname_ctor);
    SWIGTYPE_$jsmangledtype->clientdata = f;
  }
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
  InstanceMethod("$jsname", &$jsmangledname_templ::$jswrapper),
%}

/* -----------------------------------------------------------------------------
 * jsnapi_register_member_variable:  template for a statement that registers a member variable.
 *   - $jsname:         name of the function
 *   - $jsmangledname:  mangled class name
 *   - $jsgetter:       wrapper of the getter function including & and the class prefix
 *   - $jssetter:       wrapper of the setter function including & and the class prefix
 * ----------------------------------------------------------------------------- */
%fragment("jsnapi_register_member_variable", "templates")
%{
  InstanceAccessor("$jsname", $jsgetter, $jssetter),
%}

/* -----------------------------------------------------------------------------
 * jsnapi_register_static_function:  template for a statement that registers a static class function.
 *   - $jsname:         function name
 *   - $jsmangledname:  mangled class name
 *   - $jswrapper:      wrapper of the function
 * ----------------------------------------------------------------------------- */
%fragment("jsnapi_register_static_function", "templates")
%{
  StaticMethod("$jsname", &$jsmangledname_templ::$jswrapper),
%}

/* -----------------------------------------------------------------------------
 * jsnapi_register_static_variable:  template for a statement that registers a static variable.
 *   - $jsname:         variable name
 *   - $jsmangledname:  mangled class name
 *   - $jsgetter:       wrapper of the getter function including & and the class prefix
 *   - $jssetter:       wrapper of the setter function including & and the class prefix
 * ----------------------------------------------------------------------------- */
%fragment("jsnapi_register_static_variable", "templates")
%{
  StaticAccessor("$jsname", $jsgetter, $jssetter),
%}
