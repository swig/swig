// Purpose: SWIG interface file for std::optional<> type.
//
// This file defines macros for handling optional types in SWIG.
//
// ============================================================================
// USAGE
// ============================================================================
//
// 1. %optional(TYPE):
//    This macro is used to bind structs and classes to C# nullable reference types.
//    When SWIG_STD_OPTIONAL_USE_NULLABLE_REFERENCE_TYPES is defined, the type will be
//    treated as a C# nullable reference type (TYPE?).
//    Example:
//      %optional(MyStruct)
//    This will generate code to handle std::optional<MyStruct>.
//
// 2. %optional_primitive(TYPE):
//    This macro is used to bind primitive/arithmetic types (int, float, double, etc.)
//    to C# nullable value types (T?).
//    This macro uses IntPtr and Marshal for conversions.
//    Example:
//      %optional_primitive(double)
//    This will generate code to handle std::optional<double> as double? in C#.
//
// 3. %optional_enum_xxx(TYPE):
//    These macros are used for C++ enum types. Use the appropriate macro based on
//    the enum's underlying type:
//      %optional_enum_int8(TYPE)   - for enums with std::int8_t underlying type
//      %optional_enum_uint8(TYPE)  - for enums with std::uint8_t underlying type
//      %optional_enum_int16(TYPE)  - for enums with std::int16_t underlying type
//      %optional_enum_uint16(TYPE) - for enums with std::uint16_t underlying type
//      %optional_enum_int32(TYPE)  - for enums with std::int32_t underlying type (default)
//      %optional_enum_uint32(TYPE) - for enums with std::uint32_t underlying type
//      %optional_enum_int64(TYPE)  - for enums with std::int64_t underlying type
//      %optional_enum_uint64(TYPE) - for enums with std::uint64_t underlying type
//    Example:
//      %optional_enum_uint8(MyByteEnum)
//      %optional_enum_int32(MyIntEnum)
//
// 4. %optional_string():
//    This macro is used specifically for std::optional<std::string>.
//    Example:
//      %optional_string()
//    This will generate code to handle std::optional<std::string> as string? in C#.
//
// ============================================================================
// CONFIGURATION MACROS
// ============================================================================
//
// SWIG_STD_OPTIONAL_DEFAULT_TYPES:
//    When defined, automatically sets up typemaps for common types:
//    - bool, int8_t, int16_t, int32_t, int64_t and unsigned variants
//    - float, double
//    - std::string
//
// SWIG_STD_OPTIONAL_USE_NULLABLE_REFERENCE_TYPES:
//    When defined, enables C# 8.0+ nullable reference types support for classes.
//    The module should use: %module(csbegin="#nullable enable\n") MyModule
//

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

// Helper class for storing nullable value type returns from director methods
// This class provides thread-safe storage for the return value
%pragma(csharp) imclasscode=%{
  internal static class SwigOptionalValueHelper<T> where T : struct {
    [global::System.ThreadStatic]
    private static global::System.IntPtr storedPtr;

    public static global::System.IntPtr Store(T? value) {
      if (!value.HasValue) {
        return global::System.IntPtr.Zero;
      }
      // Free previous allocation if any
      if (storedPtr != global::System.IntPtr.Zero) {
        global::System.Runtime.InteropServices.Marshal.FreeHGlobal(storedPtr);
      }
      storedPtr = global::System.Runtime.InteropServices.Marshal.AllocHGlobal(
        global::System.Runtime.InteropServices.Marshal.SizeOf<T>());
      global::System.Runtime.InteropServices.Marshal.StructureToPtr(value.Value, storedPtr, false);
      return storedPtr;
    }
  }

  // Helper class for storing enum optional returns from director methods
  // Uses primitive type marshaling since enums cannot be marshaled as structures
  internal static class SwigOptionalEnumHelper {
    [global::System.ThreadStatic]
    private static global::System.IntPtr storedPtr;

    public static global::System.IntPtr Store<T>(T? value) where T : struct {
      if (!value.HasValue) {
        return global::System.IntPtr.Zero;
      }
      // Free previous allocation if any
      if (storedPtr != global::System.IntPtr.Zero) {
        global::System.Runtime.InteropServices.Marshal.FreeHGlobal(storedPtr);
      }
      int size = global::System.Runtime.InteropServices.Marshal.SizeOf(typeof(T));
      storedPtr = global::System.Runtime.InteropServices.Marshal.AllocHGlobal(size);
      // Use unchecked conversions to write the underlying value
      if (size == 1) {
        global::System.Runtime.InteropServices.Marshal.WriteByte(storedPtr, global::System.Convert.ToByte(value.Value));
      } else if (size == 2) {
        global::System.Runtime.InteropServices.Marshal.WriteInt16(storedPtr, global::System.Convert.ToInt16(value.Value));
      } else if (size == 4) {
        global::System.Runtime.InteropServices.Marshal.WriteInt32(storedPtr, global::System.Convert.ToInt32(value.Value));
      } else if (size == 8) {
        global::System.Runtime.InteropServices.Marshal.WriteInt64(storedPtr, global::System.Convert.ToInt64(value.Value));
      }
      return storedPtr;
    }
  }
%}

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

