/* ---------------------------------------------------------------------------
 * SWIG Node-API runtime : code
 * ---------------------------------------------------------------------------*/

#define SWIG_NAPI_PACKEDOBJECT 0x8000

SWIGRUNTIME Napi::Error SWIG_NAPI_NewError(Napi::Env env, int type, const char *msg) {
  switch(type) {
    default:
    case SWIG_IOError:
    case SWIG_MemoryError:
    case SWIG_SystemError:
    case SWIG_RuntimeError:
    case SWIG_DivisionByZero:
    case SWIG_SyntaxError:
      return Napi::Error::New(env, msg);
    case SWIG_OverflowError:
    case SWIG_IndexError:
      return Napi::RangeError::New(env, msg);
    case SWIG_ValueError:
    case SWIG_TypeError:
      return Napi::TypeError::New(env, msg);
  }
}

SWIGRUNTIME inline Napi::Error SWIG_NAPI_NewError(Napi::Env env, const char *msg) {
  return SWIG_NAPI_NewError(env, SWIG_RuntimeError, msg);
}

SWIGRUNTIME inline Napi::Error SWIG_NAPI_NewError(Napi::Env env, Napi::Value obj, const char *msg, swig_type_info *info) {
  return Napi::Error(env, obj);
}

#ifdef NAPI_CPP_EXCEPTIONS

SWIGRUNTIME void SWIG_NAPI_Raise(Napi::Env env, const char *msg) {
  SWIG_NAPI_ASSERT_NOTNULL_ENV;
  throw Napi::Error::New(env, msg);
}

SWIGRUNTIME void SWIG_NAPI_Raise(Napi::Env env, int type, const char *msg) {
  SWIG_NAPI_ASSERT_NOTNULL_ENV;
  switch(type) {
    default:
    case SWIG_IOError:
    case SWIG_MemoryError:
    case SWIG_SystemError:
    case SWIG_RuntimeError:
    case SWIG_DivisionByZero:
    case SWIG_SyntaxError:
      throw Napi::Error::New(env, msg);
    case SWIG_OverflowError:
    case SWIG_IndexError:
      throw Napi::RangeError::New(env, msg);
    case SWIG_ValueError:
    case SWIG_TypeError:
      throw Napi::TypeError::New(env, msg);
  }
}

SWIGRUNTIME void SWIG_NAPI_Raise(Napi::Env env, Napi::Value obj,
        const char *msg, swig_type_info *info) {
  SWIG_NAPI_ASSERT_NOTNULL_ENV;
  throw Napi::Error(env, obj);
}

#else // NAPI_CPP_EXCEPTIONS

SWIGRUNTIME inline void SWIG_NAPI_Raise(Napi::Env env, int type, const char *msg) {
  SWIG_NAPI_NewError(env, type, msg).ThrowAsJavaScriptException();
}

SWIGRUNTIME inline void SWIG_NAPI_Raise(Napi::Env env, const char *msg) {
  SWIG_NAPI_Raise(env, SWIG_RuntimeError, msg);
}

SWIGRUNTIME inline void SWIG_NAPI_Raise(Napi::Env env, Napi::Value obj,
        const char *msg, swig_type_info *info) {
  SWIG_NAPI_NewError(env, obj, msg, info).ThrowAsJavaScriptException();
}

#endif // NAPI_CPP_EXCEPTIONS

void JS_veto_set_variable(const Napi::CallbackInfo &info) {
  SWIG_NAPI_Raise(info.Env(), "Tried to write read-only variable.");
}

SWIG_Guard::SWIG_Guard(SWIG_Locks_List &_list) : list(_list), locked(false) {}
SWIG_Guard::~SWIG_Guard() {
  if (locked) {
    for (auto const &lock : list) {
      lock.second.second();
    }
  }
}


void SWIG_NAPI_ObjectWrap_inst::GetMembers(
        Napi::Env env,
        std::map<std::string, SWIG_NAPI_ObjectWrap_templ::PropertyDescriptor> &members,
        std::map<std::string, SWIG_NAPI_ObjectWrap_templ::PropertyDescriptor> &
) {
  members.erase("toString");
  members.insert({"toString", SWIG_NAPI_ObjectWrap_templ::InstanceMethod("toString", &SWIG_NAPI_ObjectWrap_templ::ToString)});
}

Napi::Function SWIG_NAPI_ObjectWrap_inst::GetClass(Napi::Env env) {
  return Napi::ObjectWrap<SWIG_NAPI_ObjectWrap_inst>::DefineClass(env, "SwigObject", {});
}

