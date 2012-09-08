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
%{v8::Persistent<v8::FunctionTemplate> SWIGV8_$jsmangledname;%}

%fragment("jsv8_define_class_template", "templates") 
%{SWIGV8_$jsmangledname = SWIGV8_CreateClassTemplate("$jsname" , $jsctor);%}

%fragment("jsv8_create_class_instance", "templates") 
%{v8::Handle<v8::Object> class_$jsmangledname = SWIGV8_$jsmangledname->GetFunction();%}

%fragment("jsv8_inherit", "templates") 
%{SWIGV8_$jsmangledname->Inherit(SWIGV8_$jsbaseclass);%}

%fragment("jsv8_register_class", "templates") 
%{$jsparent->Set(v8::String::NewSymbol("$jsname"), class_$jsmangledname);%}

%fragment("jsv8_create_namespace", "templates") 
%{v8::Handle<v8::ObjectTemplate> $jsmangledname = v8::ObjectTemplate::New();%}

%fragment("jsv8_register_member_function", "templates") 
%{SWIGV8_AddMemberFunction(SWIGV8_$jsmangledname, "$jsname", $jswrapper);%}

%fragment("jsv8_register_static_function", "templates") 
%{SWIGV8_AddGlobalFunction(SWIGV8_$jsparent, "$jsname", $jswrapper);%}

%fragment("jsv8_register_member_variable", "templates")
%{SWIGV8_AddMemberVariable(SWIGV8_$jsmangledname, "$jsname", $jsgetter, $jssetter);%}

%fragment("jsv8_register_static_variable", "templates") 
%{SWIGV8_AddGlobalVariable(SWIGV8_$jsparent, "$jsname", $jsgetter, $jssetter);%}

%fragment("jsv8_register_namespace", "templates") 
%{$jsparent->Set(v8::String::NewSymbol("$jsname"), $jsmangledname->NewInstance());%}

%fragment("JS_initializer", "templates") 
%{
extern "C" {

void $jsname_initialize(v8::Handle<v8::Context> context)
{
    v8::HandleScope scope;
    v8::Local<v8::Object> global = context->Global();

    /* create object templates for namespaces */
    $jsv8nspaces
    
    /* create class templates */
    $jsv8classtemplates
    
    /* register wrapper functions */
    $jsv8wrappers
    
    /* setup inheritances */
    $jsv8inheritance
    
    /* add static class functions and variables */
    $jsv8staticwrappers
    
    /* class instances */
    $jsv8classinstances
    
    /* register classes */
    $jsv8registerclasses
    
    /* create and register namespace objects */
    $jsv8registernspaces
}

}%}