// ============================================================================
// %optional(TYPE) - For classes and structs
// ============================================================================
%define %optional(TYPE)

%naturalvar std::optional< TYPE >;

%typemap(cstype) std::optional< TYPE >, std::optional< TYPE > const & "$typemap(cstype, TYPE)"SWIG_STD_OPTIONAL_NULLABLE_TYPE

%typemap(csin) std::optional< TYPE >, std::optional< TYPE > const & "$typemap(cstype, TYPE).getCPtr($csinput)"

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
    } else {
      $1 = std::nullopt;
    }
%}

%typemap(out) std::optional< TYPE > const & %{
    $result = $1->has_value() ? &$1->value() : nullptr;
%}

%typemap(out) std::optional< TYPE > %{
    $result = $1.has_value() ? new TYPE { $1.value() } : nullptr;
%}

// Member variable accessors for value types
%typemap(csvarin, excode=SWIGEXCODE) std::optional< TYPE >, std::optional< TYPE > const & %{
    set {
      $imcall;$excode
    }%}
%typemap(csvarout, excode=SWIGEXCODE2) std::optional< TYPE >, std::optional< TYPE > const & %{
    get {
        var instance = $imcall;
        var ret = (instance != global::System.IntPtr.Zero) ? new $typemap(cstype, TYPE)(instance, $owner) : null;$excode
        return ret;
    }%}

// Member variable accessors for pointer types
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

// Director typemaps
%typemap(directorin) std::optional< TYPE >, std::optional< TYPE > const & %{
    $input = $1.has_value() ? const_cast<TYPE*>(&$1.value()) : nullptr;
%}

// Director input
%typemap(csdirectorin) std::optional< TYPE >, std::optional< TYPE > const & "($iminput != global::System.IntPtr.Zero) ? new $typemap(cstype, TYPE)($iminput, false) : null"

// Director return typemaps (C# to C++)
%typemap(directorout) std::optional< TYPE >, std::optional< TYPE > const & %{
    if ($input != nullptr) {
      $result = *static_cast<TYPE*>($input);
    } else {
      $result = std::nullopt;
    }
%}

// For classes, we return the getCPtr of the returned object, or IntPtr.Zero for null
%typemap(csdirectorout) std::optional< TYPE >, std::optional< TYPE > const &
  "$typemap(cstype, TYPE).getCPtr($cscall).Handle"

// Instantiate the template with empty name to prevent SWIGTYPE generation
%template() std::optional< TYPE >;

%enddef


// ============================================================================
// %optional_primitive(TYPE) - For primitive types with nullable value types
// ============================================================================
%define %optional_primitive(TYPE)

%naturalvar std::optional< TYPE >;

// C# type is the existing cstype for TYPE with ? appended
// isnullablevaluetype attribute tells SWIG to keep the ? in typeof() for director method types
%typemap(cstype, isnullablevaluetype="1") std::optional< TYPE >, std::optional< TYPE > const & "$typemap(cstype, TYPE)?"

// Use void* / IntPtr for P/Invoke
%typemap(ctype) std::optional< TYPE >, std::optional< TYPE > const & "void *"
%typemap(imtype, out="global::System.IntPtr") std::optional< TYPE >, std::optional< TYPE > const & "global::System.IntPtr"

