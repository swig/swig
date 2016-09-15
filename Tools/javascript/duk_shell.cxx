#include <duktape.h>

#include "js_shell.h"

#include <iostream>
#include <stdio.h>

#ifdef __GNUC__
#include <dlfcn.h>
#define LOAD_SYMBOL(handle, name) dlsym(handle, name)
#else
#error "implement dll loading"
#endif

class DUKShell: public JSShell {
public:

  DUKShell() { ctx = NULL; };

  virtual ~DUKShell();

protected:

  virtual bool InitializeEngine();

  virtual bool ExecuteScript(const std::string& source, const std::string& scriptPath);

  virtual bool DisposeEngine();

private:

  duk_context *ctx;
};

DUKShell::~DUKShell() {
}

bool DUKShell::InitializeEngine() {

  if(ctx!=NULL) DisposeEngine();

  ctx = duk_create_heap_default();
  if(ctx==NULL) return false;

  return true;
}

bool DUKShell::ExecuteScript(const std::string& source, const std::string& scriptPath) {
  if (ctx == NULL) {
      std::cout << "uninitialized context" << std::endl;
      return false;
  }
    /*void duk_eval_string(duk_context *ctx, const char *src);*/
  if (duk_peval_string(ctx,source.c_str()) != 0) {
      std::cout << "" << scriptPath << ":" << duk_safe_to_string(ctx, -1) << std::endl;
      return false;
  } else {
      std::cout << duk_safe_to_string(ctx, -1) << std::endl;
      return true;
  };
}

bool DUKShell::DisposeEngine() {
    if (ctx != NULL) {
        duk_destroy_heap(ctx);
        ctx=NULL;
    }
    return true;
}

JSShell* DUKShell_Create() {
  return new DUKShell();
}
