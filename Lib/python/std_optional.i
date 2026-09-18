// Purpose: SWIG interface file for std::optional<> type.
//
// This file defines macros for handling optional types in SWIG.
//
// Usage:
//
// %optional(TYPE):
//    This macro is used to bind structs and classes to wrapped python interfaces returning None if the optional is empty.
//    Example:
//    %optional(MyStruct)
//    This will generate code to handle std::optional<MyStruct>.
//
// The SWIG_STD_OPTIONAL_DEFAULT_TYPES macro is used to define a set of default types that are supported by SWIG when working with std::optional.
// This macro ensures that common types such as int, double, and std::string are automatically recognized and handled by SWIG when generating bindings.
// 

%{
    #include <optional>
%}

%include <stdint.i>
%include <std_string.i>

namespace std {
  template<typename T> class optional {};
}

%define %optional(TYPE)

%naturalvar std::optional< TYPE >;

// CHECKME: when is this used
%typemap(typecheck, precedence=SWIG_TYPECHECK_POINTER) std::optional< TYPE >, std::optional< TYPE > const & (std::optional< TYPE > tmp_ov) %{
  if ($input == Py_None)
    $1 = true;
  else {
    $typemap(typecheck, TYPE)
  }
%}

%typemap(in,implicitconv=1) std::optional< TYPE > const, std::optional< TYPE > %{
  if ($input == Py_None) {
    $1 = std::nullopt;
  } else {
    $typemap(in, TYPE)
  }
%}

%typemap(in,implicitconv=1) std::optional< TYPE > const & (std::optional< TYPE > val), std::optional< TYPE > & (std::optional< TYPE > val) %{
  $1 = &val;
  if ($input == Py_None) {
    val = std::nullopt;
  } else
  {
    TYPE $1; // shadow assignment
    $typemap(in, TYPE)
    val.emplace($1);
  }
%}

%typemap(in,implicitconv=1) std::optional< TYPE > const * (std::optional< TYPE > val), std::optional< TYPE > * (std::optional< TYPE > val) %{
  $1 = &val;
  if ($input == Py_None) {
    val = std::nullopt;
  } else
  {
    TYPE $1; // shadow assignment
    $typemap(in, TYPE)
    val.emplace($1);
  }
%}

%typemap(directorin,implicitconv=1) std::optional< TYPE > const, std::optional< TYPE > %{
  if ( ($1).has_value() ) {
    auto& tmp_ov = $1;
    {
      auto& $1 = tmp_ov.value(); // shadow assignment
      $typemap(directorin, TYPE)
    }
  } else {
    $input = Py_None;
    Py_INCREF(Py_None);
  }
%}

%typemap(directorin,implicitconv=1) std::optional< TYPE > const & (std::optional< TYPE > val), std::optional< TYPE > & (std::optional< TYPE > val) %{
  if ( ($1).has_value() ) {
    auto& tmp_ov = $1;
    {
      auto& $1 = tmp_ov.value(); // shadow assignment
      $typemap(directorin, TYPE)
    }
  } else {
    $input = Py_None;
    Py_INCREF(Py_None);
  }
%}

%typemap(out) std::optional< TYPE > const, std::optional< TYPE > %{
  if ( $1.has_value() ) {
    auto const& tmp_ov = *($1).operator&(); // shadow assignment
    {
      TYPE const& result = tmp_ov.value();
      $typemap(out, TYPE)
    }
  } else {
    $result = Py_None;
    Py_INCREF(Py_None);
  }
%}


%typemap(out) std::optional< TYPE > const &, std::optional< TYPE > & %{
  if ( ($1)->has_value() )
  {
    auto const& tmp_ov = *$1; // shadow assignment
    {
      TYPE const& result = tmp_ov.value();
      $typemap(out, TYPE)
    }
  }
  else
  {
    $result = Py_None;
    Py_INCREF(Py_None);
  }
%}

%typemap(out) std::optional< TYPE > const *, std::optional< TYPE > * %{
  if ( ($1)->has_value() )
  {
    auto const& tmp_ov = *$1; // shadow assignment
    {
      TYPE const& result = tmp_ov.value();
      $typemap(out, TYPE)
    }
  }
  else
  {
    $result = Py_None;
    Py_INCREF(Py_None);
  }
%}

%enddef


#if defined(SWIG_STD_OPTIONAL_DEFAULT_TYPES)
  %optional(bool)
  %optional(std::int8_t)
  %optional(std::int16_t)
  %optional(std::int32_t)
  %optional(std::uint8_t)
  %optional(std::uint16_t)
  %optional(std::uint32_t)

  %optional(std::int64_t)
  %optional(std::uint64_t)

  %optional(float)
  %optional(double)

  %optional(std::string)
#endif
