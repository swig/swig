/* -----------------------------------------------------------------------------
 * js_ctor:  template for wrapping a ctor.
 *   - $jswrapper:        wrapper of called ctor
 *   - $jslocals:         locals part of wrapper
 *   - $jscode:           code part of wrapper
 *   - $jsargcount:       number of arguments
 *   - $jsargrequired:    required number of arguments
 *   - $jsmangledtype:    mangled type of class
 * ----------------------------------------------------------------------------- */
%fragment ("js_ctor", "templates")
%{
static JSValue $jswrapper(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst argv[])
{
    $jslocals
    if (argc < $jsargrequired || argc > $jsargcount) SWIG_exception_fail(SWIG_ERROR, "Illegal number of arguments for $jswrapper.");

    $jscode
    return SWIG_QuickJS_NewPointerObj(ctx, result, SWIGTYPE_$jsmangledtype, SWIG_POINTER_OWN);
    goto fail;
    fail:
    return JS_EXCEPTION;
}
%}

/* -----------------------------------------------------------------------------
 * js_veto_ctor:  a vetoing ctor for abstract classes
 *   - $jswrapper:        name of wrapper
 *   - $jsname:           class name
 * ----------------------------------------------------------------------------- */
%fragment ("js_veto_ctor", "templates")
%{
static JSValue $jswrapper(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst argv[])
{
    SWIG_exception(SWIG_ERROR, "Class $jsname can not be instantiated");
fail:
    return JS_EXCEPTION;
}
%}

/* -----------------------------------------------------------------------------
 * js_ctor_dispatcher:  dispatcher for overloaded constructors
 *   - $jswrapper:        name of wrapper
 *   - $$jsmangledname:   class name
 *   - $jsdispatchcases:  part containing code for dispatching
 * ----------------------------------------------------------------------------- */
%fragment ("js_ctor_dispatcher", "templates")
%{
static JSValue $jswrapper(JSContext *ctx, JSValueConst ctorObject,
    int argc, JSValueConst argv[])
{
    JSValueConst this_val = JS_EXCEPTION;

    // switch all cases by means of series of if-returns.
    $jsdispatchcases

    // default:
    SWIG_exception_fail(SWIG_ERROR, "Illegal arguments for construction of $jsmangledname");

    fail:
    return this_val;
}
%}

/* -----------------------------------------------------------------------------
 * js_overloaded_ctor:  template for wrapping a ctor.
 *   - $jswrapper:        wrapper of called ctor
 *   - $jslocals:         locals part of wrapper
 *   - $jscode:           code part of wrapper
 *   - $jsargcount:       number of arguments
 *   - $jsargrequired:    required number of arguments
 *   - $jsmangledtype:    mangled type of class
 * ----------------------------------------------------------------------------- */
%fragment ("js_overloaded_ctor", "templates")
%{
static JSValue $jswrapper(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst argv[])
{
    $jslocals
    $jscode
    return SWIG_QuickJS_NewPointerObj(ctx, result, SWIGTYPE_$jsmangledtype, SWIG_POINTER_OWN);

    goto fail;
    fail:
    return JS_EXCEPTION;
}
%}

/* -----------------------------------------------------------------------------
 * js_ctor_dispatch_case:  template for a dispatch case for calling an overloaded ctor.
 *   - $jsargcount:       number of arguments of called ctor
 *   - $jsargrequired:    required number of arguments
 *   - $jswrapper:        wrapper of called ctor
 *
 *  Note: a try-catch-like mechanism is used to switch cases
 * ----------------------------------------------------------------------------- */
%fragment ("js_ctor_dispatch_case", "templates")
%{
  if(argc >= $jsargrequired && argc <= $jsargcount) {
    this_val = $jswrapper(ctx, this_val, argc, argv);
    if(!JS_IsException(this_val)) { return this_val; }
  }
%}


/* -----------------------------------------------------------------------------
 * js_dtor:  template for a destructor wrapper
 *   - $jsmangledname:  mangled class name
 *   - $jstype:         class type
 * ----------------------------------------------------------------------------- */
%fragment ("js_dtor", "templates")
%{
static void $jswrapper(JSRuntime *rt, JSValueConst this_val)
{
  SwigObjectData *swig_object = (SwigObjectData *)JS_GetOpaque(this_val, JS_GetClassID(this_val));

#if defined(SWIGRUN_DEBUG) && SWIGRUN_DEBUG>=4
  printf("$jswrapper: %p (%p) (own=%d)\n", swig_object, swig_object->ptr, swig_object->own);  
#endif   
  
  if(swig_object) {
    if (swig_object->own) {
      js_free_rt(rt, ($jstype)swig_object->ptr);
    }
    /* remove the object data to make sure that it isn't accessed elsewhere */
    JS_SetOpaque(this_val, NULL);
    memset(swig_object, 0, sizeof(SwigObjectData));
    js_free_rt(rt, swig_object);
  }
}
%}

