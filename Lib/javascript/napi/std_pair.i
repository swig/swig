/* -----------------------------------------------------------------------------
 * std_pair.i
 *
 * SWIG typemaps for std::pair
 * ----------------------------------------------------------------------------- */

%include <std_common.i>

// ------------------------------------------------------------------------
// std::pair
// ------------------------------------------------------------------------

%{
#include <utility>
%}

namespace std {

  template<class T, class U> struct pair {
    typedef T first_type;
    typedef U second_type;

    pair();
    pair(T first, U second);
    pair(const pair& other);

    template <class U1, class U2> pair(const pair<U1, U2> &other);

    T first;
    U second;
  };

  // add specializations here

}

// When converting values to JavaScript, an std::pair is an Array with two elements

/* -------------------------*/
/* const std::pair &INPUT   */
/* -------------------------*/

// reference to const pair, C++ receives:
//  * for values -> copies (objects must be copyable)
//  * for references -> references to the JS objects
//  * for pointers -> pointers to the JS objects
%typemap(in)        std::pair const &INPUT {
  if ($input.IsArray() && $input.As<Napi::Array>().Length() == 2) {
    $1 = new $*ltype;
    Napi::Array array = $input.As<Napi::Array>();
    {
      $T0type c_val;
      Napi::Value js_val = array.Get(static_cast<uint32_t>(0));
      $typemap(in, $T0type, input=js_val, 1=c_val, argnum=pair first element);
      $1->first = SWIG_STD_MOVE(c_val);
    }
    {
      $T1type c_val;
      Napi::Value js_val = array.Get(static_cast<uint32_t>(1));
      $typemap(in, $T1type, input=js_val, 1=c_val, argnum=pair second element);
      $1->second = SWIG_STD_MOVE(c_val);
    }
  } else {
    %argument_fail(SWIG_TypeError, "Array[2]", $symname, $argnum);
  }
}
%typemap(freearg)   std::pair const &INPUT {
  delete $1;
}
%typemap(ts)        std::pair const &INPUT "[ $typemap(ts, $T0type), $typemap(ts, $T1type) ]";


/* -------------------------*/
/* const std::pair *INPUT   */
/* -------------------------*/
%apply(std::pair const &INPUT)    { std::pair const *INPUT };


/* ------------------*/
/* std::pair INPUT   */
/* ------------------*/

// pair, copy by value, C++ receives:
//  * for values -> copies (objects must be copyable)
//  * for references -> references to the JS objects
//  * for pointers -> pointers to the JS objects
// (all input arguments are protected from the GC for the duration of the operation
// and this includes the JS array that contains the references)
%typemap(in)        std::pair INPUT {
  if ($input.IsArray() && $input.As<Napi::Array>().Length() == 2) {
    Napi::Array array = $input.As<Napi::Array>();
    {
      $T0type c_val;
      Napi::Value js_val = array.Get(static_cast<uint32_t>(0));
      $typemap(in, $T0type, input=js_val, 1=c_val, argnum=pair first element);
      $1.first = SWIG_STD_MOVE(c_val);
    }
    {
      $T1type c_val;
      Napi::Value js_val = array.Get(static_cast<uint32_t>(1));
      $typemap(in, $T1type, input=js_val, 1=c_val, argnum=pair second element);
      $1.second = SWIG_STD_MOVE(c_val);
    }
  } else {
    %argument_fail(SWIG_TypeError, "Array[2]", $symname, $argnum);
  }
}
%typemap(ts)        std::pair INPUT = std::pair const &INPUT;


/* -------------------*/
/* std::pair RETURN   */
/* -------------------*/
%typemap(out)       std::pair RETURN {
  Napi::Array array = Napi::Array::New(env, 2);
  {
    Napi::Value js_val;
    $typemap(out, $T0type, 1=$1.first, result=js_val, argnum=pair first element);
    array.Set(static_cast<uint32_t>(0), js_val);
  }
  {
    Napi::Value js_val;
    $typemap(out, $T1type, 1=$1.second, result=js_val, argnum=pair second element);
    array.Set(static_cast<uint32_t>(1), js_val);
  }
  $result = array;
}
%typemap(ts)        std::pair RETURN = std::pair const &INPUT;


/* --------------------*/
/* std::pair &RETURN   */
/* --------------------*/
%typemap(out)       std::pair &RETURN {
  Napi::Array array = Napi::Array::New(env, 2);
  {
    Napi::Value js_val;
    $typemap(out, $T0type, 1=$1->first, result=js_val, argnum=pair first element);
    array.Set(static_cast<uint32_t>(0), js_val);
  }
  {
    Napi::Value js_val;
    $typemap(out, $T1type, 1=$1->second, result=js_val, argnum=pair second element);
    array.Set(static_cast<uint32_t>(1), js_val);
  }
  $result = array;
}
%typemap(ts)        std::pair &RETURN = std::pair const &INPUT;

/* --------------------*/
/* std::pair *RETURN   */
/* --------------------*/
%apply(std::pair &RETURN)    { std::pair *RETURN };


/* --------------------*/
/* std::pair &OUTPUT   */
/* --------------------*/

// Return a pair in a reference argument
%typemap(in, numinputs=0)   std::pair &OUTPUT ($*ltype _global_temp_pair) {
  $1 = &_global_temp_pair;
}
%typemap(argout)  std::pair &OUTPUT {
  Napi::Array array = Napi::Array::New(env, 2);
  {
    Napi::Value js_val;
    $typemap(out, $T0type, 1=_global_temp_pair.first, result=js_val, argnum=pair first element);
    array.Set(static_cast<uint32_t>(0), js_val);
  }
  {
    Napi::Value js_val;
    $typemap(out, $T1type, 1=_global_temp_pair.second, result=js_val, argnum=pair second element);
    array.Set(static_cast<uint32_t>(1), js_val);
  }
  $result = array;
}
%typemap(tsout)             std::pair &OUTPUT "[ $typemap(ts, $T0type), $typemap(ts, $T1type) ]";

/* --------------------*/
/* std::pair *OUTPUT   */
/* --------------------*/
%apply(std::pair &OUTPUT)    { std::pair *OUTPUT };
