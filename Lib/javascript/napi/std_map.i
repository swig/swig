/* -----------------------------------------------------------------------------
 * std_map.i
 *
 * SWIG typemaps for std::map
 * ----------------------------------------------------------------------------- */

%include <std_common.i>

// ------------------------------------------------------------------------
// std::map
// ------------------------------------------------------------------------

%{
#include <map>
#include <algorithm>
#include <stdexcept>
%}

// exported class

namespace std {

    template<class K, class T, class C = std::less<K> > class map {
        // add typemaps here
      public:
        typedef size_t size_type;
        typedef ptrdiff_t difference_type;
        typedef K key_type;
        typedef T mapped_type;
        typedef std::pair< const K, T > value_type;
        typedef value_type* pointer;
        typedef const value_type* const_pointer;
        typedef value_type& reference;
        typedef const value_type& const_reference;

        map();
        map(const map& other);
        
        unsigned int size() const;
        bool empty() const;
        void clear();
        %extend {
            const T& get(const K& key) throw (std::out_of_range) {
                std::map< K, T, C >::iterator i = self->find(key);
                if (i != self->end())
                    return i->second;
                else
                    throw std::out_of_range("key not found");
            }
            void set(const K& key, const T& x) {
%#ifdef __cpp_lib_map_try_emplace
                (*self).insert_or_assign(key, x);
%#else
                (*self)[key] = x;
%#endif
            }
            void del(const K& key) throw (std::out_of_range) {
                std::map< K, T, C >::iterator i = self->find(key);
                if (i != self->end())
                    self->erase(i);
                else
                    throw std::out_of_range("key not found");
            }
            bool has_key(const K& key) {
                std::map< K, T, C >::iterator i = self->find(key);
                return i != self->end();
            }
        }
    };

}

/* ----------------------*/
/* const std::map &INPUT */
/* ----------------------*/
%define ASSERT_STRING_MAP
static_assert(std::is_same<std::string, std::remove_cv<std::remove_reference<$T0type>::type>::type>::value,
    "Only a string (or a Symbol) can be an object property name in JavaScript");
%enddef


// reference to const map, C++ receives:
//  * for values -> copies (objects must be copyable)
//  * for references -> references to the JS objects
//  * for pointers -> pointers to the JS objects
// (all input arguments are protected from the GC for the duration of the operation
// and this includes the JS array that contains the references)
// Don't try this at home, it uses an undocumented feature of $typemap
%typemap(in)        std::map const &INPUT {
  ASSERT_STRING_MAP;
  if ($input.IsObject()) {
    $1 = new $*ltype;
    Napi::Object obj = $input.As<Napi::Object>();
    Napi::Array keys = obj.GetPropertyNames();
    for (size_t i = 0; i < keys.Length(); i++) {
      std::string c_key;
      $T1type c_val;
      Napi::Value js_key = keys.Get(i);
      Napi::Value js_val = obj.Get(js_key);
      $typemap(in, std::string, input=js_key, 1=c_key, argnum=object key);
      $typemap(in, $T1type, input=js_val, 1=c_val, argnum=object value);
      $1->emplace(c_key, c_val);
    }
  } else {
    %argument_fail(SWIG_TypeError, "object", $symname, $argnum);
  }
}
%typemap(freearg)   std::map const &INPUT {
  delete $1;
}
%typemap(ts)        std::map const &INPUT "Record<string, $typemap(ts, $T1type)>";


/* ----------------------*/
/* const std::map *INPUT */
/* ----------------------*/
%apply(std::map const &INPUT)    { std::map const *INPUT };


/* ---------------*/
/* std::map INPUT */
/* ---------------*/

// map, copy by value, C++ receives:
//  * for values -> copies (objects must be copyable)
//  * for references -> references to the JS objects
//  * for pointers -> pointers to the JS objects
// (all input arguments are protected from the GC for the duration of the operation
// and this includes the JS array that contains the references)
// Don't try this at home, it uses an undocumented feature of $typemap
%typemap(in)        std::map INPUT {
  ASSERT_STRING_MAP;
  if ($input.IsObject()) {
    Napi::Object obj = $input.As<Napi::Object>();
    Napi::Array keys = obj.GetPropertyNames();
    for (size_t i = 0; i < keys.Length(); i++) {
      std::string c_key;
      $T1type c_val;
      Napi::Value js_key = keys.Get(i);
      Napi::Value js_val = obj.Get(js_key);
      $typemap(in, std::string, input=js_key, 1=c_key, argnum=object key);
      $typemap(in, $T1type, input=js_val, 1=c_val, argnum=object value);
      $1.emplace(c_key, c_val);
    }
  } else {
    %argument_fail(SWIG_TypeError, "object", $symname, $argnum);
  }
}
%typemap(ts)        std::map INPUT "Record<string, $typemap(ts, $T1type)>";


/* ----------------*/
/* std::map RETURN */
/* ----------------*/
%typemap(out)       std::map RETURN {
  ASSERT_STRING_MAP;
  Napi::Object obj = Napi::Object::New(env);
  for (auto const &el : $1) {
    $T1type c_val = el.second;
    Napi::Value js_val;
      $typemap(in, std::string, input=js_key, 1=c_key, argnum=object key);
      $typemap(in, $T1type, input=js_val, 1=c_val, argnum=object value);
    obj.Set(el.first, js_val);
  }
  $result = obj;
}
%typemap(ts)        std::map RETURN "Record<string, $typemap(ts, $T1type)>";

/* -----------------*/
/* std::map &RETURN */
/* -----------------*/
%typemap(out)       std::map &RETURN {
  ASSERT_STRING_MAP;
  Napi::Object obj = Napi::Object::New(env);
  for (auto const &el : *$1) {
    $T1type c_val = el.second;
    Napi::Value js_val;
    $typemap(out, $T1type, 1=c_val, result=js_val, argnum=object value);
    obj.Set(el.first, js_val);
  }
  $result = obj;
}
%typemap(ts)        std::map INPUT "Record<string, $typemap(ts, $T1type)>";

/* --------------------*/
/* std::map *RETURN */
/* --------------------*/
%apply(std::map &RETURN)    { std::map *RETURN };


/* --------------------*/
/* std::map &OUTPUT */
/* --------------------*/

// Return a map in a reference argument
%typemap(in, numinputs=0)  std::map &OUTPUT ($*ltype _global_temp_map) {
  $1 = &_global_temp_map;
}
%typemap(argout)  std::map &OUTPUT {
  ASSERT_STRING_MAP;
  Napi::Object obj = Napi::Object::New(env);
  for (auto const &el : _global_temp_map) {
    $T1type c_val = el.second;
    Napi::Value js_val;
    $typemap(out, $T1type, 1=c_val, result=js_val, argnum=object value);
    obj.Set(el.first, js_val);
  }
  $result = obj;
}
%typemap(tsout)      std::map &OUTPUT "Record<string, $typemap(ts, $T1type)>";

/* --------------------*/
/* std::map *OUTPUT */
/* --------------------*/
%apply(std::map &OUTPUT)    { std::map *OUTPUT };
