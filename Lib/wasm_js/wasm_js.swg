/* wasm_js.swg
 *
 * Typemap library for the -wasm-js target. Uses SWIG's STANDARD typemap
 * names (in / out / freearg / ctype) with a JavaScript handle ABI for
 * wrapped objects, strings and containers.
 *
 * Each wrapped function emits a wasm-exported C function with the shape:
 *
 *    EMSCRIPTEN_KEEPALIVE <ret_ctype> swig_foo(<in_ctype>0 obj0, <in_ctype>1 obj1, ...) {
 *      T0 arg1; T1 arg2; ...;     // C++ locals
 *      <in typemap body>:         // populates argN from objN
 *        arg1 = swig_wasmjs::borrowed_value(obj0).as<std::string>();
 *      ResultType result;
 *      result = call(arg1, arg2, ...);
 *      <out typemap body>:        // converts result -> _outv
 *        _outv = emscripten::val(result).release_ownership();
 *      <freearg blocks>           // cleanup, if any
 *      return _outv;
 *    }
 *
 * Placeholders SWIG auto-substitutes during Swig_typemap_attach_parms:
 *   $1, $1_type, $1_ltype, $1_name      <- the C++ local (lname=arg<N>)
 *   $argnum                             <- parameter index
 * The wasm_js module post-substitutes:
 *   $input    <- C-API input variable (e.g. "obj0")
 *   $result   <- C-API output variable (e.g. "_outv")
 *   $call     <- inside JS-side typemaps, the wasm call expression
 *
 * The JS-side conversions (jsin/jsarg/jsfree/jsout) live below in
 * wasm_js-specific typemap names; SWIG has no standard equivalent
 * because the JS proxy is unique to this backend.
 */

%insert("header") %{
#include <emscripten.h>
#include <cstdlib>
#include <cstring>
#include <memory>
#include <string>
%}

/* SWIG-level director-fail macros.  Expanded by SWIG into the typemap */
/* body when a 'directorin' / 'directorout' body uses '%dirout_fail(...)'. */
/* Matches the definitions in '<typemaps/swigtypemaps.swg>' (which we don't */
/* %include because it would also drag in generic SWIGTYPE directorin/out */
/* bodies targeting mxArray/PyObject signatures).  Calls 'SWIG_DirOutFail' / */
/* 'SWIG_ErrorType' from 'Lib/wasm_js/wasm_jsrun.swg'. */
#define %outfail_fmt(_type)            "in output value of type '"_type"'"
#define %outnullref_fmt(_type)         "null reference " %outfail_fmt(_type)
#define %default_code(code)            SWIG_ArgError(code)
#define %dirout_fail(code, type)       SWIG_DirOutFail(%default_code(code), %outfail_fmt(type))
#define %dirout_nullref(type)          SWIG_DirOutFail(SWIG_NullReferenceError, %outnullref_fmt(type))

/* SWIG_ArgError default: identity passthrough (matches the matlab/python pattern */
/* when no per-arg numbering is needed).  Wrap in #ifndef so user .i files can */
/* override. */
%insert("header") %{
#ifndef SWIG_ArgError
#define SWIG_ArgError(r)   (r)
#endif
%}

/* Pull in the SWIG runtime: swigrun.swg (swig_type_info etc.) + */
/* swigerrors.swg + wasm_jsrun.swg (SWIG_ConvertPtr / SWIG_NewPointerObj */
/* for checked proxy conversion).  The runtime block precedes wrappers */
/* in wasm_js.cxx::top(). */
%include <wasm_jsruntime.swg>

/* Argout support: %append_output is invoked from 'argout' typemap bodies */

/* outputs into a fixed-size local array '_argouts[]' declared by the */
/* codegen in wasm_js.cxx::cpp_call_body; the wrapper packs them into */
/* the return.  Single-output case: wrapper directly returns '_argouts[0]' */
/* as 'void*'.  Multi-output: wrapper returns a heap-allocated 'void**'. */
%define %append_output(X)
_argouts[_argout_idx++] = (void*)(X);
%enddef

