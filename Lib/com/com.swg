/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * com.swg
 *
 * COM typemaps
 * ----------------------------------------------------------------------------- */

%typemap(ctype) void "void"
%typemap(ctype) int, const int & "/* ctype */ int"
%typemap(ctype) double, const double & "/*ctype */ double"
%typemap(ctype) long, const long & "/* ctype */ long"
%typemap(ctype) SWIGTYPE * "/* ctype */ SWIGIUnknown *"
%typemap(ctype) SWIGTYPE "/* ctype */ SWIGIUnknown *"
%typemap(ctype) SWIGTYPE & "/* ctype */ SWIGIUnknown *"

%typemap(comtype) void "void"
%typemap(comtype) int, const int & "/* comtype */ int"
%typemap(comtype) double, const double & "/* comtype */ double"
%typemap(comtype) long, const long & "/* comtype */ long"
%typemap(comtype) SWIGTYPE * "/* comtype */ $comclassname *"
%typemap(comtype) SWIGTYPE "/* comtype */ $&comclassname *"
%typemap(comtype) SWIGTYPE & "/* comtype */ $comclassname *"
%typemap(comtype) SWIGTYPE *& "/* comtype */ $*comclassname *"

%typemap(in) int, double, long %{ /* in */ $1 = ($1_ltype)$input; %}

%typemap(in) SWIGTYPE * %{
  {
    SWIGIUnknown *wrapper;

    /* Call to QueryInterface */
    HRESULT hr = ((HRESULT (SWIGSTDCALL *)(SWIGIUnknown *, REFIID, void **))
        $input->vtable[0])($input, IID_ISWIGWrappedObject, (void **) &wrapper); 

    if (hr != S_OK) {
      /* Argument was not wrapped by SWIG - directors will be needed */
    } else {
      /* GetCPtr */
      $1 = ($1_ltype) ((void * (SWIGSTDCALL *)(SWIGIUnknown *)) (wrapper->vtable[3]))(wrapper);

      /* Release */
      ((long (SWIGSTDCALL *)(SWIGIUnknown *)) (wrapper->vtable[2]))(wrapper);
    }
  }
%}

%typemap(in) SWIGTYPE & %{
  {
    SWIGIUnknown *wrapper;

    /* Call to QueryInterface */
    HRESULT hr = ((HRESULT (SWIGSTDCALL *)(SWIGIUnknown *, REFIID, void **))
        $input->vtable[0])($input, IID_ISWIGWrappedObject, (void **) &wrapper); 

    if (hr != S_OK) {
      /* Argument was not wrapped by SWIG - directors will be needed */
    } else {
      /* GetCPtr */
      $1 = ($1_ltype) ((void * (SWIGSTDCALL *)(SWIGIUnknown *)) (wrapper->vtable[3]))(wrapper);

      /* Release */
      ((long (SWIGSTDCALL *)(SWIGIUnknown *)) (wrapper->vtable[2]))(wrapper);
    }
  }
%}

%typemap(in) SWIGTYPE ($&1_type argp) %{
  {
    SWIGIUnknown *wrapper;

    /* Call to QueryInterface */
    HRESULT hr = ((HRESULT (SWIGSTDCALL *)(SWIGIUnknown *, REFIID, void **))
        $input->vtable[0])($input, IID_ISWIGWrappedObject, (void **) &wrapper); 

    if (hr != S_OK) {
      /* Argument was not wrapped by SWIG - directors will be needed */
    } else {
      /* GetCPtr */
      argp = ($&1_ltype) ((void * (SWIGSTDCALL *)(SWIGIUnknown *)) (wrapper->vtable[3]))(wrapper);

      /* Release */
      ((long (SWIGSTDCALL *)(SWIGIUnknown *)) (wrapper->vtable[2]))(wrapper);
    }
  }

  $1 = *argp;
%}

%typemap(out) int, double, long %{ /* out */ $result = $1; %}
%typemap(out) void ""

%typemap(out) SWIGTYPE * %{
  $result = (SWIGIUnknown *) SWIG_wrap$comclassname((void *) $1, $owner);
%}

