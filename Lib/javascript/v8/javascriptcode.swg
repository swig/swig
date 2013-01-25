/* -----------------------------------------------------------------------------
 * js_ctor:  template for wrapping a ctor.
 *   - $jswrapper:        wrapper of called ctor
 *   - $jslocals:         locals part of wrapper
 *   - $jscode:           code part of wrapper
 *   - $jsargcount:       number of arguments
 *   - $jsmangledtype:    mangled type of class
 * ----------------------------------------------------------------------------- */
%fragment("js_ctor", "templates") %{
v8::Handle<v8::Value> $jswrapper(const v8::Arguments& args) {
  v8::HandleScope scope;
  v8::Handle<v8::Object> self = args.Holder();
  $jslocals
  if(args.Length() != $jsargcount) SWIG_exception_fail(SWIG_ERROR, "Illegal number of arguments for $jswrapper.");  
  $jscode
  
  SWIGV8_SetPrivateData(self, result, SWIGTYPE_$jsmangledtype, SWIG_POINTER_OWN);
  return scope.Close(self);

  goto fail;
fail:
  return scope.Close(v8::Undefined());
}
%}

/* -----------------------------------------------------------------------------
 * js_veto_ctor:  a vetoing ctor for abstract classes
 *   - $jswrapper:        name of wrapper
 *   - $jsname:           class name
 * ----------------------------------------------------------------------------- */
%fragment ("js_veto_ctor", "templates")
%{
v8::Handle<v8::Value> $jswrapper(const v8::Arguments& args) {
  v8::HandleScope scope;
  SWIG_exception(SWIG_ERROR, "Class $jsname can not be instantiated");
  return scope.Close(v8::Undefined());
}
%}

/* -----------------------------------------------------------------------------
 * js_ctor_dispatcher:  dispatcher for overloaded constructors
 *   - $jswrapper:        name of wrapper
 *   - $jsname:           class name
 *   - $jsdispatchcases:  part containing code for dispatching
 * ----------------------------------------------------------------------------- */
