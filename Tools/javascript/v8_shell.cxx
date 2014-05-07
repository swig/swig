#include <assert.h>
#include <fcntl.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include <v8.h>
#include <vector>

#include "js_shell.h"

typedef int (*V8ExtensionInitializer) (v8::Handle<v8::Object> module);

class V8Shell: public JSShell {

public:
  V8Shell();

  virtual ~V8Shell();

  virtual bool RunScript(const std::string& scriptPath);

  virtual bool RunShell();


protected:

  virtual bool InitializeEngine();

  virtual bool ExecuteScript(const std::string& source, const std::string& scriptPath);

  virtual bool DisposeEngine();

private:

  v8::Handle<v8::Value> Import(const std::string& moduleName);

  v8::Persistent<v8::Context> CreateShellContext();

  void ReportException(v8::TryCatch* handler);

  static v8::Handle<v8::Value> Print(const v8::Arguments& args);

  static v8::Handle<v8::Value> Require(const v8::Arguments& args);

  static v8::Handle<v8::Value> Quit(const v8::Arguments& args);

  static v8::Handle<v8::Value> Version(const v8::Arguments& args);

  static const char* ToCString(const v8::String::Utf8Value& value);

  virtual bool _ExecuteScript(const std::string& source, const std::string& scriptPath);

protected:

  v8::Persistent<v8::Context> context;
};

#ifdef __GNUC__
#include <dlfcn.h>
#define LOAD_SYMBOL(handle, name) dlsym(handle, name)
#else
#error "implement dll loading"
#endif

V8Shell::V8Shell(){}

V8Shell::~V8Shell() {}

bool V8Shell::RunScript(const std::string& scriptPath) {

  if (!context.IsEmpty()) {
    context.Dispose();
  }

  std::string source = ReadFile(scriptPath);

  context = CreateShellContext();
  if (context.IsEmpty()) {
      printf("Could not create context.\n");
      return false;
  }
  context->Enter();

  bool success = _ExecuteScript(source, scriptPath);

  context->Exit();
  context.Dispose();
  v8::V8::Dispose();

  return true;
}

bool V8Shell::_ExecuteScript(const std::string& source, const std::string& scriptPath) {
  v8::HandleScope scope;

  // Store a pointer to this shell for later use
  v8::Handle<v8::Object> global = context->Global();
  v8::Local<v8::External> __shell__ = v8::External::New((void*) (long) this);
  global->SetHiddenValue(v8::String::New("__shell__"), __shell__);

  // Node.js compatibility: make `print` available as `console.log()`
  ExecuteScript("var console = {}; console.log = print;", "<console>");

  if(!ExecuteScript(source, scriptPath)) {
    return false;
  }

  return true;
}

bool V8Shell::RunShell() {

  if (!context.IsEmpty()) {
    context.Dispose();
  }

  context = CreateShellContext();
  if (context.IsEmpty()) {
      printf("Could not create context.\n");
      return false;
  }

  context->Enter();

  v8::Context::Scope context_scope(context);

  ExecuteScript("var console = {}; console.log = print;", "<console>");

  static const int kBufferSize = 1024;
  while (true) {
    char buffer[kBufferSize];
    printf("> ");
    char* str = fgets(buffer, kBufferSize, stdin);
    if (str == NULL) break;
    std::string source(str);
    ExecuteScript(source, "(shell)");
  }
  printf("\n");

  context->Exit();
  context.Dispose();
  v8::V8::Dispose();

  return true;
}


bool V8Shell::InitializeEngine() {
  return true;
}

bool V8Shell::ExecuteScript(const std::string& source, const std::string& name) {
  v8::HandleScope handle_scope;
  v8::TryCatch try_catch;
  v8::Handle<v8::Script> script = v8::Script::Compile(v8::String::New(source.c_str()), v8::String::New(name.c_str()));

  // Stop if script is empty
  if (script.IsEmpty()) {
    // Print errors that happened during compilation.
    ReportException(&try_catch);
    return false;
  }

  v8::Handle<v8::Value> result = script->Run();

  // Print errors that happened during execution.
  if (try_catch.HasCaught()) {
    ReportException(&try_catch);
    return false;
  } else {
    return true;
  }
}

bool V8Shell::DisposeEngine() {
  return true;
}