/* %stub_* macros (python-target's stub-emission primitives) declared as */
/* no-ops under -wasm-js -- the auto-generator in wasm_js.cxx picks */
/* up 'pystub_in'/'pystub_out' typemap attrs instead.  Loaded */

/* don't error out. */
%include <wasm_jsuserdir.swg>

/* %jscode -- target-language code-injection alias, mirroring */
/* '%pythoncode' / '%matlabcode'.  Routes to the global %insert("js") */
/* slot today; see wasm_js.cxx's TODO about wiring it inside %extend */
/* blocks so a future '%extend Foo { %jscode %{ ... %} }' lands in the */
/* emitted class body.  For now the syntactic alias still helps users */
/* 'grep' and conveys intent at the .i level. */
#define %jscode  %insert("js")

/* Pull in fragment-name machinery and primitive AsVal/From stubs so that */

/* etc. find what they expect. */
%include <wasm_jsprimtypes.swg>

/* ============================================================================ */
/* std::string */
/* ============================================================================ */

%typemap(ctype) std::string, const std::string&, std::string& "EM_VAL"
%typemap(in, tsstub_in="string") std::string {
  emscripten::val value = swig_wasmjs::borrowed_value($input);
  if (value.typeOf().as<std::string>() != "string")
    SWIG_exception_fail(SWIG_TypeError, "Expected a string");
  $1 = value.as<std::string>();
}
%typemap(in, tsstub_in="string") const std::string& (std::string temporary), std::string& (std::string temporary) {
  emscripten::val value = swig_wasmjs::borrowed_value($input);
  if (value.typeOf().as<std::string>() != "string")
    SWIG_exception_fail(SWIG_TypeError, "Expected a string");
  temporary = value.as<std::string>();
  $1 = &temporary;
}
%typemap(out, tsstub_out="string") std::string {
  $result = emscripten::val($1).release_ownership();
}
%typemap(out, tsstub_out="string") const std::string&, std::string& {
  $result = emscripten::val(*$1).release_ownership();
}
%typemap(jsarg) std::string, const std::string&, std::string& "__unwrap($input)"
%typemap(jsout) std::string, const std::string&, std::string& "__from_handle($call)"

/* ============================================================================ */
/* bool — round-trip through int for clean 0/1 across the wasm boundary */
/* ============================================================================ */

%typemap(ctype) bool "int"
%typemap(in)    bool %{ $1 = ($input) ? true : false; %}
%typemap(out)   bool %{ $result = ($1) ? 1 : 0; %}
%typemap(jsout) bool "(!!($call))"

/* ============================================================================ */

/* Optional bridge for interfaces using explicit vector proxy conversions.
   Native arrays are copied into temporary proxies and cleaned after the call. */
%define %wasm_vec(T, NAME)
%typemap(jsin) std::vector<T>, const std::vector<T>&, std::vector<T>& %{
      let __vp$argnum = $input;
      let __vown$argnum = false;
      if (Array.isArray($input)) {
        __vp$argnum = new NAME();
        __vown$argnum = true;
        try {
          for (const __x of $input) __vp$argnum.push_back(__x);
        } catch (__error) {
          __vp$argnum.delete();
          __vown$argnum = false;
          throw __error;
        }
      }
%}
%typemap(jsarg) std::vector<T>, const std::vector<T>&, std::vector<T>& "__unwrap(__vp$argnum)"
%typemap(jsfree) std::vector<T>, const std::vector<T>&, std::vector<T>& %{
      if (__vown$argnum && __vp$argnum.delete) __vp$argnum.delete();
%}
%typemap(jsout) std::vector<T>, const std::vector<T>&, std::vector<T>&
"__vec_to_arr(__from_handle($call))"

%enddef

