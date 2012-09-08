%fragment("JS_ctordefn", "templates") %{
v8::Handle<v8::Value> $jswrapper(const v8::Arguments& args) {
  v8::HandleScope scope;
  v8::Handle<v8::Object> self = args.Holder();
  $jslocals
  $jscode
  self->SetInternalField(0, v8::External::New(result));
  return scope.Close(self);
  goto fail;
fail:
  return scope.Close(v8::Undefined());
}%}

%fragment ("JS_veto_ctor", "templates")
%{
v8::Handle<v8::Value> $jsctor(const v8::Arguments& args) {
  v8::HandleScope scope;
  SWIG_exception(SWIG_ERROR, "Class $jsname can not be instantiated");
  return scope.Close(v8::Undefined());
}%}

%fragment("JS_getproperty", "templates") %{
v8::Handle<v8::Value> $jsgetter(v8::Local<v8::String> property, const v8::AccessorInfo& info) {
  v8::HandleScope scope;
  v8::Handle<v8::Value> jsresult;
  $jslocals
  $jscode
  return scope.Close(jsresult);
  goto fail;
fail:
  return scope.Close(v8::Undefined());
}%}

%fragment("JS_setproperty", "templates") %{
void $jssetter(v8::Local<v8::String> property, v8::Local<v8::Value> value, const v8::AccessorInfo& info) {
  v8::HandleScope scope;
  $jslocals
  $jscode
  goto fail;
fail:
  return;
}%}

%fragment("JS_functionwrapper", "templates") %{
v8::Handle<v8::Value> $jswrapper(const v8::Arguments &args) {
  v8::HandleScope scope;
  v8::Handle<v8::Value> jsresult;
  $jslocals
  $jscode
  return scope.Close(jsresult);
  goto fail;
fail:
  return scope.Close(v8::Undefined());
}%}

%fragment ("JS_mainctordefn", "templates")
%{
  // TODO: implement JS_mainctordefn
%}

%fragment ("JS_ctor_dispatch_case", "templates")
%{
  // TODO: implement JS_ctor_dispatch_case
%}

%fragment ("JS_destructordefn", "templates")
%{
  // TODO: implement JS_destructordefn
%}

%fragment("jsv8_declare_class_template", "templates") 
%{v8::Persistent<v8::FunctionTemplate> $jsmangledname_class;%}

%fragment("jsv8_define_class_template", "templates") 
%{$jsmangledname_class = SWIGV8_CreateClassTemplate("$jsname" , $jsctor);%}

%fragment("jsv8_create_class_instance", "templates") 
%{v8::Handle<v8::Object> $jsmangledname = $jsmangledname_class->GetFunction();%}

%fragment("jsv8_inherit", "templates") 
%{$jsmangledname_class->Inherit($jsbaseclass_class);%}

%fragment("jsv8_register_class", "templates") 
%{$jsparent->Set(v8::String::NewSymbol("$jsname"), $jsmangledname);%}

%fragment("jsv8_create_namespace", "templates") 
%{v8::Handle<v8::Object> $jsmangledname = v8::Object::New();%}

%fragment("jsv8_register_member_function", "templates") 
%{SWIGV8_AddMemberFunction($jsmangledname_class, "$jsname", $jswrapper);%}

%fragment("jsv8_register_member_variable", "templates")
%{SWIGV8_AddMemberVariable($jsmangledname_class, "$jsname", $jsgetter, $jssetter);%}

%fragment("jsv8_register_static_function", "templates") 
%{SWIGV8_AddStaticFunction($jsparent, "$jsname", $jswrapper);%}

%fragment("jsv8_register_static_variable", "templates") 
%{SWIGV8_AddStaticVariable($jsparent, "$jsname", $jsgetter, $jssetter);%}

%fragment("jsv8_register_namespace", "templates") 
%{$jsparent->Set(v8::String::NewSymbol("$jsname"), $jsmangledname);%}

%fragment("JS_initializer", "templates") 
%{
extern "C" {

void $jsname_initialize(v8::Handle<v8::Context> context)
{
  v8::HandleScope scope;
  v8::Local<v8::Object> global = context->Global();

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

}%}
