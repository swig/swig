/* TypeScript declaration insertion and alias directives. */

#define %stubcode    %insert("stubs")

#ifdef SWIG_STUBS_ENABLED

/* Widening tables -- same slot names as python.cxx for cross-target
   compatibility.  Bodies are language-neutral 'NAME=TYPES' strings. */
%define %stub_alias_in(NAME, TYPES...)
%insert("stubs_preamble") %{_##NAME = TYPES
%}
%insert("stubs_alias_in_table") %{NAME=_##NAME
%}
%enddef

%define %stub_alias_out(NAME, TYPES...)
%insert("stubs_alias_out_table") %{NAME=_##NAME
%}
%enddef

%define %stub_alias_in_key(KEY, TYPES...)
%insert("stubs_alias_in_table") %{KEY=TYPES
%}
%enddef

%define %stub_alias_out_key(KEY, TYPES...)
%insert("stubs_alias_out_table") %{KEY=TYPES
%}
%enddef

/* TS-side input/output alias registration.  Each '%ts_alias_in(NAME)'
   adds one identifier to the slot the d.ts emitter consumes; bare
   'NAME' tokens in tsstub_in expressions get rewritten to '_NAME'
   (matching the 'export type _NAME = ...' declarations the user
   places in '%insert("stubs")').  ts_alias_out is the same idea for
   output-position rewrites, used for types whose runtime marshaling
   unwraps to a primitive regardless of direction. */
%define %ts_alias_in(NAME)
%insert("ts_alias_in") %{NAME
%}
%enddef

%define %ts_alias_out(NAME)
%insert("ts_alias_out") %{NAME
%}
%enddef

/* Hand-written python-syntax stubs: skip under wasm_js.  TypeScript
   counterparts could be added later via a wasm-js-specific macro
   family ('%dts_method' etc.). */
%define %stub_method(NAME, RET, ARGS...) %enddef
%define %stub_method0(NAME, RET) %enddef
%define %stub_overload_method(NAME, RET, ARGS...) %enddef
%define %stub_overload_method0(NAME, RET) %enddef
%define %stub_overload_method_selftyped(NAME, RET, SELFTYPE, ARGS...) %enddef
%define %stub_func(NAME, RET, ARGS...) %enddef
%define %stub_overload_func(NAME, RET, ARGS...) %enddef
%define %stub_attr(NAME, TYPE...) %enddef
%define %stub_const(NAME, TYPE...) %enddef
%define %stub_class_begin(NAME) %enddef

#else

/* -stubs not enabled: every macro is a no-op (matches the
   python.cxx pyuserdir.swg #else branch). */
%define %stub_alias_in(NAME, TYPES...) %enddef
%define %stub_alias_out(NAME, TYPES...) %enddef
%define %stub_alias_in_key(KEY, TYPES...) %enddef
%define %stub_alias_out_key(KEY, TYPES...) %enddef
%define %ts_alias_in(NAME) %enddef
%define %ts_alias_out(NAME) %enddef
%define %stub_method(NAME, RET, ARGS...) %enddef
%define %stub_method0(NAME, RET) %enddef
%define %stub_overload_method(NAME, RET, ARGS...) %enddef
%define %stub_overload_method0(NAME, RET) %enddef
%define %stub_overload_method_selftyped(NAME, RET, SELFTYPE, ARGS...) %enddef
%define %stub_func(NAME, RET, ARGS...) %enddef
%define %stub_overload_func(NAME, RET, ARGS...) %enddef
%define %stub_attr(NAME, TYPE...) %enddef
%define %stub_const(NAME, TYPE...) %enddef
%define %stub_class_begin(NAME) %enddef

#endif
