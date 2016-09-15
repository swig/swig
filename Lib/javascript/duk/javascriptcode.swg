/* -----------------------------------------------------------------------------
 * js_ctor:  template for wrapping a ctor.
 *   - $jswrapper:        wrapper of called ctor
 *   - $jslocals:         locals part of wrapper
 *   - $jscode:           code part of wrapper
 *   - $jsargcount:       number of arguments
 *   - $jsmangledtype:    mangled type of class
 * ----------------------------------------------------------------------------- */
%fragment ("js_ctor", "templates")
%{
static duk_idx_t $jswrapper(duk_context *ctx)
{
  /* FRAGMENT: js_ctor */
  #ifdef SWIGRUNTIME_DEBUG
  printf("Called $jswrapper\n");
  #endif
  if (duk_get_top(ctx) != $jsargcount) {
    #ifdef SWIGRUNTIME_DEBUG
    printf("Illegal number of arguments for $jswrapper\n");
    #endif
    duk_push_string(ctx, "Illegal number of arguments for $jswrapper.");
    duk_throw(ctx);
  }
  $jslocals
  $jscode

  duk_push_this(ctx);
  duk_push_string(ctx, "\xFFprivate");
  SWIG_duk_NewPointerObj(ctx, result, SWIGTYPE_$jsmangledtype, SWIG_POINTER_OWN);  
  duk_put_prop(ctx, -3);
  
  duk_push_heapptr(ctx, SWIGTYPE_$jsmangledtype->clientdata);
  duk_set_prototype(ctx, -2);
  
  return 1;
}
%}

/* -----------------------------------------------------------------------------
 * js_veto_ctor:  a vetoing ctor for abstract classes
 *   - $jswrapper:        name of wrapper
 *   - $jsname:           class name
 * ----------------------------------------------------------------------------- */
%fragment ("js_veto_ctor", "templates")
%{
static duk_ret_t $jswrapper(duk_context *ctx)
{
  /* FRAGMENT: js_veto_ctor */
  #ifdef SWIGRUNTIME_DEBUG
  if (SWIGTYPE_$jsmangledtype != NULL ) {
    printf("Veto constructor for SWIGTYPE_$jsmangledtype\n");
  }
  #endif
  duk_push_string(ctx, "Cannot instantiate abstract class.");
  duk_throw(ctx);
}
%}

/* -----------------------------------------------------------------------------
 * js_ctor_dispatcher:  dispatcher for overloaded constructors
 *   - $jswrapper:        name of wrapper
 *   - $jsname:           class name
 *   - $jsdispatchcases:  part containing code for dispatching
 * ----------------------------------------------------------------------------- */
%fragment ("js_ctor_dispatcher", "templates")
%{
static duk_idx_t $jswrapper(duk_context *ctx)
{
  /* FRAGMENT: js_ctor_dispatcher */

  // switch all cases by means of series of if-returns.
  $jsdispatchcases

  // default:
  duk_push_string(ctx, "Illegal arguments for construction of $jsname");
  duk_throw(ctx);
}
%}

/* -----------------------------------------------------------------------------
 * js_overloaded_ctor:  template for wrapping a ctor.
 *   - $jswrapper:        wrapper of called ctor
 *   - $jslocals:         locals part of wrapper
 *   - $jscode:           code part of wrapper
 *   - $jsargcount:       number of arguments
 *   - $jsmangledtype:    mangled type of class
 * ----------------------------------------------------------------------------- */
%fragment ("js_overloaded_ctor", "templates")
%{
static duk_ret_t $jswrapper(duk_context *ctx)
{
  /* FRAGMENT: js_overloaded_ctor */
  $jslocals
  $jscode

  duk_push_this(ctx);
  duk_push_string(ctx, "\xFFprivate");
  SWIG_duk_NewPointerObj(ctx, result, SWIGTYPE_$jsmangledtype, SWIG_POINTER_OWN);  
  duk_put_prop(ctx, -3);
  /* The 'this' binding is now at the stack top. */
  duk_push_heapptr(ctx, SWIGTYPE_$jsmangledtype->clientdata);
  duk_set_prototype(ctx, -2);

  return 1;  
}
%}