SWIG_NAPI_ObjectWrap_inst::~SWIG_NAPI_ObjectWrap_inst() {
  if (this->owned) {
    if (this->info) {
      fprintf(stderr, "Warning, SWIG cannot delete an object of type %s, "
                      "it does not have a destructor. This is a memory leak.\n",
                      this->info->name);
    } else {
      fprintf(stderr, "Warning, SWIG must delete an object and does not know "
                      "its type. This is a memory leak\n");
    }
  }
}

Napi::Function SWIG_NAPI_PackedObjectWrap_inst::GetClass(Napi::Env env) {
  return Napi::ObjectWrap<SWIG_NAPI_PackedObjectWrap_inst>::DefineClass(env, "SwigPackedObject", {});
}

SWIG_NAPI_PackedObjectWrap_inst::~SWIG_NAPI_PackedObjectWrap_inst() {
  this->SWIG_Finalize();
  if (this->owned) {
    delete[] static_cast<uint8_t *>(this->self);
    this->self = SWIG_NULLPTR;
    this->owned = false;
  }
}

SWIGRUNTIME bool SWIG_NAPI_IsWrappedObject(Napi::Env env, Napi::Object v) {
  SWIG_NAPI_ASSERT_NOTNULL_ENV;
  // Check if this is a SWIG wrapper
  Napi::FunctionReference *ctor = env.GetInstanceData<EnvInstanceData>()->SWIG_NAPI_ObjectWrapCtor;
  bool instanceOf;
  NAPI_CHECK_RESULT(v.InstanceOf(ctor->Value()), instanceOf);
  return instanceOf;
#ifndef NAPI_CPP_EXCEPTIONS
  goto fail;
fail:
  return false;
#endif
}

SWIGRUNTIME int SWIG_NAPI_ConvertInstancePtr(Napi::Object objRef, void **ptr, swig_type_info *info, int flags) {
  SWIG_NAPI_ObjectWrap_inst *ow;
  Napi::Env env = objRef.Env();
  if(!objRef.IsObject()) return SWIG_ERROR;

  if (!SWIG_NAPI_IsWrappedObject(env, objRef)) {
    return SWIG_TypeError;
  }

  ow = Napi::ObjectWrap<SWIG_NAPI_ObjectWrap_inst>::Unwrap(objRef);

  // Now check if the SWIG type is compatible unless the types match exactly or the type is unknown
  if(info && ow->info != info && ow->info != SWIG_NULLPTR) {
    swig_cast_info *tc = SWIG_TypeCheckStruct(ow->info, info);
    if (!tc && ow->info->name) {
      tc = SWIG_TypeCheck(ow->info->name, info);
    }
    bool type_valid = tc != 0;
    if(!type_valid) {
      return SWIG_TypeError;
    }
    int newmemory = 0;
    *ptr = SWIG_TypeCast(tc, ow->self, &newmemory);
    assert(!newmemory); /* newmemory handling not yet implemented */
  } else {
    *ptr = ow->self;
  }

  if (((flags & SWIG_POINTER_RELEASE) == SWIG_POINTER_RELEASE) && (!ow->owned || ow->finalizer)) {
    return SWIG_ERROR_RELEASE_NOT_OWNED;
  } else {
    if (flags & SWIG_POINTER_DISOWN) {
      ow->owned = false;
    }
    if (flags & SWIG_POINTER_CLEAR) {
      ow->self = SWIG_NULLPTR;
    }
  }
  return SWIG_OK;
#ifndef NAPI_CPP_EXCEPTIONS
  goto fail;
fail:
  return SWIG_ERROR;
#endif
}


SWIGRUNTIME int SWIG_NAPI_GetInstancePtr(Napi::Value valRef, void **ptr) {
  SWIG_NAPI_ObjectWrap_inst *ow;
  if(!valRef.IsObject()) {
    return SWIG_TypeError;
  }
  Napi::Object objRef;
  NAPI_CHECK_RESULT(valRef.ToObject(), objRef);
  ow = Napi::ObjectWrap<SWIG_NAPI_ObjectWrap_inst>::Unwrap(objRef);

  if(ow->self == SWIG_NULLPTR) {
    return SWIG_ERROR;
  }

  *ptr = ow->self;
  return SWIG_OK;
#ifndef NAPI_CPP_EXCEPTIONS
  goto fail;
fail:
  return SWIG_ERROR;
#endif
}


