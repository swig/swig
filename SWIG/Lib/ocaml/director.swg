/* -*- C++ -*- */
/***********************************************************************
 * director.swg
 *
 *     This file contains support for director classes that proxy
 *     method calls from C++ to Ocaml extensions.
 *
 * Modified for Ocaml by : Art Yerkes
 * Original Author : Mark Rose (mrose@stm.lbl.gov)
 ************************************************************************/

%insert(runtime) %{

#include <assert.h>
#ifdef __cplusplus

#include <string>

/* simple thread abstraction for pthreads or win32 */
#ifdef __THREAD__
  #define __PTHREAD__
  #if defined(_WIN32) || defined(__WIN32__)
    #define pthread_mutex_lock EnterCriticalSection
    #define pthread_mutex_unlock LeaveCriticalSection
    #define pthread_mutex_t CRITICAL_SECTION
    #define MUTEX_INIT(var) CRITICAL_SECTION var
  #else
    #include <pthread.h>
    #define MUTEX_INIT(var) pthread_mutex_t var = PTHREAD_MUTEX_INITIALIZER 
  #endif
#endif

/* director base class */
class __DIRECTOR__ {
private:
    /* pointer to the wrapped ocaml object */
    CAML_VALUE _self;
    /* flag indicating whether the object is owned by ocaml or c++ */
    mutable int _disown;
    /* shared flag for breaking recursive director calls */
    static int _up;
    
#ifdef __PTHREAD__
    /* locks for sharing the _up flag in a threaded environment */
    static pthread_mutex_t _mutex_up;
    static int _mutex_active;
    static pthread_t _mutex_thread;
#endif
    
  /* reset the _up flag once the routing direction has been determined */
#ifdef __PTHREAD__
    void __clear_up() const { 
	__DIRECTOR__::_up = 0; 
	__DIRECTOR__::_mutex_active = 0;
	pthread_mutex_unlock(&_mutex_up);
    }
#else
    void __clear_up() const { 
	__DIRECTOR__::_up = 0; 
    }
#endif

public:
    /* the default constructor should not be called */
    __DIRECTOR__() { 
	assert(0); 
    }
    
    /* wrap a ocaml object, optionally taking ownership */
    __DIRECTOR__(CAML_VALUE self, int disown): _self(self), _disown(disown) {
	register_global_root(&_self);
    }
    
    /* discard our reference at destruction */
    virtual ~__DIRECTOR__() {
	remove_global_root(&_self);
	__disown(); 
        // Disown is safe here because we're just divorcing a reference that
	// points to us.  
    }
    
    /* return a pointer to the wrapped ocaml object */
    CAML_VALUE __get_self() const { 
	return callback(*caml_named_value("caml_director_get_self"),_self); 
    }

    /* get the _up flag to determine if the method call should be routed
     * to the c++ base class or through the wrapped ocaml object
     */
#ifdef __PTHREAD__
    int __get_up() const { 
	if (__DIRECTOR__::_mutex_active) {
	    if (pthread_equal(__DIRECTOR__::_mutex_thread, pthread_self())) {
		int up = _up;
		__clear_up();
		return up;
	    }
	}
	return 0;
    }
#else 
    int __get_up() const { 
	int up = _up;
	_up = 0;
	return up;
    }
#endif
    
    /* set the _up flag if the next method call should be directed to
     * the c++ base class rather than the wrapped ocaml object
     */
#ifdef __PTHREAD__
    void __set_up() const { 
	pthread_mutex_lock(&__DIRECTOR__::_mutex_up);
	__DIRECTOR__::_mutex_thread = pthread_self();
	__DIRECTOR__::_mutex_active = 1;
	__DIRECTOR__::_up = 1; 
    }
#else 
    void __set_up() const { 
	__DIRECTOR__::_up = 1; 
    }
#endif
    
    /* acquire ownership of the wrapped ocaml object (the sense of "disown"
     * is from ocaml) */
    void __disown() const { 
	assert(_self); 
	if (!_disown) { 
	    _disown=1;
	    callback(*caml_named_value("caml_obj_disown"),_self);
	} 
    }
};

int __DIRECTOR__::_up = 0;

#ifdef __PTHREAD__
MUTEX_INIT(__DIRECTOR__::_mutex_up);
pthread_t __DIRECTOR__::_mutex_thread;
int __DIRECTOR__::_mutex_active = 0;
#endif

#endif /* __cplusplus */

%}

%insert(mli) %{
    val new_derived_object: 
	(c_obj -> c_obj) ->
	(c_obj -> string -> c_obj -> c_obj) ->
	c_obj -> c_obj
%}

%insert(ml) %{
let new_derived_object cfun x_class args =
  begin
    let get_object ob =
      match !ob with
          None ->
    raise (NotObject C_void)
        | Some o -> o in
    let class_fun class_f ob_r =
    (fun meth args -> class_f (get_object ob_r) meth args) in
    let ob_ref = ref None in
    let new_class = class_fun x_class ob_ref in
    let obj =
    cfun (match args with
                C_list argl ->
	  (C_list ((C_director_core (C_obj new_class,ob_ref)) :: argl))
	  | a -> (C_list [ C_director_core 
			   (C_obj new_class,ob_ref)  ; a ])) in
    ob_ref := Some obj ;
      obj
  end
%}
