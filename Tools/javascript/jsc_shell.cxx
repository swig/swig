#include <JavaScriptCore/JavaScript.h>

#include "js_shell.h"

#include <iostream>
#include <stdio.h>

#ifdef __GNUC__
#include <dlfcn.h>
#define LOAD_SYMBOL(handle, name) dlsym(handle, name)
#else
#error "implement dll loading"
#endif

class JSCString {
private:
  std::string _cppString;
  JSStringRef _JSString = NULL;
public:
  JSCString(const std::string &_string) : _cppString(_string),
    _JSString(JSStringCreateWithUTF8CString(_string.c_str())) { }
  JSCString(JSContextRef context, JSValueRef ref) {
    _JSString = JSValueToStringCopy(context, ref, NULL);
    size_t numChars = JSStringGetMaximumUTF8CStringSize(_JSString);
    char *stringUTF8 = new char[numChars];
    JSStringGetUTF8CString(_JSString, stringUTF8, numChars);
    _cppString = stringUTF8;
    delete[] stringUTF8;
  }
  ~JSCString() {
    if (_JSString != NULL)
        JSStringRelease(_JSString);
  }
  JSStringRef JSString() { return _JSString; }
  const std::string &cppString() const { return _cppString; }
  const char *cString() const { return _cppString.c_str(); }
};

class JSCShell: public JSShell {

typedef int (*JSCIntializer)(JSGlobalContextRef context, JSObjectRef *module);

public:

  JSCShell() { context = 0; }

  virtual ~JSCShell();

protected:

  virtual bool InitializeEngine();

  virtual bool ExecuteScript(const std::string& source, const std::string& scriptPath);

  virtual bool DisposeEngine();

private:

  JSObjectRef Import(const std::string &moduleName);

  static JSValueRef Print(JSContextRef context, JSObjectRef object, JSObjectRef globalobj, size_t argc, const JSValueRef args[], JSValueRef* ex);

  static JSValueRef Require(JSContextRef context, JSObjectRef object, JSObjectRef globalobj, size_t argc, const JSValueRef args[], JSValueRef* ex);

  static bool RegisterFunction(JSGlobalContextRef context, JSObjectRef object, const char* functionName, JSObjectCallAsFunctionCallback cbFunction);

  static void PrintError(JSContextRef, JSValueRef);

private:

  JSGlobalContextRef context;
};

JSCShell::~JSCShell() {
  if(context != 0) {
    JSGlobalContextRelease(context);
    context = 0;
  }
}

bool JSCShell::InitializeEngine() {
  if(context != 0) {
    JSGlobalContextRelease(context);
    context = 0;
  }
  // TODO: check for initialization errors
  context = JSGlobalContextCreate(NULL);
  if(context == 0) return false;
  JSObjectRef globalObject = JSContextGetGlobalObject(context);

  // store this for later use
  JSClassDefinition __shell_classdef__ = JSClassDefinition();

  JSClassRef __shell_class__ = JSClassCreate(&__shell_classdef__);
  JSObjectRef __shell__ = JSObjectMake(context, __shell_class__, 0);
  bool success = JSObjectSetPrivate(__shell__, (void*) (long) this);
  if (!success) {
    std::cerr << "Could not register the shell in the Javascript context" << std::endl;
    return false;
  }
  JSCString shellKey("__shell__");
  JSObjectSetProperty(context, globalObject, shellKey.JSString(), __shell__, kJSPropertyAttributeReadOnly, NULL);

  JSCShell::RegisterFunction(context, globalObject, "print", JSCShell::Print);
  JSCShell::RegisterFunction(context, globalObject, "require", JSCShell::Require);

  return true;
}

bool JSCShell::ExecuteScript(const std::string& source, const std::string& scriptPath) {
  JSValueRef ex;
  JSCString jsScript(source);
  JSCString sourceURL(scriptPath);
  JSValueRef jsResult = JSEvaluateScript(context, jsScript.JSString(), NULL, sourceURL.JSString(), 0, &ex);
  if (jsResult == NULL && ex != NULL) {
      JSCShell::PrintError(context, ex);
      return false;
  }
  return true;
}

bool JSCShell::DisposeEngine() {
  JSGlobalContextRelease(context);
  context = 0;
  return true;
}

JSValueRef JSCShell::Print(JSContextRef context, JSObjectRef object,
                           JSObjectRef globalobj, size_t argc,
                           const JSValueRef args[], JSValueRef* ex) {
  if (argc > 0)
  {
    JSCString messega(context, args[0]);
    printf("%s\n", messega.cString());
  }

  return JSValueMakeUndefined(context);
}

// Attention: this feature should not create too high expectations.
// It is only capable of loading things relative to the execution directory
// and not relative to the parent script.
JSValueRef JSCShell::Require(JSContextRef context, JSObjectRef object,
                           JSObjectRef globalObj, size_t argc,
                           const JSValueRef args[], JSValueRef* ex) {
  JSObjectRef module = NULL;

  JSCString shellKey("__shell__");
  JSValueRef shellAsVal = JSObjectGetProperty(context, globalObj, shellKey.JSString(), NULL);
  JSObjectRef shell = JSValueToObject(context, shellAsVal, 0);
  JSCShell *_this = (JSCShell*) (long) JSObjectGetPrivate(shell);

  if (argc > 0)
  {
    JSCString modulePath(context, args[0]);
    module = _this->Import(modulePath.cppString());
  }

  if (module == NULL) {
    printf("Ooops.\n");
    return JSValueMakeUndefined(context);
  }
  return module;
}

JSObjectRef JSCShell::Import(const std::string& module_path) {

  HANDLE library;
  std::string module_name = LoadModule(module_path, &library);

  if (library == 0) {
    printf("Could not load module.");
    return 0;
  }

  std::string symname = std::string(module_name).append("_initialize");

  JSCIntializer init_function = reinterpret_cast<JSCIntializer>((long) LOAD_SYMBOL(library, symname.c_str()));
  if(init_function == 0) {
    printf("Could not find module's initializer function.");
    return 0;
  }

  JSObjectRef module;
  init_function(context, &module);

  return module;
}

bool JSCShell::RegisterFunction(JSGlobalContextRef context, JSObjectRef object,
                        const char* functionName, JSObjectCallAsFunctionCallback callback) {
    JSCString js_functionName(functionName);
    JSObjectSetProperty(context, object, js_functionName.JSString(),
                        JSObjectMakeFunctionWithCallback(context, js_functionName.JSString(), callback),
                        kJSPropertyAttributeNone, NULL);
    return true;
}

void JSCShell::PrintError(JSContextRef ctx, JSValueRef err) {

  JSCString errMsg(ctx, err);
  JSObjectRef errObj = JSValueToObject(ctx, err, 0);

  if(errObj == 0) {
    std::cerr << errMsg.cppString() << std::endl;
    return;
  }

  JSCString sourceURLKey("sourceURL");
  JSCString sourceURL(ctx, JSObjectGetProperty(ctx, errObj, sourceURLKey.JSString(), NULL));

  JSCString lineKey("line");
  JSValueRef jsLine = JSObjectGetProperty(ctx, errObj, lineKey.JSString(), NULL);
  int line = (int) JSValueToNumber(ctx, jsLine, 0);

  std::cerr << sourceURL.cppString() << ':' << line << ':' << errMsg.cppString() << std::endl;
}

JSShell* JSCShell_Create() {
  return new JSCShell();
}
