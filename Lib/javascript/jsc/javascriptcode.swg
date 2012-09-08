/*********************************************************************
  *getproperty: This template gives name to generated wrapper for the getproperty 
  *{LOCALS}: declarations for input arguments
  *{CODE}: contains input marshalling, and the action
*********************************************************************/

%fragment ("JS_getproperty", "templates")
%{
JSValueRef $jsgetter(JSContextRef context, JSObjectRef thisObject, JSStringRef propertyName, JSValueRef* exception)
{
    $jslocals
    JSValueRef jsresult;
    
    $jscode
    return jsresult;

    goto fail;
    fail:
    return NULL;  
}
%}

/**********************************************************************
  *setproperty: This template gives name to generated wrapper for the setproperty 
  *{LOCALS}: declarations for input arguments
  *{CODE}: contains input marshalling, and the action
**********************************************************************/

%fragment ("JS_setproperty", "templates")
%{
bool $jssetter(JSContextRef context, JSObjectRef thisObject, JSStringRef propertyName, JSValueRef value, JSValueRef* exception)
{
    $jslocals
    $jscode
    
    return true;
    
    goto fail;
    fail:
    return false;    
}
%}

/************************************************************************************
  *functionwrapper: This template gives name to generated wrapper for the function 
  *{LOCALS}: declarations for input arguments
  *{CODE} contains input marshalling, and the action
************************************************************************************/
%fragment ("JS_functionwrapper", "templates")
%{
JSValueRef $jswrapper(JSContextRef context, JSObjectRef function, JSObjectRef thisObject, size_t argc, const JSValueRef argv[], JSValueRef* exception)
{
  $jslocals
  JSValueRef jsresult;
  
  $jscode
  return jsresult;
  
  goto fail;
  fail:
  return NULL;  
}
%}

%fragment ("JS_functionwrapper_overload", "templates")
%{
int $jswrapper(JSContextRef context, JSObjectRef function, JSObjectRef thisObject, size_t argc, const JSValueRef argv[], JSValueRef* exception, JSValueRef* result)
{
  $jslocals
  JSValueRef jsresult;
  
  $jscode
  *result = jsresult;
  return SWIG_OK;
  
  goto fail;
  fail:
  return SWIG_TypeError;  
}
%}

/***********************************************************************
 * JS_function_dispatch_case:
 *    This template is used to create a branch for dispatching
 *    to an overloaded function.
 ***********************************************************************/

%fragment ("JS_function_dispatch_case", "templates")
%{if(argc == $jsargcount) {
     res = $jswrapper(context, function, thisObject, argc, argv, exception, &jsresult);
     if(res == SWIG_OK) { *exception = 0; return jsresult; }
  }
%}

%fragment ("JS_function_dispatch_case_default", "templates")
%{
    SWIG_exception_fail(SWIG_ERROR, "Illegal arguments for function $jsname.");
%}

/* Added template for function declaration */

%fragment ("JS_variabledecl", "templates")
%{{"$jsname", $jsgetter, $jssetter, kJSPropertyAttributeNone},%}


/* Added template for function declaration */

%fragment ("JS_functiondecl", "templates")
%{{"$jsname",$jswrapper, kJSPropertyAttributeNone},%}

%fragment ("JS_globaldefn", "templates")
%{
JSStaticValue $jsnspace_values[] = {
  $jsglobalvariables
  { 0, 0, 0, 0 }
};

JSStaticFunction $jsnspace_functions[] = {
  $jsglobalfunctions
  { 0, 0, 0 }
};

JSClassDefinition $jsnspace_classDefinition;
%}

/***********************************************************************
 * class_definition: 
 *    declarations of javascript class definition objects.
 ***********************************************************************/

%fragment ("JS_class_definition", "templates")
%{
JSClassDefinition $jsmangledname_classDefinition;

JSClassDefinition $jsmangledname_objectDefinition;

JSClassRef $jsmangledname_classRef;
%}

/***********************************************************************
 * class_table: 
 *    function and variable tables for class and object creation.
***********************************************************************/

%fragment ("JS_class_tables", "templates")
%{
JSStaticValue $jsmangledname_staticValues[] = {
  $jsstaticclassvariables
  { 0, 0, 0, 0 }
};

JSStaticFunction $jsmangledname_staticFunctions[] = {
  $jsstaticclassfunctions
  { 0, 0, 0 }
};

JSStaticValue $jsmangledname_values[] = {
  $jsclassvariables
  { 0, 0, 0, 0 }
};

JSStaticFunction $jsmangledname_functions[] = {
  $jsclassfunctions
  { 0, 0, 0 }
};
%}

/*********************************************************************
 * destructordefn:
 * This code template is used to adds the destructor wrapper function 
***********************************************************************/

