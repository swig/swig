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
%typemap(ctype) SWIGTYPE * "/* ctype */ _SWIGCOMIUnknown *"

%typemap(comtype) void "void"
%typemap(comtype) int, const int & "/* comtype */ int"
%typemap(comtype) double, const double & "/* comtype */ double"
%typemap(comtype) long, const long & "/* comtype */ long"
%typemap(comtype) SWIGTYPE * "/* comtype */ $comclassname *"

%typemap(in) int, double, long %{ /* in */ $1 = ($1_ltype)$input; %}

%typemap(in) SWIGTYPE * %{
  {
    _SWIGCOMIUnknown *wrapper;

    /* Call to QueryInterface */
    HRESULT hr = ((HRESULT (*)(_SWIGCOMIUnknown *, REFIID, void **))
        $input->vtable[0])($input, IID_ISWIGCOMWrappedObject, (void **) &wrapper); 

    if (hr != S_OK) {
      /* Argument was not wrapped by SWIG - directors will be needed */
    } else {
      /* GetCPtr */
      $1 = ($1_ltype) ((void * (*)(_SWIGCOMIUnknown *)) (wrapper->vtable[3]))(wrapper);

      /* Release */
      ((long (*)(_SWIGCOMIUnknown *)) (wrapper->vtable[2]))(wrapper);
    }
  }
%}

%typemap(out) int, double, long %{ /* out */ $result = $1; %}
%typemap(out) void ""
%typemap(out) SWIGTYPE * %{
  $result = (_SWIGCOMIUnknown *) _SWIGCOM_wrap_$*comclassname((void *) $1);
%}

%typemap(combody) SWIGTYPE * %{
%}

%typemap(combody) SWIGTYPE %{
%}

%insert("runtime") %{

#include <windows.h>

typedef void (*_SWIG_funcptr)(void);

struct _SWIGCOMWrappedObject {
  _SWIG_funcptr *vtable; /* vtable for the methods of the wrapped object */
  _SWIG_funcptr *SWIGCOMWrappedObject_vtable; /* vtable for helper methods */
  void *cPtr; /* pointer to the wrapped object */
  int cMemOwn; /* memory owned by the proxy? */
  long refCount; /* reference count */
};

GUID IID_ISWIGCOMWrappedObject = { 0x73738294, 0x8833, 0x1182, { 0x01, 0x12, 0x23, 0x34, 0x45, 0x56, 0x67, 0x78 }};

long _SWIGCOMAddRef1(void *iunk) {
  /* FIXME: use InterlockedIncrement */
  _SWIGCOMWrappedObject *obj = (_SWIGCOMWrappedObject *) iunk;

  return ++obj->refCount;
}

long _SWIGCOMAddRef2(void *iunk) {
  return _SWIGCOMAddRef1((void **)iunk - 1);
}

long _SWIGCOMRelease1(void *iunk) {
  /* FIXME: use InterlockedDecrement */
  _SWIGCOMWrappedObject *obj = (_SWIGCOMWrappedObject *) iunk;

  return --obj->refCount;
}

long _SWIGCOMRelease2(void *iunk) {
  return _SWIGCOMRelease1((void **)iunk - 1);
}

void *_SWIGCOMGetCPtr(void *iunk) {
  _SWIGCOMWrappedObject *obj = (_SWIGCOMWrappedObject *) ((void **)iunk - 1);

  return obj->cPtr;
}

#if 0
_SWIG_funcptr _SWIGCOMWrappedObject_vtable[] = {
  0, /* QueryInterface */
  (_SWIG_funcptr) _SWIGCOMAddRef2,
  (_SWIG_funcptr) _SWIGCOMRelease2,
  (_SWIG_funcptr) _SWIGCOMGetCPtr
};
#endif

struct _SWIGCOMClassFactory {
  _SWIG_funcptr *vtable;
  _SWIG_funcptr newInstance;
  long refCount;
};

/* For consistent manipulation regardless of C or C++ mode */
struct _SWIGCOMIUnknown {
  _SWIG_funcptr *vtable;
};

long _SWIGCOMClassFactoryAddRef(_SWIGCOMClassFactory *factory) {
  return ++factory->refCount;
}

long _SWIGCOMClassFactoryRelease(_SWIGCOMClassFactory *factory) {
  return --factory->refCount;
}

HRESULT _SWIGCOMClassFactoryQueryInterface(_SWIGCOMClassFactory *factory, REFIID iid, void **ppvObject) {
  if (iid == IID_IUnknown || iid == IID_IClassFactory) {
    _SWIGCOMClassFactoryAddRef(factory);
    *ppvObject = factory;

    return S_OK;
  } else {
    return E_NOINTERFACE;
  }
}

HRESULT _SWIGCOMClassFactoryCreateInstance(_SWIGCOMClassFactory *factory, IUnknown *punkOuter, REFIID riid, void **ppvObject)
{
  HRESULT hr;
  _SWIGCOMIUnknown *obj;

  if (ppvObject == NULL)
     return E_INVALIDARG;

  if (punkOuter)
     return CLASS_E_NOAGGREGATION;

  /* Create the instance */
  obj = (_SWIGCOMIUnknown *) ((void* (*)()) factory->newInstance)();

  if (obj == NULL) {
    return E_OUTOFMEMORY;
  }

  /* Add reference */
  ((long (*)(_SWIGCOMIUnknown *)) (obj->vtable[1]))(obj);

  hr = ((HRESULT (*)(_SWIGCOMIUnknown *, REFIID, void **)) obj->vtable[0])(obj, riid, ppvObject);

  /* Release reference */
  ((long (*)(_SWIGCOMIUnknown *)) (obj->vtable[2]))(obj);

  return hr;
}

HRESULT _SWIGCOMClassFactoryLockServer(_SWIGCOMClassFactory *factory, BOOL fLock) {
  CoLockObjectExternal((IUnknown *) (void *) factory, fLock, TRUE);

  return S_OK;
}

_SWIG_funcptr _SWIGCOMClassFactory_vtable[] = {
  (_SWIG_funcptr) _SWIGCOMClassFactoryQueryInterface,
  (_SWIG_funcptr) _SWIGCOMClassFactoryAddRef,
  (_SWIG_funcptr) _SWIGCOMClassFactoryRelease,
  (_SWIG_funcptr) _SWIGCOMClassFactoryCreateInstance,
  (_SWIG_funcptr) _SWIGCOMClassFactoryLockServer
};

typedef struct {
  _SWIG_funcptr newInstance;
  GUID guid;
} _SWIGCOMClassDescription_t;

%}

%insert("factory") %{

STDAPI DllGetClassObject(REFCLSID rclsid, REFIID riid, LPVOID *_ppv) {
  int i;
  _SWIGCOMClassFactory **ppv = (_SWIGCOMClassFactory **)(void *) _ppv;

  if (riid != IID_IUnknown && riid != IID_IClassFactory)
    return E_NOINTERFACE;

  for (i = 0; _SWIGCOMClassDescription[i].newInstance != NULL; ++i) {
    if (rclsid == _SWIGCOMClassDescription[i].guid) {
      /* Create a new class factory for the requested CLSID */
      *ppv = new _SWIGCOMClassFactory;
      (*ppv)->vtable = _SWIGCOMClassFactory_vtable;
      (*ppv)->newInstance = _SWIGCOMClassDescription[i].newInstance;
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

