#include "js_shell.h"

#include <iostream>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>

#ifdef __GNUC__
#include <dlfcn.h>
#define LOAD_LIBRARY(name) dlopen(name, RTLD_LAZY)
#define CLOSE_LIBRARY(handle) dlclose(handle)
#define LIBRARY_ERROR dlerror
#define LIBRARYFILE(name) std::string("lib").append(name).append(".so")
#else
#error "implement dll loading"
#endif



JSShell::~JSShell() {

  for(std::vector<HANDLE>::iterator it = loaded_modules.begin();
    it != loaded_modules.end(); ++it) {
      HANDLE handle = *it;
      CLOSE_LIBRARY(handle);
  }

}

bool JSShell::ImportModule(const std::string& name) {

   std::string lib_name = LIBRARYFILE(name);

    HANDLE handle = LOAD_LIBRARY(lib_name.c_str());
    if(handle == 0) {
      std::cout << "Could not load library " << lib_name << ":"
                << std::endl << LIBRARY_ERROR() << std::endl;
      return false;
    }

    if(!RegisterModule(handle, name)) {
      std::cout << "Could not find initializer function in " << lib_name << std::endl;
      CLOSE_LIBRARY(handle);
      return false;
    }

    loaded_modules.push_back(handle);

    return true;
}

bool JSShell::RunScript(const std::string& scriptPath) {
  std::string source = ReadFile(scriptPath);
  if(!InitializeEngine()) return false;

  if(!ExecuteScript(source, scriptPath)) {
    return false;
  }

  return DisposeEngine();
}

bool JSShell::RunShell() {

  if(!InitializeEngine()) return false;

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
  return true;
}

std::string JSShell::ReadFile(const std::string& fileName)
{
  std::string script;

  std::ifstream file(fileName.c_str());
  if (file.is_open()) {
    while ( file.good() ) {
      std::string line;
      getline(file, line);
      script.append(line);
      script.append("\n");
    }
    file.close();
  } else {
    std::cout << "Unable to open file " << fileName << "." << std::endl;
  }

  return script;
}

#ifdef ENABLE_JSC
extern JSShell* JSCShell_Create();
#endif
#ifdef ENABLE_V8
extern JSShell* V8Shell_Create();
#endif

typedef JSShell*(*ShellFactory)();

static ShellFactory js_shell_factories[2] = {
#ifdef ENABLE_JSC
JSCShell_Create,
#else
0,
#endif
#ifdef ENABLE_V8
V8Shell_Create,
#else
0,
#endif
};

JSShell *JSShell::Create(Engine engine) {
  if(js_shell_factories[engine] == 0) {
    throw "Engine not supported.";
  }
  return js_shell_factories[engine]();
}