%typemap(out) SWIGTYPE & %{
  $result = (SWIGIUnknown *) SWIG_wrap$comclassname((void *) $1, $owner);
%}

%typemap(out) SWIGTYPE 
#ifdef __cplusplus
%{ $result = (SWIGIUnknown *) SWIG_wrap$comclassname((void *) new $1_ltype((const $1_ltype &)$1), 1); %}
#else
{
  $&1_ltype $1ptr = ($&1_ltype) malloc(sizeof($1_ltype));
  memmove($1ptr, &$1, sizeof($1_type));
  $result = (SWIGIUnknown *) SWIG_wrap$comclassname((void *) $1ptr, 1);
}
#endif

%typemap(combody) SWIGTYPE * %{
%}

%typemap(combody) SWIGTYPE %{
%}

%insert("runtime") %{

#include <windows.h>
#include <olectl.h>
#include <tchar.h>
#include <initguid.h>

#include <string.h>
#include <memory.h>

typedef void (SWIGSTDCALL *SWIG_funcptr)(void);

typedef struct {
  SWIG_funcptr *vtable;
  SWIG_funcptr newInstance;
  LONG refCount;
} SWIGClassFactory;

/* For consistent manipulation regardless of C or C++ mode */
typedef struct {
  SWIG_funcptr *vtable;
} SWIGIUnknown;

typedef struct {
  SWIG_funcptr *vtable; /* vtable for the methods of the wrapped object */
  SWIG_funcptr *SWIGWrappedObject_vtable; /* vtable for helper methods */
  void *cPtr; /* pointer to the wrapped object */
  int cMemOwn; /* memory owned by the proxy? */
  LONG refCount; /* reference count */
  void (SWIGSTDCALL *deleteInstance)(SWIGIUnknown *); /* destructor */
  ITypeInfo *typeInfo; /* ITypeInfo object for IDispatch */
} SWIGWrappedObject;

DEFINE_GUID(IID_ISWIGWrappedObject, 0x73738294, 0x8833, 0x1182, 0x01, 0x12, 0x23, 0x34, 0x45, 0x56, 0x67, 0x78);
static LONG globalRefCount = 0;

long SWIGSTDCALL SWIGAddRef1(void *iunk) {
  SWIGWrappedObject *obj = (SWIGWrappedObject *) iunk;

  InterlockedIncrement(&globalRefCount);
  return InterlockedIncrement(&obj->refCount);
}

long SWIGSTDCALL SWIGAddRef2(void *iunk) {
  return SWIGAddRef1((void **)iunk - 1);
}

long SWIGSTDCALL SWIGRelease1(void *iunk) {
  SWIGWrappedObject *obj = (SWIGWrappedObject *) iunk;

  LONG res = InterlockedDecrement(&obj->refCount);

  if (res == 0) {
    if (obj->cMemOwn && obj->deleteInstance != 0) {
      obj->deleteInstance((SWIGIUnknown *) obj);
    }

#ifdef __cplusplus
    delete obj;
#else
    free(obj);
#endif    
  }

  InterlockedDecrement(&globalRefCount);
  return res;
}

long SWIGSTDCALL SWIGRelease2(void *iunk) {
  return SWIGRelease1((void **)iunk - 1);
}

void * SWIGSTDCALL SWIGGetCPtr(void *iunk) {
  SWIGWrappedObject *obj = (SWIGWrappedObject *) ((void **)iunk - 1);

  return obj->cPtr;
}

HRESULT SWIGSTDCALL SWIGGetTypeInfoCount(SWIGWrappedObject *obj, unsigned int * pctinfo) {
  *pctinfo = 1;

  return S_OK;
}

HRESULT SWIGSTDCALL SWIGGetTypeInfo(SWIGWrappedObject *obj, unsigned int iTInfo, LCID  lcid, ITypeInfo **  ppTInfo) {
  *ppTInfo = obj->typeInfo;

  return S_OK;
}

HRESULT SWIGSTDCALL SWIGGetIDsOfNames(SWIGWrappedObject *obj, REFIID riid, OLECHAR FAR* FAR* rgszNames,  
    unsigned int cNames, LCID lcid, DISPID FAR* rgDispId) {
  HRESULT hres = DispGetIDsOfNames(obj->typeInfo, rgszNames, cNames, rgDispId);

  return hres;
}

HRESULT SWIGSTDCALL SWIGInvoke(SWIGWrappedObject *obj, DISPID dispIdMember, REFIID riid, LCID lcid,                
    WORD wFlags, DISPPARAMS FAR* pDispParams, VARIANT FAR*  pVarResult,  
    EXCEPINFO FAR*  pExcepInfo, unsigned int FAR*  puArgErr) {
  HRESULT hres = DispInvoke(
      (void *) obj, obj->typeInfo,
      dispIdMember, wFlags, pDispParams,
      pVarResult, pExcepInfo, puArgErr); 

  return hres;
}

static OLECHAR SWIG_typelib_path[MAX_PATH + 1];
static ITypeLib *SWIG_typelib = NULL;

long SWIGSTDCALL SWIGClassFactoryAddRef(SWIGClassFactory *factory) {
  InterlockedIncrement(&globalRefCount);
  return InterlockedIncrement(&factory->refCount);
}

long SWIGSTDCALL SWIGClassFactoryRelease(SWIGClassFactory *factory) {
  LONG res = InterlockedDecrement(&factory->refCount);

  if (res == 0) {
#ifdef __cplusplus
    delete factory;
#else
    free(factory);
#endif    
  }

  InterlockedDecrement(&globalRefCount);
  return res;
}

HRESULT SWIGSTDCALL SWIGClassFactoryQueryInterface(SWIGClassFactory *factory, REFIID iid, void **ppvObject) {
  if (IsEqualIID(iid, IID_IUnknown) || IsEqualIID(iid, IID_IClassFactory)) {
    SWIGClassFactoryAddRef(factory);
    *ppvObject = factory;

    return S_OK;
  } else {
    return E_NOINTERFACE;
  }
}

HRESULT SWIGSTDCALL SWIGClassFactoryCreateInstance(SWIGClassFactory *factory, IUnknown *punkOuter, REFIID riid, void **ppvObject)
{
  HRESULT hr;
  SWIGIUnknown *obj;

  if (ppvObject == NULL)
     return E_INVALIDARG;

  if (punkOuter)
     return CLASS_E_NOAGGREGATION;

  /* Create the instance */
  obj = (SWIGIUnknown *) ((void* (SWIGSTDCALL *)(void *)) factory->newInstance)(NULL);

  if (obj == NULL) {
    return E_OUTOFMEMORY;
  }

  hr = ((HRESULT (SWIGSTDCALL *)(SWIGIUnknown *, REFIID, void **)) obj->vtable[0])(obj, riid, ppvObject);

  /* Release reference */
  ((long (SWIGSTDCALL *)(SWIGIUnknown *)) (obj->vtable[2]))(obj);

  return hr;
}

HRESULT SWIGSTDCALL SWIGClassFactoryLockServer(SWIGClassFactory *factory, BOOL fLock) {
  CoLockObjectExternal((IUnknown *) (void *) factory, fLock, TRUE);

  return S_OK;
}

SWIG_funcptr SWIGClassFactory_vtable[] = {
  (SWIG_funcptr) SWIGClassFactoryQueryInterface,
  (SWIG_funcptr) SWIGClassFactoryAddRef,
  (SWIG_funcptr) SWIGClassFactoryRelease,
  (SWIG_funcptr) SWIGClassFactoryCreateInstance,
  (SWIG_funcptr) SWIGClassFactoryLockServer
};

typedef struct {
  SWIG_funcptr newInstance;
  REFGUID guid;
  TCHAR *guid_string;
  TCHAR *oleaut_string;
} SWIGClassDescription_t;

HRESULT SWIGSTDCALL _wrap_opaque_QueryInterface1(void *that, REFIID iid, void ** ppvObject) {
  if (IsEqualIID(iid, IID_ISWIGWrappedObject)) {
    /* FIXME: This could be more elegant */
    SWIGAddRef1(that); 
    *ppvObject = (void *) ((void **)that + 1);
    return S_OK;
  }
  
  if (IsEqualIID(iid, IID_IUnknown)) {
    /* FIXME: This could be more elegant */
    SWIGAddRef1(that);
    *ppvObject = that;
    return S_OK;
  }
  
  return E_NOINTERFACE;
}

HRESULT SWIGSTDCALL _wrap_opaque_QueryInterface2(void *that, REFIID iid, void ** ppvObject) {
  return _wrap_opaque_QueryInterface1((void *) ((void **) that - 1), iid, ppvObject);
}

SWIG_funcptr _wrap_opaque_SWIGWrappedObject_vtable[] = {
  (SWIG_funcptr) _wrap_opaque_QueryInterface2,
  (SWIG_funcptr) SWIGAddRef2,
  (SWIG_funcptr) SWIGRelease2,
  (SWIG_funcptr) SWIGGetCPtr
};

SWIG_funcptr _wrap_opaque_vtable[] = {
  (SWIG_funcptr) _wrap_opaque_QueryInterface1,
  (SWIG_funcptr) SWIGAddRef1,
  (SWIG_funcptr) SWIGRelease1,
};

void * SWIGSTDCALL SWIG_wrap_opaque(void *arg, int cMemOwn) {
#ifdef __cplusplus
  SWIGWrappedObject *res = new SWIGWrappedObject;
#else
  SWIGWrappedObject *res = (SWIGWrappedObject *) malloc(sizeof(SWIGWrappedObject));
#endif
  res->vtable = _wrap_opaque_vtable;
  res->SWIGWrappedObject_vtable = _wrap_opaque_SWIGWrappedObject_vtable;
  res->cPtr = arg;
  res->cMemOwn = cMemOwn;
  InterlockedIncrement(&globalRefCount);
  res->refCount = 1;
  return (void *) res;
}

%}

