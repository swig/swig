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

class JSCShell: public JSShell {

typedef int (*JSCIntializer)(JSGlobalContextRef context);

public:

  JSCShell() {};

  virtual ~JSCShell();

protected:

  virtual bool RegisterModule(HANDLE library, const std::string& module_name);

  virtual bool InitializeEngine();

  virtual bool ExecuteScript(const std::string& source, const std::string& name);

  virtual bool DisposeEngine();

private:

  static JSValueRef Print(JSContextRef context,JSObjectRef object, JSObjectRef globalobj, size_t argc, const JSValueRef args[], JSValueRef* ex);

  static bool RegisterFunction(JSGlobalContextRef context, JSObjectRef object, const char* functionName, JSObjectCallAsFunctionCallback cbFunction);

  static void PrintError(JSContextRef, JSValueRef, const std::string&);

private:

  std::vector<JSCIntializer> module_initializers;

  JSGlobalContextRef context;
};

JSCShell::~JSCShell() {
  if(context != 0) {
    JSGlobalContextRelease(context);
    context = 0;
  }
}

bool JSCShell::RegisterModule(HANDLE library, const std::string& module_name) {
    std::string symname = std::string(module_name).append("_initialize");

    JSCIntializer init_function = reinterpret_cast<JSCIntializer>((long) LOAD_SYMBOL(library, symname.c_str()));
    if(init_function == 0) return false;

    module_initializers.push_back(init_function);
    return true;
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
  JSCShell::RegisterFunction(context, globalObject, "print", JSCShell::Print);
  // Call module initializers
  for(std::vector<JSCIntializer>::iterator it = module_initializers.begin();
    it != module_initializers.end(); ++it) {
      JSCIntializer init_function = *it;
      if(!init_function(context)) {
        return false;
      }
  }
  return true;
}

bool JSCShell::ExecuteScript(const std::string& source, const std::string& name) {
  JSStringRef jsScript;
  JSValueRef ex;
  jsScript = JSStringCreateWithUTF8CString(source.c_str());
  JSValueRef jsResult = JSEvaluateScript(context, jsScript, 0, 0, 0, &ex);
  JSStringRelease(jsScript);
  if (jsResult == NULL && ex != NULL) {
      JSCShell::PrintError(context, ex, name);
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
    JSStringRef string = JSValueToStringCopy(context, args[0], NULL);
    size_t numChars = JSStringGetMaximumUTF8CStringSize(string);
    char *stringUTF8 = new char[numChars];
    JSStringGetUTF8CString(string, stringUTF8, numChars);
    printf("%s\n", stringUTF8);

    delete[] stringUTF8;
  }

  return JSValueMakeUndefined(context);
}

bool JSCShell::RegisterFunction(JSGlobalContextRef context, JSObjectRef object,
                        const char* functionName, JSObjectCallAsFunctionCallback callback) {
    JSStringRef js_functionName = JSStringCreateWithUTF8CString(functionName);
    JSObjectSetProperty(context, object, js_functionName,
                        JSObjectMakeFunctionWithCallback(context, js_functionName, callback),
                        kJSPropertyAttributeNone, NULL);
    JSStringRelease(js_functionName);
    return true;
}

void JSCShell::PrintError(JSContextRef ctx, JSValueRef err, const std::string& name) {
  char *buffer;

  JSStringRef string = JSValueToStringCopy(ctx, err, 0);
  size_t length = JSStringGetLength(string);

  buffer   = new char[length+1];
  JSStringGetUTF8CString(string, buffer, length+1);
  std::string errMsg(buffer);
  JSStringRelease(string);
  delete[] buffer;

  JSObjectRef errObj = JSValueToObject(ctx, err, 0);

  if(errObj == 0) {
    std::cerr << errMsg << std::endl;
    return;
  }

  // Note: usually you would also retrieve the property "sourceURL"
  //       though, it happened that this was always ""
  JSStringRef lineKey = JSStringCreateWithUTF8CString("line");
  JSValueRef jsLine = JSObjectGetProperty(ctx, errObj, lineKey, 0);
  int line = (int) JSValueToNumber(ctx, jsLine, 0);
  JSStringRelease(lineKey);

  std::cerr << name << ":" << line << ":" << errMsg << std::endl;
}

JSShell* JSCShell_Create() {
  return new JSCShell();
}