// Convert C# nullable to IntPtr for input
%typemap(csin,
         pre="    global::System.IntPtr opt_$csinput = global::System.IntPtr.Zero;\n    if ($csinput.HasValue) {\n      opt_$csinput = global::System.Runtime.InteropServices.Marshal.AllocHGlobal(global::System.Runtime.InteropServices.Marshal.SizeOf<$typemap(cstype, TYPE)>());\n      global::System.Runtime.InteropServices.Marshal.StructureToPtr($csinput.Value, opt_$csinput, false);\n    }",
         post="\n    if (opt_$csinput != global::System.IntPtr.Zero) {\n      global::System.Runtime.InteropServices.Marshal.FreeHGlobal(opt_$csinput);\n    }"
         ) std::optional< TYPE >, std::optional< TYPE > const& "opt_$csinput"

// Convert IntPtr to C# nullable for output
%typemap(csout, excode=SWIGEXCODE) std::optional< TYPE >, std::optional< TYPE > const & {
    var ptr = $imcall;$excode
    return (ptr != global::System.IntPtr.Zero) ? global::System.Runtime.InteropServices.Marshal.PtrToStructure<$typemap(cstype, TYPE)>(ptr) : ($typemap(cstype, TYPE)?)null;
  }

// C++ input typemaps
%typemap(in) std::optional< TYPE > const & (std::optional< TYPE > var) %{
    $1 = &var;
    var = ($input != nullptr) ? std::optional< TYPE >(*static_cast<TYPE*>($input)) : std::nullopt;
%}

%typemap(in) std::optional< TYPE > %{
    if ($input != nullptr) {
      $1 = *static_cast<TYPE*>($input);
    } else {
      $1 = std::nullopt;
    }
%}

// C++ output typemaps - return pointer to static storage
%typemap(out) std::optional< TYPE > const & %{
    static TYPE $1_static_val;
    if ($1->has_value()) {
      $1_static_val = $1->value();
      $result = &$1_static_val;
    } else {
      $result = nullptr;
    }
%}

%typemap(out) std::optional< TYPE > %{
    static TYPE $1_static_val;
    if ($1.has_value()) {
      $1_static_val = $1.value();
      $result = &$1_static_val;
    } else {
      $result = nullptr;
    }
%}

// Property typemaps
%typemap(csvarin, excode=SWIGEXCODE2) std::optional< TYPE >, std::optional< TYPE > const & %{
    set {
      global::System.IntPtr opt_value = global::System.IntPtr.Zero;
      if (value.HasValue) {
        opt_value = global::System.Runtime.InteropServices.Marshal.AllocHGlobal(global::System.Runtime.InteropServices.Marshal.SizeOf<$typemap(cstype, TYPE)>());
        global::System.Runtime.InteropServices.Marshal.StructureToPtr(value.Value, opt_value, false);
      }
      try {
        $imcall;$excode
      } finally {
        if (opt_value != global::System.IntPtr.Zero) {
          global::System.Runtime.InteropServices.Marshal.FreeHGlobal(opt_value);
        }
      }
    }%}

%typemap(csvarout, excode=SWIGEXCODE2) std::optional< TYPE >, std::optional< TYPE > const & %{
    get {
      var ptr = $imcall;$excode
      return (ptr != global::System.IntPtr.Zero) ? global::System.Runtime.InteropServices.Marshal.PtrToStructure<$typemap(cstype, TYPE)>(ptr) : ($typemap(cstype, TYPE)?)null;
    }%}

// Director typemaps
%typemap(directorin) std::optional< TYPE >, std::optional< TYPE > const & %{
    static TYPE $input_static_val;
    if ($1.has_value()) {
      $input_static_val = $1.value();
      $input = &$input_static_val;
    } else {
      $input = nullptr;
    }
%}

%typemap(csdirectorin) std::optional< TYPE >, std::optional< TYPE > const & "($iminput != global::System.IntPtr.Zero) ? global::System.Runtime.InteropServices.Marshal.PtrToStructure<$typemap(cstype, TYPE)>($iminput) : ($typemap(cstype, TYPE)?)null"