%insert("factory") %{

static HMODULE SWIGModule;

STDAPI DllGetClassObject(REFCLSID rclsid, REFIID riid, LPVOID *_ppv) {

  int i;
  SWIGClassFactory **ppv = (SWIGClassFactory **)(void *) _ppv;

  if (!IsEqualIID(riid, IID_IUnknown) && !IsEqualIID(riid, IID_IClassFactory))
    return E_NOINTERFACE;

  for (i = 0; SWIGClassDescription[i].newInstance != NULL; ++i) {
    if (IsEqualCLSID(rclsid, SWIGClassDescription[i].guid)) {
      /* Create a new class factory for the requested CLSID */
#ifdef __cplusplus
      *ppv = new SWIGClassFactory;
#else
      *ppv = (SWIGClassFactory *) malloc(sizeof(SWIGClassFactory));
#endif
      (*ppv)->vtable = SWIGClassFactory_vtable;
      (*ppv)->newInstance = SWIGClassDescription[i].newInstance;
      InterlockedIncrement(&globalRefCount);
      (*ppv)->refCount = 1;

      return S_OK;
    }
  }

  return CLASS_E_CLASSNOTAVAILABLE;
}

STDAPI DllCanUnloadNow(void) {
  /* Get the value of globalRefCount in a thread-safe manner */
  /* Could be maybe more elegant */
  LONG value = InterlockedExchangeAdd(&globalRefCount, 0);

  /*
   * Note - we have a guarantee that while we are in DllCanUnloadNow
   * all CoGetClassObject calls are put on hold. There is a really tiny
   * possibility of a race condition if there is a thread that
   * just decremented globalRefCount to 0 and is just performing the
   * return instruction.
   */

  if (value == 0)
    return S_OK;
  else
    return S_FALSE;
}

STDAPI DllRegisterServer(void) {
  TCHAR module_name[MAX_PATH + 1];
  TCHAR typelib_name[MAX_PATH + 1];
  int i;
  HRESULT hres = S_OK;
  int module_name_len;

#ifdef __WINE__
  /*
   * Wine has a broken implementation of GetModuleFileName, which does not
   * work correctly with Winelib DLLs. This is a very dumb workaround.
   * If you know how to fix it properly, please send a patch :)
   */
  if (GetCurrentDirectory(MAX_PATH + 1, module_name) == 0 ||
      _tcslen(module_name) + _tcslen(_T("\\$module.dll.so")) > MAX_PATH) {
    /* DLL name will not fit into MAX_PATH characters */
    return E_UNEXPECTED;
  }

  _tcscat(module_name, _T("\\$module.dll.so"));
#else
  GetModuleFileName(SWIGModule, module_name, MAX_PATH + 1);
#endif

  _tcscpy(typelib_name, module_name);
  module_name_len = _tcslen(module_name);

/* This needs to be made more flexible                     */
/* For now we assume that the TLB is a resource in the DLL */
#if 0
  /* Change .dll to .tlb */
  typelib_name[used - 3] = 't';
  typelib_name[used - 2] = 'l';
  typelib_name[used - 1] = 'b';
#endif

  for (i = 0; SWIGClassDescription[i].newInstance != NULL; ++i) {
    HKEY hkey_clsid = NULL,
        hkey = NULL,
        hsubkey = NULL;

    if (hres == S_OK &&
       RegOpenKeyEx(HKEY_CLASSES_ROOT, _T("CLSID"), 0, KEY_ALL_ACCESS, &hkey_clsid) != ERROR_SUCCESS) {
      hres = SELFREG_E_CLASS;
    }

    if (hres == S_OK &&
        RegCreateKeyEx(hkey_clsid, SWIGClassDescription[i].guid_string, 0, NULL,
        0, KEY_ALL_ACCESS, NULL, &hkey, NULL) != ERROR_SUCCESS) {
      hres = SELFREG_E_CLASS;
    }

    if (hres == S_OK &&
        RegCreateKeyEx(hkey, _T("InprocServer32"), 0, NULL, 0, KEY_ALL_ACCESS, NULL, &hsubkey, NULL) !=
        ERROR_SUCCESS) {
      hres = SELFREG_E_CLASS;
    }

    if (hres == S_OK &&
        RegSetValueEx(hsubkey, _T(""), 0, REG_SZ, (BYTE *) module_name,
        sizeof(TCHAR) * (module_name_len + 1)) != ERROR_SUCCESS) {
      hres = SELFREG_E_CLASS;
    }

    if (hres == S_OK &&
        RegSetValueEx(hsubkey, _T("ThreadingModel"), 0, REG_SZ, (BYTE *) _T("Both"),
        sizeof(TCHAR) * 5) != ERROR_SUCCESS) {
      hres = SELFREG_E_CLASS;
    }

    if (hkey_clsid != NULL)
      CloseHandle(hkey_clsid);
    if (hkey != NULL)
      CloseHandle(hkey);
    if (hsubkey != NULL)
      CloseHandle(hsubkey);

    hkey = hkey_clsid = NULL;

    if (hres == S_OK &&
        RegCreateKeyEx(HKEY_CLASSES_ROOT, SWIGClassDescription[i].oleaut_string, 0, NULL,
        0, KEY_ALL_ACCESS, NULL, &hkey, NULL) != ERROR_SUCCESS) {
      hres = SELFREG_E_CLASS;
    }

    if (hres == S_OK &&
        RegCreateKeyEx(hkey, _T("CLSID"), 0, NULL,
        0, KEY_ALL_ACCESS, NULL, &hkey_clsid, NULL) != ERROR_SUCCESS) {
      hres = SELFREG_E_CLASS;
    }

    if (hres == S_OK &&
        RegSetValueEx(hkey_clsid, _T(""), 0, REG_SZ, (BYTE *) SWIGClassDescription[i].guid_string,
        sizeof(TCHAR) * 39) != ERROR_SUCCESS) {
      hres = SELFREG_E_CLASS;
    }

    if (hkey_clsid != NULL)
      CloseHandle(hkey_clsid);
    if (hkey != NULL)
      CloseHandle(hkey);
  }

  {
    HKEY hkey_typelib = NULL,
        hkey = NULL,
        hkey_version = NULL,
        hkey_helpdir = NULL,
        hkey_flags = NULL,
        hkey_lcid = NULL,
        hkey_win32 = NULL;

    if (hres == S_OK &&
        RegOpenKeyEx(HKEY_CLASSES_ROOT, _T("TypeLib"), 0, KEY_ALL_ACCESS, &hkey_typelib) != ERROR_SUCCESS) {
      hres = SELFREG_E_TYPELIB;
    }

    if (hres == S_OK &&
        RegCreateKeyEx(hkey_typelib, SWIG_tlb_guid_string, 0, NULL,
        0, KEY_ALL_ACCESS, NULL, &hkey, NULL) != ERROR_SUCCESS) {
      hres = SELFREG_E_TYPELIB;
    }

    if (hres == S_OK &&
        RegCreateKeyEx(hkey, /* FIXME */ _T("1.0"), 0, NULL,
        0, KEY_ALL_ACCESS, NULL, &hkey_version, NULL) != ERROR_SUCCESS) {
      hres = SELFREG_E_TYPELIB;
    }

    if (hres == S_OK &&
        RegSetValueEx(hkey_version, _T(""), 0, REG_SZ, (BYTE *) _T("$module"),
        sizeof(TCHAR) * _tcslen(_T("$module"))) != ERROR_SUCCESS) {
      hres = SELFREG_E_TYPELIB;
    }

    if (hres == S_OK &&
        RegCreateKeyEx(hkey_version, _T("HELPDIR"), 0, NULL,
        0, KEY_ALL_ACCESS, NULL, &hkey_helpdir, NULL) != ERROR_SUCCESS) {
      hres = SELFREG_E_TYPELIB;
    }

    if (hres == S_OK &&
        RegSetValueEx(hkey_helpdir, _T(""), 0, REG_SZ, (BYTE *) "0",
        sizeof(TCHAR) * 2) != ERROR_SUCCESS) {
      hres = SELFREG_E_TYPELIB;
    }

    if (hres == S_OK &&
        RegCreateKeyEx(hkey_version, _T("FLAGS"), 0, NULL,
        0, KEY_ALL_ACCESS, NULL, &hkey_flags, NULL) != ERROR_SUCCESS) {
      hres = SELFREG_E_TYPELIB;
    }

    if (hres == S_OK &&
        RegSetValueEx(hkey_flags, _T(""), 0, REG_SZ, (BYTE *) _T("0"),
        sizeof(TCHAR) * 2) != ERROR_SUCCESS) {
      hres = SELFREG_E_TYPELIB;
    }

    if (hres == S_OK &&
        RegCreateKeyEx(hkey_version, _T("0"), 0, NULL,
        0, KEY_ALL_ACCESS, NULL, &hkey_lcid, NULL) != ERROR_SUCCESS) {
      hres = SELFREG_E_TYPELIB;
    }

    if (hres == S_OK &&
        RegCreateKeyEx(hkey_lcid, _T("win32"), 0, NULL,
        0, KEY_ALL_ACCESS, NULL, &hkey_win32, NULL) != ERROR_SUCCESS) {
      hres = SELFREG_E_TYPELIB;
    }

    if (hres == S_OK &&
        RegSetValueEx(hkey_win32, _T(""), 0, REG_SZ, (BYTE *) typelib_name,
        sizeof(TCHAR) * (module_name_len + 1)) != ERROR_SUCCESS) {
      hres = SELFREG_E_TYPELIB;
    }

    if (hkey_helpdir != NULL)
      CloseHandle(hkey_helpdir);
    if (hkey_flags != NULL)
      CloseHandle(hkey_flags);
    if (hkey_typelib != NULL)
      CloseHandle(hkey_typelib);
    if (hkey != NULL)
      CloseHandle(hkey);
    if (hkey_version != NULL)
      CloseHandle(hkey_version);
    if (hkey_lcid != NULL)
      CloseHandle(hkey_lcid);
    if (hkey_win32 != NULL)
      CloseHandle(hkey_win32);
  }

  return hres;
}

STDAPI DllUnregisterServer(void) {
  HRESULT hres = S_OK;
  /*
   * We may only remove keys that we created. Therefore some operation may fail
   * if we are trying to delete a non-empty key, but this is not an error.
   */
  int leftovers = 0;
  int i;

  for (i = 0; SWIGClassDescription[i].newInstance != NULL; ++i) {
    HKEY hkey_clsid = NULL,
        hkey = NULL;

    if (hres == S_OK &&
       RegOpenKeyEx(HKEY_CLASSES_ROOT, _T("CLSID"), 0, KEY_ALL_ACCESS, &hkey_clsid) != ERROR_SUCCESS) {
      hres = SELFREG_E_CLASS;
    }

    if (hres == S_OK &&
        RegOpenKeyEx(hkey_clsid, SWIGClassDescription[i].guid_string, 0, KEY_ALL_ACCESS, &hkey) != ERROR_SUCCESS) {
      hres = SELFREG_E_CLASS;
    }

    if (hres == S_OK &&
        RegDeleteKey(hkey, _T("InprocServer32")) != ERROR_SUCCESS) {
      hres = SELFREG_E_CLASS;
    }

    if (hkey != NULL)
      CloseHandle(hkey);

    if (hres == S_OK &&
        RegDeleteKey(hkey_clsid, SWIGClassDescription[i].guid_string) != ERROR_SUCCESS) {
      leftovers = 1;
    }

    if (hkey_clsid != NULL)
      CloseHandle(hkey_clsid);

    hkey = NULL;

    if (hres == S_OK &&
        RegOpenKeyEx(HKEY_CLASSES_ROOT, SWIGClassDescription[i].oleaut_string, 0, KEY_ALL_ACCESS, &hkey) != ERROR_SUCCESS) {
      hres = SELFREG_E_CLASS;
    }

    if (hres == S_OK &&
        RegDeleteKey(hkey, _T("CLSID")) != ERROR_SUCCESS) {
      hres = SELFREG_E_CLASS;
    }

    if (hkey != NULL)
      CloseHandle(hkey);

    if (hres == S_OK &&
        RegDeleteKey(HKEY_CLASSES_ROOT, SWIGClassDescription[i].oleaut_string) != ERROR_SUCCESS) {
      leftovers = 1;
    }
  }

  {
    HKEY hkey_typelib = NULL,
        hkey = NULL,
        hkey_version = NULL,
        hkey_lcid = NULL;

    if (hres == S_OK &&
        RegOpenKeyEx(HKEY_CLASSES_ROOT, _T("TypeLib"), 0, KEY_ALL_ACCESS, &hkey_typelib) != ERROR_SUCCESS) {
      hres = SELFREG_E_TYPELIB;
    }

    if (hres == S_OK &&
        RegOpenKeyEx(hkey_typelib, SWIG_tlb_guid_string, 0, KEY_ALL_ACCESS, &hkey) != ERROR_SUCCESS) {
      hres = SELFREG_E_TYPELIB;
    }

    if (hres == S_OK &&
        RegOpenKeyEx(hkey, /* FIXME */ _T("1.0"), 0, KEY_ALL_ACCESS, &hkey_version) != ERROR_SUCCESS) {
      hres = SELFREG_E_TYPELIB;
    }

    if (hres == S_OK &&
        RegDeleteKey(hkey_version, _T("HELPDIR")) != ERROR_SUCCESS) {
      hres = SELFREG_E_TYPELIB;
    }

    if (hres == S_OK &&
        RegDeleteKey(hkey_version, _T("FLAGS")) != ERROR_SUCCESS) {
      hres = SELFREG_E_TYPELIB;
    }

    if (hres == S_OK &&
        RegOpenKeyEx(hkey_version, _T("0"), 0, KEY_ALL_ACCESS, &hkey_lcid) != ERROR_SUCCESS) {
      hres = SELFREG_E_TYPELIB;
    }

    if (hres == S_OK &&
        RegDeleteKey(hkey_lcid, _T("win32")) != ERROR_SUCCESS) {
      hres = SELFREG_E_TYPELIB;
    }

    if (hkey_lcid != NULL)
      CloseHandle(hkey_lcid);

    if (hres == S_OK &&
        RegDeleteKey(hkey_version, _T("0")) != ERROR_SUCCESS) {
      hres = SELFREG_E_TYPELIB;
    }

    if (hkey_version != NULL)
      CloseHandle(hkey_version);

    if (hres == S_OK &&
        RegDeleteKey(hkey, _T("1.0")) != ERROR_SUCCESS) {
      hres = SELFREG_E_TYPELIB;
    }

    if (hkey != NULL)
      CloseHandle(hkey);

    if (hres == S_OK &&
        RegDeleteKey(hkey_typelib, SWIG_tlb_guid_string) != ERROR_SUCCESS) {
      leftovers = 1;
    }

    if (hkey_typelib != NULL)
      CloseHandle(hkey_typelib);
  }

  if (hres == S_OK && leftovers) {
    /* Procedure successful, but some leftover keys present */
    return S_FALSE;
  }

  return hres;
}

#ifdef __cplusplus
extern "C"
#endif
BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD fdwReason,
    LPVOID lpvReserved) {
  if (fdwReason == DLL_PROCESS_ATTACH) {
    SWIGModule = hinstDLL;

    HRESULT hres = S_OK;

#ifdef __WINE__
    /*
     * Wine has a broken implementation of GetModuleFileName, which does not
     * work correctly with Winelib DLLs. Here we try to get the module file
     * name from the registry.
     */
    {
      HKEY hkey_typelib = NULL,
          hkey = NULL,
          hkey_version = NULL,
          hkey_lcid = NULL;
      LONG bytesRead = MAX_PATH + 1;

      if (hres == S_OK &&
          RegOpenKeyEx(HKEY_CLASSES_ROOT, _T("TypeLib"), 0, KEY_ALL_ACCESS, &hkey_typelib) != ERROR_SUCCESS) {
        hres = E_UNEXPECTED;
      }

      if (hres == S_OK &&
          RegOpenKeyEx(hkey_typelib, SWIG_tlb_guid_string, 0, KEY_ALL_ACCESS, &hkey) != ERROR_SUCCESS) {
        hres = E_UNEXPECTED;
      }

      if (hres == S_OK &&
          RegOpenKeyEx(hkey, /* FIXME */ _T("1.0"), 0, KEY_ALL_ACCESS, &hkey_version) != ERROR_SUCCESS) {
        hres = E_UNEXPECTED;
      }

      if (hres == S_OK &&
          RegOpenKeyEx(hkey_version, _T("0"), 0, KEY_ALL_ACCESS, &hkey_lcid) != ERROR_SUCCESS) {
        hres = E_UNEXPECTED;
      }

      if (hres == S_OK &&
          /* NOTE: we explicitly need to use the wide-char version here */
          RegQueryValueW(hkey_lcid, L"win32", SWIG_typelib_path, &bytesRead) != ERROR_SUCCESS) {
        hres = E_UNEXPECTED;
      }

      if (hkey_typelib != NULL)
        CloseHandle(hkey_typelib);
      if (hkey != NULL)
        CloseHandle(hkey);
      if (hkey_version != NULL)
        CloseHandle(hkey_version);
      if (hkey_lcid != NULL)
        CloseHandle(hkey_lcid);
    }
#else
    hres = GetModuleFileNameW(SWIGModule, SWIG_typelib_path, MAX_PATH + 1);
#endif

    if (hres == S_OK) {
      LoadTypeLib(SWIG_typelib_path, &SWIG_typelib);
    }
  } else if (fdwReason == DLL_PROCESS_DETACH) {
    if (SWIG_typelib != NULL) {
      /* Call release on the typelib */
      SWIGIUnknown *tlb_unknown = (SWIGIUnknown *) SWIG_typelib;
      ((long (SWIGSTDCALL *)(SWIGIUnknown *)) (tlb_unknown->vtable[2]))(tlb_unknown);
    }
  }

  return TRUE;
}

%}