/* -----------------------------------------------------------------------------
 * js_dtor:  template for a destructor wrapper
 *   - $jsmangledname:  mangled class name
 *   - $jstype:         class type
 *   - ${destructor_action}: The custom destructor action to invoke.
 * ----------------------------------------------------------------------------- */
%fragment ("js_dtoroverride", "templates")
%{
static void $jswrapper(JSRuntime *rt, JSValueConst this_val)
{
  SwigObjectData *swig_object = (SwigObjectData *)JS_GetOpaque(this_val, JS_GetClassID(this_val));

#if defined(SWIGRUN_DEBUG) && SWIGRUN_DEBUG>=4
  printf("$jswrapper: %p (%p) (own=%d)\n", swig_object, swig_object->ptr, swig_object->own);  
#endif   
  
  if(swig_object) {
    if (swig_object->own) {
      $jstype arg1 = ($jstype)swig_object->ptr;
      ${destructor_action}
    }
    /* remove the object data to make sure that it isn't accessed elsewhere */
    JS_SetOpaque(this_val, NULL);
    memset(swig_object, 0, sizeof(SwigObjectData));
    js_free_rt(rt, swig_object);
  }
}
%}

/* -----------------------------------------------------------------------------
 * js_getter:  template for getter function wrappers
 *   - $jswrapper:  wrapper function name
 *   - $jslocals:   locals part of wrapper
 *   - $jscode:     code part of wrapper
 * ----------------------------------------------------------------------------- */
%fragment ("js_getter", "templates")
%{
static JSValue $jswrapper(JSContext *ctx, JSValueConst this_val)
{
    $jslocals
    JSValue jsresult;

    $jscode
    return jsresult;

    goto fail;
    fail:
    return JS_EXCEPTION;
}
%}

/* -----------------------------------------------------------------------------
 * js_setter:  template for setter function wrappers
 *   - $jswrapper:  wrapper function name
 *   - $jslocals:   locals part of wrapper
 *   - $jscode:     code part of wrapper
 * ----------------------------------------------------------------------------- */
%fragment ("js_setter", "templates")
%{
static JSValueConst $jswrapper(JSContext *ctx, JSValueConst this_val, JSValue value)
{
    $jslocals
    $jscode

    return JS_UNDEFINED;

    goto fail;
    fail:
    return JS_EXCEPTION;
}
%}

/* -----------------------------------------------------------------------------
 * js_function:  template for function wrappers
 *   - $jswrapper:     wrapper function name
 *   - $jslocals:      locals part of wrapper
 *   - $jsargcount:    number of arguments
 *   - $jsargrequired: required number of arguments
 *   - $jscode:        code part of wrapper
 * ----------------------------------------------------------------------------- */
%fragment ("js_function", "templates")
%{
static JSValue $jswrapper(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst argv[])
{
  $jslocals
  JSValue jsresult;

  if (argc < $jsargrequired || argc > $jsargcount) SWIG_exception_fail(SWIG_ERROR, "Illegal number of arguments for $jswrapper.");

  $jscode
  return jsresult;

  goto fail;
  fail:
  return JS_EXCEPTION;
}
%}

/* -----------------------------------------------------------------------------
 * js_function_dispatcher:  template for a function dispatcher for overloaded functions
 *   - $jswrapper:  wrapper function name
 *   - $jsname:     name of the wrapped function
 *   - $jslocals:   locals part of wrapper
 *   - $jscode:     code part of wrapper
 * ----------------------------------------------------------------------------- */
%fragment ("js_function_dispatcher", "templates")
%{
static JSValue $jswrapper(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst argv[])
{
  $jslocals
  JSValue jsresult;
  int res;
  $jscode

  SWIG_exception_fail(SWIG_ERROR, "Illegal arguments for function $jsname.");
  return jsresult;

  goto fail;
  fail:
  return JS_EXCEPTION;
}
%}

/* -----------------------------------------------------------------------------
 * js_overloaded_function:  template for a overloaded function
 *   - $jswrapper:     wrapper function name
 *   - $jslocals:      locals part of wrapper
 *   - $jsargcount:    required number of arguments
 *   - $jsargrequired: required number of arguments
 *   - $jscode:        code part of wrapper
 * ----------------------------------------------------------------------------- */
