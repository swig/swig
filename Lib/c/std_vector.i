// Wrap const and non-const at() methods as set() and get(), this is simpler to use from C and more clear.
%define %swig_vector_methods(Type...)
  %extend {
    void set(size_type n, const value_type& val) { self->at(n) = val; }
    value_type get(size_type n) const { return self->at(n); }
  }

  // Standard typemaps wrap get_allocator(), but it's not really useful for us, so don't bother with it.
  %ignore get_allocator
%enddef

%define %swig_vector_methods_val(Type...)
  %swig_vector_methods(Type...)
%enddef

%include <std/std_vector.i>
