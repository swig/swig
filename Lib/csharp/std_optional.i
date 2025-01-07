// Purpose: SWIG interface file for std::optional<> type.
//
// This file defines macros for handling optional types in SWIG.
// The macros provided are %optional, %optional_string, and %optional_arithmetic.
//
// Usage:
//
// 1. %optional_arithmetic(TYPE, INTERNAL_NAME [, CLASSMODIFIER]):
//    This macro is used to bind arithmetic types (int, float, double, etc.) to C# nullable value type (represented as Nullable<T>).
//    Example:
//    %optional_arithmetic(double, OptDouble)
//    This will generate code to handle std::optional<double>.
//    An internal class name OptDouble will be created to bind the optional type from C++ to C# nullable value type. The internal class will be marked as internal by default.
//    If you want to change the access modifier of the internal class for one specific type, you can pass an optional CLASSMODIFIER parameter to the macro.
//    See the SWIG_STD_OPTIONAL_INTERNAL_CLASS_MODIFIER macro for more information.
// 
// 2. %optional_string():
//    This macro is used specifically for std::optional<std::string>.
//    Example:
//    %optional_string()
//    This will generate code to handle std::optional<std::string>.
//
// 3. %optional(TYPE):
//    This macro is used to bind structs and classes to either C# nullable reference type (if SWIG_STD_OPTIONAL_USE_NULLABLE_REFERENCE_TYPES is defined) or C# non-nullable reference type.
//    Example:
//    %optional(MyStruct)
//    This will generate code to handle std::optional<MyStruct>.
//
// The SWIG_STD_OPTIONAL_DEFAULT_TYPES macro is used to define a set of default types that are supported by SWIG when working with std::optional.
// This macro ensures that common types such as int, double, and std::string are automatically recognized and handled by SWIG when generating bindings.
//
// The SWIG_STD_OPTIONAL_USE_NULLABLE_REFERENCE_TYPES macro definition is used to enable the use of nullable reference types in the generated SWIG bindings.
// When this macro is defined, SWIG will generate code that treats std::optional types as C# nullable reference types, allowing the compiler to run null-state analysis (C# >= 8 required).
// When this macro is defined, any module using this file should be declared with the #nullable enable directive.
// Example:
// %module(csbegin="#nullable enable\n") MyModule
//
// The SWIG_STD_OPTIONAL_INTERNAL_CLASS_MODIFIER macro is used to define the access modifier for the internal class generated for the arithmetic optional types. By default it is set to internal.
// You may want to define it to 'public' so the internal class is accessible from outside the assembly it's defined in. See the documentation of the SWIG_CSBODY_PROXY macro for more information.
// Defining this macro will affect all optional arithmetic types defined in the module.

#if defined(SWIG_STD_OPTIONAL_USE_NULLABLE_REFERENCE_TYPES)
%define SWIG_STD_OPTIONAL_NULLABLE_TYPE "?" %enddef
#else
%define SWIG_STD_OPTIONAL_NULLABLE_TYPE "" %enddef
#endif

#ifndef SWIG_STD_OPTIONAL_STRINGIFY
#define SWIG_STD_OPTIONAL_STRINGIFY_(x) #x
#define SWIG_STD_OPTIONAL_STRINGIFY(x) SWIG_STD_OPTIONAL_STRINGIFY_(x)
#endif


%{
    #include <optional>
%}

%include <stdint.i>
%include <std_string.i>

namespace std {
  template<typename T> class optional {
    public:
        typedef T value_type;

        optional();
        optional(T value);
        optional(const optional& other);

        constexpr bool has_value() const noexcept;
        constexpr const T& value() const&;
  };
}

%define %optional(TYPE)

%naturalvar std::optional< TYPE >;

%typemap(cstype) std::optional< TYPE >, std::optional< TYPE > const & "$typemap(cstype, TYPE)"SWIG_STD_OPTIONAL_NULLABLE_TYPE


// This typemap is used to convert C# nullable type to the handler passed to the
// intermediate native wrapper function.
%typemap(csin) std::optional< TYPE >, std::optional< TYPE > const & "$typemap(cstype, TYPE).getCPtr($csinput)"

// This is used for functions returning optional values.
%typemap(csout, excode=SWIGEXCODE) std::optional< TYPE > {
    var instance = $imcall;
    var ret = (instance != global::System.IntPtr.Zero) ? new $typemap(cstype, TYPE)(instance, true) : null;$excode
    return ret;
  }
%typemap(csout, excode=SWIGEXCODE) std::optional< TYPE > const &, std::optional< TYPE > *, std::optional< TYPE > const * {
    var instance = $imcall;
    var ret = (instance != global::System.IntPtr.Zero) ? new $typemap(cstype, TYPE)(instance, $owner) : null;$excode
    return ret;
  }

%typemap(in) std::optional< TYPE > const & (std::optional< TYPE > var) %{
    $1 = &var;
    var = ($input == nullptr) ? std::nullopt : std::optional< TYPE > { *(TYPE*) $input };
%}

