%insert(runtime) %{

/**
 * Creates a class template for a class with specified initialization function. 
 */
v8::Handle<v8::FunctionTemplate> SWIGV8_CreateClassTemplate(const char* symbol) {
    v8::HandleScope scope;
    v8::Local<v8::FunctionTemplate> class_templ = v8::FunctionTemplate::New();
    class_templ->SetClassName(v8::String::NewSymbol(symbol));

    v8::Handle<v8::ObjectTemplate> inst_templ = class_templ->InstanceTemplate();
    inst_templ->SetInternalFieldCount(1);

    return scope.Close(class_templ);
}

/**
 * Registers a class method with given name for a given class template. 
 */
void SWIGV8_AddMemberFunction(v8::Handle<v8::FunctionTemplate> class_templ, const char* symbol, v8::InvocationCallback _func) {
    v8::Handle<v8::ObjectTemplate> proto_templ = class_templ->PrototypeTemplate();
    proto_templ->Set(v8::String::NewSymbol(symbol), v8::FunctionTemplate::New(_func));    
}

/**
 * Registers a class property with given name for a given class template. 
 */
void SWIGV8_AddMemberVariable(v8::Handle<v8::FunctionTemplate> class_templ, const char* symbol, v8::AccessorGetter getter, v8::AccessorSetter setter) {
  v8::Handle<v8::ObjectTemplate> proto_templ = class_templ->InstanceTemplate();
  proto_templ->SetAccessor(v8::String::NewSymbol(symbol), getter, setter);
}

/**
 * Registers a class method with given name for a given object. 
 */
void SWIGV8_AddStaticFunction(v8::Handle<v8::Object> obj, const char* symbol, v8::InvocationCallback _func) {
  obj->Set(v8::String::NewSymbol(symbol), v8::FunctionTemplate::New(_func)->GetFunction());
}

/**
 * Registers a class method with given name for a given object. 
 */
void SWIGV8_AddStaticVariable(v8::Handle<v8::Object> obj, const char* symbol, v8::AccessorGetter getter, v8::AccessorSetter setter) {
  obj->SetAccessor(v8::String::NewSymbol(symbol), getter, setter);
}

void JS_veto_set_variable(v8::Local<v8::String> property, v8::Local<v8::Value> value, const v8::AccessorInfo& info)
{
    char buffer[256];
    char msg[512];
    int res;
    
    property->WriteUtf8(buffer, 256);
    res = sprintf(msg, "Tried to write read-only variable: %s.", buffer);
    
    if(res<0) {
      SWIG_exception(SWIG_ERROR, "Tried to write read-only variable.");
    } else {
      SWIG_exception(SWIG_ERROR, msg);
    }
}

%} // v8_helper_functions