/* -----------------------------------------------------------------------------
 * js_ctor_dispatch_case:  template for a dispatch case for calling an overloaded ctor.
 *   - $jsargcount:       number of arguments of called ctor
 *   - $jswrapper:        wrapper of called ctor
 *
 *  Note: a try-catch-like mechanism is used to switch cases
 * ----------------------------------------------------------------------------- */
%fragment ("js_ctor_dispatch_case", "templates")
%{
  /* FRAGMENT: js_ctor_dispatch_case */
  if(duk_get_top(ctx) == $jsargcount) {
    $jswrapper(ctx);
    //FIXME
    //if(thisObject != NULL) { *exception=0; return thisObject; } /* reset exception and return */
  }
%}


/* -----------------------------------------------------------------------------
 * js_dtor:  template for a destructor wrapper
 *   - $jsmangledname:  mangled class name
 *   - $jstype:         class type
 * ----------------------------------------------------------------------------- */
%fragment ("js_dtor", "templates")
%{
static duk_ret_t $jswrapper(duk_context *ctx)
{
  /* FRAGMENT: js_dtor */
  #ifdef SWIGRUNTIME_DEBUG
  printf("Called $jswrapper...\n");
  #endif
  printf("STACK TOP: %i\n", duk_get_top(ctx));
  duk_size_t sz;
  duk_get_prop_string(ctx, -2, "\xFFprivate");
  swig_duk_userdata *t = (swig_duk_userdata*)duk_to_fixed_buffer(ctx, -1, &sz);
  if(t) {
    if (t->ptr) {
      duk_free(($jstype)t->ptr);
    }
    duk_push_pointer(ctx, NULL);
    duk_put_prop_string(ctx, -2, "\xFFprivate");
    duk_free(t);
  }
  
  return 0; /* Is this sane? */
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
static duk_ret_t $jswrapper(duk_context *ctx)
{
  /* FRAGMENT: js_dtoroverride */
  #ifdef SWIGRUNTIME_DEBUG
  printf("Called $jswrapper...\n");
  #endif
  duk_size_t sz;
  duk_get_prop_string(ctx, -2, "\xFFprivate");
  swig_duk_userdata *t = (swig_duk_userdata*)duk_to_fixed_buffer(ctx, -1, &sz);
  if(t) {
    if (t->own) {
      $jstype arg1 = ($jstype)t->ptr;
      ${destructor_action}
    }
    // remove the private data to make sure that it isn't accessed elsewhere
    duk_push_pointer(ctx, NULL);
    duk_put_prop(ctx, -2);
    duk_free(ctx, t);
    return 0;
  }
  return 0;
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
static duk_ret_t $jswrapper(duk_context *ctx)
{
  /* FRAGMENT: js_getter */
  #ifdef SWIGRUNTIME_DEBUG
  printf("Called js_getter $jswrapper...\n");
  #endif
  /* The object must be on the top of the value stack on entry. */
  
  $jslocals
  
  duk_push_this(ctx);
  void *thisObject = duk_get_heapptr(ctx, -1);
  
  $jscode

  return 1;
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
static duk_ret_t $jswrapper(duk_context *ctx)
{
  /* FRAGMENT: js_setter */
  /* The value must be on the stack top at entry. */
  duk_push_this(ctx);
  void *thisObject = duk_get_heapptr(ctx, -1);
  duk_pop(ctx);
  duk_idx_t value = -1;
  
  $jslocals
  $jscode

  return 1;
}
%}

/* -----------------------------------------------------------------------------
 * js_function:  template for function wrappers
 *   - $jswrapper:  wrapper function name
 *   - $jslocals:   locals part of wrapper
 *   - $jscode:     code part of wrapper
 * ----------------------------------------------------------------------------- */
%fragment ("js_function", "templates")
%{
static duk_ret_t $jswrapper(duk_context *ctx)
{
  /* FRAGMENT: js_function */
  #ifdef SWIGRUNTIME_DEBUG
  printf("Called $jswrapper\n");
  #endif
  if (duk_get_top(ctx) != $jsargcount) {
    duk_push_string(ctx, "Illegal numargs for $jswrapper. Expected $jsargcount");
    duk_throw(ctx);
  }
  duk_push_this(ctx);
  void *thisObject = duk_get_heapptr(ctx, -1);

  $jslocals
  $jscode

  return 1;
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
static duk_ret_t $jswrapper(duk_context *ctx)
{
  /* FRAGMENT: js_function_dispatcher */
  $jslocals
  $jscode

  return 1;
}
%}

/* -----------------------------------------------------------------------------
 * js_overloaded_function:  template for a overloaded function
 *   - $jswrapper:  wrapper function name
 *   - $jslocals:   locals part of wrapper
 *   - $jscode:     code part of wrapper
 * ----------------------------------------------------------------------------- */
%fragment ("js_overloaded_function", "templates")
%{
static duk_ret_t $jswrapper(duk_context *ctx)
{
  /* FRAGMENT: js_overloaded_function */
  
  if(duk_get_top(ctx) != $jsargcount) {
    duk_push_string(ctx, "Illegal number of arguments for $jswrapper.");
  }

  $jslocals
  $jscode

  return 1;
}
%}

/* -----------------------------------------------------------------------------
 * js_function_dispatch_case:  template for a case used in the function dispatcher
 *   - $jswrapper:  wrapper function name
 *   - $jsargcount: number of arguments of overloaded function
 *   - $jscode:     code part of wrapper
 * ----------------------------------------------------------------------------- */
%fragment ("js_function_dispatch_case", "templates")
%{
  /* FRAGMENT: js_function_dispatch_case */
  if(duk_get_top(ctx) == $jsargcount) {
    $jswrapper(ctx);
    return 1;
  }
%}

/* -----------------------------------------------------------------------------
 * duk_variable_declaration:  template for a variable table entry
 *   - $jsname:       name of the variable
 *   - $jsgetter:     wrapper of getter function
 *   - $jssetter:     wrapper of setter function
 * ----------------------------------------------------------------------------- */
%fragment ("duk_variable_declaration", "templates")
%{
  /* FRAGMENT: duk_variable_declaration */
  {"$jsname", $jsgetter, $jssetter},
%}


/* -----------------------------------------------------------------------------
 * duk_function_declaration:  template for a function table entry
 *   - $jsname:       name of the variable
 *   - $jswrapper:    wrapper function
 * ----------------------------------------------------------------------------- */
%fragment ("duk_function_declaration", "templates")
%{
  /* FRAGMENT: duk_function_declaration */
  {"$jsname", $jswrapper, $jsargcount},
%}

/* -----------------------------------------------------------------------------
 * duk_class_declaration:  template for a namespace declaration
 *   - $jsmangledname:      mangled class name
 * ----------------------------------------------------------------------------- */
%fragment ("duk_class_declaration", "templates")
%{ 
  /* FRAGMENT: duk_class_declaration (unused with Duktape) */
%}

/* -----------------------------------------------------------------------------
 * duk_class_tables:  template for a namespace declaration
 *   - $jsmangledname:            mangled class name
 *   - $jsstaticclassvariables:   list of static variable entries
 *   - $jsstaticclassfunctions:   list of static function entries
 *   - $jsclassvariables:         list of member variable entries
 *   - $jsclassfunctions:         list of member function entries
 * ----------------------------------------------------------------------------- */
%fragment ("duk_class_tables", "templates")
%{
  /* FRAGMENT: duk_class_tables */
  static swig_duk_property $jsmangledname_staticValues[] = {
    $jsstaticclassvariables
    { NULL, NULL, NULL }
  };

  static duk_function_list_entry $jsmangledname_staticFunctions[] = {
    $jsstaticclassfunctions
    { NULL, NULL, 0 }
  };

  static swig_duk_property $jsmangledname_properties[] = {
    $jsclassvariables
    { NULL, NULL, NULL }
  };

  static duk_function_list_entry $jsmangledname_functions[] = {
    $jsclassfunctions
    { NULL, NULL, 0 }
  };
%}

/* -----------------------------------------------------------------------------
 * duk_define_class_template:  template for defining a class template
 *   - $jsmangledname:            mangled class name
 *   - $jsmangledtype:            mangled class type
 *   - $jsctor:                   wrapper of ctor
 *   - $jsbaseclass:              mangled name of base class
 * ----------------------------------------------------------------------------- */
%fragment ("duk_class_definition", "templates")
%{
  /* FRAGMENT: duk_class_definition */
	/* Push constructor function; all Duktape/C functions are
	 * "constructable" and can be called as 'new Foo()'.
	 */
  duk_idx_t $jsmangledname_idx = duk_push_c_function(ctx, $jsctor, DUK_VARARGS);
  /* Push MyObject.prototype object. */ 
  $jsclass_inheritance
  /* The stack is now [constructor, prototype] */
  /* Install methods and static properties */
  swig_duk_install_properties(ctx, $jsmangledname_idx, $jsmangledname_staticValues);
  duk_put_function_list(ctx, $jsmangledname_idx, $jsmangledname_staticFunctions);
  swig_duk_install_properties(ctx, $jsmangledname_idx, $jsmangledname_properties);
  duk_put_function_list(ctx, $jsmangledname_idx , $jsmangledname_functions);
  /* The stack is now [constructor, prototype (w/ finalizer)] */
  /* Install finalizer into the prototype */
  duk_push_c_function(ctx, $jsdtor, /*nargs*/ 2);
  duk_set_finalizer(ctx, $jsmangledname_idx);
  /* Set the constructor prototype to the ancestor object. */
  duk_set_prototype(ctx, $jsmangledname_idx);
  /* Setup references. */  
  void *$jsmangledname_ptr = duk_get_heapptr(ctx, $jsmangledname_idx);
  SWIGTYPE_$jsmangledtype->clientdata = $jsmangledname_ptr;
%}

%fragment ("duk_class_inherit", templates)
%{
  /* FRAGMENT: duk_class_inherit */
  /* Push the parent object to the value stack. */
  if (SWIGTYPE_p$jsbaseclassmangled != NULL) {
    duk_push_heapptr(ctx, SWIGTYPE_p$jsbaseclassmangled->clientdata);
  } else {
    duk_push_string(ctx, "Invalid class! $jsbaseclassmangled");
    duk_throw(ctx);
  }
%}

%fragment ("duk_class_noinherit", templates)
%{
  /* FRAGMENT: duk_class_noinherit */
  /* Push a copy of the SWIG object to the value stack. */
  duk_push_heapptr(ctx, swig_obj_ptr);
  duk_dup(ctx, -1);
  duk_replace(ctx, -2);
%}

/* -----------------------------------------------------------------------------
 * duk_register_class:  template for registration of a class
 *   - $jsname:                   class name
 *   - $jsmangledname:            mangled class name
 *   - $jsnspace:                 mangled name of namespace
 * ----------------------------------------------------------------------------- */
%fragment ("duk_class_registration", "templates")
%{
  /* FRAGMENT: duk_class_registration */
  {
    duk_idx_t p_idx = duk_push_heapptr(ctx, $jsnspace_ptr);
    duk_push_string(ctx, "$jsname");
    duk_push_heapptr(ctx, $jsmangledname_ptr);
    duk_put_prop(ctx, p_idx); /* Register class in the namespace */
  }

%}

/* -----------------------------------------------------------------------------
 * duk_nspace_declaration:  template for a namespace declaration
 *   - $jsnspace:           mangled name of the namespace
 *   - $jsglobalvariables:  list of variable entries
 *   - $jsglobalfunctions:  list if fuction entries
 * ----------------------------------------------------------------------------- */
%fragment ("duk_nspace_declaration", "templates")
%{
  /* FRAGMENT: duk_nspace_declaration */
  static swig_duk_property $jsnspace_properties[] = {
    $jsglobalvariables
    { NULL, NULL, NULL }
  };

  static duk_function_list_entry $jsnspace_functions[] = {
    $jsglobalfunctions
    { NULL, NULL, 0 }
  };
%}

/* -----------------------------------------------------------------------------
 * duk_nspace_definition:  template for definition of a namespace object
 *   - $jsmangledname:            mangled name of namespace
 * ----------------------------------------------------------------------------- */
%fragment ("duk_nspace_definition", "templates")
%{

    duk_idx_t $jsmangledname_idx;
    void *$jsmangledname_ptr;
    {
        duk_idx_t parent_idx = duk_push_heapptr(ctx, $jsparent_ptr);
        duk_push_string(ctx, "$jsname");
        $jsmangledname_idx = duk_push_object(ctx);
        swig_duk_install_properties(ctx, $jsmangledname_idx, $jsnspace_properties);
        duk_put_function_list(ctx, $jsmangledname_idx, $jsnspace_functions);
        $jsmangledname_ptr = duk_get_heapptr(ctx, $jsmangledname_idx);
        duk_put_prop(ctx, parent_idx);
    }
%}