// Director return typemaps (C# to C++)
// The C++ side allocates static storage for the returned value
%typemap(directorout) std::optional< TYPE >, std::optional< TYPE > const & %{
    if ($input != nullptr) {
      $result = *static_cast<TYPE*>($input);
    } else {
      $result = std::nullopt;
    }
%}

// For director return, we need to store the value somewhere. We use a thread-local static in C++ side.
// The C# side just returns the IntPtr - if null, means nullopt; if non-null, points to the value.
%typemap(csdirectorout) std::optional< TYPE >, std::optional< TYPE > const &
  "$imclassname.SwigOptionalValueHelper<$typemap(cstype, TYPE)>.Store($cscall)"

// Pointer typemaps (for struct members)
%typemap(cstype, isnullablevaluetype="1") std::optional< TYPE > *, std::optional< TYPE > const * "$typemap(cstype, TYPE)?"
%typemap(ctype) std::optional< TYPE > *, std::optional< TYPE > const * "void *"
%typemap(imtype, out="global::System.IntPtr") std::optional< TYPE > *, std::optional< TYPE > const * "global::System.IntPtr"

%typemap(csin,
         pre="    global::System.IntPtr opt_$csinput = global::System.IntPtr.Zero;\n    if ($csinput.HasValue) {\n      opt_$csinput = global::System.Runtime.InteropServices.Marshal.AllocHGlobal(global::System.Runtime.InteropServices.Marshal.SizeOf<$typemap(cstype, TYPE)>());\n      global::System.Runtime.InteropServices.Marshal.StructureToPtr($csinput.Value, opt_$csinput, false);\n    }",
         post="\n    if (opt_$csinput != global::System.IntPtr.Zero) {\n      global::System.Runtime.InteropServices.Marshal.FreeHGlobal(opt_$csinput);\n    }"
         ) std::optional< TYPE > *, std::optional< TYPE > const * "opt_$csinput"

%typemap(csvarin, excode=SWIGEXCODE2) std::optional< TYPE > *, std::optional< TYPE > const * %{
    set {
      global::System.IntPtr opt_value = global::System.IntPtr.Zero;
      if (value.HasValue) {
        opt_value = global::System.Runtime.InteropServices.Marshal.AllocHGlobal(global::System.Runtime.InteropServices.Marshal.SizeOf<$typemap(cstype, TYPE)>());
        global::System.Runtime.InteropServices.Marshal.StructureToPtr(value.Value, opt_value, false);
      }
      try {
        $imcall;$excode
      } finally {
        if (opt_value != global::System.IntPtr.Zero) {
          global::System.Runtime.InteropServices.Marshal.FreeHGlobal(opt_value);
        }
      }
    }%}

%typemap(csvarout, excode=SWIGEXCODE2) std::optional< TYPE > *, std::optional< TYPE > const * %{
    get {
      var ptr = $imcall;$excode
      return (ptr != global::System.IntPtr.Zero) ? global::System.Runtime.InteropServices.Marshal.PtrToStructure<$typemap(cstype, TYPE)>(ptr) : ($typemap(cstype, TYPE)?)null;
    }%}

%typemap(in) std::optional< TYPE > * (std::optional< TYPE > var) %{
    $1 = &var;
    var = ($input != nullptr) ? std::optional< TYPE >(*static_cast<TYPE*>($input)) : std::nullopt;
%}

%typemap(out) std::optional< TYPE > * %{
    static TYPE $1_static_val;
    if ($1->has_value()) {
      $1_static_val = $1->value();
      $result = &$1_static_val;
    } else {
      $result = nullptr;
    }
%}

// Instantiate the template with empty name to prevent SWIGTYPE generation
%template() std::optional< TYPE >;

%enddef


// ============================================================================
// %optional_enum(TYPE, UNDERLYING, SIZE, READ_METHOD, WRITE_METHOD) - For enum types
// ============================================================================
// Internal macro - use the convenience macros below instead:
//   %optional_enum_int8(TYPE)  - for enums with std::int8_t underlying type
//   %optional_enum_uint8(TYPE)   - for enums with std::uint8_t underlying type
//   %optional_enum_int16(TYPE)  - for enums with std::int16_t underlying type
//   %optional_enum_uint16(TYPE) - for enums with std::uint16_t underlying type
//   %optional_enum_int32(TYPE)    - for enums with std::int32_t underlying type
//   %optional_enum_uint32(TYPE)   - for enums with std::uint32_t underlying type
//   %optional_enum_int64(TYPE)   - for enums with std::int64_t underlying type
//   %optional_enum_uint64(TYPE)  - for enums with std::uint64_t underlying type