/* ============================================================================ */
/* Director (C++ <-> JS) typemaps for primitives. */
/* ============================================================================ */
/*  */
/* Wire contract enforced by wasm_js.cxx::classDirectorMethod: */
/*  */
/* directorin body  : ASSIGNS to '$input' (an 'EM_VAL' local declared by */
/* the language module) from '$1' (the C++ value). */
/* Produce the EM_VAL via 'emscripten::val::release_ownership()'. */
/*  */
/* directorout body : READS '$input' (an 'EM_VAL' released from the */
/* JS return val) and ASSIGNS '$result' (a C++ local */
/* declared by the language module via SwigType_lstr). */
/* Wrap with 'emscripten::val::take_ownership($input)' */
/* to operate on it as an emscripten::val. */
/*  */

/* proper proxy class instances (via M.__wrap_<C>) instead of raw {_ptr} */
/* carriers. */

%typemap(directorin) bool %{
  $input = emscripten::val(static_cast<bool>($1)).release_ownership();
%}
%typemap(directorout) bool %{
  $result = emscripten::val::take_ownership($input).as<bool>();
%}

%typemap(directorin) int, long, unsigned int, unsigned long %{
  $input = emscripten::val(static_cast<double>($1)).release_ownership();
%}
%typemap(directorin) long long, unsigned long long %{
  $input = emscripten::val($1).release_ownership();
%}
/* JS callers may return either a Number (5) or a BigInt (5n) for */
/* integer-typed virtuals.  Probe typeOf and dispatch -- embind rejects */
/* mismatched wire types if we pick the wrong one. */
%typemap(directorout) int, long, long long, unsigned int, unsigned long, unsigned long long %{
  {
    emscripten::val __v = emscripten::val::take_ownership($input);
    if (__v.typeOf().as<std::string>() == "bigint") {
      $result = static_cast<$1_ltype>(__v.as<long long>());
    } else {
      $result = static_cast<$1_ltype>(__v.as<double>());
    }
  }
%}
%typemap(directorin) std::string, const std::string& %{
  $input = emscripten::val(std::string($1)).release_ownership();
%}
%typemap(directorout) std::string %{
  $result = emscripten::val::take_ownership($input).as<std::string>();
%}

/* Wrapped class pointers use JavaScript value handles at the wasm boundary. */
%typemap(ctype) SWIGTYPE *, SWIGTYPE & "EM_VAL"
%typemap(in, tsstub_proxy="1") SWIGTYPE & {
  void *pointer = 0;
  if (!SWIG_IsOK(SWIG_ConvertPtr($input, &pointer, $descriptor, 0))) {
    SWIG_exception_fail(SWIG_TypeError, "Incompatible wrapped object");
  }
  $1 = ($1_ltype)pointer;
}
%typemap(out, tsstub_proxy="1") SWIGTYPE & {
  $result = SWIG_NewPointerObj((void *)$1, $descriptor, $owner);
}
%typemap(in, tsstub_proxy="1", tsstub_nullable="1") SWIGTYPE * {
  emscripten::val value = swig_wasmjs::borrowed_value($input);
  void *pointer = 0;
  if (!value.isNull() && !SWIG_IsOK(SWIG_ConvertPtr($input, &pointer, $descriptor, 0)))
    SWIG_exception_fail(SWIG_TypeError, "Incompatible wrapped pointer");
  $1 = ($1_ltype)pointer;
}
%typemap(out, tsstub_proxy="1", tsstub_nullable="1") SWIGTYPE * {
  $result = SWIG_NewPointerObj((void *)$1, $descriptor, $owner);
}
%typemap(typecheck, precedence=SWIG_TYPECHECK_POINTER) SWIGTYPE * {
  emscripten::val value = swig_wasmjs::borrowed_value($input);
  void *pointer = 0;
  $1 = value.isNull() || SWIG_IsOK(SWIG_ConvertPtr($input, &pointer, $descriptor, 0));
}
%typemap(typecheck, precedence=SWIG_TYPECHECK_POINTER) SWIGTYPE & {
  void *pointer = 0;
  $1 = SWIG_IsOK(SWIG_ConvertPtr($input, &pointer, $descriptor, 0)) && pointer;
}
%typemap(jsarg) SWIGTYPE *, SWIGTYPE & "__unwrap($input)"
%typemap(jsout) SWIGTYPE *, SWIGTYPE & "__from_handle($call)"

