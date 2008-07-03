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

%typemap(comtype) void "void"
%typemap(comtype) int, const int & "/* comtype */ int"
%typemap(comtype) double, const double & "/* comtype */ double"
%typemap(comtype) long, const long & "/* comtype */ long"
%typemap(comtype) SWIGTYPE * "/* comtype */ $comclassname *"

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

%typemap(out) int, double, long %{ /* out */ $result = $1; %}
%typemap(out) void ""
%typemap(out) SWIGTYPE * %{
  $result = (SWIGIUnknown *) SWIG_wrap$*comclassname((void *) $1);
%}

%typemap(combody) SWIGTYPE * %{
%}

%typemap(combody) SWIGTYPE %{
%}

%insert("runtime") %{

#include <windows.h>
#include <olectl.h>

#include <string.h>
#include <memory.h>

typedef void (SWIGSTDCALL *SWIG_funcptr)(void);

struct SWIGWrappedObject {
  SWIG_funcptr *vtable; /* vtable for the methods of the wrapped object */
  SWIG_funcptr *SWIGWrappedObject_vtable; /* vtable for helper methods */
  void *cPtr; /* pointer to the wrapped object */
  int cMemOwn; /* memory owned by the proxy? */
  long refCount; /* reference count */
  ITypeInfo *typeInfo; /* ITypeInfo object for IDispatch */
} SWIGWrappedObject;

GUID IID_ISWIGWrappedObject = { 0x73738294, 0x8833, 0x1182, { 0x01, 0x12, 0x23, 0x34, 0x45, 0x56, 0x67, 0x78 }};

long SWIGSTDCALL SWIGAddRef1(void *iunk) {
  /* FIXME: use InterlockedIncrement */
  SWIGWrappedObject *obj = (SWIGWrappedObject *) iunk;

  return ++obj->refCount;
}

long SWIGSTDCALL SWIGAddRef2(void *iunk) {
  return SWIGAddRef1((void **)iunk - 1);
}

long SWIGSTDCALL SWIGRelease1(void *iunk) {
  /* FIXME: use InterlockedDecrement */
  SWIGWrappedObject *obj = (SWIGWrappedObject *) iunk;

  return --obj->refCount;
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

static OLECHAR *SWIG_typelib_path;
static ITypeLib *SWIG_typelib;

typedef struct {
  SWIG_funcptr *vtable;
  SWIG_funcptr newInstance;
  long refCount;
};

/* For consistent manipulation regardless of C or C++ mode */
struct SWIGIUnknown {
  SWIG_funcptr *vtable;
};

long SWIGSTDCALL SWIGClassFactoryAddRef(SWIGClassFactory *factory) {
  return ++factory->refCount;
}

long SWIGSTDCALL SWIGClassFactoryRelease(SWIGClassFactory *factory) {
  return --factory->refCount;
}

HRESULT SWIGSTDCALL SWIGClassFactoryQueryInterface(SWIGClassFactory *factory, REFIID iid, void **ppvObject) {
  if (iid == IID_IUnknown || iid == IID_IClassFactory) {
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
  obj = (SWIGIUnknown *) ((void* (SWIGSTDCALL *)()) factory->newInstance)();

  if (obj == NULL) {
    return E_OUTOFMEMORY;
  }

  /* Add reference */
  ((long (SWIGSTDCALL *)(SWIGIUnknown *)) (obj->vtable[1]))(obj);

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
  GUID guid;
  char *guid_string;
} SWIGClassDescription_t;

HRESULT SWIGSTDCALL _wrap_opaque_QueryInterface1(void *that, GUID *iid, void ** ppvObject) {
  if (SWIGIsEqual(iid, &IID_ISWIGWrappedObject)) {
    /* FIXME: This could be more elegant */
    SWIGAddRef1(that); 
    *ppvObject = (void *) ((void **)that + 1);
    return S_OK;
  }
  
  if (SWIGIsEqual(iid, &IID_IUnknown)) {
    /* FIXME: This could be more elegant */
    SWIGAddRef1(that);
    *ppvObject = that;
    return S_OK;
  }
  
  return E_NOINTERFACE;
}

HRESULT SWIGSTDCALL _wrap_opaque_QueryInterface2(void *that, GUID *iid, void ** ppvObject) {
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

void * SWIGSTDCALL SWIG_wrap_opaque(void *arg) {
#ifdef __cplusplus
  SWIGWrappedObject *res = new SWIGWrappedObject;
#else
  SWIGWrappedObject *res = (SWIGWrappedObject *) malloc(sizeof(SWIGWrappedObject));
#endif
  res->vtable = _wrap_opaque_vtable;
  res->SWIGWrappedObject_vtable = _wrap_opaque_SWIGWrappedObject_vtable;
  res->cPtr = arg;
  res->cMemOwn = 0;
  res->refCount = 0;
  return (void *) res;
}

%}

%insert("factory") %{

static HMODULE SWIGModule;

STDAPI DllGetClassObject(REFCLSID _rclsid, REFIID _riid, LPVOID *_ppv) {
#ifdef __cplusplus
  const GUID *rclsid = &_rclsid;
  const GUID *riid = &_riid;
#else
  const GUID *rclsid = _rclsid;
  const GUID *riid = _riid;
#endif

  int i;
  SWIGClassFactory **ppv = (SWIGClassFactory **)(void *) _ppv;

  if (riid != IID_IUnknown && riid != IID_IClassFactory)
    return E_NOINTERFACE;

  for (i = 0; SWIGClassDescription[i].newInstance != NULL; ++i) {
    if (rclsid == SWIGClassDescription[i].guid) {
      /* Create a new class factory for the requested CLSID */
      *ppv = new SWIGClassFactory;
      (*ppv)->vtable = SWIGClassFactory_vtable;
      (*ppv)->newInstance = SWIGClassDescription[i].newInstance;
      (*ppv)->refCount = 1;

      return S_OK;
    }
  }

  return CLASS_E_CLASSNOTAVAILABLE;
}

STDAPI DllCanUnloadNow(void) {
  /* FIXME */
  return S_FALSE;
}

STDAPI DllRegisterServer(void) {
  char *module_name;
  int allocated = 256;
  int used;
  int i;

  do {
#ifdef __cplusplus
    module_name = new char[allocated];
    typelib_name = new char[allocated];
#else
    module_name = (char *) malloc(allocated);
    typelib_name = (char *) malloc(allocated);
#endif
    used = GetModuleFileName(SWIGModule /*GetModuleHandle("$module.dll")*/, module_name, allocated);

    if (used == allocated) {
      delete module_name;
      allocated *= 2;
    }
  } while (used == allocated);

  for (i = 0; SWIGClassDescription[i].newInstance != NULL; ++i) {
    HKEY hkey_clsid, hkey, hsubkey;

    if (RegOpenKeyEx(HKEY_CLASSES_ROOT, "CLSID", 0, KEY_ALL_ACCESS, &hkey_clsid) != ERROR_SUCCESS) {
      delete module_name;
      return SELFREG_E_CLASS;
    }

    if (RegCreateKeyEx(hkey_clsid, SWIGClassDescription[i].guid_string, 0, NULL,
        0, KEY_ALL_ACCESS, NULL, &hkey, NULL) != ERROR_SUCCESS) {
      CloseHandle(hkey_clsid);
      delete module_name;
      return SELFREG_E_CLASS;
    }

    if (RegCreateKeyEx(hkey, "InprocServer32", 0, NULL, 0, KEY_ALL_ACCESS, NULL, &hsubkey, NULL) !=
        ERROR_SUCCESS) {
      CloseHandle(hkey_clsid);
      CloseHandle(hkey);
      delete module_name;
      return SELFREG_E_CLASS;
    }

    if (RegSetValueEx(hsubkey, "", NULL, REG_SZ, (BYTE *) module_name, used + 1) != ERROR_SUCCESS) {
      CloseHandle(hkey_clsid);
      CloseHandle(hkey);
      CloseHandle(hsubkey);
      delete module_name;
      return SELFREG_E_CLASS;
    }

    if (RegSetValueEx(hsubkey, "ThreadingModel", NULL, REG_SZ, (BYTE *) "Both", 5) != ERROR_SUCCESS) {
      CloseHandle(hkey_clsid);
      CloseHandle(hkey);
      CloseHandle(hsubkey);
      delete module_name;
      return SELFREG_E_CLASS;
    }

    CloseHandle(hkey_clsid);
    CloseHandle(hkey);
    CloseHandle(hsubkey);
  }

  {
    HKEY hkey_typelib, hkey, hkey_version, hkey_helpdir, hkey_flags, hkey_0, hkey_win32;

    if (RegOpenKeyEx(HKEY_CLASSES_ROOT, "TypeLib", 0, KEY_ALL_ACCESS, &hkey_typelib) != ERROR_SUCCESS) {
      delete module_name;
      return SELFREG_E_CLASS;
    }

    if (RegCreateKeyEx(hkey_typelib, SWIG_tlb_guid_string, 0, NULL,
        0, KEY_ALL_ACCESS, NULL, &hkey, NULL) != ERROR_SUCCESS) {
      CloseHandle(hkey_typelib);
      delete module_name;
      return SELFREG_E_TYPELIB;
    }

    if (RegCreateKeyEx(hkey, /* FIXME */ "1.0", 0, NULL,
        0, KEY_ALL_ACCESS, NULL, &hkey_version, NULL) != ERROR_SUCCESS) {
      CloseHandle(hkey);
      CloseHandle(hkey_typelib);
      delete module_name;
      return SELFREG_E_TYPELIB;
    }

    if (RegCreateKeyEx(hkey_version, "HELPDIR", 0, NULL,
        0, KEY_ALL_ACCESS, NULL, &hkey_helpdir, NULL) != ERROR_SUCCESS) {
      CloseHandle(hkey_version);
      CloseHandle(hkey);
      CloseHandle(hkey_typelib);
      delete module_name;
      return SELFREG_E_TYPELIB;
    }

    if (RegSetValueEx(hkey_helpdir, "", NULL, REG_SZ, (BYTE *) "0", 2) != ERROR_SUCCESS) {
      CloseHandle(hkey_helpdir);
      CloseHandle(hkey_version);
      CloseHandle(hkey);
      CloseHandle(hkey_typelib);
      delete module_name;
      return SELFREG_E_TYPELIB;
    }

    CloseHandle(hkey_helpdir);

    if (RegCreateKeyEx(hkey_version, "FLAGS", 0, NULL,
        0, KEY_ALL_ACCESS, NULL, &hkey_flags, NULL) != ERROR_SUCCESS) {
      CloseHandle(hkey_version);
      CloseHandle(hkey);
      CloseHandle(hkey_typelib);
      delete module_name;
      return SELFREG_E_TYPELIB;
    }

    if (RegSetValueEx(hkey_flags, "", NULL, REG_SZ, (BYTE *) "0", 2) != ERROR_SUCCESS) {
      CloseHandle(hkey_flags);
      CloseHandle(hkey_version);
      CloseHandle(hkey);
      CloseHandle(hkey_typelib);
      delete module_name;
      return SELFREG_E_TYPELIB;
    }

    CloseHandle(hkey_flags);

    if (RegCreateKeyEx(hkey_version, "0", 0, NULL,
        0, KEY_ALL_ACCESS, NULL, &hkey_0, NULL) != ERROR_SUCCESS) {
      CloseHandle(hkey_version);
      CloseHandle(hkey);
      CloseHandle(hkey_typelib);
      delete module_name;
      return SELFREG_E_TYPELIB;
    }

    if (RegCreateKeyEx(hkey_0, "win32", 0, NULL,
        0, KEY_ALL_ACCESS, NULL, &hkey_win32, NULL) != ERROR_SUCCESS) {
      CloseHandle(hkey_0);
      CloseHandle(hkey_version);
      CloseHandle(hkey);
      CloseHandle(hkey_typelib);
      delete module_name;
      return SELFREG_E_TYPELIB;
    }

    if (RegSetValueEx(hkey_win32, "", NULL, REG_SZ, (BYTE *) module_name, used + 1) != ERROR_SUCCESS) {
      CloseHandle(hkey_win32);
      CloseHandle(hkey_0);
      CloseHandle(hkey_version);
      CloseHandle(hkey);
      CloseHandle(hkey_typelib);
      delete module_name;
      return SELFREG_E_TYPELIB;
    }

    CloseHandle(hkey_typelib);
    CloseHandle(hkey);
    CloseHandle(hkey_version);
    CloseHandle(hkey_0);
    CloseHandle(hkey_win32);
  }

  delete module_name;

  return S_OK;
}

STDAPI DllUnregisterServer(void) {
  return S_OK;
}

#ifdef __cplusplus
extern "C"
#endif
BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD fdwReason,
    LPVOID lpvReserved) {
  if (fdwReason == DLL_PROCESS_ATTACH) {
    SWIGModule = hinstDLL;

    /* FIXME: temporary, just for testing. I'll come up with something sensible ;) */
    SWIG_typelib_path = L"c:\\swig\\simple.tlb";
    LoadTypeLib(SWIG_typelib_path, &SWIG_typelib);
  }

  return TRUE;
}

%}

