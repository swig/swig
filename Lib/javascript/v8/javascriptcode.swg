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

%fragment ("js_veto_ctor", "templates")
%{
v8::Handle<v8::Value> $jswrapper(const v8::Arguments& args) {
  v8::HandleScope scope;
  SWIG_exception(SWIG_ERROR, "Class $jsname can not be instantiated");
  return scope.Close(v8::Undefined());
}
%}

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
  scope.Close(v8::Undefined());
}
%}

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

%fragment("jsv8_declare_class_template", "templates") 
%{
  SWIGV8_ClientData $jsmangledname_clientData;
%}

%fragment("jsv8_define_class_template", "templates") 
%{
  v8::Handle<v8::FunctionTemplate> $jsmangledname_class = SWIGV8_CreateClassTemplate("$jsmangledname");
  $jsmangledname_clientData.class_templ = $jsmangledname_class;
  $jsmangledname_clientData.dtor = $jsdtor;  
  SWIGTYPE$jsmangledtype->clientdata = &$jsmangledname_clientData;
%}

%fragment("jsv8_inherit", "templates") 
%{
  $jsmangledname_class->Inherit($jsbaseclass_class);
%}

%fragment("jsv8_create_class_instance", "templates") 
%{
  v8::Handle<v8::FunctionTemplate> $jsmangledname_class_0 = SWIGV8_CreateClassTemplate("$jsname");
  $jsmangledname_class_0->SetCallHandler($jsctor);
  $jsmangledname_class_0->Inherit($jsmangledname_class);
  $jsmangledname_class_0->SetHiddenPrototype(true);
  v8::Handle<v8::Object> $jsmangledname_obj = $jsmangledname_class_0->GetFunction();
%}

%fragment("jsv8_register_class", "templates") 
%{
  $jsparent_obj->Set(v8::String::NewSymbol("$jsname"), $jsmangledname_obj);
%}

%fragment("jsv8_create_namespace", "templates") 
%{
  v8::Handle<v8::Object> $jsmangledname_obj = v8::Object::New();
%}

%fragment("jsv8_register_member_function", "templates") 
%{
  SWIGV8_AddMemberFunction($jsmangledname_class, "$jsname", $jswrapper);
%}

%fragment("jsv8_register_member_variable", "templates")
%{
  SWIGV8_AddMemberVariable($jsmangledname_class, "$jsname", $jsgetter, $jssetter);
%}

%fragment("jsv8_register_static_function", "templates") 
%{
  SWIGV8_AddStaticFunction($jsparent_obj, "$jsname", $jswrapper);
%}

%fragment("jsv8_register_static_variable", "templates") 
%{
  SWIGV8_AddStaticVariable($jsparent_obj, "$jsname", $jsgetter, $jssetter);
%}

%fragment("jsv8_register_namespace", "templates") 
%{
  $jsparent_obj->Set(v8::String::NewSymbol("$jsname"), $jsmangledname_obj);
%}

%fragment("js_initializer", "templates") 
%{
extern "C" {

void $jsname_initialize(v8::Handle<v8::Context> context)
{
  SWIG_InitializeModule(0);

  v8::HandleScope scope;
  v8::Local<v8::Object> global_obj = context->Global();

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
