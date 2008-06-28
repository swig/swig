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

typedef void (SWIGSTDCALL *SWIG_funcptr)(void);

struct SWIGWrappedObject {
  SWIG_funcptr *vtable; /* vtable for the methods of the wrapped object */
  SWIG_funcptr *SWIGWrappedObject_vtable; /* vtable for helper methods */
  void *cPtr; /* pointer to the wrapped object */
  int cMemOwn; /* memory owned by the proxy? */
  long refCount; /* reference count */
};

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

#if 0
SWIG_funcptr SWIGWrappedObject_vtable[] = {
  0, /* QueryInterface */
  (SWIG_funcptr) SWIGAddRef2,
  (SWIG_funcptr) SWIGRelease2,
  (SWIG_funcptr) SWIGGetCPtr
};
#endif

struct SWIGClassFactory {
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
} SWIGClassDescription_t;

%}

%insert("factory") %{

STDAPI DllGetClassObject(REFCLSID rclsid, REFIID riid, LPVOID *_ppv) {
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

STDAPI DllCanUnloadNow() {
  /* FIXME */
  return S_FALSE;
}

%}

