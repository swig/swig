/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * com.swg
 *
 * COM typemaps
 * ----------------------------------------------------------------------------- */

%typemap(ctype) bool,               const bool &               "unsigned int"
%typemap(ctype) char,               const char &               "char"
%typemap(ctype) signed char,        const signed char &        "signed char"
%typemap(ctype) unsigned char,      const unsigned char &      "unsigned char"
%typemap(ctype) short,              const short &              "short"
%typemap(ctype) unsigned short,     const unsigned short &     "unsigned short"
%typemap(ctype) int,                const int &                "int"
%typemap(ctype) unsigned int,       const unsigned int &       "unsigned int"
%typemap(ctype) long,               const long &               "long"
%typemap(ctype) unsigned long,      const unsigned long &      "unsigned long"
%typemap(ctype) long long,          const long long &          "long long"
%typemap(ctype) unsigned long long, const unsigned long long & "unsigned long long"
%typemap(ctype) float,              const float &              "float"
%typemap(ctype) double,             const double &             "double"
%typemap(ctype) void                                           "void"
%typemap(ctype) SWIGTYPE * "SWIGIUnknown *"
%typemap(ctype) SWIGTYPE "SWIGIUnknown *"
%typemap(ctype) SWIGTYPE & "SWIGIUnknown *"
%typemap(ctype) enum SWIGTYPE "int"

%typemap(comtype) bool,               const bool &               "unsigned int"
%typemap(comtype) char,               const char &               "char"
%typemap(comtype) signed char,        const signed char &        "signed char"
%typemap(comtype) unsigned char,      const unsigned char &      "unsigned char"
%typemap(comtype) short,              const short &              "short"
%typemap(comtype) unsigned short,     const unsigned short &     "unsigned short"
%typemap(comtype) int,                const int &                "int"
%typemap(comtype) unsigned int,       const unsigned int &       "unsigned int"
%typemap(comtype) long,               const long &               "long" /* Probably should be __int3264 */
%typemap(comtype) unsigned long,      const unsigned long &      "unsigned long" /* As above */
%typemap(comtype) long long,          const long long &          "hyper"
%typemap(comtype) unsigned long long, const unsigned long long & "unsigned hyper"
%typemap(comtype) float,              const float &              "float"
%typemap(comtype) double,             const double &             "double"
%typemap(comtype) void                                           "void"
%typemap(comtype) SWIGTYPE * "$comclassname *"
%typemap(comtype) SWIGTYPE "$&comclassname *"
%typemap(comtype) SWIGTYPE & "$comclassname *"
%typemap(comtype) SWIGTYPE *& "$*comclassname *"
%typemap(comtype) enum SWIGTYPE "int"

%typemap(in) bool
%{ $1 = $input ? true : false; %}

%typemap(in) char, 
             signed char, 
             unsigned char, 
             short, 
             unsigned short, 
             int, 
             unsigned int, 
             long, 
             unsigned long, 
             long long, 
             unsigned long long, 
             float, 
             double
%{ $1 = ($1_ltype)$input; %}

%typemap(in) const bool & ($*1_ltype temp)
%{ temp = $input ? true : false; 
   $1 = &temp; %}

%typemap(in) const char & ($*1_ltype temp), 
             const signed char & ($*1_ltype temp), 
             const unsigned char & ($*1_ltype temp), 
             const short & ($*1_ltype temp), 
             const unsigned short & ($*1_ltype temp), 
             const int & ($*1_ltype temp), 
             const unsigned int & ($*1_ltype temp), 
             const long & ($*1_ltype temp), 
             const unsigned long & ($*1_ltype temp), 
             const long long & ($*1_ltype temp), 
             const float & ($*1_ltype temp), 
             const double & ($*1_ltype temp)
%{ temp = ($*1_ltype)$input; 
   $1 = &temp; %}

%typemap(in) void ""

