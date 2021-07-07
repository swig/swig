/* -----------------------------------------------------------------------------
 * std_shared_ptr.i
 *
 * Copyright (c) 1995-2021 The SWIG Developers 
 *
 * ---------
 * Author(s)
 * ---------
 *     Tama MA (Tama.Ma@ibm.com)
 *
 * ---------------
 * Getting started
 * ---------------
 * 
 * // 1) mysingleton.hpp
 *
 * class MySingleton {
 * public:
 *   static std::shared_ptr<MySingleton> GetMySingleton();
 *   std::string GetVersion() const { return "my-singleton-1.0"; }
 * };
 *
 * // 2) mysingleton.go.i
 * 
 * %module "mysingleton"
 * %include <std_string.i>
 * %include <std_shared_ptr.i>
 * %shared_ptr(SharedPtrMySingleton, MySingleton);
 * %include <mysingleton.hpp>
 *
 * // 3) mysingleton_test.go
 *
 * func TestMySingleton(t *testing.T) {
 *     instance := mysingleton.MySingletonGetMySingleton()
 *     actual_version := instance.GetVersion()
 *     expected_version := "my-singleton-1.0"
 *     if actual_version != expected_version {
 *         t.Errorf("[TestMySingleton] actual_version: %s | expected_version: %s", actual_version, expected_version) 
 *     }
 * }
 *     
 * -----------
 * Description
 * -----------
 * 1) <std_shared_ptr.i> provides limited Go-wrapper for std::shared_ptr.
 * 2) For the purpose of automatic memory management, we :
 *       - have deliberately disabled std::shared_ptr constructor wrapper support
 *       - recommend using factory methods (as shown above) to create shared_ptr instances
 * 3) shared_ptr objects are automatically freed by Go-GC when they go out of scope. Hints:
 *       - To manually trigger Go-GC, run: runtime.GC()
 *       - Otherwise, GC would be automatic.
 * 4) For convenience, users can access public methods of the underlying types directly. The following are equivalent:
 *       - instance.GetVersion()                // here: instance       ~ std::shared_ptr<MySingleton>*
 *       - instance.Get().GetVersion()          // here: instance.Get() ~ MySingleton*
 *
 * ----------------------------------------------------------------------------- */

%{
#include <memory>
%}

%ignore std::shared_ptr::shared_ptr;

namespace std {

  template<class T>
  class shared_ptr {
  public:
    T* operator->() const noexcept;
    T* get() const noexcept;

    long use_count() const noexcept;
  };

}

%define %shared_ptr(GO_SHARED_PTR_INTERFACE_TYPE, CPP_UNDERLYING_TYPE)

%template(##GO_SHARED_PTR_INTERFACE_TYPE) std::shared_ptr<##CPP_UNDERLYING_TYPE>;

%go_import("runtime")
%typemap(goout, noblock=1) std::shared_ptr<##CPP_UNDERLYING_TYPE> {
    runtime.SetFinalizer(&$result, func(swigptr_##GO_SHARED_PTR_INTERFACE_TYPE *##GO_SHARED_PTR_INTERFACE_TYPE) { 
        Delete##GO_SHARED_PTR_INTERFACE_TYPE(*swigptr_##GO_SHARED_PTR_INTERFACE_TYPE)
    })
    $result = $1
}

%enddef