%fragment ("JS_destructordefn", "templates")
%{
void _wrap_$jsmangledname_finalize(JSObjectRef thisObject)
{
  SWIG_PRV_DATA* t = (SWIG_PRV_DATA*)JSObjectGetPrivate(thisObject);
  if(t && t->swigCMemOwn) free (($jstype*)t->swigCObject);
  if(t) free(t);
}
%}

/*********************************************************************
 * constructor_definition:
 * This code template is used to adds the main constructor wrapper function 
***********************************************************************/


%fragment ("JS_mainctordefn", "templates")
%{
JSObjectRef $jswrapper(JSContextRef context, JSObjectRef ctorObject,
    size_t argc, const JSValueRef argv[], JSValueRef* exception)
{
    JSObjectRef thisObject = NULL;
    
    // switch all cases by means of series of if-returns. 
    $jsdispatchcases

    // default: 
    SWIG_exception_fail(SWIG_ERROR, "Illegal arguments for contruction of $jsmangledname");
    
    fail:
    return thisObject;
}
%}

%fragment ("JS_veto_ctor", "templates")
%{
JSObjectRef $jsctor(JSContextRef context, JSObjectRef ctorObject,
    size_t argc, const JSValueRef argv[], JSValueRef* exception)
{
    SWIG_exception(SWIG_ERROR, "Class $jsname can not be instantiated");
    return 0;
}
%}

/**************************************************************************************
ctor_dispatch_case: This template is used for the constructor which is overloaded  
***************************************************************************************/

%fragment ("JS_ctor_dispatch_case", "templates")
%{if(argc == $jsargcount) {
    thisObject = $jswrapper(context, NULL, argc, argv, exception);
    if(thisObject != NULL) { *exception=0; return thisObject; } /* reset exception and return */
  }
%}
  
  
%fragment ("JS_ctordefn", "templates")
%{
JSObjectRef $jswrapper(JSContextRef context, JSObjectRef thisObject, size_t argc, const JSValueRef argv[], JSValueRef* exception)
{
    $jslocals
    $jscode

    return SWIG_JSC_NewPointerObj(context, result, SWIGTYPE_$jsmangledtype, SWIG_POINTER_OWN);    

    goto fail;
    fail:
    return NULL;
}
%}
/**********************************************************************
initializer:This template is dynamic growing and aggregates everything 
**********************************************************************/

%fragment ("JS_initializer", "templates") %{
#ifdef __cplusplus
extern "C" {
#endif

bool $jsname_initialize(JSGlobalContextRef context) {
    SWIG_InitializeModule(0);

    JSObjectRef global_object = JSContextGetGlobalObject(context);
    
    /* Initialize the base swig type object */
    _SwigObject_objectDefinition.staticFunctions = _SwigObject_functions;
    _SwigObject_objectDefinition.staticValues = _SwigObject_values;
    _SwigObject_classRef = JSClassCreate(&_SwigObject_objectDefinition);
    
    /* Create objects for namespaces */
    $jscreatenamespaces

    /* Create classes */
    $jsinitializercode

    /* Register namespaces */
    $jsregisternamespaces

    return true;
}

#ifdef __cplusplus
}
#endif

%}

/*****************************************************************************************
  *create_class_template:
  *This template is used to add a Static references to class templates.
*****************************************************************************************/

%fragment ("JS_create_class_template", "templates")
%{ $jsmangledname_classDefinition.staticFunctions = $jsmangledname_staticFunctions;
    $jsmangledname_classDefinition.staticValues = $jsmangledname_staticValues;
    $jsmangledname_classDefinition.callAsConstructor = $jsctor;
    $jsmangledname_objectDefinition.staticValues = $jsmangledname_values;
    $jsmangledname_objectDefinition.staticFunctions = $jsmangledname_functions;
    $jsmangledname_objectDefinition.parentClass = $jsbaseclass_classRef;
    JSClassRef $jsmangledname_classRef = JSClassCreate(&$jsmangledname_objectDefinition);
    SWIGTYPE_$jsmangledtype->clientdata = $jsmangledname_classRef;%}

/*****************************************************************************************
  *register_class:
  * This template is used to adds a class registration statement to initializer function
*****************************************************************************************/

%fragment ("JS_register_class", "templates")
%{JS_registerClass(context, $jsnspace_object, "$jsname", &$jsmangledname_classDefinition);%}


/* create and register namespaces */

%fragment ("JS_create_namespace", "templates")
%{ $jsmangledname_classDefinition.staticFunctions = $jsmangledname_functions;
    $jsmangledname_classDefinition.staticValues = $jsmangledname_values;
    JSObjectRef $jsmangledname_object = JSObjectMake(context, JSClassCreate(&$jsmangledname_classDefinition), NULL);
%}

%fragment ("JS_register_namespace", "templates")
%{
JS_registerNamespace(context, $jsmangledname_object, $jsparent_object, "$jsname"); %}
