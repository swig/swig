%insert(runtime) %{

// Note: since 3.19 there are new CallBack types, since 03.21.9 the old ones have been removed
#if (SWIG_V8_VERSION < 0x031903)
typedef v8::InvocationCallback  SwigV8FunctionCallback;
typedef v8::AccessorGetter      SwigV8AccessorGetterCallback;
typedef v8::AccessorSetter      SwigV8AccessorSetterCallback;
typedef v8::AccessorInfo        SwigV8PropertyCallbackInfoVoid;
#else
typedef v8::FunctionCallback            SwigV8FunctionCallback;
typedef v8::AccessorGetterCallback      SwigV8AccessorGetterCallback;
typedef v8::AccessorSetterCallback      SwigV8AccessorSetterCallback;
typedef v8::PropertyCallbackInfo<void>  SwigV8PropertyCallbackInfoVoid;
#endif

/**
 * Creates a class template for a class with specified initialization function.
 */
SWIGRUNTIME v8::Handle<v8::FunctionTemplate> SWIGV8_CreateClassTemplate(const char* symbol) {
    SWIGV8_HANDLESCOPE_ESC();
    
    v8::Local<v8::FunctionTemplate> class_templ = SWIGV8_FUNCTEMPLATE_NEW_VOID();
    class_templ->SetClassName(SWIGV8_SYMBOL_NEW(symbol));

    v8::Handle<v8::ObjectTemplate> inst_templ = class_templ->InstanceTemplate();
    inst_templ->SetInternalFieldCount(1);

    v8::Handle<v8::ObjectTemplate> equals_templ = class_templ->PrototypeTemplate();
    equals_templ->Set(SWIGV8_SYMBOL_NEW("equals"), SWIGV8_FUNCTEMPLATE_NEW(_SWIGV8_wrap_equals));

    v8::Handle<v8::ObjectTemplate> cptr_templ = class_templ->PrototypeTemplate();
    cptr_templ->Set(SWIGV8_SYMBOL_NEW("getCPtr"), SWIGV8_FUNCTEMPLATE_NEW(_wrap_getCPtr));

    SWIGV8_ESCAPE(class_templ);
}

/**
 * Registers a class method with given name for a given class template.
 */
SWIGRUNTIME void SWIGV8_AddMemberFunction(v8::Handle<v8::FunctionTemplate> class_templ, const char* symbol,
  SwigV8FunctionCallback _func) {
    v8::Handle<v8::ObjectTemplate> proto_templ = class_templ->PrototypeTemplate();
    proto_templ->Set(SWIGV8_SYMBOL_NEW(symbol), SWIGV8_FUNCTEMPLATE_NEW(_func));
}

/**
 * Registers a class property with given name for a given class template.
 */
SWIGRUNTIME void SWIGV8_AddMemberVariable(v8::Handle<v8::FunctionTemplate> class_templ, const char* symbol,
  SwigV8AccessorGetterCallback getter, SwigV8AccessorSetterCallback setter) {
  v8::Handle<v8::ObjectTemplate> proto_templ = class_templ->InstanceTemplate();
  proto_templ->SetAccessor(SWIGV8_SYMBOL_NEW(symbol), getter, setter);
}

/**
 * Registers a class method with given name for a given object.
 */
SWIGRUNTIME void SWIGV8_AddStaticFunction(v8::Handle<v8::Object> obj, const char* symbol,
  const SwigV8FunctionCallback& _func) {
  obj->Set(SWIGV8_SYMBOL_NEW(symbol), SWIGV8_FUNCTEMPLATE_NEW(_func)->GetFunction());
}

/**
 * Registers a class method with given name for a given object.
 */
SWIGRUNTIME void SWIGV8_AddStaticVariable(v8::Handle<v8::Object> obj, const char* symbol,
  SwigV8AccessorGetterCallback getter, SwigV8AccessorSetterCallback setter) {
  obj->SetAccessor(SWIGV8_SYMBOL_NEW(symbol), getter, setter);
}

SWIGRUNTIME void JS_veto_set_variable(v8::Local<v8::String> property, v8::Local<v8::Value> value,
  const SwigV8PropertyCallbackInfoVoid& info)
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
