
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <iostream>
#include <string>
#include <vector>

#include <dlfcn.h>

#include <JavaScriptCore/JavaScript.h>

using namespace std;

static JSValueRef jsc_printstring(JSContextRef context,JSObjectRef object, JSObjectRef globalobj, size_t argc, const JSValueRef	args[], JSValueRef* ex);
static char* jsccreateStringWithContentsOfFile(const char* fileName);
bool jsc_registerFunction(JSGlobalContextRef context, JSObjectRef object, const char* FunctionName,JSObjectCallAsFunctionCallback cbFunction);

typedef void* HANDLE;
typedef int (*JSCIntializer)(JSGlobalContextRef context);

void jsc_printError(JSContextRef, JSValueRef, const std::string&);

void print_usage() {
    std::cout << "javascript [-l module] <js-file>" << std::endl;
}

int main(int argc, char* argv[]) {

    std::string scriptPath;
    
    std::vector<std::string> module_names;
    
    std::vector<HANDLE> loaded_modules;
    std::vector<JSCIntializer> module_initializers;

    for (int idx = 1; idx < argc; ++idx) {
      if(strcmp(argv[idx], "-l") == 0) {
        idx++;
        if(idx > argc) {
          print_usage();
          exit(-1);
        }
        std::string module_name(argv[idx]);
        module_names.push_back(module_name);
      } else {
        scriptPath = argv[idx];
      }
    }
    
    for(std::vector<std::string>::iterator it = module_names.begin();
      it != module_names.end(); ++it) {
      std::string module_name = *it;
      std::string lib_name = std::string("lib").append(module_name).append(".so");

      HANDLE handle = dlopen(lib_name.c_str(), RTLD_LAZY);
      if(handle == 0) {
        std::cout << "Could not load library " << lib_name << ":" 
                  << std::endl << dlerror() << std::endl;
        continue;
      }
      
      std::string symname;
      symname.append(module_name).append("_initialize");
      
      JSCIntializer init_function = reinterpret_cast<JSCIntializer>((long) dlsym(handle, symname.c_str()));
      if(init_function == 0) {
        std::cout << "Could not find initializer function in module " << module_name << std::endl;
        dlclose(handle);
        continue;
      }
      
      loaded_modules.push_back(handle);
      module_initializers.push_back(init_function);
    }
    
    static int failed;

    JSGlobalContextRef context = JSGlobalContextCreate(NULL);
    JSObjectRef globalObject = JSContextGetGlobalObject(context);

    jsc_registerFunction(context, globalObject, "print", jsc_printstring); // Utility print function
    
    // Call module initializers
    for(std::vector<JSCIntializer>::iterator it = module_initializers.begin();
      it != module_initializers.end(); ++it) {
        JSCIntializer init_function = *it;
        init_function(context);
    }
    
    // Evaluate the javascript
    char* scriptContent = jsccreateStringWithContentsOfFile(scriptPath.c_str());
    JSStringRef jsScript;
    
    if(!scriptContent) {
        printf("FAIL: runme script could not be loaded.\n");
        failed = 1;
    }
    else {
        JSValueRef ex;
        jsScript = JSStringCreateWithUTF8CString(scriptContent);
        JSValueRef jsResult = JSEvaluateScript(context, jsScript, 0, 0, 0, &ex);
        
        if (!jsResult && ex) {
            jsc_printError(context, ex, scriptPath);
            failed = 1;
        }
    }

    if (scriptContent != NULL) {
        free(scriptContent);
    }
        
    JSStringRelease(jsScript);

    JSGlobalContextRelease(context);
    globalObject = 0;

    for(std::vector<HANDLE>::iterator it = loaded_modules.begin();
      it != loaded_modules.end(); ++it) {
        HANDLE handle = *it;
        dlclose(handle);
    }
    
    if (failed) {
        printf("FAIL: Some tests failed.\n");
        return 1;
    }
}

static JSValueRef jsc_printstring(JSContextRef context,JSObjectRef object, JSObjectRef globalobj, size_t argc, const JSValueRef	args[], JSValueRef* ex)
{
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

static char* jsccreateStringWithContentsOfFile(const char* fileName)
{
	char* buffer;
	
	size_t buffer_size = 0;
	size_t buffer_capacity = 1024;
	buffer = (char*)malloc(buffer_capacity);
	
	FILE* f = fopen(fileName, "r");
	if (!f)
	{
		fprintf(stderr, "Could not open file: %s\n", fileName);
		return 0;
	}
	
	while (!feof(f) && !ferror(f))
	{
		buffer_size += fread(buffer + buffer_size, 1, buffer_capacity - buffer_size, f);
		if (buffer_size == buffer_capacity)
		{ 
			// guarantees space for trailing '\0'
			buffer_capacity *= 2;
			buffer = (char*)realloc(buffer, buffer_capacity);
		}
	}
	fclose(f);
	buffer[buffer_size] = '\0';
	
	return buffer;
}

bool jsc_registerFunction(JSGlobalContextRef context, JSObjectRef object, 
                        const char* functionName, JSObjectCallAsFunctionCallback callback)
{
    JSStringRef js_functionName = JSStringCreateWithUTF8CString(functionName);
    JSObjectSetProperty(context, object, js_functionName,
                        JSObjectMakeFunctionWithCallback(context, js_functionName, callback), 
                        kJSPropertyAttributeNone, NULL);
    JSStringRelease(js_functionName);
    return true;
}

void jsc_printError(JSContextRef ctx, JSValueRef err, const std::string& sourceUrl)
{
  char *buffer;
    
  JSStringRef string = JSValueToStringCopy(ctx, err, 0);
  size_t length = JSStringGetLength(string);
  
  buffer   = (char*) malloc(length+1);
  JSStringGetUTF8CString(string, buffer, length+1);
  std::string errMsg(buffer);
  JSStringRelease(string);
  free(buffer);

  JSObjectRef errObj = JSValueToObject(ctx, err, 0);
  
  if(errObj == 0) {
    return;
  }
  // Note: usually you would also retrieve the property "sourceURL"
  //       though, it happened that this was always ""
  JSStringRef lineKey = JSStringCreateWithUTF8CString("line");
  JSValueRef jsLine = JSObjectGetProperty(ctx, errObj, lineKey, 0);
  int line = (int) JSValueToNumber(ctx, jsLine, 0);  
  JSStringRelease(lineKey);

  std::cerr << sourceUrl << ":" << line << ":" << errMsg << std::endl;
    
}
