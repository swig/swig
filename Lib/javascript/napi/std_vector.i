/* -----------------------------------------------------------------------------
 * std_vector.i
 * ----------------------------------------------------------------------------- */

%include <std_common.i>

%insert(header) %{
#include <vector>
#include <stdexcept>
%}

namespace std {
    
    template<class T> class vector {
      public:
        typedef size_t size_type;
        typedef ptrdiff_t difference_type;
        typedef T value_type;
        typedef value_type* pointer;
        typedef const value_type* const_pointer;
        typedef value_type& reference;
        typedef const value_type& const_reference;

        vector();
        vector(size_type n);
        vector(const vector& other);

        size_type size() const;
        size_type capacity() const;
        void reserve(size_type n);
        %rename(isEmpty) empty;
        bool empty() const;
        void clear();
        %rename(add) push_back;
        void push_back(const value_type& x);
        %extend {
            const_reference get(int i) throw (std::out_of_range) {
                int size = int(self->size());
                if (i>=0 && i<size)
                    return (*self)[i];
                else
                    throw std::out_of_range("vector index out of range");
            }
            void set(int i, const value_type& val) throw (std::out_of_range) {
                int size = int(self->size());
                if (i>=0 && i<size)
                    (*self)[i] = val;
                else
                    throw std::out_of_range("vector index out of range");
            }
        }
    };

    // bool specialization
    template<> class vector<bool> {
      public:
        typedef size_t size_type;
        typedef ptrdiff_t difference_type;
        typedef bool value_type;
        typedef value_type* pointer;
        typedef const value_type* const_pointer;
        typedef value_type& reference;
        typedef bool const_reference;

        vector();
        vector(size_type n);
        vector(const vector& other);

        size_type size() const;
        size_type capacity() const;
        void reserve(size_type n);
        %rename(isEmpty) empty;
        bool empty() const;
        void clear();
        %rename(add) push_back;
        void push_back(const value_type& x);
        %extend {
            bool get(int i) throw (std::out_of_range) {
                int size = int(self->size());
                if (i>=0 && i<size)
                    return (*self)[i];
                else
                    throw std::out_of_range("vector index out of range");
            }
            void set(int i, const value_type& val) throw (std::out_of_range) {
                int size = int(self->size());
                if (i>=0 && i<size)
                    (*self)[i] = val;
                else
                    throw std::out_of_range("vector index out of range");
            }
        }
    };
}

%define specialize_std_vector(T)
#warning "specialize_std_vector - specialization for type T no longer needed"
%enddef

/* -------------------------*/
/* const std::vector &INPUT */
/* -------------------------*/

// reference to const vector, C++ receives:
//  * for values -> copies (objects must be copyable)
//  * for references -> references to the JS objects
//  * for pointers -> pointers to the JS objects
// (all input arguments are protected from the GC for the duration of the operation
// and this includes the JS array that contains the references)
// Don't try this at home, it uses an undocumented feature of $typemap
%typemap(in)        std::vector const &INPUT {
  if ($input.IsArray()) {
    $1 = new $*ltype;
    Napi::Array array = $input.As<Napi::Array>();
    for (size_t i = 0; i < array.Length(); i++) {
      $T0type c_val;
      Napi::Value js_val = array.Get(i);
      $typemap(in, $T0type, input=js_val, 1=c_val, argnum=array value);
      $1->emplace_back(c_val);
    }
  } else {
    %argument_fail(SWIG_TypeError, "Array", $symname, $argnum);
  }
}
%typemap(freearg)   std::vector const &INPUT {
  delete $1;
}
%typemap(ts)        std::vector const &INPUT "$typemap(ts, $T0type)[]";


/* -------------------------*/
/* const std::vector *INPUT */
/* -------------------------*/
%apply(std::vector const &INPUT)    { std::vector const *INPUT };


/* ------------------*/
/* std::vector INPUT */
/* ------------------*/

// vector, copy by value, C++ receives:
//  * for values -> copies (objects must be copyable)
//  * for references -> references to the JS objects
//  * for pointers -> pointers to the JS objects
// (all input arguments are protected from the GC for the duration of the operation
// and this includes the JS array that contains the references)
// Don't try this at home, it uses an undocumented feature of $typemap
%typemap(in)        std::vector INPUT {
  if ($input.IsArray()) {
    Napi::Array array = $input.As<Napi::Array>();
    for (size_t i = 0; i < array.Length(); i++) {
      $T0type c_val;
      Napi::Value js_val = array.Get(i);
      $typemap(in, $T0type, input=js_val, 1=c_val, argnum=array value);
      $1.emplace_back(c_val);
    }
  } else {
    %argument_fail(SWIG_TypeError, "Array", $symname, $argnum);
  }
}
%typemap(ts)        std::vector INPUT "$typemap(ts, $T0type)[]";


/* -------------------*/
/* std::vector RETURN */
/* -------------------*/
%typemap(out)       std::vector RETURN {
  Napi::Array array = Napi::Array::New(env, $1.size());
  for (size_t i = 0; i < $1.size(); i++) {
    $T0type c_val = $1.at(i);
    Napi::Value js_val;
    $typemap(out, $T0type, 1=c_val, result=js_val, argnum=array value);
    array.Set(i, js_val);
  }
  $result = array;
}
%typemap(ts)        std::vector RETURN "$typemap(ts, $T0type)[]";

/* --------------------*/
/* std::vector &RETURN */
/* --------------------*/
%typemap(out)       std::vector &RETURN {
  Napi::Array array = Napi::Array::New(env, $1->size());
  for (size_t i = 0; i < $1->size(); i++) {
    $T0type c_val = $1->at(i);
    Napi::Value js_val;
    $typemap(out, $T0type, 1=c_val, result=js_val, argnum=array value);
    array.Set(i, js_val);
  }
  $result = array;
}
%typemap(ts)        std::vector &RETURN "$typemap(ts, $T0type)[]";

/* --------------------*/
/* std::vector *RETURN */
/* --------------------*/
%apply(std::vector &RETURN)    { std::vector *RETURN };


/* --------------------*/
/* std::vector &OUTPUT */
/* --------------------*/

// Return a vector in a reference argument
%typemap(in, numinputs=0)  std::vector &OUTPUT ($*ltype _global_temp_vector) {
  $1 = &_global_temp_vector;
}
%typemap(argout)  std::vector &OUTPUT {
  Napi::Array array = Napi::Array::New(env, _global_temp_vector.size());
  for (size_t i = 0; i < _global_temp_vector.size(); i++) {
    $T0type c_val = _global_temp_vector.at(i);
    Napi::Value js_val;
    $typemap(out, $T0type, 1=c_val, result=js_val, argnum=array value);
    array.Set(i, js_val);
  }
  $result = array;
}
%typemap(tsout)      std::vector &OUTPUT "$typemap(ts, $T0type)[]";

/* --------------------*/
/* std::vector *OUTPUT */
/* --------------------*/
%apply(std::vector &OUTPUT)    { std::vector *OUTPUT };