/* Class values cross the wasm ABI as handles, never native C++ objects. */
%typemap(ctype) SWIGTYPE "EM_VAL"
%typemap(in, tsstub_proxy="1") SWIGTYPE {
  void *pointer = 0;
  if (!SWIG_IsOK(SWIG_ConvertPtr($input, &pointer, $&descriptor, 0)) || !pointer) {
    SWIG_exception_fail(SWIG_TypeError, "Incompatible wrapped value");
  }
  $1 = *($&1_ltype)pointer;
}
%typemap(out, tsstub_proxy="1") SWIGTYPE {
  swig_type_info *descriptor = $&descriptor;
  if (!descriptor || !descriptor->clientdata)
    SWIG_exception_fail(SWIG_TypeError, "Cannot return an unregistered class by value");
  std::unique_ptr<$1_ltype> copy(new $1_ltype($1));
  $result = SWIG_NewPointerObj(copy.get(), descriptor, SWIG_POINTER_OWN);
  copy.release();
}
%typemap(jsarg) SWIGTYPE "__unwrap($input)"
%typemap(jsout) SWIGTYPE "__from_handle($call)"

/* Keep scalar values on the native wasm ABI instead of the class fallback. */
%define %wasm_scalar_value(TYPE)
%typemap(ctype) TYPE "TYPE"
%typemap(in) TYPE { $1 = $input; }
%typemap(out) TYPE { $result = $1; }
%typemap(jsarg, wasmjs_scalar="1") TYPE "$input"
%typemap(jsout) TYPE "$call"
%enddef
%wasm_scalar_value(char)
%wasm_scalar_value(signed char)
%wasm_scalar_value(unsigned char)
%wasm_scalar_value(short)
%wasm_scalar_value(unsigned short)
%wasm_scalar_value(int)
%wasm_scalar_value(unsigned int)
%wasm_scalar_value(long)
%wasm_scalar_value(unsigned long)
%wasm_scalar_value(long long)
%wasm_scalar_value(unsigned long long)
%wasm_scalar_value(float)
%wasm_scalar_value(double)
%typemap(ctype) enum SWIGTYPE, const enum SWIGTYPE & "EM_VAL"
%typemap(in) enum SWIGTYPE {
  if (!swig_wasmjs::enum_conversion< $1_ltype >::read(swig_wasmjs::borrowed_value($input), &$1))
    SWIG_exception_fail(SWIG_TypeError, "Invalid enum value or underlying integer range");
}
%typemap(in) const enum SWIGTYPE & ($*1_ltype temporary) {
  if (!swig_wasmjs::enum_conversion< $*1_ltype >::read(swig_wasmjs::borrowed_value($input), &temporary))
    SWIG_exception_fail(SWIG_TypeError, "Invalid enum value or underlying integer range");
  $1 = &temporary;
}
%typemap(out) enum SWIGTYPE {
  $result = swig_wasmjs::enum_conversion< $1_ltype >::write($1).release_ownership();
}
%typemap(out) const enum SWIGTYPE & {
  $result = swig_wasmjs::enum_conversion< $*1_ltype >::write(*$1).release_ownership();
}
%typemap(jsarg) enum SWIGTYPE, const enum SWIGTYPE & "__unwrap($input)"
%typemap(jsout) enum SWIGTYPE, const enum SWIGTYPE & "__from_handle($call)"
%typemap(jsout) void "$call"
%typemap(jsarg, wasmjs_scalar="1") bool "$input"

