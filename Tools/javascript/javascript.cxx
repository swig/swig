#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>
#include <string>
#include <vector>

#include "js_shell.h"

void print_usage() {
  std::cout << "javascript [-i] [-jsc|-v8] [-l module] <js-file>" << std::endl;
}

int main(int argc, char* argv[]) {

  std::string scriptPath = "";
  std::vector<std::string> module_names;

  bool interactive = false;
  JSShell* shell = 0;

  for (int idx = 1; idx < argc; ++idx) {
    if(strcmp(argv[idx], "-l") == 0) {
      idx++;
      if(idx > argc) {
        print_usage();
        exit(-1);
      }
      std::string module_name(argv[idx]);
      module_names.push_back(module_name);
    } else if(strcmp(argv[idx], "-v8") == 0) {
        shell = JSShell::Create(JSShell::V8);
    } else if(strcmp(argv[idx], "-jsc") == 0) {
        shell = JSShell::Create(JSShell::JSC);
    } else if(strcmp(argv[idx], "-i") == 0) {
      interactive = true;
    } else {
      scriptPath = argv[idx];
    }
  }

  if (shell == 0) {
    shell = JSShell::Create();
  }

  bool failed = false;
  for(std::vector<std::string>::iterator it = module_names.begin();
    it != module_names.end(); ++it) {
    std::string module_name = *it;

    bool success = shell->ImportModule(module_name);
    failed |= !success;
  }

  if (failed) {
    delete shell;
    printf("FAIL: Some modules could not be loaded.\n");
    return -1;
  }

  if(interactive) {
    failed = !(shell->RunShell());
  } else {
    failed = !(shell->RunScript(scriptPath));
  }

  if (failed) {
    delete shell;
    printf("FAIL: Error during execution of script.\n");
    return 1;
  }

  delete shell;

  return 0;
}
