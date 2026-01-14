%insert(wrapper) %{

/*
 * SWIG_QuickJS_createRegistries: initialize the registry objects:
 *   - class registry (needed for multiple inheritance) (table)
 *   - generic registry (used in callbacks) (array)
 * These registries are properties of a global registry "QuickJS"
 * => QuickJS.class_registry, QuickJS.registry
 * Returns -1 in case of exception, 0 if OK.
 */
SWIGINTERN int SWIG_QuickJS_createRegistries(JSContext *ctx)
{
  JSValue registry, class_registry, generic_registry;
  JSValue swig_object_registry, base_registry;
  JSValueConst globalObject;
  JSAtom atom;
  int r;

  globalObject = JS_GetGlobalObject(ctx);
  if (JS_IsException(globalObject)) {
    return -1;
  }

  atom = JS_NewAtom(ctx, "QuickJS");
  if (atom == JS_ATOM_NULL) { return -1; }

  r = JS_HasProperty(ctx, globalObject, atom);
  if (r == -1)  { return -1; }
  if (!r) {
    registry = JS_NewObject(ctx);
    if (JS_IsException(registry)) { return -1; }
    r = JS_DefinePropertyValue(ctx, globalObject, atom, registry, JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
    if (r == -1) { return -1; }
    JS_DupValue(ctx, registry);
  } else {
    registry = JS_GetProperty(ctx, globalObject, atom);
    if (JS_IsException(registry)) { return -1; }
    if (!JS_IsObject(registry)) {
      JS_ThrowTypeError(ctx, "QuickJS registry anomaly (not an object). Please report.\n");
      return -1;
    }
  }
  JS_FreeAtom(ctx, atom);

  atom = JS_NewAtom(ctx, "class_registry");
  if (atom == JS_ATOM_NULL) { return -1; }
  r = JS_HasProperty(ctx, registry, atom);
  if (r == -1)  { return -1; }
  if (!r) {
    class_registry = JS_NewObject(ctx);
    if (JS_IsException(class_registry)) { return -1; }
    r = JS_DefinePropertyValue(ctx, registry, atom, class_registry, JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
    if (r == -1) { return -1; }
  }
  JS_FreeAtom(ctx, atom);

  atom = JS_NewAtom(ctx, "base_registry");
  if (atom == JS_ATOM_NULL) { return -1; }
  r = JS_HasProperty(ctx, registry, atom);
  if (r == -1)  { return -1; }
  if (!r) {
    base_registry = JS_NewObject(ctx);
    if (JS_IsException(base_registry)) { return -1; }
    r = JS_DefinePropertyValue(ctx, registry, atom, base_registry, JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
    if (r == -1) { return -1; }
  }
  JS_FreeAtom(ctx, atom);

  atom = JS_NewAtom(ctx, "registry");
  if (atom == JS_ATOM_NULL) { return -1; }
  r = JS_HasProperty(ctx, registry, atom);
  if (r == -1)  { return -1; }
  if (!r) {
    generic_registry = JS_NewArray(ctx);
    if (JS_IsException(generic_registry)) { return -1; }
    r = JS_DefinePropertyValue(ctx, registry, atom, generic_registry, JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
    if (r == -1) { return -1; }
  }
  JS_FreeAtom(ctx, atom);

  atom = JS_NewAtom(ctx, "swig_object");
  if (atom == JS_ATOM_NULL) { return -1; }
  r = JS_HasProperty(ctx, registry, atom);
  if (r == -1)  { return -1; }
  if (!r) {
    swig_object_registry = JS_NewObject(ctx);
    if (JS_IsException(swig_object_registry)) { return -1; }
    r = JS_DefinePropertyValue(ctx, registry, atom, swig_object_registry, JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
    if (r == -1) { return -1; }
  }
  JS_FreeAtom(ctx, atom);

  JS_FreeValue(ctx, registry);
  JS_FreeValue(ctx, globalObject);

  return 0;
}

/*
 * SWIG_QuickJS_getRegistry: returns the instance of the
 * generic registry QuickJS.registry.
 * The returred value should be freed.
 */
SWIGINTERN JSValueConst SWIG_QuickJS_getRegistry(JSContext *ctx)
{
  JSValueConst global_registry, registry;
  JSValueConst globalObject;
  JSAtom atom;

  globalObject = JS_GetGlobalObject(ctx);
  if (JS_IsException(globalObject)) {
    return globalObject;
  }

  atom = JS_NewAtom(ctx, "QuickJS");
  if (atom == JS_ATOM_NULL) {
    return JS_EXCEPTION;
  }

  global_registry = JS_GetProperty(ctx, globalObject, atom);
  JS_FreeAtom(ctx, atom);
  if (JS_IsException(global_registry)) {
    return global_registry;
  }

  atom = JS_NewAtom(ctx, "registry");
  if (atom == JS_ATOM_NULL) {
    return JS_EXCEPTION;
  }
  registry = JS_GetProperty(ctx, global_registry, atom);
  if (JS_IsException(registry)) {
    return registry;
  }

  JS_FreeAtom(ctx, atom);
  JS_FreeValue(ctx, global_registry);
  JS_FreeValue(ctx, globalObject);

  return registry;
}

/*
 * SWIG_QuickJS_registryAdd: add a value in the generic registry
 * Return -1 in case of exception and an integer reference
 * if OK.
 */
int SWIG_QuickJS_registryAdd(JSContext *ctx, JSValueConst value)
{
  JSValueConst registry;
  uint32_t idx;
  int r;

  registry = SWIG_QuickJS_getRegistry(ctx);
  if (JS_IsException(registry)) { return -1; }

  idx = SWIG_QuickJS_ArrayLength(ctx, registry);
  r = JS_SetPropertyUint32(ctx, registry, idx, JS_DupValue(ctx, value));
  if (r == -1) { return -1; }
  JS_FreeValue(ctx, registry);
  return (int)idx;
}

/*
 * SWIG_QuickJS_registryRemove: remove a value from the generic registry
 * Return -1 in case of exception, 0 otherwise.
 */
int SWIG_QuickJS_registryRemove(JSContext *ctx, int idx)
{
  JSValueConst registry;
  JSValue v;
  JSAtom atom;
  uint32_t len;

  assert(idx >= 0);
  registry = SWIG_QuickJS_getRegistry(ctx);
  if (JS_IsException(registry)) { return -1; }

  len = (uint32_t)SWIG_QuickJS_ArrayLength(ctx, registry);
  if ((uint32_t)idx < len) {
    v = JS_GetPropertyUint32(ctx, registry, (uint32_t)idx);
    if (!(JS_IsException(v) || JS_IsNull(v) || JS_IsUndefined(v))) {
      JS_FreeValue(ctx, v);
    }
    atom = JS_NewAtomUInt32(ctx, idx);
    JS_DeleteProperty(ctx, registry, atom, 0);
    JS_FreeAtom(ctx, atom);
  }
  JS_FreeValue(ctx, registry);
  return 0;
}

/*
 * SWIG_QuickJS_registryGet: get a value from the generic registry
 * Return the value (*) or an exception.
 * (*) The returned value should be freed.
 */
JSValueConst SWIG_QuickJS_registryGet(JSContext *ctx, int idx)
{
  JSValueConst registry;
  uint32_t len;
  JSValueConst jsresult;

  assert(idx >= 0);
  registry = SWIG_QuickJS_getRegistry(ctx);
  if (JS_IsException(registry)) { return registry; }

  len = (uint32_t)SWIG_QuickJS_ArrayLength(ctx, registry);
  if ((uint32_t)idx > len) {
    return JS_ThrowRangeError(ctx, "Invalid index %d for registry", idx);
  }
  jsresult = JS_GetPropertyUint32(ctx, registry, (uint32_t)idx);
  JS_FreeValue(ctx, registry);
  return jsresult;
}

/*
 * SWIG_QuickJS_getSwigObjectRegistry: returns the instance of the
 * SwigObject registry QuickJS.swig_object (stores SwigObject
 * class-id, prototypes, etc...
 * The returred value should be freed.
 */
SWIGINTERN JSValueConst SWIG_QuickJS_getSwigObjectRegistry(JSContext *ctx)
{
  JSValueConst global_registry, registry;
  JSValueConst globalObject;
  JSAtom atom;

  globalObject = JS_GetGlobalObject(ctx);
  if (JS_IsException(globalObject)) {
    return globalObject;
  }

  atom = JS_NewAtom(ctx, "QuickJS");
  if (atom == JS_ATOM_NULL) {
    return JS_EXCEPTION;
  }

  global_registry = JS_GetProperty(ctx, globalObject, atom);
  JS_FreeAtom(ctx, atom);
  if (JS_IsException(global_registry)) {
    return global_registry;
  }

  atom = JS_NewAtom(ctx, "swig_object");
  if (atom == JS_ATOM_NULL) {
    return JS_EXCEPTION;
  }
  registry = JS_GetProperty(ctx, global_registry, atom);
  if (JS_IsException(registry)) {
    return registry;
  }

  JS_FreeAtom(ctx, atom);
  JS_FreeValue(ctx, global_registry);
  JS_FreeValue(ctx, globalObject);

  return registry;
}

/*
 * SWIG_QuickJS_getClassRegistry: returns the instance of the
 * class registry: QuickJS.class_registry.
 * The returned value should be freed.
 */
SWIGINTERN JSValueConst SWIG_QuickJS_getClassRegistry(JSContext *ctx)
{
  JSValueConst registry, class_registry;
  JSValueConst globalObject;
  JSAtom atom;

  globalObject = JS_GetGlobalObject(ctx);
  if (JS_IsException(globalObject)) {
    return globalObject;
  }

  atom = JS_NewAtom(ctx, "QuickJS");
  if (atom == JS_ATOM_NULL) {
    return JS_EXCEPTION;
  }

  registry = JS_GetProperty(ctx, globalObject, atom);
  JS_FreeAtom(ctx, atom);
  if (JS_IsException(registry)) {
    return registry;
  }

  atom = JS_NewAtom(ctx, "class_registry");
  if (atom == JS_ATOM_NULL) {
    return JS_EXCEPTION;
  }
  class_registry = JS_GetProperty(ctx, registry, atom);
  if (JS_IsException(class_registry)) {
    return class_registry;
  }

  JS_FreeAtom(ctx, atom);
  JS_FreeValue(ctx, registry);
  JS_FreeValue(ctx, globalObject);

  return class_registry;
}

/*
 * SWIG_QuickJS_classRegistryLookup: search for a class by name in the registry.
 * Return the class prototype (*) if found, undefined if not found or
 * an exception in case of error.
 * (*) The returned value should be freed.
 */
SWIGINTERN JSValueConst SWIG_QuickJS_classRegistryLookup(JSContext *ctx, const char *class_name)
{
  JSValueConst class_registry;
  JSValueConst proto = JS_UNDEFINED;
  JSAtom atom;
  int r;

  class_registry = SWIG_QuickJS_getClassRegistry(ctx);
  if (JS_IsException(class_registry)) { return JS_EXCEPTION; }

  atom = JS_NewAtom(ctx, class_name);
  if (atom == JS_ATOM_NULL) {
    JS_FreeValue(ctx, class_registry);
    return JS_EXCEPTION;
  }

  r = JS_HasProperty(ctx, class_registry, atom);
  if (r == -1) { return JS_EXCEPTION; }
  if (r) {
    proto = JS_GetProperty(ctx, class_registry, atom);
  }

  JS_FreeAtom(ctx, atom);
  JS_FreeValue(ctx, class_registry);
  return proto;
}

/*
 * SWIG_QuickJS_classRegistryAdd: add a prototype in the class registry
 * Return -1 in case of exception, 0 otherwise.
 */
SWIGINTERN int SWIG_QuickJS_classRegistryAdd(JSContext *ctx, const char *name, JSValueConst proto)
{
  JSValueConst class_registry;
  JSAtom atom;
  int r;

  class_registry = SWIG_QuickJS_getClassRegistry(ctx);
  if (JS_IsException(class_registry)) { return -1; }

  atom = JS_NewAtom(ctx, name);
  if (atom == JS_ATOM_NULL) {
    return -1;
  }
  r = JS_HasProperty(ctx, class_registry, atom);
  if (r == -1) { return -1; }
  if (r) {
    JS_ThrowInternalError(ctx, "class %s already registered", name);
    return -1;
  }
  JS_DupValue(ctx, proto);
  r = JS_DefinePropertyValue(ctx, class_registry, atom, proto, JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
  if (r == -1) { return -1; }
  JS_FreeAtom(ctx, atom);
  JS_FreeValue(ctx, class_registry);
  return 0;
}

/*
 * SWIG_QuickJS_getBaseRegistry: returns the instance of the
 * base registry: QuickJS.base_registry.
 * The returned value should be freed.
 */
SWIGINTERN JSValueConst SWIG_QuickJS_getBaseRegistry(JSContext *ctx)
{
  JSValueConst registry, base_registry;
  JSValueConst globalObject;
  JSAtom atom;

  globalObject = JS_GetGlobalObject(ctx);
  if (JS_IsException(globalObject)) {
    return globalObject;
  }

  atom = JS_NewAtom(ctx, "QuickJS");
  if (atom == JS_ATOM_NULL) {
    return JS_EXCEPTION;
  }

  registry = JS_GetProperty(ctx, globalObject, atom);
  JS_FreeAtom(ctx, atom);
  if (JS_IsException(registry)) {
    return registry;
  }

  atom = JS_NewAtom(ctx, "base_registry");
  if (atom == JS_ATOM_NULL) {
    return JS_EXCEPTION;
  }
  base_registry = JS_GetProperty(ctx, registry, atom);
  if (JS_IsException(base_registry)) {
    return base_registry;
  }

  JS_FreeAtom(ctx, atom);
  JS_FreeValue(ctx, registry);
  JS_FreeValue(ctx, globalObject);

  return base_registry;
}

/*
 * Base registry definition: the objective is to store in an object
 * used as a map all the bases of a given class. The base registry
 * records 1 object per class (name), in which the keys will be
 * the base classes (and the value is the boolean 'true' but only the
 * existence of the key will be checked).
 *
 * SWIG_QuickJS_baseRegistryClassAdd: add a class in
 * the base registry.
 * Return the created object.
 * The returned value should be freed.
 */
SWIGINTERN JSValueConst SWIG_QuickJS_baseRegistryClassAdd(JSContext *ctx, const char *name)
{
  JSValueConst base_registry;
  JSAtom atom;
  JSValue jsresult;
  int r;

  base_registry = SWIG_QuickJS_getBaseRegistry(ctx);
  if (JS_IsException(base_registry)) { return base_registry; }

  atom = JS_NewAtom(ctx, name);
  if (atom == JS_ATOM_NULL) { return JS_EXCEPTION; }
  r = JS_HasProperty(ctx, base_registry, atom);
  if (r == -1) { return JS_EXCEPTION; }
  if (!r) {
    jsresult = JS_NewObject(ctx);
    if (JS_IsException(jsresult)) { return jsresult; }
    r = JS_DefinePropertyValue(ctx, base_registry, atom, JS_DupValue(ctx, jsresult), JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
    if (r == -1) { return JS_EXCEPTION; }
  } else {
    jsresult = JS_ThrowReferenceError(ctx, "class %s already in the base registry", name);
  }
  JS_FreeAtom(ctx, atom);
  JS_FreeValue(ctx, base_registry);
  return jsresult;
}

/*
 * SWIG_QuickJS_baseRegistryClassLookup: find a class in
 * the base registry and returns its base map if found,
 * or JS_UNDEFINED if not found or an exception.
 * The returned value should be freed.
 */
SWIGINTERN JSValueConst SWIG_QuickJS_baseRegistryClassLookup(JSContext *ctx, const char *name)
{
  JSValueConst base_registry;
  JSAtom atom;
  JSValueConst jsresult = JS_UNDEFINED;
  int r;

  base_registry = SWIG_QuickJS_getBaseRegistry(ctx);
  if (JS_IsException(base_registry)) { return base_registry; }

  atom = JS_NewAtom(ctx, name);
  if (atom == JS_ATOM_NULL) { return JS_EXCEPTION; }

  r = JS_HasProperty(ctx, base_registry, atom);
  if (r == -1) { return JS_EXCEPTION; }
  if (r) {
    jsresult = JS_GetProperty(ctx, base_registry, atom);
  }
  JS_FreeAtom(ctx, atom);
  JS_FreeValue(ctx, base_registry);
  return jsresult;
}


/*
 * SWIG_QuickJS_registerProperties: funtion to register properties
 * in 'object': functions, variables and constants.
 * Used by registerClass and registerNamespace.
 * Returns -1 in case of exception, 0 otherwise.
 */
SWIGINTERN int SWIG_QuickJS_registerProperties(JSContext *ctx,
                            const char* name,
                            JSValue object,
                            const SWIG_QuickJS_FunctionListEntry* prototype_functions,
                            int prototype_functions_num,
                            const SWIG_QuickJS_VariableListEntry* prototype_variables,
                            int prototype_variables_num,
                            const SWIG_QuickJS_ConstantListEntry* prototype_constants,
                            int prototype_constants_num)
{
  int i, r;
  JSAtom atom;
  char buf[2];
  const char *fname;


  for (i = 0; i < prototype_functions_num; i++) {
    /* special case: __str__ becomes toString */
    fname = prototype_functions[i].name;
    if ((!strcmp(fname, "__str__")) || (!strcmp(fname, "__tostring"))) {
      fname = "toString";
    }
    r = JS_DefinePropertyValueStr(ctx, object,
                              fname,
                              JS_NewCFunction(ctx,
                                  prototype_functions[i].func,
                                  prototype_functions[i].name,
                                  prototype_functions[i].length),
                              JS_PROP_C_W_E);
    if (r <= 0) {
#if defined(SWIGRUN_DEBUG)
      printf("Error :failed to register function %s in %s\n",
        prototype_functions[i].name, name);
#endif
      return -1;
    }
  }
  for (i = 0; i < prototype_variables_num; i++) {
    atom = JS_NewAtom(ctx, prototype_variables[i].name);
    if (atom == JS_ATOM_NULL) {
        return -1;
    }
    r = JS_DefinePropertyGetSet(ctx, object,
                              atom,
                              JS_NewCFunction2(ctx,
                                  (JSCFunction*)prototype_variables[i].getter,
                                  prototype_variables[i].name,
                                  1, JS_CFUNC_getter, 0),
                              JS_NewCFunction2(ctx,
                                  (JSCFunction*)prototype_variables[i].setter,
                                  prototype_variables[i].name,
                                  2, JS_CFUNC_setter, 2),
                              JS_PROP_C_W_E);
    JS_FreeAtom(ctx, atom);
    if (r <= 0) {
#if defined(SWIGRUN_DEBUG)
      printf("Error :failed to register variable %s in %s\n",
        prototype_variables[i].name, name);
#endif
      return -1;
    }
  }

  for (i = 0; i < prototype_constants_num; i++) {
    atom = JS_NewAtom(ctx, prototype_constants[i].name);
    if (atom == JS_ATOM_NULL) {
        return -1;
    }

    if (prototype_constants[i].tag == SWIG_CONST_TYPE_ENUM) {
      r = JS_DefinePropertyValue(ctx, object, atom,
                            JS_NewInt64(ctx, prototype_constants[i].i64) , JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
    } else if (prototype_constants[i].tag == SWIG_CONST_TYPE_INT64) {
      r = JS_DefinePropertyValue(ctx, object, atom,
                            JS_NewInt64(ctx, prototype_constants[i].i64) , JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
    } else if (prototype_constants[i].tag == SWIG_CONST_TYPE_INT32) {
      r = JS_DefinePropertyValue(ctx, object, atom,
                            JS_NewInt32(ctx, prototype_constants[i].i32) , JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
    } else if (prototype_constants[i].tag == SWIG_CONST_TYPE_UINT32) {
      r = JS_DefinePropertyValue(ctx, object, atom,
                            JS_NewUint32(ctx, (uint32_t)prototype_constants[i].i32) , JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
    } else if (prototype_constants[i].tag == SWIG_CONST_TYPE_STRING) {
      r = JS_DefinePropertyValue(ctx, object, atom,
                            JS_NewString(ctx, prototype_constants[i].str), JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
    } else if (prototype_constants[i].tag == SWIG_CONST_TYPE_UINT64) {
      r = JS_DefinePropertyValue(ctx, object, atom,
                            JS_NewInt64(ctx, prototype_constants[i].i64) , JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
    } else if (prototype_constants[i].tag == SWIG_CONST_TYPE_DOUBLE) {
      r = JS_DefinePropertyValue(ctx, object, atom,
                            __JS_NewFloat64(ctx, prototype_constants[i].f64) , JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
    } else if (prototype_constants[i].tag == SWIG_CONST_TYPE_BOOL) {
      r = JS_DefinePropertyValue(ctx, object, atom,
                            JS_NewBool(ctx, (bool)prototype_constants[i].i32) , JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
    } else if (prototype_constants[i].tag == SWIG_CONST_TYPE_CHAR) {
      buf[0] = (char)prototype_constants[i].i32;
      buf[1] = 0;
      r = JS_DefinePropertyValue(ctx, object, atom,
                            JS_NewString(ctx, buf), JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
    } else if (prototype_constants[i].tag == SWIG_CONST_TYPE_UNDEFINED) {
      r = JS_DefinePropertyValue(ctx, object, atom,
                            JS_UNDEFINED, JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);

    } else {
      JS_ThrowTypeError(ctx, "invalid type %d for constant", prototype_constants[i].tag);
      r = -1;
    }
    JS_FreeAtom(ctx, atom);
    if (r <= 0) {
#if defined(SWIGRUN_DEBUG)
      printf("Error :failed to register constant %s in %s\n",
        prototype_constants[i].name, name);
#endif
      return -1;
    }
  }
  return 0;
}

/* SWIG_QuickJS_basesAdd: helper function in inheritance to fill the base map
 * of a class
 * See base registry above.
 */
SWIGINTERN int SWIG_QuickJS_basesAdd(JSContext *ctx, JSValueConst base_map, const char *base_name)
{
  JSValueConst basebase;
  JSAtom atom;
  JSPropertyEnum *prop_names;
  uint32_t prop_num;
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_BASES)
  JSValue prop_value;
  const char *s;
#endif
  int r;
  int j;

  basebase = SWIG_QuickJS_baseRegistryClassLookup(ctx, base_name);
  if (JS_IsObject(basebase)) {
    /* copy all the base ancestors into the current base map... */
    r = JS_GetOwnPropertyNames(ctx, &prop_names, &prop_num, basebase, JS_GPN_STRING_MASK);
    if (r == -1) { return -1; }
    for (j = 0; j < (int)prop_num; j++) {
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_BASES)
      s = JS_AtomToCString(ctx, prop_names[j].atom);
      printf(" %s", s);
      JS_FreeCString(ctx, s);
      prop_value = JS_GetProperty(ctx, basebase, prop_names[j].atom);
      /* paranoid check */
      assert(JS_IsBool(prop_value) && JS_ToBool(ctx, prop_value));
#endif
      /* only add a ancestor if not already recorded (from another branch
       * in multi-inheritance */
      r = JS_HasProperty(ctx, base_map, prop_names[j].atom);
      if (r == -1) { return -1; }
      if (!r) {
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_BASES)
        printf("+");
#endif
        r = JS_SetProperty(ctx, base_map, prop_names[j].atom, JS_NewBool(ctx, 1));
        if (r == -1) { return -1; }
      }
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_BASES)
      JS_FreeValue(ctx, prop_value);
#endif
    }
    JS_FreePropertyEnum(ctx, prop_names, prop_num);
  }
  JS_FreeValue(ctx, basebase);

  /* ...and add the base itself */
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_BASES)
  printf(" %s", base_name);
#endif
  atom = JS_NewAtom(ctx, base_name);
  if ((atom != JS_ATOM_NULL) && (!JS_HasProperty(ctx, base_map, atom))) {
    r = JS_SetProperty(ctx, base_map, atom, JS_NewBool(ctx, 1));
    if (r == -1) { return -1; }
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_BASES)
    printf("+");
#endif
  }
  JS_FreeAtom(ctx, atom);
  return 0;
}


/* SWIG_QuickJS_getBasePrototype1: helper function in inheritance to fill the combined
 * prototype with the properties of the base class parents
 * See SWIG_QuickJS_getBasePrototype.
 */
SWIGINTERN int SWIG_QuickJS_getBasePrototype1(JSContext *ctx, JSValue proto, JSValueConst base)
{
  JSPropertyEnum *prop_names;
  uint32_t prop_num;
  JSPropertyDescriptor prop;
  JSValueConst next;
  int j, r;
  /*--const char *s;--*/

  while (!JS_StrictEq(ctx, base, SWIG_QuickJS_swig_object_class_definition.prototype)) {
    /* get the own properties of the base */
    r = JS_GetOwnPropertyNames(ctx, &prop_names, &prop_num, base, JS_GPN_STRING_MASK|JS_GPN_ENUM_ONLY);
    if (r < 0) { return -1; }

    for (j = 0; j < (int)prop_num; j++) {
      /* only add properties that are not already present (ie coming from a
       * previous base). */
      r = JS_HasProperty(ctx, proto, prop_names[j].atom);
      if (r == -1) { return -1; }
      if (!r) {
        r = JS_GetOwnProperty(ctx, &prop, base, prop_names[j].atom);
        if (r < 0) { return -1; }
        if (r == 0) { JS_ThrowInternalError(ctx, "property missing"); return -1; }
        if (prop.flags & JS_PROP_GETSET) {
          r = JS_DefinePropertyGetSet(ctx, proto, prop_names[j].atom, prop.getter, prop.setter, JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE|JS_PROP_THROW);
        } else {
          r = JS_DefinePropertyValue(ctx, proto, prop_names[j].atom, prop.value, JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE|JS_PROP_THROW);
        }
        if (r < 0) { return -1; }
      }
    }
    JS_FreePropertyEnum(ctx, prop_names, prop_num);
    next = JS_GetPrototype(ctx, base);
    JS_FreeValue(ctx, base);
    base = next;
  }
  JS_FreeValue(ctx, base); /* free the last prototype value obtained by JS_GetPrototype above */
  return 0;
}


/*
 * SWIG_QuickJS_getBasePrototype: build and register a prototype object aggregating
 * the prototypes of the class whose names are provided as arguments.
 * At the same time, it initializes the base_registry, building a map of
 * all ancestors of the class.
 * The combined prototype is meant to support multiple inheritance.
 * If there is only one base class, the returned value is its prototype (single
 * inheritance).
 */
SWIGINTERN JSValueConst SWIG_QuickJS_getBasePrototype(JSContext *ctx, const char *class_name, const char **bases, int bases_num)
{
  JSValue proto;
  JSValueConst base;
  JSValueConst base_map;
  int i, r;
  char proto_name[SWIG_QUICKJS_CLASS_NAME_MAX];
  int l = 0, remaining_len = SWIG_QUICKJS_CLASS_NAME_MAX-1;

  if (bases_num == 0) {
    return JS_DupValue(ctx, SWIG_QuickJS_swig_object_class_definition.prototype);
  }

  base_map = SWIG_QuickJS_baseRegistryClassAdd(ctx, class_name);
  if (JS_IsException(base_map)) { return base_map; }

#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_BASES)
  printf("Add bases for '%s':", class_name);
  /* the name of each base class will be printed by 'basesAdd' */
#endif
  for ( i = 0; i < bases_num; i++) {
    r = SWIG_QuickJS_basesAdd(ctx, base_map, bases[i]);
    if (r == -1) { return JS_EXCEPTION; }
  }
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_BASES)
  printf("\n");
#endif
  JS_FreeValue(ctx, base_map);

  if (bases_num == 1) {
      return SWIG_QuickJS_classRegistryLookup(ctx, bases[0]);
  }

  /* Build the combine prototype name, in order to check if it exists already
   * in the registry. */
  proto_name[0] = 0;
  for (i = 0; i < bases_num; i++) {
    if (i > 0) {
      strncat(&(proto_name[l]), "_Si_", remaining_len);
      remaining_len -= 4;
      l += 4;
    }
    strncat(&(proto_name[l]), bases[i], remaining_len);
    remaining_len -= strlen(bases[i]);
    l += strlen(bases[i]);
  }
  /*--printf("Combined proto name for %s: %s\n", class_name, proto_name);--*/

  /* check if the prototype already exists in the registry */
  proto = SWIG_QuickJS_classRegistryLookup(ctx, proto_name);
  if (JS_IsException(proto)) { return JS_EXCEPTION; }
  /* found */
  if (JS_IsObject(proto)) { return proto; }

  /* not found... */
  /*--printf("Build base prototype %s: %d\n", class_name, bases_num);--*/
  proto = JS_NewObjectClass(ctx, SWIG_QuickJS_swig_prototype_class_class_definition.class_id);
  if (JS_IsException(proto)) { return JS_EXCEPTION; }
  /* the combined prototype inherits from SwigObject */
  r = JS_SetPrototype(ctx, proto, SWIG_QuickJS_swig_object_class_definition.prototype);
  if (r < 0) { return JS_EXCEPTION; }

  for (i = 0; i < bases_num; i++) {
    base = SWIG_QuickJS_classRegistryLookup(ctx, bases[i]);
    if (JS_IsObject(base)) {
      /* note: base value is freed by this function */
      r = SWIG_QuickJS_getBasePrototype1(ctx, proto, base);
      if (r < 0) { return JS_EXCEPTION; }
    } else {
      /* if a base is invalid or not found, it is ignored */
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_TRACE)
      printf("Warning: base class '%s' for '%s' not found (ignored)\n", bases[i], class_name);
#endif
    }
  }
  /* Register the new prototype in the class registry (as class1+class2... or similar)
    * in case the same multiple inheritance is used again. */
  r = SWIG_QuickJS_classRegistryAdd(ctx, proto_name, proto);
  if (r < 0) { return JS_EXCEPTION; }

  return proto;
}

/*
 * SWIG_QuickJS_registerClass: register a class in a namespace,
 * taking care of creating the class definition,
 * the constructor, the prototype and linking
 * together all of these.
 * If reg=true, the class is registered in the class registry.
 */
SWIGINTERN int SWIG_QuickJS_registerClass(JSContext *ctx,
                            JSValueConst nspace,
                            const char* clsName,
                            SWIG_QuickJS_ClassDefinition* clsDef,
                            bool reg)
{
  JSValue ctor;
  JSClassDef def = {clsDef->class_name, clsDef->dtor, NULL, NULL, NULL};
  int r;

  /* Ensure that the dtor is defined */
  if (clsDef->dtor == NULL) {
    def.finalizer = SwigObject_delete;
  }

  /* Initialize the classID and the class object */
  if (JS_NewClassID(&(clsDef->class_id)) == JS_INVALID_CLASS_ID) { return -1; }
  if (JS_NewClass(JS_GetRuntime(ctx), clsDef->class_id, &def)) { return -1; }

  /* Initialize and set the prototype and constructor */
  clsDef->prototype = JS_NewObjectClass(ctx, SWIG_QuickJS_swig_prototype_class_class_definition.class_id);
  if (JS_IsException(clsDef->prototype)) { return -1; }

  r = SWIG_QuickJS_registerProperties(ctx, clsName, clsDef->prototype,
            clsDef->functions, clsDef->functions_num,
            clsDef->variables, clsDef->variables_num,
            clsDef->constants, clsDef->constants_num);
  if (r < 0) { return r; }
  r = JS_DefinePropertyValueStr(ctx, clsDef->prototype, ".of.",
            JS_NewString(ctx, clsDef->class_name), 0);
  if (r <= 0) { return r; }
  JS_SetOpaque(clsDef->prototype, clsDef);

  /* Set the parent class prototype as prototype of the prototype...
   * Note 1: getBasePrototype will create a specific prototype in case of multiple inheritance.
   * Note 2: base_prototype does not apply to object_class, which is the top of the hierarchy (not
   * excluding would generate a circular ref) */
  if (clsDef != &SWIG_QuickJS_swig_object_class_definition) {
    clsDef->base_prototype = SWIG_QuickJS_getBasePrototype(ctx, clsDef->class_name, clsDef->bases, clsDef->bases_num);
    if (JS_IsException(clsDef->base_prototype)) { return -1; }
    r = JS_SetPrototype(ctx, clsDef->prototype, clsDef->base_prototype);
    if (r <= 0) { return r; }
    JS_FreeValue(ctx, clsDef->base_prototype);
  }

  ctor = JS_NewCFunction2(ctx, clsDef->ctor, clsName, -1, JS_CFUNC_constructor, 0);
  if (JS_IsException(ctor)) { return -1; }
  /* the constructor must include the "static" fields of the class (enums, const static members, methods):
   * set its prototype as the class prototype. */
  r = JS_SetPrototype(ctx, ctor, clsDef->prototype);
  if (r < 0) { return r; }
  JS_SetConstructor(ctx, ctor, clsDef->prototype);
  JS_SetClassProto(ctx, clsDef->class_id, clsDef->prototype);

  /* Register the constructor in its namespace */
  r = JS_SetPropertyStr(ctx, nspace, clsName, ctor);
  if (r == -1) { return -1; }

  if (reg) {
    /* Register the class definition in the class registry */
    r = SWIG_QuickJS_classRegistryAdd(ctx, clsDef->class_name, clsDef->prototype);
    /*r = SWIG_QuickJS_classRegistryAdd(ctx, clsName, clsDef->prototype);*/
    if (r < 0) { return r; }
  }

  return true;
}

/*
 * SWIG_QuickJS_veto_set_variable: helper function 'setter' for constants, throwing
 * an error in case of an attempt to modify the value
 */
SWIGINTERN JSValue SWIG_QuickJS_veto_set_variable(JSContext *ctx, JSValue this_val, JSValue value)
{
    SWIG_exception(SWIG_ERROR, "Tried to write read-only variable.");
fail:
    return JS_EXCEPTION;
}

/* JS_initializeNamespace: create a namespace object, with its
 * global functions, variables and constants.
 * returns -1 in case of exception, 0 otherwise.
 */
SWIGINTERN int SWIG_QuickJS_initializeNamespace(JSContext *ctx,
                            const char *name, JSValue *nspace,
                            const SWIG_QuickJS_FunctionListEntry* namespace_functions,
                            int namespace_functions_num,
                            const SWIG_QuickJS_VariableListEntry* namespace_variables,
                            int namespace_variables_num,
                            const SWIG_QuickJS_ConstantListEntry* namespace_constants,
                            int namespace_constants_num)
{
  if (nspace == NULL) {
    JS_ThrowReferenceError(ctx, "invalid namespace reference for '%s' (null)", name);
    return -1;
  }

  *nspace = JS_NewObject(ctx);
  if (JS_IsException(*nspace)) { return -1; }
  return SWIG_QuickJS_registerProperties(ctx, name, *nspace,
            namespace_functions, namespace_functions_num,
            namespace_variables, namespace_variables_num,
            namespace_constants, namespace_constants_num);
}

%}