%define %wasm_integer_check(TYPE, LOW, HIGH)
%typemap(jstypecheck, wasmjs_scalar="1") TYPE "Number.isInteger($input) && $input >= LOW && $input <= HIGH"
%typemap(jsin, wasmjs_scalar="1") TYPE {
  if (!Number.isInteger($input) || $input < LOW || $input > HIGH)
    throw new TypeError("Expected an integer in the native type's range");
}
%enddef
%wasm_integer_check(char, -128, 127)
%wasm_integer_check(signed char, -128, 127)
%wasm_integer_check(unsigned char, 0, 255)
%wasm_integer_check(short, -32768, 32767)
%wasm_integer_check(unsigned short, 0, 65535)
%wasm_integer_check(int, -2147483648, 2147483647)
%wasm_integer_check(unsigned int, 0, 4294967295)
%wasm_integer_check(long, -2147483648, 2147483647)
%wasm_integer_check(unsigned long, 0, 4294967295)
%typemap(jstypecheck, wasmjs_scalar="1") long long "typeof $input === 'bigint' && BigInt.asIntN(64, $input) === $input"
%typemap(jstypecheck, wasmjs_scalar="1") unsigned long long "typeof $input === 'bigint' && BigInt.asUintN(64, $input) === $input"
%typemap(jsin, wasmjs_scalar="1") long long {
  if (typeof $input !== 'bigint' || BigInt.asIntN(64, $input) !== $input)
    throw new TypeError("Expected a signed 64-bit bigint");
}
%typemap(jsin, wasmjs_scalar="1") unsigned long long {
  if (typeof $input !== 'bigint' || BigInt.asUintN(64, $input) !== $input)
    throw new TypeError("Expected an unsigned 64-bit bigint");
}
%typemap(jstypecheck, wasmjs_scalar="1") float "typeof $input === 'number' && (!Number.isFinite($input) || Math.abs($input) <= 3.4028234663852886e38)"
%typemap(jsin, wasmjs_scalar="1") float {
  if (typeof $input !== 'number' || (Number.isFinite($input) && Math.abs($input) > 3.4028234663852886e38))
    throw new TypeError("Expected a number within the finite float range");
}
%typemap(jstypecheck, wasmjs_scalar="1") double "typeof $input === 'number'"
%typemap(jsin, wasmjs_scalar="1") double {
  if (typeof $input !== 'number') throw new TypeError("Expected a number");
}
%typemap(jstypecheck, wasmjs_scalar="1") bool "typeof $input === 'boolean'"
%typemap(jsin, wasmjs_scalar="1") bool {
  if (typeof $input !== 'boolean') throw new TypeError("Expected a boolean");
}
%typemap(jstypecheck) std::string, const std::string&, std::string& "typeof $input === 'string'"

/* Conventional NUL-terminated C strings use value handles too. */
%typemap(ctype) char *, const char * "EM_VAL"
%typemap(in, tsstub_in="string") char * (std::string temporary), const char * (std::string temporary) {
  emscripten::val value = swig_wasmjs::borrowed_value($input);
  if (value.typeOf().as<std::string>() != "string")
    SWIG_exception_fail(SWIG_TypeError, "Expected a string");
  temporary = value.as<std::string>();
  $1 = const_cast<char *>(temporary.c_str());
}
%typemap(out, tsstub_out="string | null") char *, const char * {
  $result = ($1 ? emscripten::val(std::string($1)) : emscripten::val::null()).release_ownership();
}
%typemap(jsarg) char *, const char * "__unwrap($input)"
%typemap(jsout) char *, const char * "__from_handle($call)"
%typemap(jstypecheck) char *, const char * "typeof $input === 'string'"

%typemap(jsout) unsigned int, unsigned long "(($call) >>> 0)"
%typemap(jsout) unsigned long long "BigInt.asUintN(64, $call)"

