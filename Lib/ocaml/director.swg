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

#ifdef __cplusplus

#include <string>

namespace Swig {
  /* simple thread abstraction for pthreads on win32 */
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
  class Director {
    private:
      /* pointer to the wrapped ocaml object */
      CAML_VALUE swig_self;
      /* flag indicating whether the object is owned by ocaml or c++ */
      mutable bool swig_disown_flag;
      /* shared flag for breaking recursive director calls */
      static bool swig_up;

#ifdef __PTHREAD__
      /* locks for sharing the swig_up flag in a threaded environment */
      static pthread_mutex_t swig_mutex_up;
      static bool swig_mutex_active;
      static pthread_t swig_mutex_thread;
#endif

      /* reset the swig_up flag once the routing direction has been determined */
#ifdef __PTHREAD__
      void swig_clear_up() const { 
        Swig::Director::swig_up = false; 
        Swig::Director::swig_mutex_active = false;
        pthread_mutex_unlock(&swig_mutex_up);
      }
#else
      void swig_clear_up() const { 
        Swig::Director::swig_up = false; 
      }
#endif

    public:
      /* wrap a ocaml object, optionally taking ownership */
      Director(CAML_VALUE self, bool disown) : swig_self(self), swig_disown_flag(disown) {
        register_global_root(&swig_self);
      }

      /* discard our reference at destruction */
      virtual ~Director() {
        remove_global_root(&swig_self);
        swig_disown(); 
        // Disown is safe here because we're just divorcing a reference that
        // points to us.  
      }

      /* return a pointer to the wrapped ocaml object */
      CAML_VALUE swig_get_self() const { 
        return callback(*caml_named_value("caml_director_get_self"),swig_self); 
      }

      /* get the swig_up flag to determine if the method call should be routed
       * to the c++ base class or through the wrapped ocaml object
       */
#ifdef __PTHREAD__
      bool swig_get_up() const { 
        if (Swig::Director::swig_mutex_active) {
          if (pthread_equal(Swig::Director::swig_mutex_thread, pthread_self())) {
            bool up = swig_up;
            swig_clear_up();
            return up;
          }
        }
        return false;
      }
#else 
      bool swig_get_up() const { 
        bool up = swig_up;
        swig_up = false;
        return up;
      }
#endif

      /* set the swig_up flag if the next method call should be directed to
       * the c++ base class rather than the wrapped ocaml object
       */
#ifdef __PTHREAD__
      void swig_set_up() const { 
        pthread_mutex_lock(&Swig::Director::swig_mutex_up);
        Swig::Director::swig_mutex_thread = pthread_self();
        Swig::Director::swig_mutex_active = true;
        Swig::Director::swig_up = true; 
      }
#else 
      void swig_set_up() const { 
        Swig::Director::swig_up = true; 
      }
#endif

      /* acquire ownership of the wrapped ocaml object (the sense of "disown"
       * is from ocaml) */
      void swig_disown() const { 
        if (!swig_disown_flag) { 
          swig_disown_flag=true;
          callback(*caml_named_value("caml_obj_disown"),swig_self);
        } 
      }
  };

  bool Swig::Director::swig_up = false;

#ifdef __PTHREAD__
  MUTEX_INIT(Swig::Director::swig_mutex_up);
  pthread_t Swig::Director::swig_mutex_thread;
  bool Swig::Director::swig_mutex_active = false;
#endif

}

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