v8::Persistent<v8::Context> V8Shell::CreateShellContext() {
  v8::HandleScope scope;

  // Create a template for the global object.
  v8::Handle<v8::ObjectTemplate> global = v8::ObjectTemplate::New();

  // Bind global functions
  global->Set(v8::String::New("print"), v8::FunctionTemplate::New(V8Shell::Print));
  global->Set(v8::String::New("quit"), v8::FunctionTemplate::New(V8Shell::Quit));
  global->Set(v8::String::New("require"), v8::FunctionTemplate::New(V8Shell::Require));
  global->Set(v8::String::New("version"), v8::FunctionTemplate::New(V8Shell::Version));

  v8::Persistent<v8::Context> _context = v8::Context::New(NULL, global);

  return _context;
}

v8::Handle<v8::Value> V8Shell::Import(const std::string& module_path)
{
  v8::HandleScope scope;

  HANDLE library;
  std::string module_name = LoadModule(module_path, &library);

  std::string symname = std::string(module_name).append("_initialize");

  V8ExtensionInitializer init_function = reinterpret_cast<V8ExtensionInitializer>((long) LOAD_SYMBOL(library, symname.c_str()));

  if(init_function == 0) {
    printf("Could not find initializer function.");
    return v8::Undefined();
  }

  v8::Local<v8::Object> module = v8::Object::New();
  init_function(module);
  return scope.Close(module);
}

v8::Handle<v8::Value> V8Shell::Print(const v8::Arguments& args) {
  bool first = true;
  for (int i = 0; i < args.Length(); i++) {
    v8::HandleScope handle_scope;
    if (first) {
      first = false;
    } else {
      printf(" ");
    }
    v8::String::Utf8Value str(args[i]);
    const char* cstr = V8Shell::ToCString(str);
    printf("%s", cstr);
  }
  printf("\n");
  fflush(stdout);
  return v8::Undefined();
}

v8::Handle<v8::Value> V8Shell::Require(const v8::Arguments& args) {
  v8::HandleScope scope;

  if (args.Length() != 1) {
    printf("Illegal arguments for `require`");
  };

  v8::String::Utf8Value str(args[0]);
  const char* cstr = V8Shell::ToCString(str);
  std::string moduleName(cstr);

  v8::Local<v8::Object> global = v8::Context::GetCurrent()->Global();
  v8::Local<v8::Value> hidden = global->GetHiddenValue(v8::String::New("__shell__"));
  v8::Local<v8::External> __shell__ = v8::Local<v8::External>::Cast(hidden);
  V8Shell* _this = (V8Shell*) (long) __shell__->Value();

  v8::Handle<v8::Value> module = _this->Import(moduleName);

  return scope.Close(module);
}

v8::Handle<v8::Value> V8Shell::Quit(const v8::Arguments& args) {
  int exit_code = args[0]->Int32Value();
  fflush(stdout);
  fflush(stderr);
  exit(exit_code);
  return v8::Undefined();
}

v8::Handle<v8::Value> V8Shell::Version(const v8::Arguments& args) {
  return v8::String::New(v8::V8::GetVersion());
}

void V8Shell::ReportException(v8::TryCatch* try_catch) {
  v8::HandleScope handle_scope;
  v8::String::Utf8Value exception(try_catch->Exception());
  const char* exception_string = V8Shell::ToCString(exception);
  v8::Handle<v8::Message> message = try_catch->Message();
  if (message.IsEmpty()) {
    // V8 didn't provide any extra information about this error; just
    // print the exception.
    printf("%s\n", exception_string);
  } else {
    // Print (filename):(line number): (message).
    v8::String::Utf8Value filename(message->GetScriptResourceName());
    const char* filename_string = V8Shell::ToCString(filename);
    int linenum = message->GetLineNumber();
    printf("%s:%i: %s\n", filename_string, linenum, exception_string);
    // Print line of source code.
    v8::String::Utf8Value sourceline(message->GetSourceLine());
    const char* sourceline_string = V8Shell::ToCString(sourceline);
    printf("%s\n", sourceline_string);
    // Print wavy underline (GetUnderline is deprecated).
    int start = message->GetStartColumn();
    for (int i = 0; i < start; i++) {
      printf(" ");
    }
    int end = message->GetEndColumn();
    for (int i = start; i < end; i++) {
      printf("^");
    }
    printf("\n");
    v8::String::Utf8Value stack_trace(try_catch->StackTrace());
    if (stack_trace.length() > 0) {
      const char* stack_trace_string = V8Shell::ToCString(stack_trace);
      printf("%s\n", stack_trace_string);
    }
  }
}

// Extracts a C string from a V8 Utf8Value.
const char* V8Shell::ToCString(const v8::String::Utf8Value& value) {
  return *value ? *value : "<string conversion failed>";
}

JSShell* V8Shell_Create() {
  return new V8Shell();
}