/* C++ probes consume JavaScript handles regardless of the native call ABI. */
%define %wasm_scalar_typecheck(TYPE, PRECEDENCE, KIND)
%typemap(typecheck, precedence=PRECEDENCE, wasmjs_scalar="1", fragment=SWIG_AsVal_frag(TYPE)) TYPE {
  emscripten::val value = swig_wasmjs::borrowed_value($input);
  $1 = value.typeOf().as<std::string>() == KIND &&
       SWIG_IsOK(SWIG_AsVal_dec(TYPE)(reinterpret_cast<void *>($input), 0));
}
%enddef
%wasm_scalar_typecheck(bool, SWIG_TYPECHECK_BOOL, "boolean")
%wasm_scalar_typecheck(char, SWIG_TYPECHECK_INT8, "number")
%wasm_scalar_typecheck(signed char, SWIG_TYPECHECK_INT8, "number")
%wasm_scalar_typecheck(unsigned char, SWIG_TYPECHECK_UINT8, "number")
%wasm_scalar_typecheck(short, SWIG_TYPECHECK_INT16, "number")
%wasm_scalar_typecheck(unsigned short, SWIG_TYPECHECK_UINT16, "number")
%wasm_scalar_typecheck(int, SWIG_TYPECHECK_INT32, "number")
%wasm_scalar_typecheck(unsigned int, SWIG_TYPECHECK_UINT32, "number")
%wasm_scalar_typecheck(long, SWIG_TYPECHECK_INT32, "number")
%wasm_scalar_typecheck(unsigned long, SWIG_TYPECHECK_UINT32, "number")
%wasm_scalar_typecheck(long long, SWIG_TYPECHECK_INT64, "bigint")
%wasm_scalar_typecheck(unsigned long long, SWIG_TYPECHECK_UINT64, "bigint")
%typemap(typecheck, precedence=SWIG_TYPECHECK_FLOAT, wasmjs_scalar="1") float {
  $1 = swig_wasmjs::borrowed_value($input).typeOf().as<std::string>() == "number";
}
%typemap(typecheck, precedence=SWIG_TYPECHECK_DOUBLE, wasmjs_scalar="1") double {
  $1 = swig_wasmjs::borrowed_value($input).typeOf().as<std::string>() == "number";
}
%typemap(typecheck, precedence=SWIG_TYPECHECK_STRING) std::string, const std::string &, std::string &, char *, const char * {
  $1 = swig_wasmjs::borrowed_value($input).typeOf().as<std::string>() == "string";
}
%typemap(typecheck, precedence=SWIG_TYPECHECK_INT32, wasmjs_enum="1") enum SWIGTYPE {
  $1 = swig_wasmjs::enum_conversion< $1_ltype >::read(swig_wasmjs::borrowed_value($input), 0);
}
%typemap(typecheck, precedence=SWIG_TYPECHECK_INT32, wasmjs_enum="1") const enum SWIGTYPE & {
  $1 = swig_wasmjs::enum_conversion< $*1_ltype >::read(swig_wasmjs::borrowed_value($input), 0);
}
%typemap(typecheck, precedence=SWIG_TYPECHECK_POINTER) SWIGTYPE {
  void *pointer = 0;
  $1 = SWIG_IsOK(SWIG_ConvertPtr($input, &pointer, $&descriptor, 0)) && pointer;
}

/* Const scalar references borrow a wrapper-local value for the native call.
   Mutable scalar references retain pointer semantics unless explicitly mapped. */
%define %wasm_scalar_const_reference(TYPE)
%typemap(ctype) const TYPE & = TYPE;
%typemap(in) const TYPE & (TYPE temporary) {
  temporary = (TYPE)$input;
  $1 = &temporary;
}
%typemap(out) const TYPE & { $result = *$1; }
%typemap(jsin) const TYPE & = TYPE;
%typemap(jsarg) const TYPE & = TYPE;
%typemap(jsout) const TYPE & = TYPE;
%typemap(jstypecheck) const TYPE & = TYPE;
%typemap(typecheck) const TYPE & = TYPE;
%enddef
%wasm_scalar_const_reference(bool)
%wasm_scalar_const_reference(char)
%wasm_scalar_const_reference(signed char)
%wasm_scalar_const_reference(unsigned char)
%wasm_scalar_const_reference(short)
%wasm_scalar_const_reference(unsigned short)
%wasm_scalar_const_reference(int)
%wasm_scalar_const_reference(unsigned int)
%wasm_scalar_const_reference(long)
%wasm_scalar_const_reference(unsigned long)
%wasm_scalar_const_reference(long long)
%wasm_scalar_const_reference(unsigned long long)
%wasm_scalar_const_reference(float)
%wasm_scalar_const_reference(double)
