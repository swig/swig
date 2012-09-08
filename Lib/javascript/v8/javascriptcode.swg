
%fragment("v8_initializer", "templates") %{
void ${MODULE}_Initialize(v8::Handle<v8::Context> context)
{
    v8::HandleScope scope;

    // register the module in globale context
    v8::Local<v8::Object> global = context->Global();

    ${PART_NAMESPACES}

    ${PART_CLASS_TEMPLATES}

    ${PART_WRAPPERS}

    ${PART_INHERITANCE}

    ${PART_REGISTER}
}%}

%fragment("v8_declare_class_template", "templates") %{
v8::Persistent<v8::FunctionTemplate> SWIGV8_${NAME_MANGLED};%}

%fragment("v8_define_class_template", "templates") %{
SWIGV8_${NAME_MANGLED} = SWIGV8_CreateClassTemplate("${NAME_UNQUALIFIED}" , ${NAME_MANGLED}_new);%}

%fragment("v8_inherit", "templates") %{
SWIGV8_${NAME_MANGLED}->Inherit(SWIGV8_${BASE_CLASS});%}

%fragment("v8_register_class", "templates") %{
${CONTEXT}->Set(v8::String::NewSymbol("${NAME_UNQUALIFIED}", SWIGV8_${NAME_MANGLED}->GetFunction()));%}

%fragment("v8_ctor_wrapper", "templates") %{
v8::Handle<v8::Value> ${NAME_MANGLED}_new(const v8::Arguments& args) {
    v8::HandleScope scope;
    v8::Handle<v8::Object> self = args.Holder();
    ${LOCALS}
    ${ACTION}
    self->SetInternalField(0, v8::External::New(ptr));
    return self;        
}
%}

%fragment("v8_getter", "templates") %{
v8::Handle<v8::Value> ${NAME_MANGLED}_get(v8::Local<v8::String> property, const v8::AccessorInfo& info) {
    v8::HandleScope scope;
    v8::Handle<v8::Object> ret;
    ${LOCALS}
    ${ACTION}
    ${MARSHAL_OUTPUT}
    return scope.Close(ret);
}
%}

%fragment("v8_setter", "templates") %{
void ${NAME_MANGLED}_set(v8::Local<v8::String> property, v8::Local<v8::Value> value, const v8::AccessorInfo& info) {
    ${LOCALS}
    ${MARSHAL_INPUT}
    ${ACTION}
}
%}

%fragment("v8_function", "templates") %{
v8::Handle<v8::Value> ${NAME_MANGLED}(const Arguments &args) {
    v8::HandleScope scope;
    v8::Handle<v8::Object> ret;
    ${LOCALS}
    ${MARSHAL_INPUT}
    ${ACTION}
    ${MARSHAL_OUTPUT}
    return scope.Close(ret);
}
%}