%fragment ("js_overloaded_function", "templates")
%{
static int $jswrapper(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst argv[], JSValue* p_result)
{
  $jslocals
  JSValue jsresult;

  if (argc < $jsargrequired || argc > $jsargcount) SWIG_exception_fail(SWIG_ERROR, "Illegal number of arguments for $jswrapper.");

  $jscode
  *p_result = jsresult;
  return SWIG_OK;

  goto fail;
  fail:
  return SWIG_ERROR;
}
%}

/* -----------------------------------------------------------------------------
 * js_function_dispatch_case:  template for a case used in the function dispatcher
 *   - $jswrapper:     wrapper function name
 *   - $jsargcount:    number of arguments of overloaded function
 *   - $jsargrequired: required number of arguments
 *   - $jscode:        code part of wrapper
 * ----------------------------------------------------------------------------- */
%fragment ("js_function_dispatch_case", "templates")
%{
  if(argc >= $jsargrequired && argc <= $jsargcount) {
     res = $jswrapper(ctx, this_val, argc, argv, &jsresult);
     if(res == SWIG_OK) { return jsresult; }
  }
%}

/* -----------------------------------------------------------------------------
 * js_check_arg:  template for checking if an argument exists
 *   - $jsarg: number of argument
 * ----------------------------------------------------------------------------- */
%fragment ("js_check_arg", "templates")
%{
  if(argc > $jsarg)%}

/* -----------------------------------------------------------------------------
 * quickjs_constant_declaration:  template for a constant table entry
 *   - $jsname:       name of the constant
 *   - $jstype:       type of the constant
 *   - $jsvalue:      value of the constant
 * ----------------------------------------------------------------------------- */
%fragment ("quickjs_constant_declaration", "templates")
%{SWIG_JS_PROP_$jstype_DEF("$jsname", ($jsvalue)),%}

/* -----------------------------------------------------------------------------
 * quickjs_variable_declaration:  template for a variable table entry
 *   - $jsname:       name of the variable
 *   - $jsgetter:     wrapper of getter function
 *   - $jssetter:     wrapper of setter function
 * ----------------------------------------------------------------------------- */
%fragment ("quickjs_variable_declaration", "templates")
%{SWIG_JS_CGETSET_DEF("$jsname", $jsgetter, $jssetter),%}


/* -----------------------------------------------------------------------------
 * quickjs_function_declaration:  template for a function table entry
 *   - $jsname:       name of the variable
 *   - $jswrapper:    wrapper function
 *   - $jsargcount:   number of arguments
 * ----------------------------------------------------------------------------- */
%fragment ("quickjs_function_declaration", "templates")
%{SWIG_JS_CFUNC_DEF("$jsname", $jsargcount, $jswrapper),%}

/* -----------------------------------------------------------------------------
 * quickjs_classtemplate_declaration:  template for a class declaration
 *   - $jsmangledname:      mangled class name
 * ----------------------------------------------------------------------------- */
%fragment ("quickjs_class_declaration", "templates")
%{
static SWIG_QuickJS_ClassDefinition $jsmangledname_class_definition;
%}

/* -----------------------------------------------------------------------------
 * quickjs_class_tables:  template for a namespace declaration
 *   - $jsmangledname:            mangled class name
 *   - $jsstaticclassvariables:   list of static variable entries
 *   - $jsstaticclassfunctions:   list of static function entries
 *   - $jsclassconstants:         list of constant entries
 *   - $jsclassvariables:         list of member variable entries
 *   - $jsclassfunctions:         list of member function entries
 *   - $jsclassbases:             list of classes names the class inherits from
 * ----------------------------------------------------------------------------- */
%fragment ("quickjs_class_tables", "templates")
%{
static SWIG_QuickJS_FunctionListEntry $jsmangledname_class_functions[] = {
  $jsclassfunctions
  $jsstaticclassfunctions
};
static SWIG_QuickJS_VariableListEntry $jsmangledname_class_variables[] = {
  $jsclassvariables
  $jsstaticclassvariables
};
static const SWIG_QuickJS_ConstantListEntry $jsmangledname_class_constants[] = {
  $jsclassconstants
};
static const char *$jsmangledname_class_bases[] = {
  $jsclassbases
};
%}

/* -----------------------------------------------------------------------------
 * quickjs_define_class_template:  template for defining a class template
 *   - $jsmangledname:            mangled class name
 *   - $jsmangledtype:            mangled class type
 *   - $jsctor:                   wrapper of ctor
 *   - $jsclass_inheritance:      base class information
 * ----------------------------------------------------------------------------- */
