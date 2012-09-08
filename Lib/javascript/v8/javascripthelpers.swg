
%insert(runtime) %{

/**
 * Creates a class template for a class without extra initialization function. 
 */
v8::Persistent<v8::FunctionTemplate> SWIGV8_CreateClassTemplate(const char* symbol) {
    v8::Local<v8::FunctionTemplate> class_templ = v8::FunctionTemplate::New();
    class_templ->SetClassName(v8::String::NewSymbol(symbol));

    v8::Handle<v8::ObjectTemplate> inst_templ = class_templ->InstanceTemplate();
    inst_templ->SetInternalFieldCount(1);

    return v8::Persistent<v8::FunctionTemplate>::New(class_templ);
}

/**
 * Creates a class template for a class with specified initialization function. 
 */
v8::Persistent<v8::FunctionTemplate> SWIGV8_CreateClassTemplate(const char* symbol, v8::InvocationCallback _func) {
    v8::Local<v8::FunctionTemplate> class_templ = v8::FunctionTemplate::New(_func);
    class_templ->SetClassName(v8::String::NewSymbol(symbol));

    v8::Handle<v8::ObjectTemplate> inst_templ = class_templ->InstanceTemplate();
    inst_templ->SetInternalFieldCount(1);

    return v8::Persistent<v8::FunctionTemplate>::New(class_templ);
}

v8::Handle<v8::ObjectTemplate> SWIGV8_CreateNamespace(const char* name, v8::Handle<v8::Context> parentContext) {
    Handle<ObjectTemplate> namespace = ObjectTemplate::New();
}

/**
 * Sets the pimpl data of a V8 class. 
 */
v8::Handle<v8::Value> SWIGV8_SetInstance(const v8::Arguments& args, void* data) {
    v8::HandleScope scope;

    v8::Handle<v8::Object> self = args.Holder();
    self->SetInternalField(0, v8::External::New(data));

    return self;
}

/**
 * Registers a class method with given name for a given class template. 
 */
void SWIGV8_AddClassMethod(v8::Handle<v8::FunctionTemplate> class_templ, const char* symbol, v8::InvocationCallback _func) {
    v8::Handle<v8::ObjectTemplate> proto_templ = class_templ->PrototypeTemplate();
    proto_templ->Set(v8::String::NewSymbol(symbol), v8::FunctionTemplate::New(_func));    
}

/**
 * Registers a class method with given name for a given class template. 
 */
void SWIGV8_AddGlobalMethod(v8::Handle<v8::ObjectTemplate> obj_templ, const char* symbol, v8::InvocationCallback _func) {
    obj_templ->Set(String::New(symbol), FunctionTemplate::New(_func));
}

/**
 * Registers a class property with given name for a given class template. 
 */
void SWIGV8_AddProperty(v8::Handle<v8::FunctionTemplate> class_templ, const char* varname, v8::AccessorGetter getter, v8::AccessorSetter setter) {
    v8::Handle<v8::ObjectTemplate> proto_templ = class_templ->InstanceTemplate();
    proto_templ->SetAccessor(v8::String::New(varname), getter, setter);
}

%} // v8_helper_functions