%define %optional_enum(TYPE, UNDERLYING, SIZE, READ_METHOD, WRITE_METHOD)

%naturalvar std::optional< TYPE >;

// C# type is the existing cstype for TYPE with ? appended
// isnullablevaluetype attribute tells SWIG to keep the ? in typeof() for director method types
%typemap(cstype, isnullablevaluetype="1") std::optional< TYPE >, std::optional< TYPE > const & "$typemap(cstype, TYPE)?"

// Use void* / IntPtr for P/Invoke
%typemap(ctype) std::optional< TYPE >, std::optional< TYPE > const & "void *"
%typemap(imtype, out="global::System.IntPtr") std::optional< TYPE >, std::optional< TYPE > const & "global::System.IntPtr"

// Convert C# nullable enum to IntPtr for input - using Marshal methods
%typemap(csin,
         pre="    global::System.IntPtr opt_$csinput = global::System.IntPtr.Zero;\n    if ($csinput.HasValue) {\n      opt_$csinput = global::System.Runtime.InteropServices.Marshal.AllocHGlobal(SIZE);\n      global::System.Runtime.InteropServices.Marshal.WRITE_METHOD(opt_$csinput, (UNDERLYING)$csinput.Value);\n    }",
         post="\n    if (opt_$csinput != global::System.IntPtr.Zero) {\n      global::System.Runtime.InteropServices.Marshal.FreeHGlobal(opt_$csinput);\n    }"
         ) std::optional< TYPE >, std::optional< TYPE > const& "opt_$csinput"

// Convert IntPtr to C# nullable enum for output
%typemap(csout, excode=SWIGEXCODE) std::optional< TYPE >, std::optional< TYPE > const & {
    var ptr = $imcall;$excode
    if (ptr != global::System.IntPtr.Zero) {
      return ($typemap(cstype, TYPE))global::System.Runtime.InteropServices.Marshal.READ_METHOD(ptr);
    }
    return null;
  }

// C++ input typemaps
%typemap(in) std::optional< TYPE > const & (std::optional< TYPE > var) %{
    $1 = &var;
    var = ($input != nullptr) ? std::optional< TYPE >(*static_cast<TYPE*>($input)) : std::nullopt;
%}

%typemap(in) std::optional< TYPE > %{
    if ($input != nullptr) {
      $1 = *static_cast<TYPE*>($input);
    } else {
      $1 = std::nullopt;
    }
%}

// C++ output typemaps - return pointer to static storage
%typemap(out) std::optional< TYPE > const & %{
    static TYPE $1_static_val;
    if ($1->has_value()) {
      $1_static_val = $1->value();
      $result = &$1_static_val;
    } else {
      $result = nullptr;
    }
%}

%typemap(out) std::optional< TYPE > %{
    static TYPE $1_static_val;
    if ($1.has_value()) {
      $1_static_val = $1.value();
      $result = &$1_static_val;
    } else {
      $result = nullptr;
    }
%}

// Property typemaps
%typemap(csvarin, excode=SWIGEXCODE2) std::optional< TYPE >, std::optional< TYPE > const & %{
    set {
      global::System.IntPtr opt_value = global::System.IntPtr.Zero;
      if (value.HasValue) {
        opt_value = global::System.Runtime.InteropServices.Marshal.AllocHGlobal(SIZE);
        global::System.Runtime.InteropServices.Marshal.WRITE_METHOD(opt_value, (UNDERLYING)value.Value);
      }
      try {
        $imcall;$excode
      } finally {
        if (opt_value != global::System.IntPtr.Zero) {
          global::System.Runtime.InteropServices.Marshal.FreeHGlobal(opt_value);
        }
      }
    }%}