%typemap(in) SWIGTYPE * %{
  {
    SWIGIUnknown *wrapper;

    /* Call to QueryInterface */
    HRESULT hr = ((HRESULT (SWIGSTDCALL *)(SWIGIUnknown *, GUID *, void **))
        $input->vtable[0])($input, &IID_ISWIGWrappedObject, (void **) &wrapper); 

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
    HRESULT hr = ((HRESULT (SWIGSTDCALL *)(SWIGIUnknown *, GUID *, void **))
        $input->vtable[0])($input, &IID_ISWIGWrappedObject, (void **) &wrapper); 

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
    HRESULT hr = ((HRESULT (SWIGSTDCALL *)(SWIGIUnknown *, GUID *, void **))
        $input->vtable[0])($input, &IID_ISWIGWrappedObject, (void **) &wrapper); 

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

%typemap(in) enum SWIGTYPE %{ $1 = ($1_ltype)$input; %}

%typemap(out) bool,
              char, 
              signed char, 
              unsigned char, 
              short, 
              unsigned short, 
              int, 
              unsigned int, 
              long, 
              unsigned long, 
              long long, 
              unsigned long long, 
              float, 
              double
%{ $result = $1; %}

%typemap(out) const bool &, 
              const char &, 
              const signed char &, 
              const unsigned char &, 
              const short &, 
              const unsigned short &, 
              const int &, 
              const unsigned int &, 
              const long &, 
              const unsigned long &, 
              const long long &, 
              const float &, 
              const double &
%{ $result = *$1; %}

%typemap(out) void ""

%typemap(ctype) char *, char[], char[ANY] "WCHAR *"
%typemap(comtype) char *, char[], char[ANY] "BSTR"

%typemap(in) char *, char[], char[ANY] {
  if ($input) {
    int SWIG_len = WideCharToMultiByte(CP_ACP, 0, $input, -1, 0, 0, 0, 0);
    $1 = (char *) malloc(SWIG_len);
    WideCharToMultiByte(CP_ACP, 0, $input, -1, $1, SWIG_len, 0, 0);
  }
}

%typemap(freearg) char *, char[], char[ANY] {
  if ($input) {
    free($1);
  }
}

%typemap(out) char *, char[], char[ANY] %{
  if ($1) {
    int SWIG_len = MultiByteToWideChar(CP_ACP, 0, $1, -1, 0, 0);
    WCHAR *SWIG_res = (WCHAR *) CoTaskMemAlloc((SWIG_len + 2) * sizeof(WCHAR));
    /* First 4 bytes contain length in bytes */
    *((unsigned int *) SWIG_res) = (unsigned int) (SWIG_len - 1) * sizeof(WCHAR);
    MultiByteToWideChar(CP_ACP, 0, $1, -1, SWIG_res + 2, SWIG_len);
    $result = SWIG_res + 2;
  }
%}

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

%typemap(out) enum SWIGTYPE %{ $result = $1; %}

%typemap(throws)  char, 
                  signed char, 
                  unsigned char, 
                  short, 
                  unsigned short, 
                  int, 
                  unsigned int, 
                  long, 
                  unsigned long, 
                  long long, 
                  unsigned long long, 
                  float, 
                  double,
                  SWIGTYPE *,
                  SWIGTYPE &,
                  SWIGTYPE,
                  SWIGTYPE[],
                  SWIGTYPE[ANY]
%{
  return $null;
%}


%insert("runtime") %{

#include <windows.h>
#include <olectl.h>
#include <tchar.h>

#include <string.h>
#include <memory.h>

typedef void (SWIGSTDCALL *SWIG_funcptr)(void);

typedef struct {
  SWIG_funcptr *vtable;
  SWIG_funcptr newInstance;
  LONG refCount;
  int aggregatable;
} SWIGClassFactory;

/* For consistent manipulation regardless of C or C++ mode */
typedef struct {
  SWIG_funcptr *vtable;
} SWIGIUnknown;

typedef struct {
  SWIG_funcptr *vtable; /* vtable for the methods of the wrapped object */
  SWIG_funcptr *SWIGWrappedObject_vtable; /* vtable for helper methods */
  SWIG_funcptr *aggregated_vtable; /* vtable to present to the outer object */
  void *cPtr; /* pointer to the wrapped object */
  int cMemOwn; /* memory owned by the proxy? */
  LONG refCount; /* reference count */
  void (*deleteInstance)(void *); /* destructor */
  ITypeInfo *typeInfo; /* ITypeInfo object for IDispatch */
  SWIGIUnknown *outer; /* outer type in COM aggregation */
} SWIGWrappedObject;

GUID IID_ISWIGWrappedObject = { 0x73738294, 0x8833, 0x1182, { 0x01, 0x12, 0x23, 0x34, 0x45, 0x56, 0x67, 0x78 }};
static LONG globalRefCount = 0;

static int SWIGIsEqual(const GUID *a, const GUID *b) {
  return memcmp(a, b, sizeof(GUID)) == 0;
}

long SWIGSTDCALL SWIGAddRef1(void *iunk) {
  SWIGWrappedObject *obj = (SWIGWrappedObject *) iunk;

  if (obj->outer != NULL) {
    return ((long (SWIGSTDCALL *)(SWIGIUnknown *)) (obj->outer->vtable[1]))(obj->outer);
  } else {
    InterlockedIncrement(&globalRefCount);
    return InterlockedIncrement(&obj->refCount);
  }
}

long SWIGSTDCALL SWIGAddRef2(void *iunk) {
  return SWIGAddRef1((void **)iunk - 1);
}

long SWIGSTDCALL SWIGAddRef3(void *iunk) {
  SWIGWrappedObject *obj = (SWIGWrappedObject *) ((void **)iunk - 2);

  InterlockedIncrement(&globalRefCount);
  return InterlockedIncrement(&obj->refCount);
}

long SWIGSTDCALL SWIGRelease1(void *iunk) {
  SWIGWrappedObject *obj = (SWIGWrappedObject *) iunk;

  if (obj->outer != NULL) {
    return ((long (SWIGSTDCALL *)(SWIGIUnknown *)) (obj->outer->vtable[2]))(obj->outer);
  } else {
    LONG res = InterlockedDecrement(&obj->refCount);

    if (res == 0) {
      if (obj->cMemOwn && obj->deleteInstance != 0) {
        obj->deleteInstance(obj->cPtr);
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
}

long SWIGSTDCALL SWIGRelease2(void *iunk) {
  return SWIGRelease1((void **)iunk - 1);
}

long SWIGSTDCALL SWIGRelease3(void *iunk) {
  SWIGWrappedObject *obj = (SWIGWrappedObject *) ((void **)iunk - 2);

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

HRESULT SWIGSTDCALL SWIGClassFactoryQueryInterface(SWIGClassFactory *factory, GUID *iid, void **ppvObject) {
  if (SWIGIsEqual(iid, &IID_IUnknown) || SWIGIsEqual(iid, &IID_IClassFactory)) {
    SWIGClassFactoryAddRef(factory);
    *ppvObject = factory;

    return S_OK;
  } else {
    return E_NOINTERFACE;
  }
}

HRESULT SWIGSTDCALL SWIGClassFactoryCreateInstance(SWIGClassFactory *factory, SWIGIUnknown *punkOuter, GUID *riid, void **ppvObject)
{
  HRESULT hr;
  SWIGWrappedObject *obj;

  if (ppvObject == NULL)
     return E_INVALIDARG;

  if (punkOuter && (!factory->aggregatable || !SWIGIsEqual(riid, &IID_IUnknown)))
     return CLASS_E_NOAGGREGATION;

  /* Create the instance */
  obj = (SWIGWrappedObject *) ((void* (SWIGSTDCALL *)(void *)) factory->newInstance)(NULL);

  if (obj == NULL) {
    return E_OUTOFMEMORY;
  }

  if (!punkOuter) {
    hr = ((HRESULT (SWIGSTDCALL *)(SWIGIUnknown *, GUID *, void **)) obj->vtable[0])
        ((SWIGIUnknown *) obj, riid, ppvObject);

    /* Release reference */
    ((long (SWIGSTDCALL *)(SWIGIUnknown *)) (obj->vtable[2]))((SWIGIUnknown *) obj);
  } else {
    obj->outer = punkOuter;

    /* We need to return the address of aggregate_vtable */
    *ppvObject = &obj->aggregated_vtable;

    hr = S_OK;
  }

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
  GUID *guid;
  TCHAR *guid_string;
  TCHAR *oleaut_string;
  int aggregatable;
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

STDAPI DllGetClassObject(REFCLSID _rclsid, REFIID _riid, LPVOID *_ppv) {
#if defined(__cplusplus) || defined(CINTERFACE)
  const GUID *rclsid = &_rclsid;
  const GUID *riid = &_riid;
#else
  const GUID *rclsid = _rclsid;
  const GUID *riid = _riid;
#endif

  int i;
  SWIGClassFactory **ppv = (SWIGClassFactory **)(void *) _ppv;

  if (!SWIGIsEqual(riid, &IID_IUnknown) && !SWIGIsEqual(riid, &IID_IClassFactory))
    return E_NOINTERFACE;

  for (i = 0; SWIGClassDescription[i].newInstance != NULL; ++i) {
    if (SWIGIsEqual(rclsid, SWIGClassDescription[i].guid)) {
      /* Create a new class factory for the requested CLSID */
#ifdef __cplusplus
      *ppv = new SWIGClassFactory;
#else
      *ppv = (SWIGClassFactory *) malloc(sizeof(SWIGClassFactory));
#endif
      (*ppv)->vtable = SWIGClassFactory_vtable;
      (*ppv)->newInstance = SWIGClassDescription[i].newInstance;
      (*ppv)->aggregatable = SWIGClassDescription[i].aggregatable;
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
    GetModuleFileNameW(SWIGModule, SWIG_typelib_path, MAX_PATH + 1);
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