%typemap(in) std::optional< TYPE > %{
    if ($input != nullptr) {
      $1 = *static_cast<TYPE*>($input);
    }
%}

%typemap(out) std::optional< TYPE > const & %{ 
    $result = $1->has_value() ? &$1->value() : nullptr;
%}

%typemap(out) std::optional< TYPE > %{ 
    $result = $1.has_value() ? new TYPE { $1.value() } : nullptr;
%}


// This code is used for the optional-valued properties in C#.
%typemap(cstype) std::optional< TYPE > *, std::optional< TYPE > const * "$typemap(cstype, TYPE)"SWIG_STD_OPTIONAL_NULLABLE_TYPE
%typemap(csin) std::optional< TYPE > *, std::optional< TYPE > const * "$typemap(cstype, TYPE).getCPtr($csinput)"

%typemap(csvarin, excode=SWIGEXCODE) std::optional< TYPE > *, std::optional< TYPE > const * %{
    set {
      $imcall;$excode
    }%}
%typemap(csvarout, excode=SWIGEXCODE2) std::optional< TYPE > *, std::optional< TYPE > const * %{
    get {
        var instance = $imcall;
        var ret = (instance != global::System.IntPtr.Zero) ? new $typemap(cstype, TYPE)(instance, $owner) : null;$excode
        return ret;
    }%}

%typemap(in) std::optional< TYPE > * (std::optional< TYPE > var) %{
    $1 = &var;
    var = ($input == nullptr) ? std::nullopt : std::optional< TYPE > { *(TYPE*) $input };
%}
%typemap(out) std::optional< TYPE > * %{ 
    $result = $1->has_value() ? &$1->value() : nullptr;
%}

%typemap(csdirectorin) std::optional< TYPE >, std::optional< TYPE > const & "($iminput != global::System.IntPtr.Zero) ? new $typemap(cstype, TYPE)($iminput, true) : null"


%enddef

// ----------------------------------------------------------------------------
// optional arithmetic specialisation
// ----------------------------------------------------------------------------
// Macro to set the class modifier for the internal class generated for the
// optional type.
#ifndef SWIG_STD_OPTIONAL_INTERNAL_CLASS_MODIFIER
#define SWIG_STD_OPTIONAL_INTERNAL_CLASS_MODIFIER internal
#endif

// Define the optional arithmetic types.
%define %optional_arithmetic(TYPE, NAME, CLASSMODIFIER...)
 
// The std::optional<> specializations themselves are only going to be used
// inside our own code, the user will deal with either T? or T, depending on
// whether T is a value or a reference type, so make them private to our own
// assembly.
#if #CLASSMODIFIER == ""
%typemap(csclassmodifiers) std::optional< TYPE > SWIG_STD_OPTIONAL_STRINGIFY(SWIG_STD_OPTIONAL_INTERNAL_CLASS_MODIFIER) " class"
#else
%typemap(csclassmodifiers) std::optional< TYPE > SWIG_STD_OPTIONAL_STRINGIFY(CLASSMODIFIER) " class"
#endif

// Do this to use reference typemaps instead of the pointer ones used by
// default for the member variables of this type.
//
// Notice that this must be done before %template below, SWIG must know about
// all features attached to the type before dealing with it.
%naturalvar std::optional< TYPE >;

// Even although we're not going to really use them, we must still name the
// exported template instantiation, otherwise SWIG would give it an
// auto-generated name starting with SWIGTYPE which would be even uglier.
%template("NAME") std::optional< TYPE >;


// Define the type we want to use in C#.
%typemap(cstype) std::optional< TYPE >, std::optional< TYPE > const & "$typemap(cstype, TYPE)?"

// This typemap is used to convert C# nullable type to the handler passed to the
// intermediate native wrapper function.
%typemap(csin,
         pre="    NAME opt_$csinput = $csinput.HasValue ? new NAME($csinput.Value) : new NAME();"
         ) std::optional< TYPE >, std::optional< TYPE > const& "$csclassname.getCPtr(opt_$csinput)"

// This is used for functions returning optional values.
%typemap(csout, excode=SWIGEXCODE) std::optional< TYPE >, std::optional< TYPE > const & {
    NAME ret = new NAME($imcall, $owner);$excode
    return ret.has_value() ? ret.value() : ($typemap(cstype, TYPE)?)null;
  }

// This code is used for the optional-valued properties in C#.
%typemap(csvarin, excode=SWIGEXCODE2) std::optional< TYPE >, std::optional< TYPE > const & %{
    set {
      NAME opt_value = value.HasValue ? new NAME(value.Value) : new NAME();
      $imcall;$excode
    }%}
%typemap(csvarout, excode=SWIGEXCODE2) std::optional< TYPE >, std::optional< TYPE > const & %{
    get {
      NAME ret = new NAME($imcall, $owner);$excode
      return ret.has_value() ? ret.value() : ($typemap(cstype, TYPE)?)null;
    }%}

