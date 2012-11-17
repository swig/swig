#ifndef JS_SHELL_H
#define JS_SHELL_H

#include <vector>
#include <string>

typedef void* HANDLE;

class JSShell {

public:
  enum Engine {
    JSC,
    V8
  };

public:

  JSShell() {}

  virtual ~JSShell() = 0;

  static JSShell* Create();

  bool ImportModule(const std::string& name);

  virtual bool RunScript(const std::string& scriptPath);

  virtual bool RunShell();

protected:

  virtual bool RegisterModule(HANDLE library, const std::string& module_name) = 0;

  virtual bool InitializeEngine() = 0;

  virtual bool ExecuteScript(const std::string& source, const std::string& name) = 0;

  virtual bool DisposeEngine() = 0;

  static std::string ReadFile(const std::string& fileName);

protected:

  std::vector<HANDLE> loaded_modules;

};

typedef JSShell* (*JSShellFactory)();

#endif // JS_SHELL_H
