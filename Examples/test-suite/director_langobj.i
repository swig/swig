// Tests that a director method argument of the language object type is passed
// through to the target language unchanged. The const reference form had no
// directorin typemap, so it was wrapped as an opaque proxy object instead.

%module(directors="1") director_langobj

#ifndef SWIG_Object
#define SWIG_Object void *
#endif

%feature("director") Callback;

%inline {

struct Callback {
  virtual void callback(SWIG_Object param1) = 0;
  virtual void callback_ref(SWIG_Object const &param1) = 0;
  virtual ~Callback() {}
};

void call_callback(Callback *handler, SWIG_Object param1) {
  handler->callback(param1);
}

void call_callback_ref(Callback *handler, SWIG_Object param1) {
  handler->callback_ref(param1);
}

}
