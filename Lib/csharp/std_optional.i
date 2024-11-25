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

%typemap(cstype) std::optional< TYPE >, std::optional< TYPE > const & "$typemap(cstype, TYPE)"


// This typemap is used to convert C# nullable type to the handler passed to the
// intermediate native wrapper function.
%typemap(csin) std::optional< TYPE >, std::optional< TYPE > const & "$typemap(cstype, TYPE).getCPtr($csinput)"

// This is used for functions returning optional values.
%typemap(csout, excode=SWIGEXCODE) std::optional< TYPE >, std::optional< TYPE > const & {
    var instance = $imcall;
    var ret = (instance != global::System.IntPtr.Zero) ? new $typemap(cstype, TYPE)(instance, $owner) : null;$excode
    return ret;
  }

%typemap(in) std::optional< TYPE >, std::optional< TYPE > const & (std::optional< TYPE > var) %{
    $1 = &var;
    var = ($input == nullptr) ? std::nullopt : std::optional< TYPE > { *(TYPE*) $input };
%}
%typemap(out) std::optional< TYPE > const & %{ 
    $result = $1->has_value() ? new TYPE { $1->value() } : nullptr;
%}

%typemap(out) std::optional< TYPE > %{ 
    $result = $1.has_value() ? new TYPE { $1.value() } : nullptr;
%}


// This code is used for the optional-valued properties in C#.
%typemap(cstype) std::optional< TYPE > *, std::optional< TYPE > const * "$typemap(cstype, TYPE)"
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
    $result = $1->has_value() ? new TYPE { $1->value() } : nullptr;
%}


%typemap(csdirectorin) std::optional< TYPE >, std::optional< TYPE > const & "($iminput != global::System.IntPtr.Zero) ? new $typemap(cstype, TYPE)($iminput, true) : null"


%enddef


// ----------------------------------------------------------------------------
// optional arithmetic specialisation
// ----------------------------------------------------------------------------
%define %optional_arithmetic(TYPE, NAME)
 
// The std::optional<> specializations themselves are only going to be used
// inside our own code, the user will deal with either T? or T, depending on
// whether T is a value or a reference type, so make them private to our own
// assembly.
%typemap(csclassmodifiers) std::optional< TYPE > "internal class"

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
%typemap(cstype) std::optional<std::string> "string"

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
%typemap(cstype) std::optional<std::string> const & "string"

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
%typemap(cstype) std::optional<std::string> * "string"

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


#if !defined(SWIG_NO_STD_OPTIONAL_DEFAULT_TYPES)
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