%fragment ("js_ctor_dispatcher", "templates")
%{
v8::Handle<v8::Value> $jswrapper(const v8::Arguments& args) {
  v8::HandleScope scope;
  OverloadErrorHandler errorHandler;
  v8::Handle<v8::Value> self;
  
  // switch all cases by means of series of if-returns.
  $jsdispatchcases

  // default:
  SWIG_exception_fail(SWIG_ERROR, "Illegal arguments for contruction of $jsmangledname");
  
fail:
  return scope.Close(v8::Undefined());
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
v8::Handle<v8::Value> $jswrapper(const v8::Arguments& args, V8ErrorHandler& SWIGV8_ErrorHandler) {
  v8::HandleScope scope;
  v8::Handle<v8::Object> self = args.Holder();
  $jslocals
  if(args.Length() != $jsargcount) SWIG_exception_fail(SWIG_ERROR, "Illegal number of arguments for $jswrapper.");  
  $jscode
  
  SWIGV8_SetPrivateData(self, result, SWIGTYPE_$jsmangledtype, SWIG_POINTER_OWN);
  return scope.Close(self);

  goto fail;
fail:
  return scope.Close(v8::Undefined());
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
  if(args.Length() == $jsargcount) {
    errorHandler.err.Clear();
    self = $jswrapper(args, errorHandler);
    if(errorHandler.err.IsEmpty()) { 
      return scope.Close(self);
    }
  }
%}

/* -----------------------------------------------------------------------------
 * js_dtor:  template for a destructor wrapper
 *   - $jsmangledname:  mangled class name
 *   - $jstype:         class type
 * ----------------------------------------------------------------------------- */
%fragment ("js_dtor", "templates")
%{
void $jswrapper(v8::Persistent< v8::Value > object, void *parameter) {
  SWIGV8_Proxy* proxy = (SWIGV8_Proxy*) parameter;
  if(proxy->swigCMemOwn && proxy->swigCObject) {
    std::cout << "Deleting wrapped instance: " << proxy->info->name << std::endl;
    $jsfree proxy->swigCObject;
  }
  delete proxy;
}
%}

/* -----------------------------------------------------------------------------
 * js_getter:  template for getter function wrappers
 *   - $jswrapper:  wrapper function name
 *   - $jslocals:   locals part of wrapper
 *   - $jscode:     code part of wrapper
 * ----------------------------------------------------------------------------- */
%fragment("js_getter", "templates") 
%{
v8::Handle<v8::Value> $jswrapper(v8::Local<v8::String> property, const v8::AccessorInfo& info) {
  v8::HandleScope scope;
  v8::Handle<v8::Value> jsresult;
  $jslocals
  $jscode
  return scope.Close(jsresult);
  goto fail;
fail:
  return scope.Close(v8::Undefined());
}
%}

/* -----------------------------------------------------------------------------
 * js_setter:  template for setter function wrappers
 *   - $jswrapper:  wrapper function name
 *   - $jslocals:   locals part of wrapper
 *   - $jscode:     code part of wrapper
 * ----------------------------------------------------------------------------- */
%fragment("js_setter", "templates")
%{
void $jswrapper(v8::Local<v8::String> property, v8::Local<v8::Value> value, const v8::AccessorInfo& info) {
  v8::HandleScope scope;
  $jslocals
  $jscode
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
v8::Handle<v8::Value> $jswrapper(const v8::Arguments &args) {
  v8::HandleScope scope;
  v8::Handle<v8::Value> jsresult;
  $jslocals
  if(args.Length() != $jsargcount) SWIG_exception_fail(SWIG_ERROR, "Illegal number of arguments for $jswrapper.");  
  
  $jscode
  return scope.Close(jsresult);
  goto fail;
fail:
  return scope.Close(v8::Undefined());
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
v8::Handle<v8::Value> $jswrapper(const v8::Arguments &args) {
  v8::HandleScope scope;
  v8::Handle<v8::Value> jsresult;
  OverloadErrorHandler errorHandler;
  $jscode

  SWIG_exception_fail(SWIG_ERROR, "Illegal arguments for function $jsname.");

  goto fail;
fail:
  return scope.Close(v8::Undefined());
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
v8::Handle<v8::Value> $jswrapper(const v8::Arguments &args, V8ErrorHandler& SWIGV8_ErrorHandler)
{
  v8::HandleScope scope;  
  v8::Handle<v8::Value> jsresult;
  $jslocals
  $jscode
  return scope.Close(jsresult);  
  goto fail;
fail:
  return scope.Close(jsresult);
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
  if(args.Length() == $jsargcount) {
     errorHandler.err.Clear();
     jsresult = $jswrapper(args, errorHandler);
     if(errorHandler.err.IsEmpty()) {
      return scope.Close(jsresult);
     }
  }
%}

/* -----------------------------------------------------------------------------
 * jsv8_declare_class_template:  template for a class template declaration.
 *   - $jsmangledname:  mangled class name
 * ----------------------------------------------------------------------------- */
%fragment("jsv8_declare_class_template", "templates") 
%{
  SWIGV8_ClientData $jsmangledname_clientData;
%}

/* -----------------------------------------------------------------------------
 * jsv8_define_class_template:  template for a class template definition.
 *   - $jsmangledname:  mangled class name
 *   - $jsmangledtype:  mangled class type
 *   - $jsdtor:         the dtor wrapper
 * ----------------------------------------------------------------------------- */
%fragment("jsv8_define_class_template", "templates") 
%{
  v8::Handle<v8::FunctionTemplate> $jsmangledname_class = SWIGV8_CreateClassTemplate("$jsmangledname");
  $jsmangledname_clientData.class_templ = $jsmangledname_class;
  $jsmangledname_clientData.dtor = $jsdtor;  
  SWIGTYPE$jsmangledtype->clientdata = &$jsmangledname_clientData;
%}

/* -----------------------------------------------------------------------------
 * jsv8_inherit:  template for an class inherit statement.
 *   - $jsmangledname:  mangled class name
 *   - $jsbaseclass:    mangled name of the base class
 * ----------------------------------------------------------------------------- */
%fragment("jsv8_inherit", "templates") 
%{
  $jsmangledname_class->Inherit($jsbaseclass_class);
%}

/* -----------------------------------------------------------------------------
 * jsv8_create_class_instance:  template for creating an class object.
 *   - $jsname:         class name
 *   - $jsmangledname:  mangled class name
 * ----------------------------------------------------------------------------- */
%fragment("jsv8_create_class_instance", "templates") 
%{
  v8::Handle<v8::FunctionTemplate> $jsmangledname_class_0 = SWIGV8_CreateClassTemplate("$jsname");
  $jsmangledname_class_0->SetCallHandler($jsctor);
  $jsmangledname_class_0->Inherit($jsmangledname_class);
  $jsmangledname_class_0->SetHiddenPrototype(true);
  v8::Handle<v8::Object> $jsmangledname_obj = $jsmangledname_class_0->GetFunction();
%}

/* -----------------------------------------------------------------------------
 * jsv8_register_class:  template for a statement that registers a class in a parent namespace.
 *   - $jsname:         class name
 *   - $jsmangledname:  mangled class name
 *   - $jsparent:       mangled name of parent namespace
 * ----------------------------------------------------------------------------- */
%fragment("jsv8_register_class", "templates") 
%{
  $jsparent_obj->Set(v8::String::NewSymbol("$jsname"), $jsmangledname_obj);
%}

/* -----------------------------------------------------------------------------
 * jsv8_create_namespace:  template for a statement that creates a namespace object.
 *   - $jsmangledname:  mangled namespace name
 * ----------------------------------------------------------------------------- */
%fragment("jsv8_create_namespace", "templates") 
%{
  v8::Handle<v8::Object> $jsmangledname_obj = v8::Object::New();
%}

/* -----------------------------------------------------------------------------
 * jsv8_register_namespace:  template for a statement that registers a namespace in a parent namespace.
 *   - $jsname:         name of namespace
 *   - $jsmangledname:  mangled name of namespace
 *   - $jsparent:       mangled name of parent namespace
 * ----------------------------------------------------------------------------- */
%fragment("jsv8_register_namespace", "templates") 
%{
  $jsparent_obj->Set(v8::String::NewSymbol("$jsname"), $jsmangledname_obj);
%}

/* -----------------------------------------------------------------------------
 * jsv8_register_member_function:  template for a statement that registers a member function.
 *   - $jsmangledname:  mangled class name
 *   - $jsname:         name of the function
 *   - $jswrapper:      wrapper of the member function
 * ----------------------------------------------------------------------------- */
%fragment("jsv8_register_member_function", "templates") 
%{
  SWIGV8_AddMemberFunction($jsmangledname_class, "$jsname", $jswrapper);
%}

/* -----------------------------------------------------------------------------
 * jsv8_register_member_variable:  template for a statement that registers a member variable.
 *   - $jsmangledname:  mangled class name
 *   - $jsname:         name of the function
 *   - $jsgetter:       wrapper of the getter function
 *   - $jssetter:       wrapper of the setter function
 * ----------------------------------------------------------------------------- */
%fragment("jsv8_register_member_variable", "templates")
%{
  SWIGV8_AddMemberVariable($jsmangledname_class, "$jsname", $jsgetter, $jssetter);
%}

/* -----------------------------------------------------------------------------
 * jsv8_register_static_function:  template for a statement that registers a static class function.
 *   - $jsname:         function name
 *   - $jswrapper:      wrapper of the function
 *   - $jsparent:       mangled name of parent namespace
 *
 * Note: this template is also used for global functions.
 * ----------------------------------------------------------------------------- */
%fragment("jsv8_register_static_function", "templates") 
%{
  SWIGV8_AddStaticFunction($jsparent_obj, "$jsname", $jswrapper);
%}

/* -----------------------------------------------------------------------------
 * jsv8_register_static_variable:  template for a statement that registers a static variable.
 *   - $jsname:         variable name
 *   - $jsparent:       mangled name of parent namespace
 *   - $jsgetter:       wrapper of the getter function
 *   - $jssetter:       wrapper of the setter function
 *
 * Note: this template is also used for global variables.
 * ----------------------------------------------------------------------------- */
%fragment("jsv8_register_static_variable", "templates") 
%{
  SWIGV8_AddStaticVariable($jsparent_obj, "$jsname", $jsgetter, $jssetter);
%}

/* -----------------------------------------------------------------------------
 * js_initializer:  template for the module initializer function
 *   - $jsname:                   module name
 *   - $jsv8nspaces:              part with code creating namespace objects
 *   - $jsv8classtemplates:       part with code creating class templates
 *   - $jsv8wrappers:             part with code that registers wrapper functions
 *   - $jsv8inheritance:          part with inherit statements
 *   - $jsv8classinstances:       part with code creating class objects
 *   - $jsv8staticwrappers:       part with code adding static functions to class objects
 *   - $jsv8registerclasses:      part with code that registers class objects in namespaces
 *   - $jsv8registernspaces:      part with code that registers namespaces in parent namespaces
 * ----------------------------------------------------------------------------- */
%fragment("js_initializer", "templates") 
%{
extern "C" {

void $jsname_initialize(v8::Handle<v8::Object> global_obj)
{
  SWIG_InitializeModule(0);

  v8::HandleScope scope;

  // a class template for creating proxies of undefined types
  SWIGV8_SWIGTYPE_Proxy_class_templ = SWIGV8_CreateClassTemplate("SwigProxy");
  
  /* create objects for namespaces */
  $jsv8nspaces
  
  /* create class templates */
  $jsv8classtemplates
  
  /* register wrapper functions */
  $jsv8wrappers
  
  /* setup inheritances */
  $jsv8inheritance
      
  /* class instances */
  $jsv8classinstances
  
  /* add static class functions and variables */
  $jsv8staticwrappers

  /* register classes */
  $jsv8registerclasses
  
  /* create and register namespace objects */
  $jsv8registernspaces

}

} // extern "C"
%}
