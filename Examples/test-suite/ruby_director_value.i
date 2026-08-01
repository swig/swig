// Tests that a VALUE director method argument is passed through to Ruby
// unchanged. The const reference form had no directorin typemap and so was
// wrapped as an opaque proxy object instead of being passed straight through.

%module(directors="1") ruby_director_value

%feature("director") Callback;

%inline %{
struct Callback {
  virtual void callback(VALUE param1) = 0;
  virtual void callback_ref(VALUE const &param1) = 0;
  virtual ~Callback() {}
};

void call_callback(Callback *handler, VALUE param1) {
  handler->callback(param1);
}

void call_callback_ref(Callback *handler, VALUE param1) {
  handler->callback_ref(param1);
}
%}