%typemap(csdirectorin,
         pre="    NAME opt_$iminput = ($iminput != global::System.IntPtr.Zero) ? new NAME($iminput, true) : new NAME();"
         ) std::optional< TYPE >, std::optional< TYPE > const & "opt_$iminput.has_value() ? opt_$iminput.value() : ($typemap(cstype, TYPE)?)null"

%enddef


// ----------------------------------------------------------------------------
// optional string specialisation
// ----------------------------------------------------------------------------
%define %optional_string()

%naturalvar std::optional<std::string>;

// std::optional<std::string>
%typemap(ctype) std::optional<std::string> "const char *"
%typemap(imtype) std::optional<std::string> "string"
%typemap(cstype) std::optional<std::string> "string"SWIG_STD_OPTIONAL_NULLABLE_TYPE

%typemap(csdirectorin) std::optional<std::string> "$iminput"
%typemap(csdirectorout) std::optional<std::string> "$cscall"

%typemap(in) std::optional<std::string> (std::optional<std::string> var) %{
    $1 = &var;
    var = ($input == nullptr) ? std::nullopt : std::optional<std::string> { (char const*) $input };
%}
%typemap(out) std::optional<std::string> %{ 
    $result = SWIG_csharp_string_callback($1.has_value() ? $1.value().c_str() : nullptr );
%}

%typemap(csin) std::optional<std::string> "$csinput"
%typemap(csout, excode=SWIGEXCODE) std::optional<std::string> {
    string ret = $imcall;$excode
    return ret;
  }

%typemap(typecheck) std::optional<std::string> = char *;


// std::optional<std::string> const &
%typemap(ctype) std::optional<std::string> const & "const char *"
%typemap(imtype) std::optional<std::string> const & "string"
%typemap(cstype) std::optional<std::string> const & "string"SWIG_STD_OPTIONAL_NULLABLE_TYPE

%typemap(csdirectorin) std::optional<std::string> const & "$iminput"
%typemap(csdirectorout) std::optional<std::string> const & "$cscall"

%typemap(in) std::optional<std::string> const & (std::optional<std::string> var) %{
    $1 = &var;
    var = ($input == nullptr) ? std::nullopt : std::optional<std::string> { (char const*) $input };
%}
%typemap(out) std::optional<std::string> const & %{ 
    $result = SWIG_csharp_string_callback($1->has_value() ? $1->value().c_str() : nullptr); 
%}

%typemap(directorin) std::optional<std::string> const & %{ 
    $input = $1.has_value() ? $1.value().c_str() : nullptr;
%}
%typemap(directorout) std::optional<std::string> const & %{
    #error not implemented
%}

%typemap(csin) std::optional<std::string> const & "$csinput"
%typemap(csout, excode=SWIGEXCODE) std::optional<std::string> const & {
    string ret = $imcall;$excode
    return ret;
  }

%typemap(typecheck) std::optional<std::string> const & = char *;


// std::optional<std::string> * (used to map C# properties)
%typemap(ctype) std::optional<std::string> * "const char *"
%typemap(imtype) std::optional<std::string> * "string"
%typemap(cstype) std::optional<std::string> * "string"SWIG_STD_OPTIONAL_NULLABLE_TYPE

%typemap(csdirectorin) std::optional<std::string> * "$iminput"
%typemap(csdirectorout) std::optional<std::string> * "$cscall"

%typemap(in) std::optional<std::string> * (std::optional<std::string> var) %{
    $1 = &var;
    var = ($input == nullptr) ? std::nullopt : std::optional<std::string> { (char const*) $input };
%}
%typemap(out) std::optional<std::string> * %{ 
    $result = SWIG_csharp_string_callback($1->has_value() ? $1->value().c_str() : nullptr); 
%}

%typemap(csvarin, excode=SWIGEXCODE2) std::optional<std::string> * %{
    set {
      $imcall;$excode
    } %}
%typemap(csvarout, excode=SWIGEXCODE2) std::optional<std::string> * %{
    get {
      string ret = $imcall;$excode
      return ret;
    } %}

%typemap(csin) std::optional<std::string> * "$csinput"
%typemap(csout, excode=SWIGEXCODE) std::optional<std::string> * {
    string ret = $imcall;$excode
    return ret;
  }

%enddef

#if defined(SWIG_STD_OPTIONAL_DEFAULT_TYPES)
  %optional_arithmetic(bool, OptBool)
  %optional_arithmetic(std::int8_t, OptSignedByte)
  %optional_arithmetic(std::int16_t, OptSignedShort)
  %optional_arithmetic(std::int32_t, OptSignedInt)
  %optional_arithmetic(std::uint8_t, OptUnsignedByte)
  %optional_arithmetic(std::uint16_t, OptUnsignedShort)
  %optional_arithmetic(std::uint32_t, OptUnsignedInt)

  %optional_arithmetic(std::int64_t, OptSignedLong)
  %optional_arithmetic(std::uint64_t, OptUnsignedLong)

  %optional_arithmetic(float, OptFloat)
  %optional_arithmetic(double, OptDouble)

  %optional_string()
#endif