%typemap(csvarout, excode=SWIGEXCODE2) std::optional< TYPE >, std::optional< TYPE > const & %{
    get {
      var ptr = $imcall;$excode
      if (ptr != global::System.IntPtr.Zero) {
        return ($typemap(cstype, TYPE))global::System.Runtime.InteropServices.Marshal.READ_METHOD(ptr);
      }
      return null;
    }%}

// Director typemaps
%typemap(directorin) std::optional< TYPE >, std::optional< TYPE > const & %{
    static TYPE $input_static_val;
    if ($1.has_value()) {
      $input_static_val = $1.value();
      $input = &$input_static_val;
    } else {
      $input = nullptr;
    }
%}

%typemap(csdirectorin) std::optional< TYPE >, std::optional< TYPE > const & "($iminput != global::System.IntPtr.Zero) ? ($typemap(cstype, TYPE))global::System.Runtime.InteropServices.Marshal.READ_METHOD($iminput) : ($typemap(cstype, TYPE)?)null"

// Director return typemaps (C# to C++)
%typemap(directorout) std::optional< TYPE >, std::optional< TYPE > const & %{
    if ($input != nullptr) {
      $result = *static_cast<TYPE*>($input);
    } else {
      $result = std::nullopt;
    }
%}

// For enums, we need to use specific Marshal methods instead of the generic helper
// because enums cannot be marshaled as unmanaged structures
%typemap(csdirectorout) std::optional< TYPE >, std::optional< TYPE > const &
  "$imclassname.SwigOptionalEnumHelper.Store<UNDERLYING>(($cscall).HasValue ? (UNDERLYING)($cscall).Value : (UNDERLYING?)null)"

// Pointer typemaps (for struct members)
%typemap(cstype, isnullablevaluetype="1") std::optional< TYPE > *, std::optional< TYPE > const * "$typemap(cstype, TYPE)?"
%typemap(ctype) std::optional< TYPE > *, std::optional< TYPE > const * "void *"
%typemap(imtype, out="global::System.IntPtr") std::optional< TYPE > *, std::optional< TYPE > const * "global::System.IntPtr"

%typemap(csin,
         pre="    global::System.IntPtr opt_$csinput = global::System.IntPtr.Zero;\n    if ($csinput.HasValue) {\n      opt_$csinput = global::System.Runtime.InteropServices.Marshal.AllocHGlobal(SIZE);\n      global::System.Runtime.InteropServices.Marshal.WRITE_METHOD(opt_$csinput, (UNDERLYING)$csinput.Value);\n    }",
         post="\n    if (opt_$csinput != global::System.IntPtr.Zero) {\n      global::System.Runtime.InteropServices.Marshal.FreeHGlobal(opt_$csinput);\n    }"
         ) std::optional< TYPE > *, std::optional< TYPE > const * "opt_$csinput"

%typemap(csvarin, excode=SWIGEXCODE2) std::optional< TYPE > *, std::optional< TYPE > const * %{
    set {
      global::System.IntPtr opt_value = global::System.IntPtr.Zero;
      if (value.HasValue) {
        opt_value = global::System.Runtime.InteropServices.Marshal.AllocHGlobal(SIZE);
        global::System.Runtime.InteropServices.Marshal.WRITE_METHOD(opt_value, (UNDERLYING)value.Value);
      }
      try {
        $imcall;$excode
      } finally {
        if (opt_value != global::System.IntPtr.Zero) {
          global::System.Runtime.InteropServices.Marshal.FreeHGlobal(opt_value);
        }
      }
    }%}

%typemap(csvarout, excode=SWIGEXCODE2) std::optional< TYPE > *, std::optional< TYPE > const * %{
    get {
      var ptr = $imcall;$excode
      if (ptr != global::System.IntPtr.Zero) {
        return ($typemap(cstype, TYPE))global::System.Runtime.InteropServices.Marshal.READ_METHOD(ptr);
      }
      return null;
    }%}

%typemap(in) std::optional< TYPE > * (std::optional< TYPE > var) %{
    $1 = &var;
    var = ($input != nullptr) ? std::optional< TYPE >(*static_cast<TYPE*>($input)) : std::nullopt;
%}

%typemap(out) std::optional< TYPE > * %{
    static TYPE $1_static_val;
    if ($1->has_value()) {
      $1_static_val = $1->value();
      $result = &$1_static_val;
    } else {
      $result = nullptr;
    }
%}

