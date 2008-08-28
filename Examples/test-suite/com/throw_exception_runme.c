#define CINTERFACE
#include <stdio.h>
#include <windows.h>

#ifndef MSVC
/* This is a workaround for a VC specific attribute */
#define __RPC__deref_out
#endif

#ifdef __DMC__
#define __RPCNDR_H_VERSION__        ( 450 ) 
#endif

#include "throw_exception/throw_exception_generated.h"

void check_message(wchar_t *expected_msg) {
  IErrorInfo *iei = NULL;
  wchar_t *descr = NULL;

  GetErrorInfo(0, &iei);

  iei->lpVtbl->GetDescription(iei, &descr);
  iei->lpVtbl->Release(iei);

  if (wcscmp(expected_msg, descr)) {
    fprintf(stderr, "Incorrect message description\n");
    exit(1);
  }

  /* Should we release descr? */
  CoTaskMemFree(descr - 2);
}

int main() {
  Ithrow_exception *te = NULL;
  IFooStatic *fs = NULL;
  IFoo *foo = NULL;
  IErrorInfo *iei = NULL;
  HRESULT hres;

  CoInitialize(NULL);

  CoCreateInstance(&CLSID_throw_exceptionImpl, NULL, CLSCTX_INPROC_SERVER, &IID_Ithrow_exception, (void **) &te);

  /* Construct Foo object */
  te->lpVtbl->get_Foo(te, &fs);
  fs->lpVtbl->new_Foo(fs, &foo);

  hres = foo->lpVtbl->test_int(foo);

  if (hres != E_ABORT) {
    fprintf(stderr, "Exception should have been thrown\n");
    exit(1);
  }

  check_message(L"C++ int exception thrown");

  hres = foo->lpVtbl->test_msg(foo);

  if (hres != E_ABORT) {
    fprintf(stderr, "Exception should have been thrown\n");
    exit(1);
  }

  check_message(L"C++ char const * exception thrown");

  hres = foo->lpVtbl->test_cls(foo);

  if (hres != E_ABORT) {
    fprintf(stderr, "Exception should have been thrown\n");
    exit(1);
  }

  check_message(L"C++ Error exception thrown");

  foo->lpVtbl->Release(foo);
  fs->lpVtbl->Release(fs);
  te->lpVtbl->Release(te);

  CoUninitialize();

  return 0;
}