%fragment ("quickjs_class_definition", "templates")
%{
  $jsmangledname_class_definition.magic = SWIG_PROTOTYPE_CLASS_MAGIC;
  $jsmangledname_class_definition.class_name = "$jsmangledname";
  $jsmangledname_class_definition.dtor = $jsdtor;
  $jsmangledname_class_definition.ctor = $jsctor;
  /* actual base_prototype is computed in 'registerClass' */
  $jsmangledname_class_definition.base_prototype = JS_UNDEFINED;
  /* actual class_id is computed in 'registerClass' */
  $jsmangledname_class_definition.class_id = JS_INVALID_CLASS_ID;
  /* actual prototype is computed in 'registerClass' */
  $jsmangledname_class_definition.prototype = JS_UNDEFINED;  
  $jsmangledname_class_definition.functions = $jsmangledname_class_functions;
  $jsmangledname_class_definition.functions_num = countof($jsmangledname_class_functions);
  $jsmangledname_class_definition.variables = $jsmangledname_class_variables;
  $jsmangledname_class_definition.variables_num = countof($jsmangledname_class_variables);
  $jsmangledname_class_definition.constants = $jsmangledname_class_constants;
  $jsmangledname_class_definition.constants_num = countof($jsmangledname_class_constants);
  $jsmangledname_class_definition.bases = $jsmangledname_class_bases;
  $jsmangledname_class_definition.bases_num = countof($jsmangledname_class_bases);
  
  SWIGTYPE_$jsmangledtype->clientdata = (void*)&$jsmangledname_class_definition;
%}

%fragment ("quickjs_class_inherit", templates)
%{
    if (SWIGTYPE_p$jsbaseclassname != NULL) {
      $jsmangledname_class_definition.base_prototype = $jsbaseclassmangled_class_definition.prototype;
    } else {
      $jsmangledname_class_definition.base_prototype = SWIG_QuickJS_swig_object_class_definition.prototype;      
    }
%}

%fragment ("quickjs_class_noinherit", templates)
%{
    $jsmangledname_class_definition.base_prototype = SWIG_QuickJS_swig_object_class_definition.prototype;
%}


/* -----------------------------------------------------------------------------
 * quickjs_register_class:  template for registration of a class
 *   - $jsname:                   class name
 *   - $jsmangledname:            mangled class name
 *   - $jsnspace:                 mangled name of namespace
 * ----------------------------------------------------------------------------- */
%fragment ("quickjs_class_registration", "templates")
%{
  if(JS_registerClass(ctx, 
      $jsnspace_namespace, 
      "$jsname", 
      &$jsmangledname_class_definition,
      true) < 0) {
    return SWIG_ERROR;
  }
%}


/* -----------------------------------------------------------------------------
 * quickjs_nspace_declaration:  template for a namespace declaration
 *   - $jsnspace:           mangled name of the namespace
 *   - $jsglobalvariables:  list of variable entries
 *   - $jsglobalfunctions:  list of function entries
 *   - $jsglobalconstants:  list of constant entries
 * ----------------------------------------------------------------------------- */
%fragment ("quickjs_nspace_declaration", "templates")
%{

static const SWIG_QuickJS_FunctionListEntry $jsnspace_functions[] = {
  $jsglobalfunctions
};
static const SWIG_QuickJS_VariableListEntry $jsnspace_variables[] = {
  $jsglobalvariables
};
static const SWIG_QuickJS_ConstantListEntry $jsnspace_constants[] = {
  $jsglobalconstants
};

static JSValue $jsmangledname_namespace;
%}

/* -----------------------------------------------------------------------------
 * quickjs_nspace_definition:  template for definition of a namespace object
 *   - $jsmangledname:            mangled name of namespace
 * ----------------------------------------------------------------------------- */
%fragment ("quickjs_nspace_definition", "templates")
%{
  JS_initializeNamespace(ctx, 
    "$jsmangledname",
    &($jsmangledname_namespace), 
    $jsmangledname_functions, countof($jsmangledname_functions),
    $jsmangledname_variables, countof($jsmangledname_variables),
    $jsmangledname_constants, countof($jsmangledname_constants));
%}

/* -----------------------------------------------------------------------------
 * quickjs_nspace_registration:  template for registration of a namespace object
 *   - $jsname:                   name of namespace
 *   - $jsmangledname:            mangled name of namespace
 *   - $jsparent:                 mangled name of parent namespace
 * ----------------------------------------------------------------------------- */
%fragment ("quickjs_nspace_registration", "templates")
%{
  JS_SetPropertyStr(ctx, $jsparent_namespace, "$jsname", $jsmangledname_namespace);
%}