SWIGRUNTIME int SWIG_NAPI_ConvertPtr(Napi::Value valRef, void **ptr, swig_type_info *info, int flags) {
  // special case: JavaScript null => C NULL pointer
  if (valRef.IsNull()) {
    if ((flags & SWIG_POINTER_NO_NULL) == SWIG_POINTER_NO_NULL) {
      return SWIG_NullReferenceError;
    }
    *ptr=0;
    return SWIG_OK;
  }

  if (!valRef.IsObject()) {
    return SWIG_TypeError;
  }

  Napi::Object objRef;
  NAPI_CHECK_RESULT(valRef.ToObject(), objRef);
  return SWIG_NAPI_ConvertInstancePtr(objRef, ptr, info, flags);
#ifndef NAPI_CPP_EXCEPTIONS
  goto fail;
fail:
  return SWIG_ERROR;
#endif
}

SWIGRUNTIME Napi::Value SWIG_NAPI_NewPointerObj(Napi::Env env, void *ptr, swig_type_info *info, int flags) {
  SWIG_NAPI_ASSERT_NOTNULL_ENV;
  Napi::External<void> native;
  Napi::FunctionReference *ctor;

  if (ptr == SWIG_NULLPTR) {
    return env.Null();
  }
  native = Napi::External<void>::New(env, ptr);

  size_t *idx = info != SWIG_NULLPTR ?
        reinterpret_cast<SWIG_NAPI_ClientData *>(info->clientdata) :
        SWIG_NULLPTR;
  if ((flags & SWIG_NAPI_PACKEDOBJECT) == SWIG_NAPI_PACKEDOBJECT) {
    ctor = env.GetInstanceData<EnvInstanceData>()->SWIG_NAPI_PackedObjectWrapCtor;
  } else if (idx == SWIG_NULLPTR) {
    // This type does not have a dedicated wrapper
    ctor = env.GetInstanceData<EnvInstanceData>()->SWIG_NAPI_ObjectWrapCtor;
  } else {
    ctor = env.GetInstanceData<EnvInstanceData>()->ctor[*idx];
  }

  Napi::Value wrapped;
  NAPI_CHECK_RESULT(ctor->New({native}), wrapped);

  // Preserve the type even if using the generic wrapper
  if (idx == SWIG_NULLPTR && info != SWIG_NULLPTR) {
    Napi::Object obj;
    NAPI_CHECK_RESULT(wrapped.ToObject(), obj);
    Napi::ObjectWrap<SWIG_NAPI_ObjectWrap_inst>::Unwrap(obj)->info = info;
  }

  if ((flags & SWIG_POINTER_OWN) == SWIG_POINTER_OWN) {
    Napi::Object obj;
    NAPI_CHECK_RESULT(wrapped.ToObject(), obj);
    Napi::ObjectWrap<SWIG_NAPI_ObjectWrap_inst>::Unwrap(obj)->owned = true;
  }

  return wrapped;
#ifndef NAPI_CPP_EXCEPTIONS
  goto fail;
fail:
  return Napi::Value();
#endif
}

SWIGRUNTIME int SWIG_NAPI_SetFinalizer(Napi::Env env, Napi::Value val, SWIG_NAPI_Finalizer *finalizer) {
  Napi::Object obj;
  SWIG_NAPI_ObjectWrap_inst *unwrapped;
  NAPI_CHECK_RESULT(val.ToObject(), obj);
  if (!SWIG_NAPI_IsWrappedObject(env, obj)) {
    return SWIG_TypeError;
  }
  unwrapped = Napi::ObjectWrap<SWIG_NAPI_ObjectWrap_inst>::Unwrap(obj);
  unwrapped->finalizer = finalizer;
  return SWIG_OK;
#ifndef NAPI_CPP_EXCEPTIONS
  goto fail;
fail:
  return SWIG_ERROR;
#endif
}

SWIGRUNTIME void SWIG_NAPI_SetInstanceData(Napi::Env env, void *module_instance_data) {
  env.GetInstanceData<EnvInstanceData>()->module_instance_data = module_instance_data;
}
SWIGRUNTIME void *SWIG_NAPI_GetInstanceData(Napi::Env env) {
  return env.GetInstanceData<EnvInstanceData>()->module_instance_data;
}

SWIGRUNTIME Napi::Value _SWIG_NAPI_wrap_equals(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
  Napi::Value jsresult;
  void *arg1 = (void *) 0 ;
  void *arg2 = (void *) 0 ;
  bool result;
  int res1;
  int res2;

  if(info.Length() != 1) SWIG_Error(SWIG_ERROR, "Illegal number of arguments for equals.");

  res1 = SWIG_GetInstancePtr(info.This(), &arg1);
  if (!SWIG_IsOK(res1)) {
    SWIG_Error(SWIG_ERROR, "Could not get pointer from 'this' object for equals.");
  }
  res2 = SWIG_GetInstancePtr(info[0], &arg2);
  if (!SWIG_IsOK(res2)) {
    SWIG_Error(SWIG_ArgError(res2), " in method '" "equals" "', argument " "1"" of type '" "void *""'");
  }

  result = (bool)(arg1 == arg2);
  jsresult = Napi::Boolean::New(env, result);

  return jsresult;
#ifndef NAPI_CPP_EXCEPTIONS
  goto fail;
fail:
  return Napi::Value();
#endif
}