// Instantiate the template with empty name to prevent SWIGTYPE generation
%template() std::optional< TYPE >;

%enddef

// Convenience macros for different enum underlying types
%define %optional_enum_int8(TYPE)
%optional_enum(TYPE, sbyte, 1, ReadByte, WriteByte)
%enddef

%define %optional_enum_uint8(TYPE)
%optional_enum(TYPE, byte, 1, ReadByte, WriteByte)
%enddef

%define %optional_enum_int16(TYPE)
%optional_enum(TYPE, short, 2, ReadInt16, WriteInt16)
%enddef

%define %optional_enum_uint16(TYPE)
%optional_enum(TYPE, ushort, 2, ReadInt16, WriteInt16)
%enddef

%define %optional_enum_int32(TYPE)
%optional_enum(TYPE, int, 4, ReadInt32, WriteInt32)
%enddef

%define %optional_enum_uint32(TYPE)
%optional_enum(TYPE, uint, 4, ReadInt32, WriteInt32)
%enddef

%define %optional_enum_int64(TYPE)
%optional_enum(TYPE, long, 8, ReadInt64, WriteInt64)
%enddef

%define %optional_enum_uint64(TYPE)
%optional_enum(TYPE, ulong, 8, ReadInt64, WriteInt64)
%enddef


// ============================================================================
// %optional_string - For std::optional<std::string>
// ============================================================================
%define %optional_string()

%naturalvar std::optional<std::string>;

// std::optional<std::string>
%typemap(ctype) std::optional<std::string> "const char *"
%typemap(imtype) std::optional<std::string> "string"
%typemap(cstype) std::optional<std::string> "string"SWIG_STD_OPTIONAL_NULLABLE_TYPE

%typemap(directorin) std::optional<std::string> %{
    $input = $1.has_value() ? $1.value().c_str() : nullptr;
%}
%typemap(directorout) std::optional<std::string> %{
    $result = ($input != nullptr) ? std::optional<std::string>{(const char*)$input} : std::nullopt;
%}
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

%typemap(directorin) std::optional<std::string> const & %{
    $input = $1.has_value() ? $1.value().c_str() : nullptr;
%}
%typemap(directorout) std::optional<std::string> const & %{
    $result = ($input != nullptr) ? std::optional<std::string>{(const char*)$input} : std::nullopt;
%}
%typemap(csdirectorin) std::optional<std::string> const & "$iminput"
%typemap(csdirectorout) std::optional<std::string> const & "$cscall"

%typemap(in) std::optional<std::string> const & (std::optional<std::string> var) %{
    $1 = &var;
    var = ($input == nullptr) ? std::nullopt : std::optional<std::string> { (char const*) $input };
%}
%typemap(out) std::optional<std::string> const & %{
    $result = SWIG_csharp_string_callback($1->has_value() ? $1->value().c_str() : nullptr);
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


// ============================================================================
// Default types (when SWIG_STD_OPTIONAL_DEFAULT_TYPES is defined)
// ============================================================================
#if defined(SWIG_STD_OPTIONAL_DEFAULT_TYPES)

  // Use %optional_primitive for all primitive types
  %optional_primitive(bool)
  %optional_primitive(std::int8_t)
  %optional_primitive(std::int16_t)
  %optional_primitive(std::int32_t)
  %optional_primitive(std::uint8_t)
  %optional_primitive(std::uint16_t)
  %optional_primitive(std::uint32_t)
  %optional_primitive(std::int64_t)
  %optional_primitive(std::uint64_t)
  %optional_primitive(float)
  %optional_primitive(double)

  // Also add native C/C++ types (int, short, long, etc.) that may differ from stdint types
  %optional_primitive(signed char)
  %optional_primitive(unsigned char)
  %optional_primitive(short)
  %optional_primitive(unsigned short)
  %optional_primitive(int)
  %optional_primitive(unsigned int)
  %optional_primitive(long)
  %optional_primitive(unsigned long)
  %optional_primitive(long long)
  %optional_primitive(unsigned long long)

  %optional_string()

#endif // SWIG_STD_OPTIONAL_DEFAULT_TYPES
