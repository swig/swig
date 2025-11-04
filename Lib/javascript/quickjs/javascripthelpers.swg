%insert(wrapper) %{

/*
 * SWIG_QuickJS_createRegistries: initialize the registry objects:
 *   - class registry (needed for multiple inheritance)
 *   - generic registry (used in callbacks)
 * Theses registries are properties of a global registry "QuickJS"
 * => QuickJS.class_registry, QuickJS.registry 
 */ 
SWIGINTERN int SWIG_QuickJS_createRegistries(JSContext *ctx)
{
  JSValueConst registry, class_registry, generic_registry;
  JSValueConst globalObject;
  JSAtom atom;  
  globalObject = JS_GetGlobalObject(ctx);
  
  atom = JS_NewAtom(ctx, "QuickJS");
  if (atom == JS_ATOM_NULL) { return -1; }
  
  if(!JS_HasProperty(ctx, globalObject, atom)) {
    registry = JS_NewObject(ctx);
    if(JS_IsException(registry)) return -1;
    JS_DefinePropertyValue(ctx, globalObject, atom, registry, JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
    JS_DupValue(ctx, registry);
  } else {
    registry = JS_GetProperty(ctx, globalObject, atom);
    if(JS_IsException(registry)) return -1;
    if(!JS_IsObject(registry)) {
      JS_ThrowTypeError(ctx, "QuickJS registry anomaly (not an object). Please report.\n");
      return -1;
    } 
  }
  JS_FreeAtom(ctx, atom);
  
  atom = JS_NewAtom(ctx, "class_registry");
  if (atom == JS_ATOM_NULL) { return -1; }
  if(!JS_HasProperty(ctx, registry, atom)) {
    class_registry = JS_NewObject(ctx);
    if(JS_IsException(class_registry)) return -1;
    JS_DefinePropertyValue(ctx, registry, atom, class_registry, JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
  }
  JS_FreeAtom(ctx, atom);
  
  atom = JS_NewAtom(ctx, "registry");
  if (atom == JS_ATOM_NULL) { return -1; }
  if(!JS_HasProperty(ctx, registry, atom)) {
    generic_registry = JS_NewObject(ctx);
    if(JS_IsException(generic_registry)) return -1;
    JS_DefinePropertyValue(ctx, registry, atom, generic_registry, JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
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
  
  atom = JS_NewAtom(ctx, "QuickJS");
  if (atom == JS_ATOM_NULL) { 
    return JS_EXCEPTION;
  }
  
  global_registry = JS_GetProperty(ctx, globalObject, atom);
  if(JS_IsException(global_registry)) return JS_EXCEPTION;
  JS_FreeAtom(ctx, atom);
  
  atom = JS_NewAtom(ctx, "registry");
  if (atom == JS_ATOM_NULL) { 
    return JS_EXCEPTION;
  }
  registry = JS_GetProperty(ctx, global_registry, atom);
  if(JS_IsException(registry)) return JS_EXCEPTION;

  JS_FreeAtom(ctx, atom);
  JS_FreeValue(ctx, global_registry);
  JS_FreeValue(ctx, globalObject);
  
  return registry;
}

/*
 * SWIG_QuickJS_getClassRegistry: returns the instance of the
 * class registry: QuickJS.class_registry.
 * The returred value should be freed.
 */
SWIGINTERN JSValueConst SWIG_QuickJS_getClassRegistry(JSContext *ctx)
{
  JSValueConst registry, class_registry;
  JSValueConst globalObject;
  JSAtom atom;

  globalObject = JS_GetGlobalObject(ctx);
  
  atom = JS_NewAtom(ctx, "QuickJS");
  if (atom == JS_ATOM_NULL) { 
    return JS_EXCEPTION;
  }
  
  registry = JS_GetProperty(ctx, globalObject, atom);
  if(JS_IsException(registry)) return JS_EXCEPTION;
  JS_FreeAtom(ctx, atom);
  
  atom = JS_NewAtom(ctx, "class_registry");
  if (atom == JS_ATOM_NULL) { 
    return JS_EXCEPTION;
  }
  class_registry = JS_GetProperty(ctx, registry, atom);
  if(JS_IsException(class_registry)) { return JS_EXCEPTION; }

  JS_FreeAtom(ctx, atom);
  JS_FreeValue(ctx, registry);
  JS_FreeValue(ctx, globalObject);
  
  return class_registry;
}

/*
 * SWIG_QuickJS_classRegistryLookup: search for a class by name in the registry
 */
SWIGINTERN JSValueConst SWIG_QuickJS_classRegistryLookup(JSContext *ctx, const char *class_name)
{
  JSValueConst class_registry;
  JSValueConst proto = JS_UNDEFINED;
  JSAtom atom;

  class_registry = SWIG_QuickJS_getClassRegistry(ctx);
  if(JS_IsException(class_registry)) return JS_EXCEPTION;

  atom = JS_NewAtom(ctx, class_name);
  if (atom == JS_ATOM_NULL) { 
    JS_FreeValue(ctx, class_registry);
    return JS_EXCEPTION;
  }
    
  if(JS_HasProperty(ctx, class_registry, atom)) {
    proto = JS_GetProperty(ctx, class_registry, atom);
  }
  JS_FreeAtom(ctx, atom);
  JS_FreeValue(ctx, class_registry);
  return proto;
}

/*
 * SWIG_QuickJS_classRegistryAdd: add a prototype in the class registry
 */
SWIGINTERN int SWIG_QuickJS_classRegistryAdd(JSContext *ctx, const char *name, JSValueConst proto)
{
  JSValueConst class_registry;
  JSAtom atom;

  class_registry = SWIG_QuickJS_getClassRegistry(ctx);
  if(JS_IsException(class_registry)) { return -1; }
  
  atom = JS_NewAtom(ctx, name);
  if (atom == JS_ATOM_NULL) { 
    return -1;
  }    
  if(JS_HasProperty(ctx, class_registry, atom)) {
    JS_ThrowInternalError(ctx, "class %s already registered", name);
    return -1;
  }
  JS_DupValue(ctx, proto);
  JS_DefinePropertyValue(ctx, class_registry, atom, proto, JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
  JS_FreeAtom(ctx, atom);
  JS_FreeValue(ctx, class_registry);
  return 0;
}

/*
 * JS_registerProperties: funtion to register properties
 * in 'object': functions, variables and constants.
 * Used by registerClass and registerNamespace.
 */
SWIGINTERN int JS_registerProperties(JSContext *ctx, 
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
  
  
  for(i=0; i<prototype_functions_num; i++) {
    /* special case: __str__ becomes toString */
    fname = prototype_functions[i].name;
    if(!strcmp(fname, "__str__")) {
      fname = "toString";
    }
    r = JS_DefinePropertyValueStr(ctx, object,
                              fname, 
                              JS_NewCFunction(ctx, 
                                  prototype_functions[i].func, 
                                  prototype_functions[i].name, 
                                  prototype_functions[i].length),
                              JS_PROP_C_W_E);
    if (r<=0) {
#if defined(SWIGRUN_DEBUG)
      printf("Error :failed to register function %s in %s\n", 
        prototype_functions[i].name, name);
#endif        
      return r;
    }
  }
  for(i=0; i<prototype_variables_num; i++) {
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
    if (r<=0) {
#if defined(SWIGRUN_DEBUG)
      printf("Error :failed to register variable %s in %s\n", 
        prototype_variables[i].name, name);
#endif        
      return r;
    }
  }
  
  for(i=0; i<prototype_constants_num; i++) {
    atom = JS_NewAtom(ctx, prototype_constants[i].name);
    if (atom == JS_ATOM_NULL) { 
        return -1;
    }  
    
    if(prototype_constants[i].tag == SWIG_CONST_TYPE_ENUM) {
      r = JS_DefinePropertyValue(ctx, object, atom, 
                            JS_NewInt64(ctx, prototype_constants[i].i64) , JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
    } else if(prototype_constants[i].tag == SWIG_CONST_TYPE_INT64) {
      r = JS_DefinePropertyValue(ctx, object, atom, 
                            JS_NewInt64(ctx, prototype_constants[i].i64) , JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
    } else if(prototype_constants[i].tag == SWIG_CONST_TYPE_INT32) {
      r = JS_DefinePropertyValue(ctx, object, atom, 
                            JS_NewInt32(ctx, prototype_constants[i].i32) , JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
    } else if(prototype_constants[i].tag == SWIG_CONST_TYPE_UINT32) {
      r = JS_DefinePropertyValue(ctx, object, atom, 
                            JS_NewUint32(ctx, (uint32_t)prototype_constants[i].i32) , JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
    } else if(prototype_constants[i].tag == SWIG_CONST_TYPE_STRING) {
      r = JS_DefinePropertyValue(ctx, object, atom, 
                            JS_NewString(ctx, prototype_constants[i].str), JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
    } else if(prototype_constants[i].tag == SWIG_CONST_TYPE_UINT64) {
      r = JS_DefinePropertyValue(ctx, object, atom, 
                            JS_NewInt64(ctx, prototype_constants[i].i64) , JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
    } else if(prototype_constants[i].tag == SWIG_CONST_TYPE_DOUBLE) {
      r = JS_DefinePropertyValue(ctx, object, atom, 
                            __JS_NewFloat64(ctx, prototype_constants[i].f64) , JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
    } else if(prototype_constants[i].tag == SWIG_CONST_TYPE_BOOL) {
      r = JS_DefinePropertyValue(ctx, object, atom, 
                            JS_NewBool(ctx, (bool)prototype_constants[i].i32) , JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
    } else if(prototype_constants[i].tag == SWIG_CONST_TYPE_CHAR) {
      buf[0] = (char)prototype_constants[i].i32;
      buf[1] = 0;
      r = JS_DefinePropertyValue(ctx, object, atom, 
                            JS_NewString(ctx, buf), JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
    } else if(prototype_constants[i].tag == SWIG_CONST_TYPE_UNDEFINED) {
      r = JS_DefinePropertyValue(ctx, object, atom, 
                            JS_UNDEFINED, JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
      
    } else {
      JS_ThrowTypeError(ctx, "invalid type %d for constant", prototype_constants[i].tag);
      r = -1;
    }
    JS_FreeAtom(ctx, atom);
    if (r<=0) {
#if defined(SWIGRUN_DEBUG)
      printf("Error :failed to register constant %s in %s\n", 
        prototype_constants[i].name, name);
#endif        
      return r;
    }
  }  
  return 1;
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
  const char *s;

  while (!JS_StrictEq(ctx, base, SWIG_QuickJS_swig_object_class_definition.prototype)) {
    /* get the own properties of the base */
    JS_GetOwnPropertyNames(ctx, &prop_names, &prop_num, base, JS_GPN_STRING_MASK|JS_GPN_ENUM_ONLY);

    for(j=0; j<(int)prop_num; j++) {
      s = JS_AtomToCString(ctx, prop_names[j].atom);
      /*--printf("%s", s);--*/
      JS_FreeCString(ctx, s);
      /* only add properties that are not already present (ie coming from a 
       * previous base. */
      if(!JS_HasProperty(ctx, proto, prop_names[j].atom)) {
        /*--printf("+");--*/
        r = JS_GetOwnProperty(ctx, &prop, base, prop_names[j].atom);
        if(r<0) { return -1; }
        if(prop.flags & JS_PROP_GETSET) {
          r = JS_DefinePropertyGetSet(ctx, proto, prop_names[j].atom, prop.getter, prop.setter, JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
        } else {
          r = JS_DefinePropertyValue(ctx, proto, prop_names[j].atom, prop.value, JS_PROP_CONFIGURABLE|JS_PROP_ENUMERABLE);
        }
        if(r<0) { return -1; }
      }
      /*--printf(" ");--*/
    }
    /*--printf("\n");--*/
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
 * This combined prototype is meant to support multiple inheritance.
 * If there is only one base class, the returned value is its prototype (single
 * inheritance).
 */
SWIGINTERN JSValueConst SWIG_QuickJS_getBasePrototype(JSContext *ctx, const char *class_name, const char **bases, int bases_num) 
{
  JSValue proto;
  JSValueConst base;
  int i, r;
  char proto_name[SWIG_QUICKJS_CLASS_NAME_MAX];
  int l = 0, remaining_len = SWIG_QUICKJS_CLASS_NAME_MAX-1;

  if(bases_num == 0) {
    return JS_DupValue(ctx, SWIG_QuickJS_swig_object_class_definition.prototype);
  }
  if(bases_num == 1) {
      return SWIG_QuickJS_classRegistryLookup(ctx, bases[0]);
  }
  
  /* Build the combine prototype name, in order to check if it exists already
   * in the registry. */
  proto_name[0] = 0;
  for(i=0; i<bases_num; i++) {
    if(i>0) {
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
  if(JS_IsException(proto)) { return JS_EXCEPTION; }
  /* found */
  if(JS_IsObject(proto)) { return proto; }
  
  /* not found... */
  /*--printf("Build base prototype %s: %d\n", class_name, bases_num);--*/
  proto = JS_NewObjectClass(ctx, SWIG_QuickJS_swig_prototype_class_class_definition.class_id);
  if(JS_IsException(proto)) { return JS_EXCEPTION; }
  /* the combined prototype inherits from SwigObject */
  JS_SetPrototype(ctx, proto, SWIG_QuickJS_swig_object_class_definition.prototype);
  
  for(i=0; i<bases_num; i++) {
    base = SWIG_QuickJS_classRegistryLookup(ctx, bases[i]);
    if (JS_IsObject(base)) {
      /* note: base value is freed by this function */
      r = SWIG_QuickJS_getBasePrototype1(ctx, proto, base);
      if(r<0) { return JS_EXCEPTION; }
    } else {
      /* if a base is invalid or not found, it is ignored */
      printf("Warning: base class '%s' for '%s' not found (ignored)\n", bases[i], class_name);
    }
  }
  /* Register the new prototype in the class registry (as class1+class2... or similar)
    * in case the same multiple inheritance is used again. */ 
  r = SWIG_QuickJS_classRegistryAdd(ctx, proto_name, proto);
  if(r < 0) { return JS_EXCEPTION; }
  
  return proto;  
}

/*
 * JS_registerClass: register a class in a namespace,
 * taking care of creating the class definition,
 * the constructor, the prototype and linking
 * together all of these.
 * If reg==true, the class is registered in the class registry.
 */
SWIGINTERN int JS_registerClass(JSContext *ctx, 
                            JSValueConst nspace,
                            const char* clsName,
                            SWIG_QuickJS_ClassDefinition* clsDef,
                            bool reg)
{
  JSValue ctor;
  JSClassDef def = {clsDef->class_name, clsDef->dtor, NULL, NULL, NULL};
  int r;
  
  /* Create the classID and the class object */
  clsDef->class_id = 0;
  if(JS_NewClassID(&(clsDef->class_id)) == JS_INVALID_CLASS_ID) { return -1; }
  if(JS_NewClass(JS_GetRuntime(ctx), clsDef->class_id, &def)) { return -1; }
  
  /* Initialize and set the prototype and constructor */
  clsDef->prototype = JS_NewObjectClass(ctx, SWIG_QuickJS_swig_prototype_class_class_definition.class_id);
  if(JS_IsException(clsDef->prototype)) { return -1; }
  
  r = JS_registerProperties(ctx, clsName, clsDef->prototype, 
            clsDef->functions, clsDef->functions_num,
            clsDef->variables, clsDef->variables_num,
            clsDef->constants, clsDef->constants_num);
  if(r <= 0) { return r; }
  r = JS_DefinePropertyValueStr(ctx, clsDef->prototype, ".of.", 
            JS_NewString(ctx, clsDef->class_name), 0);
  if(r <= 0) { return r; }
  JS_SetOpaque(clsDef->prototype, clsDef);

  /* Set the parent class prototype as prototype of the prototype... */
  clsDef->base_prototype = SWIG_QuickJS_getBasePrototype(ctx, clsDef->class_name, clsDef->bases, clsDef->bases_num);
  if(JS_IsException(clsDef->base_prototype)) { return -1; }
  JS_SetPrototype(ctx, clsDef->prototype, clsDef->base_prototype);
  JS_FreeValue(ctx, clsDef->base_prototype);
  
  ctor = JS_NewCFunction2(ctx, clsDef->ctor, clsName, -1, JS_CFUNC_constructor, 0);
  if(JS_IsException(ctor)) { return -1; }
  /* the constructor must include the "static" fields of the class (enums, const static members, methods):
   * set its prototype as the class prototype. */
  JS_SetPrototype(ctx, ctor, clsDef->prototype);
  JS_SetConstructor(ctx, ctor, clsDef->prototype);  
  JS_SetClassProto(ctx, clsDef->class_id, clsDef->prototype);
  
  /* Register the constructor in its namespace */
  JS_SetPropertyStr(ctx, nspace, clsName, ctor);
  
  if(reg) {
    /* Register the class definition in the class registry */
    r = SWIG_QuickJS_classRegistryAdd(ctx, clsDef->class_name, clsDef->prototype);
    if(r < 0) { return r; }
  }
  
  return true;
}

/*
 * JS_veto_set_variable: helper function 'setter' for constants, throwing
 * an error in case of an attempt to modify the value
 */
SWIGINTERN JSValue JS_veto_set_variable(JSContext *ctx, JSValue this_val, JSValue value)
{
    SWIG_exception(SWIG_ERROR, "Tried to write read-only variable.");
fail:    
    return JS_EXCEPTION;
}

/* JS_initializeNamespace: create a namespace object, with its 
 * global functions, variables and constants.
 */
SWIGINTERN int JS_initializeNamespace(JSContext *ctx, 
                            const char *name, JSValue *nspace,
                            const SWIG_QuickJS_FunctionListEntry* namespace_functions,
                            int namespace_functions_num,
                            const SWIG_QuickJS_VariableListEntry* namespace_variables,
                            int namespace_variables_num,
                            const SWIG_QuickJS_ConstantListEntry* namespace_constants,
                            int namespace_constants_num)
{
  if(nspace == NULL) {
    JS_ThrowReferenceError(ctx, "invalid namespace reference for '%s' (null)", name);
    return -1;
  }
  
  *nspace = JS_NewObject(ctx);
  if(JS_IsException(*nspace)) { return -1; }

  return JS_registerProperties(ctx, name, *nspace, 
            namespace_functions, namespace_functions_num,
            namespace_variables, namespace_variables_num,
            namespace_constants, namespace_constants_num);
}

%}