/* ---------------------------------------------------------------------------
 * PackedData object
 * (objects visible to JS that do not have a dedicated wrapper but must preserve type)
 * ---------------------------------------------------------------------------*/

SWIGRUNTIME
Napi::Value SWIG_NAPI_NewPackedObj(Napi::Env env, void *data, size_t size, swig_type_info *type) {
  void *data_copy = new uint8_t[size];
  memcpy(data_copy, data, size);
  Napi::Value val = SWIG_NAPI_NewPointerObj(env, data_copy, type, SWIG_POINTER_OWN | SWIG_NAPI_PACKEDOBJECT);
  Napi::Object obj;
  if (val.IsEmpty()) goto fail;

  NAPI_CHECK_RESULT(val.ToObject(), obj);
  Napi::ObjectWrap<SWIG_NAPI_ObjectWrap_inst>::Unwrap(obj)->size = size;

fail:
  return val;
}

SWIGRUNTIME
int SWIG_NAPI_ConvertPacked(Napi::Value valRef, void *ptr, size_t size, swig_type_info *type) {
  void *tmp;
  if (!SWIG_IsOK(SWIG_NAPI_ConvertPtr(valRef, &tmp, type, 0))) {
    return SWIG_ERROR;
  }
  memcpy(ptr, tmp, size);
  return SWIG_OK;
}


/* ---------------------------------------------------------------------------
 * Support for IN/OUTPUT typemaps (see Lib/typemaps/inoutlist.swg)
 *
 * ---------------------------------------------------------------------------*/

SWIGRUNTIME
Napi::Value SWIG_NAPI_AppendOutput(Napi::Env env, Napi::Value result, Napi::Value obj) {
  if (result.IsUndefined()) {
    result = Napi::Array::New(env);
  } else if (!result.IsArray()) {
    Napi::Array tmparr = Napi::Array::New(env);
    tmparr.Set(static_cast<uint32_t>(0), result);
    result = tmparr;
  }

  Napi::Array arr = result.As<Napi::Array>();
  arr.Set(arr.Length(), obj);
  return arr;
}

/* ---------------------------------------------------------------------------
 * Execute the jobs on the queue on the main thread
 * ---------------------------------------------------------------------------*/
#if NAPI_HAS_THREADS
void SWIG_NAPI_RunMainThreadQueue(uv_async_t *async) {
#ifdef SWIGRUNTIME_DEBUG
  printf("Running scheduled tasks on main thread\n");
#endif
  auto env_data = reinterpret_cast<EnvInstanceData *>(async->data);

  // As the lambdas are very light, it is better to not release the lock at all
  std::lock_guard<std::mutex> lock(env_data->js_main_thread.lock);
  while (!env_data->js_main_thread.jobs.empty()) {
    env_data->js_main_thread.jobs.front()();
    env_data->js_main_thread.jobs.pop();
  }
  // Disable the async because the queue is empty
  // (we do not want to block Node from exiting)
#ifndef __EMSCRIPTEN__
  uv_unref(reinterpret_cast<uv_handle_t *>(env_data->js_main_thread.handle));
#endif
}
#endif


/* ---------------------------------------------------------------------------
 * Schedule a job to run on the main thread
 * ---------------------------------------------------------------------------*/
void SWIG_NAPI_RunOnJSMainThread(EnvInstanceData *env_data, std::function<void()> &&job) {
#if NAPI_HAS_THREADS
  if (env_data->js_main_thread.main_thread_id == std::this_thread::get_id()) {
#ifdef SWIGRUNTIME_DEBUG
    printf("Running scheduled task synchronously on the main thread\n");
#endif
    job();
  } else {
#ifdef SWIGRUNTIME_DEBUG
    printf("Scheduling a task on the main thread\n");
#endif
    std::lock_guard<std::mutex> lock(env_data->js_main_thread.lock);
    env_data->js_main_thread.jobs.emplace(std::move(job));
    assert(uv_async_send(env_data->js_main_thread.handle) == 0);
#ifndef __EMSCRIPTEN__
    uv_ref(reinterpret_cast<uv_handle_t *>(env_data->js_main_thread.handle));
#endif
  }
#else
#ifdef SWIGRUNTIME_DEBUG
  printf("Running a task on the main thread w/o thread support\n");
#endif
  job();
#endif
}
