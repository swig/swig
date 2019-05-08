/* File : example.i */
%module example


%wrapper
%{
#include <cstring>
#include <string>

#if (V8_MAJOR_VERSION-0) < 4 && (SWIG_V8_VERSION < 0x031903)
#    define V8_RETURN(val) return scope.Close(val)
#else
#    define V8_RETURN(val) args.GetReturnValue().Set(val); return
#endif
#if (V8_MAJOR_VERSION-0) < 4 && (SWIG_V8_VERSION < 0x032318)
#    define V8_UNDEFINED() v8::Undefined()
#else
#    define V8_UNDEFINED() v8::Undefined(v8::Isolate::GetCurrent())
#endif


// 'unused' attribute only necessary for GNUC < v3.4
static /* __attribute__ ((__unused__)) */ V8ErrorHandler V8_ErrorHandler;


typedef struct worker_packet {
    // -- basic --
	uv_work_t request;
	v8::Persistent<v8::Function> callback;
	// -- persistent variables --
	std::string result;
	// -- async operation --
	void (*execute)(std::string&);
} worker_packet;


// async process - parallel with node thread
static void work_async(uv_work_t* request) {
    worker_packet* packet = static_cast<worker_packet*>(request->data);
    packet->execute(packet->result);
    // add a delay for dramatic effect - not necessary
}


// send async result back to node's thread
static void work_complete(uv_work_t* request, int status) {
    v8::Isolate* iso = v8::Isolate::GetCurrent();
    v8::HandleScope scope(iso);
    worker_packet* packet = static_cast<worker_packet*>(request->data);
    const int argc = 1;
    v8::Handle<v8::Value> argv[] = {
        v8::String::NewFromUtf8(iso, packet->result.c_str())
    };
    v8::Local<v8::Function>::New(iso, packet->callback)->Call
        (iso->GetCurrentContext()->Global(), argc, argv);
    packet->callback.Reset();
    delete work;
}


static void entry(const v8::FunctionCallbackInfo<v8::Value>& args) {
    v8::Isolate* iso = v8::Isolate::GetCurrent();
    v8::Local<v8::Value> value = args[0];
    if (!value->IsFunction()) {
        V8_ErrorHandler.error((-1), "Invalid parameter type.");
        return;
    }
    worker_packet* packet = new worker_packet();
    packet->request.data = packet;
    packet->execute = [](std::string& res) { res = "My delayed message."; };
    v8::Local<v8::Function> callback = v8::Local<v8::Function>::Cast(value);
    packet->callback.Reset(iso, callback);
    uv_queue_work(uv_default_loop(), &packet->request,
        work_async, work_complete);
    args.GetReturnValue().Set(Undefined(iso));
}


void JavaScript_exampleV8_callback_function(const v8::Arguments& args) {
    v8::HandleScope scope
	if (args.Length() != 1) {
        V8_ErrorHandler.error((-1), "Illegal number of arguments.");
        V8_RETURN(V8_UNDEFINED());
	}
    entry(args);
    v8::Handle<v8::Value> jsresult = V8_UNDEFINED();
    V8_RETURN(jsresult);
}
%}


%native(num_to_string) void JavaScript_exampleV8_callback_function();
