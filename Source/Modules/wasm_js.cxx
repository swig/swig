/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - https://www.swig.org.
 *
 * wasm_js.cxx
 *
 * Experimental Emscripten WebAssembly and JavaScript language module.
 * Generates C++ wrappers, a CommonJS proxy module, an export list and optional
 * TypeScript declarations.
 * ----------------------------------------------------------------------------- */

#include "swigmod.h"
#include <ctype.h> /* isalnum (cpp_to_ts: drop X:: qualified prefixes) */

static const char *usage = "\
WebAssembly+JS Options (use with -wasm-js):\n\
  -stubs       Emit TypeScript .d.ts declarations alongside .js/.cpp\n";

/* TypeScript stub generation -- mirrors python.cxx's -stubs/.pyi system.
   When 'stubs=1', top() opens a '.d.ts' output file, registers the
   "stubs" file slot, and the per-handler stubEmit*() helpers append
   'declare function' / 'class { ... }' signatures.  Off by default;
   user opts in via 'swig -wasm-js -stubs'. */
static int stubs = 0;
static File *f_stubs_dts = 0;          /* .d.ts output file */
static String *f_stubs = 0;            /* current receiving buffer */
static String *f_stubs_module = 0;     /* module-level (outside any class) */
static String *f_stubs_class_body = 0; /* per-class body buffer */

class WASM_JS : public Language {
public:
  WASM_JS() :
    director_classes(0),
    f_out_cpp(0),
    f_out_js(0),
    f_out_exports(0),
    f_cpp_runtime(0),
    f_cpp_header(0),
    f_cpp_wrappers(0),
    f_cpp_init(0),
    f_directors(0),
    f_directors_h(0),
    f_js_pre(0),
    f_js_classes(0),
    f_js_module(0),
    f_js_user(0),
    class_cname(0),
    class_jsname(0),
    class_js_body(0),
    class_cpp_section(0),
    enum_cname(0),
    enum_js_body(0),
    ctor_overloads(0),
    ctor_arities_seen(0),
    ctor_overload_count(0),
    member_names_seen(0),
    member_overload_counts(0),
    global_names_seen(0),
    global_overload_counts(0),
    cpp_to_js_class(0),
    mangle_to_jsname(0),
    indexed_classes(0),
    js_to_cpp_canonical(0),
    classes_needing_probes(0),
    types_needing_typecheck_probes(0),
    global_overloads(0),
    static_overloads(0),
    member_overloads(0),
    stub_free_fn_buckets(0),
    stub_method_buckets(0),
    stub_method_order(0),
    stub_free_fn_order(0),
    stub_static_instance_pending(0),
    class_has_base(false),
    ts_alias_in_set(0),
    ts_alias_out_set(0) {
    directorLanguage();
  }

  /* Allocate a unique-per-(scope, name) C identifier suffix. */
  int next_index(Hash *h, const String *key) {
    if (!h)
      return 0;
    String *v = (String *)Getattr(h, key);
    int n = v ? atoi(Char(v)) : 0;
    char buf[32];
    snprintf(buf, sizeof(buf), "%d", n + 1);
    Setattr(h, key, buf);
    return n;
  }

  int unsupported(Node *n, const char *what) {
    Swig_error(Getfile(n), Getline(n), "%s is not supported by -wasm-js.\n", what);
    return SWIG_ERROR;
  }

  virtual int globalvariableHandler(Node *n) {
    return unsupported(n, "Global variable wrapping");
  }
  virtual int staticmembervariableHandler(Node *n) {
    return unsupported(n, "Static member variable wrapping");
  }
  virtual int constantWrapper(Node *n);
  virtual int importDirective(Node *n) {
    return unsupported(n, "%import");
  }

  virtual int functionWrapper(Node *) {
    return SWIG_OK;
  }
  virtual void main(int argc, char *argv[]);
  virtual int top(Node *n);

  /* Recursive pre-pass: walk every node in the AST looking for class
     declarations (nodeType "class") and register their C++ name -> JS
     symbol in cpp_to_js_class.  Run before Language::top(n) so that
     js_marshal_return can wrap class-typed returns regardless of
     decl-vs-use order. */
  void prepopulate_class_names(Node *n) {
    if (!n)
      return;
    String *nt = nodeType(n);
    if (nt && Strcmp(nt, "class") == 0) {
      String *jsname = Getattr(n, "sym:name");
      SwigType *t = Getattr(n, "name");
      /* SWIG synthesises '__dummy_<N>__' sym names for unnamed
         '%template()' instantiations.  These have no JS proxy, no
         swig_type_info entry -- skip the registration so they don't
         appear in dispatcher arg-class lookups. */
      if (jsname && Strncmp(jsname, "__dummy_", 8) == 0) {
        prepopulate_class_names(firstChild(n));
        prepopulate_class_names(nextSibling(n));
        return;
      }
      if (jsname && t) {
        String *cn = SwigType_str(t, 0);
        Setattr(cpp_to_js_class, cn, jsname);
        SwigType *pointer = Copy(t);
        SwigType_add_pointer(pointer);
        String *tag = SwigType_manglestr(pointer);
        Setattr(cpp_to_js_class, tag, jsname);
        Delete(tag);
        Delete(pointer);
        /* Reverse map: JS class name -> canonical cpp form.  Used at
           end-of-top() to emit swig_can_<Class> probe wrappers. */
        if (!js_to_cpp_canonical)
          js_to_cpp_canonical = NewHash();
        if (!Getattr(js_to_cpp_canonical, jsname)) {
          Setattr(js_to_cpp_canonical, jsname, t);
        }
        if (Swig_scopename_check(cn)) {
          String *bare = Swig_scopename_last(cn);
          Setattr(cpp_to_js_class, bare, jsname);
          Delete(bare);
        }
        String *ns = SwigType_namestr(t);
        if (ns && Strcmp(ns, cn) != 0) {
          Setattr(cpp_to_js_class, ns, jsname);
          if (Swig_scopename_check(ns)) {
            String *bare = Swig_scopename_last(ns);
            Setattr(cpp_to_js_class, bare, jsname);
            Delete(bare);
          }
        }
        if (ns)
          Delete(ns);
        Delete(cn);
      }
    }
    /* Recurse into children + siblings. */
    prepopulate_class_names(firstChild(n));
    prepopulate_class_names(nextSibling(n));
  }

  virtual int classHandler(Node *n);
  virtual int memberfunctionHandler(Node *n);
  virtual int membervariableHandler(Node *n);
  virtual int constructorHandler(Node *n);
  virtual int destructorHandler(Node *n);
  virtual int staticmemberfunctionHandler(Node *n);
  virtual int globalfunctionHandler(Node *n);
  virtual int enumDeclaration(Node *n);
  virtual int enumvalueDeclaration(Node *n);

  virtual int classDirectorInit(Node *n);
  virtual int classDirectorEnd(Node *n);
  virtual int classDirectorConstructor(Node *n);
  virtual int classDirectorDefaultConstructor(Node *n);
  virtual int classDirectorMethod(Node *n, Node *parent, String *super);

  /* Per-class C-linkage director ctor wrapper export name + flag set
     by classHandler for director-enabled classes.  When the wrapper
     is emitted, the JS-side proxy ctor learns to detect new.target
     subclassing and route through it. */
  Hash *director_classes; /* C++ classname -> "1" if director-enabled */

protected:
  File *f_out_cpp;
  File *f_out_js;
  File *f_out_exports;

  /* C++ output accumulators (mirrors matlab.cxx: runtime, header, wrappers,
     init).  Final .cpp is assembled by concatenating them in order at the
     end of top().  "runtime" holds swigrun.swg + wasm-js-specific runtime
     (SWIG_ConvertPtr etc.) and the SwigType type table. */
  String *f_cpp_runtime;
  String *f_cpp_header;
  String *f_cpp_wrappers;
  String *f_cpp_init;

  String *f_directors;
  String *f_directors_h;
  String *f_js_pre;
  String *f_js_classes;
  String *f_js_module;
  String *f_js_user; /* Free-form user JS, %insert("js") {...}; emitted
                        after class defs AND after the module literal
                        (bound to '__m') is built, but before the
                        factory returns.  Lets user .i files patch both
                        SWIG-emitted prototype methods (Function.prototype...)
                        and the module-level functions (__m.horzcat,
                        __m.vertcat, ...).  Reference '__m' to patch
                        module exports. */

  String *class_cname;
  String *class_jsname;
  String *class_js_body;
  String *class_cpp_section;

  String *enum_cname;
  String *enum_js_body;

  /* Per-class ctor overloads: a List of Hash{arity, swig_name,
     dispatch_class, dispatch_idx}.  classHandler builds a JS
     dispatcher that picks per (arity, args[N].constructor.name).
     Replaces the old first-wins-per-arity logic. */
  List *ctor_overloads;
  Hash *ctor_arities_seen;
  int ctor_overload_count;
  Hash *member_names_seen;      /* per-class: jsname -> "1" (for JS-side dedup) */
  Hash *member_overload_counts; /* per-class: jsname -> "N" (next index for C symbol) */
  Hash *global_names_seen;      /* module-level: jsname -> "1" */
  Hash *global_overload_counts; /* module-level: fname -> "N" */
  Hash *cpp_to_js_class;
  Hash *mangle_to_jsname;
  Hash *indexed_classes;
  Hash *js_to_cpp_canonical;
  Hash *classes_needing_probes; /* JS class names referenced from any
                                    dispatcher.  Drives probe-wrapper
                                    emission at top()-end so we only
                                    emit probes that are actually
                                    called. */
  Hash *types_needing_typecheck_probes;
  Hash *global_overloads; /* jsname -> List<Hash{arg0_jsclass, body,
                              arity}>.  Built in globalfunctionHandler,
                              drained in top() to emit a dispatcher per
                              jsname (arg0-type based). */
  Hash *static_overloads; /* jsname -> List<Hash{swig_name, jsargs,
                              arity, prim_checks, call_args_js,
                              js_body}>.  Built in
                              staticmemberfunctionHandler, drained in
                              classHandler end to emit a per-arity
                              dispatcher (so MX.sym("a") routes to
                              sym(name) not sym(name, undefined,
                              undefined)). */
  Hash *member_overloads; /* Same shape as static_overloads but for
                              non-static member methods.  Lets
                              Sparsity.row(k) and Sparsity.row()
                              coexist via args.length dispatch. */
  /* TypeScript declaration buckets retain the same ranking snapshots
     as runtime dispatchers. Emit each overload group in canonical order
     because TypeScript selects the first matching declaration. */
  Hash *stub_free_fn_buckets;
  Hash *stub_method_buckets;
  List *stub_method_order;
  /* Preserves first-encounter order of buckets for deterministic
     emission. */
  List *stub_free_fn_order;
  /* "<class>::<jsname>" -> String of instance-form d.ts signatures for
     static methods.  Python/MATLAB allow calling statics on instances;
     the runtime emits prototype forwarders for them, and these pending
     signatures type that form.  Spliced into f_stubs_class_body at
     class end, skipping names a real instance method already owns. */
  Hash *stub_static_instance_pending;
  bool class_has_base;

  String *mangle(const String *s) {
    return Swig_name_mangle_string(s);
  }

  void register_export(const char *swig_name) {
    Printf(f_out_exports, "_%s\n", swig_name);
  }

  /* Mark a JS class as needing a 'swig_can_<Class>' probe wrapper.
     Called from dispatcher-emit sites; the actual wrapper is emitted at
     end-of-top() in emit_probe_wrappers().  Filter SWIG-internal
     '__dummy_<N>__' names (unnamed '%template()' instantiations) -- no
     real proxy exists, so the probe would reference a nonexistent
     swig_type_info symbol and fail to link. */
  void register_probe(const String *jsname) {
    if (!jsname || Len(jsname) == 0)
      return;
    if (Strncmp(jsname, "__dummy_", 8) == 0)
      return;
    if (!classes_needing_probes)
      classes_needing_probes = NewHash();
    Setattr(classes_needing_probes, jsname, "1");
  }

  /* Single-place type-check emission, shared by the three dispatcher
     sites (global free fn / static member / non-static member).  Returns
     the JS expression to OR into an overload's 'type_checks' string, or
     NULL if no discrim can be derived for this type.  Preference order:
       1. Class-typed parm  -> 'M._swig_can_<JsCls>(__unwrap(args[i]))'
       2. char* parm        -> 'typeof args[i] === 'string''
       3. primitive parm    -> typeof boolean/number/bigint
       4. container parm    -> 'M._swig_can_<mangled>(__unwrap(args[i]))'
                                (via register_typecheck_probe; fixes the
                                "first-overload-wins" bug for things like
                                rootfinder(name, solver, SXDict|MXDict|Function, opts))
       5. anything else     -> NULL (caller treats as "always true") */
  String *build_arg_check(Parm *q, int pi) {
    SwigType *t = Getattr(q, "type");
    if (!t)
      return NULL;

    Swig_typemap_attach_parms("jstypecheck", q, 0);
    String *jstc = Getattr(q, "tmap:jstypecheck");
    bool scalar_handle = Equal(Getattr(q, "tmap:ctype"), "EM_VAL") && GetFlag(q, "tmap:jstypecheck:wasmjs_scalar");
    if (jstc && Len(jstc) > 0 && !scalar_handle) {
      String *expr = Copy(jstc);
      String *idx = NewStringf("args[%d]", pi);
      Replaceall(expr, "$input", idx);
      Delete(idx);
      return expr;
    }
    if (Equal(Getattr(q, "tmap:ctype"), "EM_VAL")) {
      String *probe = register_typecheck_probe(q, pi);
      if (Len(probe))
        return probe;
      Delete(probe);
      if (scalar_handle)
        return NULL;
    }
    String *cls = lookup_js_class(t);
    if (cls && Len(cls) > 0) {
      register_probe(cls);
      return NewStringf("M._swig_can_%s(__unwrap(args[%d]))", Char(cls), pi);
    }
    String *ct = Getattr(q, "tmap:ctype");
    if (ct && (Strstr(ct, "char*") || Strstr(ct, "char *"))) {
      return NewStringf("typeof args[%d] === 'string'", pi);
    }

    {
      SwigType *tres = SwigType_typedef_resolve_all(Copy(t));
      SwigType *effective = tres ? tres : t;
      /* Strip leading cv/ref/ptr (effective is "long long const &" etc.). */
      SwigType *bare = SwigType_ltype(effective);
      if (bare && SwigType_isreference(bare))
        SwigType_del_reference(bare);
      if (bare && SwigType_ispointer(bare))
        SwigType_del_pointer(bare);
      SwigType *toinspect = bare ? bare : effective;
      int tk = SwigType_type(toinspect);
      String *r = NULL;
      if (tk == T_BOOL) {
        /* Strict: a JS number is NOT a bool, so overload dispatch lets
           Slice(int,int) win over Slice(int, bool ind1) etc. */
        r = NewStringf("(typeof args[%d] === 'boolean')", pi);
      } else if (tk == T_INT || tk == T_UINT || tk == T_SHORT || tk == T_USHORT || tk == T_LONG || tk == T_ULONG || tk == T_LONGLONG || tk == T_ULONGLONG ||
                 tk == T_SCHAR || tk == T_UCHAR || tk == T_FLOAT || tk == T_DOUBLE) {
        r = NewStringf("(typeof args[%d] === 'number' || typeof args[%d] === 'bigint')", pi, pi);
      }
      if (bare)
        Delete(bare);
      if (tres)
        Delete(tres);
      if (r)
        return r;
    }
    /* Fall-through: try the typecheck-probe path for container types
       (map/pair/vector) that don't have a JS class proxy. */
    String *probe_expr = register_typecheck_probe(q, pi);
    if (probe_expr && Len(probe_expr) > 0)
      return probe_expr;
    if (probe_expr)
      Delete(probe_expr);
    return NULL;
  }

  String *register_typecheck_probe(Parm *original, int index) {
    SwigType *type = Getattr(original, "type");
    String *parameter_name = Getattr(original, "name");
    Parm *parameter = NewParm(type, parameter_name, 0);
    Setattr(parameter, "lname", "result");
    Swig_typemap_attach_parms("typecheck", parameter, 0);
    bool has_check = Getattr(parameter, "tmap:typecheck") != 0;
    if (Equal(Getattr(original, "tmap:ctype"), "EM_VAL") && GetFlag(parameter, "tmap:typecheck:wasmjs_scalar"))
      has_check = false;
    Delete(parameter);
    if (!has_check)
      return NewString("");
    SwigType *resolved = SwigType_typedef_resolve_all(type);
    SwigType *effective = resolved ? resolved : type;
    String *mangled = Swig_name_mangle_string(effective);
    String *named = parameter_name ? mangle(parameter_name) : NewString("value");
    String *probe_id = NewStringf("type%s_%s", mangled, named);
    Delete(named);
    if (!types_needing_typecheck_probes)
      types_needing_typecheck_probes = NewHash();
    Parm *probe_parameter = NewParm(effective, parameter_name, 0);
    Setattr(types_needing_typecheck_probes, probe_id, probe_parameter);
    Delete(probe_parameter);
    String *expression = NewStringf("M._swig_can_%s(__unwrap(args[%d]))", probe_id, index);
    Delete(probe_id);
    Delete(mangled);
    Delete(resolved);
    return expression;
  }

  /* Emit a conversion probe using the target's typecheck typemap, or the
     standard pointer conversion for a wrapped class. */
  void emit_conversion_probe(const String *name, SwigType *type, const String *parameter_name = 0) {
    Parm *p = NewParm(type, parameter_name, 0);
    Setattr(p, "lname", "result");
    Swig_typemap_attach_parms("typecheck", p, 0);
    String *tm = Getattr(p, "tmap:typecheck");
    Printf(f_cpp_wrappers,
           "EMSCRIPTEN_KEEPALIVE int %s(EM_VAL p) {\n"
           "  emscripten::val _input_owner = p ? emscripten::val::take_ownership(p) : emscripten::val::undefined();\n",
           name);
    if (tm) {
      String *body = Copy(tm);
      Replaceall(body, "$input", "p");
      Printf(f_cpp_wrappers, "  int result = 0;\n  %s\n  return result;\n", body);
      Delete(body);
    } else {
      SwigType *pointer = Copy(type);
      SwigType_add_pointer(pointer);
      String *tag = SwigType_manglestr(pointer);
      Printf(f_cpp_wrappers,
             "  void *result = 0;\n"
             "  swig_type_info *type = SWIG_TypeQuery(\"%s\");\n"
             "  return type && SWIG_IsOK(SWIG_ConvertPtr(p, &result, type, 0));\n",
             tag);
      Delete(tag);
      Delete(pointer);
    }
    Printf(f_cpp_wrappers, "}\n");
    register_export(Char(name));
    Delete(p);
  }

  void emit_typecheck_probe_wrappers() {
    if (!types_needing_typecheck_probes)
      return;
    for (Iterator it = First(types_needing_typecheck_probes); it.key; it = Next(it)) {
      String *name = NewStringf("swig_can_%s", it.key);
      emit_conversion_probe(name, Getattr(it.item, "type"), Getattr(it.item, "name"));
      Delete(name);
    }
  }

  void emit_probe_wrappers() {
    if (!classes_needing_probes || !js_to_cpp_canonical)
      return;
    for (Iterator it = First(classes_needing_probes); it.key; it = Next(it)) {
      SwigType *type = Getattr(js_to_cpp_canonical, it.key);
      if (type) {
        String *name = NewStringf("swig_can_%s", it.key);
        emit_conversion_probe(name, type);
        Delete(name);
      }
    }
  }

  /* Typemap lookups follow SWIG's standard names (ctype/in/out/freearg)
     with the standard $1, $input, $result placeholders.  JS-side hooks use
     wasm-js-specific names (jsin/jsarg/jsfree/jsout) since SWIG has no
     standard for the JS proxy side.

     Convention: each parm has lname set to "arg<N+1>" (matlab.cxx pattern)
     and we treat the C-API input variable as "obj<N>" (substituted into
     $input).  This means an in typemap body  "$1 = std::string($input);"
     emits  "arg1 = std::string(obj0);"  after Swig_typemap_attach_parms +
     our $input Replaceall.  */

  /* Assign canonical lnames/names to each parm. Re-runnable; idempotent. */
  void name_parms(ParmList *p) {
    int i = 1;
    for (Parm *q = p; q; q = nextSibling(q), ++i) {
      String *lname = NewStringf("arg%d", i);
      Setattr(q, "lname", lname);
      if (!Getattr(q, "name"))
        Setattr(q, "name", lname);
      Delete(lname);
    }
  }

  /* Parm has typemap(in, numinputs=0) — server-side filled, not in wasm sig. */
  bool is_in_numinputs0(Parm *q) {
    return checkAttribute(q, "tmap:in:numinputs", "0");
  }

  /* Obj-name for the input-side (wasm-export signature) variable for a
     parm at survivor-index s. The survivor index advances only for parms
     that ARE in the input signature, so numinputs=0 parms don't take a
     slot.  Returns a fresh string (caller frees). */
  String *obj_name(int s) {
    return NewStringf("obj%d", s);
  }

  /* C-side parm declarations: "<ctype> obj0, <ctype> obj1, ...".  Uses
     the standard 'ctype' typemap; falls back to the C++ ltype string.
     Skips parms with typemap(in, numinputs=0) — those are server-side
     filled. */
  String *parm_decls(ParmList *p) {
    Swig_typemap_attach_parms("ctype", p, 0);
    Swig_typemap_attach_parms("in", p, 0); /* for numinputs check */
    String *out = NewString("");
    int s = 0; /* survivor index (only advances for parms in the C sig) */
    for (Parm *q = p; q; q = nextSibling(q)) {
      if (is_in_numinputs0(q))
        continue;
      String *tm = Getattr(q, "tmap:ctype");
      String *oname = obj_name(s);
      if (tm) {
        Printf(out, "%s%s %s", s == 0 ? "" : ", ", tm, oname);
      } else {
        SwigType *t = Getattr(q, "type");
        String *ts = SwigType_str(t, 0);
        Printf(out, "%s%s %s", s == 0 ? "" : ", ", ts, oname);
        Delete(ts);
      }
      Delete(oname);
      ++s;
    }
    return out;
  }

  /* Emit "<T> arg<N>; <in-typemap-body>" for parms that have an 'in'
     typemap defined.  Parms without an 'in' typemap use no local at all
     -- the call site refers to the C-API variable obj<S> directly.

     S is the survivor index (input-only): obj0, obj1 in source order,
     skipping numinputs=0 parms.  Their typemap bodies typically don't
     reference $input (no input to reference), but if they do, the
     reference is to the *next* surviving obj<S>, which would still be
     wrong -- numinputs=0 typemaps with $input references shouldn't
     exist in practice. */
  String *parm_prologue(ParmList *p) {
    Swig_typemap_attach_parms("in", p, 0);
    Swig_typemap_attach_parms("freearg", p, 0);
    String *out = NewString("");
    int s = 0;      /* 0-based JS-arg index (a0, a1, ...) */
    int argnum = 1; /* 1-based SWIG argnum for typemap_locals mangling */
    for (Parm *q = p; q; q = nextSibling(q)) {
      bool skip_obj = is_in_numinputs0(q);
      String *tm = Getattr(q, "tmap:in");
      if (tm) {
        SwigType *t = Getattr(q, "type");
        String *lname = Getattr(q, "lname");
        SwigType *value_type = cplus_value_type(t);
        String *ltype = SwigType_lstr(value_type ? value_type : t, lname);
        Delete(value_type);
        /* Outer-scope local: declared once at wrapper top so the call */
        /* site (parm_args) can reference it without scope hopping. */
        Printf(out, "  %s{};\n", ltype);
        Delete(ltype);

        /* Make a working copy of the body — we may rewrite identifiers */
        /* in it as we emit '(T m)' locals.  Function scope, not block */
        /* scope (heap-allocated locals would dangle past block close). */
        String *body = Copy(tm);
        String *free_map = Getattr(q, "tmap:freearg");
        String *cleanup = free_map && Len(free_map) ? Copy(free_map) : 0;

        /* Typemap-declared '(T m)' locals: replicate SWIG core's */
        /* typemap_locals mangling (rename to 'm<argnum>', substitute */
        /* in body) -- we bypass 'Wrapper *f' so the standard mangling */
        /* path doesn't fire, and without per-parm mangling, methods */
        /* with multiple same-type ref args collide. */
        Parm *locals = (Parm *)Getattr(q, "tmap:in:locals");
        for (Parm *lp = locals; lp; lp = nextSibling(lp)) {
          SwigType *lt = Getattr(lp, "type");
          String *raw_name = Getattr(lp, "name");
          if (!raw_name || Len(raw_name) == 0)
            continue;
          String *mangled = NewStringf("%s%d", raw_name, argnum);
          String *lts = SwigType_str(lt, mangled);
          String *initializer = Getattr(lp, "value");
          if (initializer)
            Printf(out, "  %s = %s;\n", lts, initializer);
          else
            Printf(out, "  %s{};\n", lts);
          Replace(body, raw_name, mangled, DOH_REPLACE_ID);
          if (cleanup)
            Replace(cleanup, raw_name, mangled, DOH_REPLACE_ID);
          Delete(lts);
          Delete(mangled);
        }

        String *oname = skip_obj ? NewString("__numinputs0_no_input") : obj_name(s);
        if (cleanup) {
          Replaceall(cleanup, "$input", oname);
          Printf(out, "  auto _cleanup%d = swig_wasmjs::make_cleanup([&]() {\n%s\n  });\n", argnum, cleanup);
          Delete(cleanup);
        }
        /* The guard also runs when this conversion fails after allocating temporary storage. */
        Printf(out, "  {\n");
        Replaceall(body, "$input", oname);
        Printf(out, "    %s\n", body);
        Printf(out, "  }\n");
        Delete(body);
        Delete(oname);
      }
      if (!skip_obj)
        ++s;
      ++argnum;
    }
    return out;
  }

  /* C++ call-site arg list. Parms with an 'in' typemap pass via the lname
     local (arg<N>) populated by parm_prologue; parms without pass obj<S>
     directly. Canonical SWIG casts restore reference and nested pointer
     qualifiers removed from the local storage type. Attach is idempotent. */
  String *parm_args(ParmList *p) {
    Swig_typemap_attach_parms("in", p, 0);
    String *out = NewString("");
    int s = 0; /* survivor index for obj<S> */
    bool first = true;
    for (Parm *q = p; q; q = nextSibling(q)) {
      String *tm = Getattr(q, "tmap:in");
      bool skip_obj = is_in_numinputs0(q);
      if (!first)
        Printv(out, ", ", NIL);
      first = false;
      if (tm) {
        SwigType *t = Getattr(q, "type");
        String *argument = SwigType_rcaststr(t, Getattr(q, "lname"));
        Printv(out, argument, NIL);
        Delete(argument);
      } else {
        String *oname = obj_name(s);
        Printv(out, oname, NIL);
        Delete(oname);
      }
      if (!skip_obj)
        ++s;
    }
    return out;
  }

  /* JS function-signature parameter list: always plain a0, a1, ...
     (the user-facing JS arg names).  Skips numinputs=0 parms.  Does NOT
     consult 'jsarg' — that typemap rewrites the *wasm call expression*,
     not the JS function signature; mixing the two causes the param name
     to be the malloc'd buffer (e.g. '__ps1') while the body references
     the canonical 'a0', leaving the param unused and 'a0' undefined. */
  String *js_arg_names(ParmList *p) {
    Swig_typemap_attach_parms("in", p, 0);
    String *out = NewString("");
    int s = 0;
    for (Parm *q = p; q; q = nextSibling(q)) {
      if (is_in_numinputs0(q))
        continue;
      Printf(out, "%sa%d", s == 0 ? "" : ", ", s);
      ++s;
    }
    return out;
  }

  /* Build the JS-side call-arguments list, auto-unwrapping registered
     class-type parms ('a0' -> 'a0._ptr').  Counterpart to
     js_arg_names() which is for the JS function signature.  Skips
     numinputs=0 parms (server-side filled).  Used by
     memberfunctionHandler / constructorHandler / etc. where
     emit_js_body's richer typemap-aware path is overkill. */
  String *js_call_args(ParmList *p) {
    Swig_typemap_attach_parms("in", p, 0);
    String *out = NewString("");
    int s = 0;
    for (Parm *q = p; q; q = nextSibling(q)) {
      if (is_in_numinputs0(q))
        continue;
      if (s > 0)
        Printv(out, ", ", NIL);
      if (is_registered_class_type(Getattr(q, "type"))) {
        Printf(out, "__unwrap(a%d)", s);
      } else {
        Printf(out, "a%d", s);
      }
      ++s;
    }
    return out;
  }

  int parm_arity(ParmList *p) {
    int n = 0;
    for (Parm *q = p; q; q = nextSibling(q))
      ++n;
    return n;
  }

  /* JS-visible arity: count only parms that contribute a real JS arg
     (skip 'tmap:in:numinputs=0' parms like argout-only references).
     Must mirror js_arg_names exactly so the dispatcher's
     'args.length' case key matches what the user actually passes. */
  int parm_arity_js(ParmList *p) {
    Swig_typemap_attach_parms("in", p, 0);
    int n = 0;
    for (Parm *q = p; q; q = nextSibling(q)) {
      if (is_in_numinputs0(q))
        continue;
      ++n;
    }
    return n;
  }

  /* Find the JS-index of the first parm with a default value, where the
     entire suffix is also defaulted.  -1 if no defaults at all.  Used
     to drive the truncation loop for default-arg phantom overloads. */
  int first_default_arity(ParmList *p) {
    int js_idx = 0;
    int first = -1;
    for (Parm *q = p; q; q = nextSibling(q)) {
      if (is_in_numinputs0(q))
        continue;
      String *v = Getattr(q, "value");
      if (v && Len(v) > 0) {
        if (first == -1)
          first = js_idx;
      } else {
        /* A non-defaulted parm appears after a defaulted one --
           reset (shouldn't happen with valid C++ default-arg
           semantics). */
        first = -1;
      }
      ++js_idx;
    }
    return first;
  }

  /* Build the JS-side defaults prologue for a truncated arity.  Emits
     'const a<i> = <jslit>;' for each missing arg, where <jslit> is a
     BigInt literal for integer-typed parms, a plain number for
     float-typed, etc.  Unrecognised default expressions get
     'undefined'.  Returns a fresh String the caller must Delete. */
  String *build_defaults_prologue(ParmList *p, int trunc) {
    String *out = NewString("");
    int s = 0;
    for (Parm *q = p; q; q = nextSibling(q)) {
      if (is_in_numinputs0(q))
        continue;
      if (s >= trunc) {
        String *val = Getattr(q, "value");
        SwigType *t = Getattr(q, "type");
        SwigType *tres = t ? SwigType_typedef_resolve_all(t) : 0;
        String *ts = SwigType_str(tres ? tres : t, 0);
        const char *cs = ts ? Char(ts) : "";
        bool emitted = false;
        if (val && Len(val) > 0) {
          const char *vs = Char(val);
          bool looks_numeric = false;
          {
            const char *q2 = vs;
            while (*q2 == ' ')
              ++q2;
            if (*q2 == '-' || *q2 == '+')
              ++q2;
            if (*q2 >= '0' && *q2 <= '9')
              looks_numeric = true;
          }
          bool is_bool_kw = (strcmp(vs, "true") == 0 || strcmp(vs, "false") == 0);
          /* C++ string-literal defaults ('"reference"') are valid JS
             string literals as-is; pass through for string-typed parms. */
          bool is_string_lit = (vs[0] == '"');
          if (is_bool_kw) {
            Printf(out, "      const a%d = %s;\n", s, vs);
            emitted = true;
          } else if (looks_numeric) {

            String *ct = Getattr(q, "tmap:ctype");
            const char *cts = ct ? Char(ct) : "";
            bool is_bigint;
            if (ct && Len(ct) > 0) {
              is_bigint = (strstr(cts, "long long") || strstr(cts, "int64") || strstr(cts, "uint64"));
            } else {

              is_bigint = (strstr(cs, "long long") || strstr(cs, "int64") || strstr(cs, "uint64"));
            }
            if (is_bigint) {
              Printf(out, "      const a%d = %sn;\n", s, vs);
            } else {
              Printf(out, "      const a%d = %s;\n", s, vs);
            }
            emitted = true;
          } else if (is_string_lit) {
            Printf(out, "      const a%d = %s;\n", s, vs);
            emitted = true;
          } else {
            /* Empty standard containers use native JavaScript values; wrapped classes use their default constructor. */
            int vlen = (int)strlen(vs);
            if (vlen >= 2 && vs[vlen - 1] == ')' && vs[vlen - 2] == '(') {
              /* "<Type>()" -- empty ctor. */
              if (strncmp(cs, "std::map<", 9) == 0 || strncmp(cs, "std::unordered_map<", 19) == 0) {
                Printf(out, "      const a%d = new Map();\n", s);
                emitted = true;
              } else if (strncmp(cs, "std::vector<", 12) == 0 || strncmp(cs, "std::deque<", 11) == 0 || strncmp(cs, "std::list<", 10) == 0) {
                Printf(out, "      const a%d = [];\n", s);
                emitted = true;
              } else if (t) {
                /* Try to map to a registered JS proxy class. */
                String *cls = lookup_js_class(t);
                if (cls && Len(cls) > 0) {
                  Printf(out, "      const a%d = new %s();\n", s, Char(cls));
                  emitted = true;
                }
              }
            }
          }
        }
        if (!emitted) {
          Printf(out, "      const a%d = undefined;\n", s);
        }
        if (ts)
          Delete(ts);
        if (tres)
          Delete(tres);
      }
      ++s;
    }
    return out;
  }

  /* Emit a JS method body: jsin prologue per parm, wasm call, jsout to
     marshal return, jsfree per parm post-call.  Skips numinputs=0 parms
     entirely (no JS-side input, no wasm-export arg). */
  String *emit_js_body(ParmList *p, SwigType *rt, const String *swig_name, const char *self_prefix, Node *context = 0, bool marshal_output = true) {
    Swig_typemap_attach_parms("jsin", p, 0);
    Swig_typemap_attach_parms("jsarg", p, 0);
    Swig_typemap_attach_parms("jsfree", p, 0);
    Swig_typemap_attach_parms("in", p, 0);
    Swig_typemap_attach_parms("ctype", p, 0);

    String *out = NewString("");
    List *cleanups = NewList();

    int argument_index = 0;
    for (Parm *parameter = p; parameter; parameter = nextSibling(parameter)) {
      if (is_in_numinputs0(parameter))
        continue;
      String *check = build_arg_check(parameter, argument_index);
      if (check && Len(check)) {
        String *from = NewStringf("args[%d]", argument_index);
        String *to = NewStringf("a%d", argument_index);
        Replaceall(check, from, to);
        Printf(out, "      if (!(%s)) throw new TypeError('Invalid argument %d');\n", check, argument_index + 1);
        Delete(from);
        Delete(to);
      }
      Delete(check);
      ++argument_index;
    }

    /* Prologue: emit per-parm jsin typemaps with $input/$argnum subst. */
    int s = 0;
    for (Parm *q = p; q; q = nextSibling(q)) {
      if (is_in_numinputs0(q))
        continue;
      String *tm = Getattr(q, "tmap:jsin");
      if (tm && !(Equal(Getattr(q, "tmap:ctype"), "EM_VAL") && GetFlag(q, "tmap:jsin:wasmjs_scalar"))) {
        String *body = Copy(tm);
        String *aname = NewStringf("a%d", s);
        String *idxs = NewStringf("%d", s);
        Replaceall(body, "$input", aname);
        Replaceall(body, "$argnum", idxs);
        Printv(out, body, NIL);
        Delete(body);
        Delete(aname);
        Delete(idxs);
      }
      String *cleanup = Getattr(q, "tmap:jsfree");
      if (cleanup) {
        String *body = Copy(cleanup);
        String *argument = NewStringf("a%d", s);
        String *index = NewStringf("%d", s);
        Replaceall(body, "$input", argument);
        Replaceall(body, "$argnum", index);
        Append(cleanups, body);
        Printf(out, "      try {\n");
        Delete(body);
        Delete(argument);
        Delete(index);
      }
      ++s;
    }

    /* Build call-args list.  Resolution order per parm:
         1. jsarg typemap (e.g. std::string's '__ps$argnum' malloc'd buf).
         2. Class-type auto-unwrap: if the parm's C++ type is a
            registered class (cpp_to_js_class hit), emit 'a<S>._ptr'
            so JS callers pass proxy instances directly.
         3. Default: raw 'a<S>'. */
    String *call_args = NewString("");
    s = 0;
    bool first = true;
    for (Parm *q = p; q; q = nextSibling(q)) {
      if (is_in_numinputs0(q))
        continue;
      if (!first)
        Printf(call_args, ", ");
      first = false;
      String *tm = Getattr(q, "tmap:jsarg");
      String *aname = NewStringf("a%d", s);
      String *idxs = NewStringf("%d", s);
      if (tm && !(Equal(Getattr(q, "tmap:ctype"), "EM_VAL") && GetFlag(q, "tmap:jsarg:wasmjs_scalar"))) {
        String *expr = Copy(tm);
        Replaceall(expr, "$input", aname);
        Replaceall(expr, "$argnum", idxs);
        Printv(call_args, expr, NIL);
        Delete(expr);
      } else {
        /* Generic rule: any parm whose 'ctype' typemap is 'EM_VAL'
           crosses the wasm boundary as an i32 handle into Embind's
           value table.  The JS side must hand the value to
           '__swig_take_handle' first (via '__unwrap').  This covers:
             - Registered wrapped classes  (xType ctype = EM_VAL)
             - Dict, SpDict, MXDict, ...   (xType ctype = EM_VAL)
             - Sparsity, MX, SX, DM, ...   (same)
           For primitive ctypes (int, double, const char*, ...) the
           wasm ABI handles the value directly -- pass raw.
           __unwrap also tolerates null/undefined (returns 0), letting
           callers omit default-arg-slot dicts.  */
        String *ctype = Getattr(q, "tmap:ctype");
        if (ctype && Strcmp(ctype, "EM_VAL") == 0) {
          Printf(call_args, "__unwrap(%s)", Char(aname));
        } else {
          Printv(call_args, aname, NIL);
        }
      }
      Delete(aname);
      Delete(idxs);
      ++s;
    }

    String *raw_call;
    if (self_prefix && self_prefix[0]) {
      raw_call = NewStringf("__chk(M._%s(%s%s%s))", swig_name, self_prefix, Len(call_args) > 0 ? ", " : "", call_args);
    } else {
      raw_call = NewStringf("__chk(M._%s(%s))", swig_name, call_args);
    }
    SwigType *eff_rt = effective_js_return_type(rt, p);
    String *marshalled = marshal_output ? js_marshal_return(eff_rt ? eff_rt : rt, Char(raw_call), context) : Copy(raw_call);

    Printf(out, "      return %s;\n", marshalled);
    for (int index = Len(cleanups) - 1; index >= 0; --index)
      Printf(out, "      } finally {\n%s\n      }\n", Getitem(cleanups, index));
    Delete(cleanups);
    Delete(call_args);
    Delete(raw_call);
    Delete(marshalled);
    return out;
  }

  /* Strip C++ qualifiers ('const', '&', '*', whitespace) from a printed
     SwigType_str.  Returned String is a fresh allocation (caller deletes). */
  String *trim_cpp_qualifiers(const String *full) {
    const char *cs = Char(full);
    int cn = Len(full);
    while (cn > 0 && (cs[0] == ' ' || cs[0] == '\t')) {
      cs++;
      cn--;
    }
    while (cn > 0 && (cs[cn - 1] == ' ' || cs[cn - 1] == '\t'))
      cn--;
    if (cn > 6 && strncmp(cs, "const ", 6) == 0) {
      cs += 6;
      cn -= 6;
    }
    for (;;) {
      while (cn > 0 && (cs[cn - 1] == '&' || cs[cn - 1] == '*' || cs[cn - 1] == ' ' || cs[cn - 1] == '\t'))
        cn--;
      if (cn > 6 && strncmp(cs + cn - 6, " const", 6) == 0) {
        cn -= 6;
        continue;
      }
      break;
    }
    return NewStringWithSize(cs, cn);
  }

  /* Look up 'bare' (and its last-'::' suffix) in cpp_to_js_class.
     Returns the registered JS class name (owned by cpp_to_js_class; do
     NOT delete) or NULL. */
  String *lookup_bare(String *bare) {
    if (!cpp_to_js_class || !bare || Len(bare) == 0)
      return NULL;
    String *hit = (String *)Getattr(cpp_to_js_class, bare);
    if (hit)
      return hit;

    const char *cs = Char(bare);
    int cn = Len(bare);
    const char *last = NULL;
    for (int i = 0; i + 1 < cn; ++i) {
      if (cs[i] == ':' && cs[i + 1] == ':')
        last = cs + i + 2;
    }
    if (last && last > cs) {
      int suff_len = cn - (last - cs);
      String *stripped = NewStringWithSize(last, suff_len);
      hit = (String *)Getattr(cpp_to_js_class, stripped);
      Delete(stripped);
    }
    return hit;
  }

  /* The canonical class-name lookup.  Tries (in order):
       1. printed SwigType_str trimmed of cv, reference and pointer qualifiers
       2. typedef-resolved form of same
       3. SwigType_namestr (no spaces around <>)
     Each variant is also retried with the leading namespace stripped
     (last-'::' suffix).  Returns the registered JS class name (owned by
     cpp_to_js_class; do NOT delete) or NULL.  This replaces 5+
     duplicate copies of the same trim-and-lookup pattern. */
  String *lookup_js_class(SwigType *rt) {
    if (!rt || !cpp_to_js_class)
      return NULL;
    SwigType *canonical = SwigType_typedef_resolve_all(rt);
    SwigType *pointer = SwigType_base(canonical ? canonical : rt);
    SwigType_add_pointer(pointer);
    String *tag = SwigType_manglestr(pointer);
    String *registered = Getattr(cpp_to_js_class, tag);
    Delete(tag);
    Delete(pointer);
    Delete(canonical);
    if (registered)
      return registered;
    /* Variant 1: direct print. */
    String *cname = SwigType_str(rt, 0);
    String *bare = trim_cpp_qualifiers(cname);
    String *hit = lookup_bare(bare);
    Delete(bare);
    Delete(cname);
    if (hit)
      return hit;
    /* Variant 2: typedef-resolved. */
    SwigType *t = Copy(rt);
    SwigType *resolved = SwigType_typedef_resolve_all(t);
    if (resolved) {
      String *rstr = SwigType_str(resolved, 0);
      String *rbare = trim_cpp_qualifiers(rstr);
      hit = lookup_bare(rbare);
      Delete(rbare);
      Delete(rstr);
      Delete(resolved);
    }
    Delete(t);
    if (hit)
      return hit;
    /* Variant 3: namestr form. */
    SwigType *t2 = Copy(rt);
    String *namestr = SwigType_namestr(t2);
    if (namestr) {
      String *nbare = trim_cpp_qualifiers(namestr);
      hit = lookup_bare(nbare);
      Delete(nbare);
      Delete(namestr);
    }
    Delete(t2);
    return hit;
  }

  bool is_registered_class_type(SwigType *rt) {
    String *hit = lookup_js_class(rt);
    return hit && Len(hit) > 0;
  }

  /* JS-side return marshalling.
       1. If a 'jsout' typemap is defined, use it (substituting '$call').
       2. Else if the return type is a registered class, wrap as
          'new JsName(__PRIVATE_CTOR, $call)' so callers receive a JS
          proxy instance instead of a raw void* pointer.
       3. Else identity (primitive returns: bigint / number / void). */
  String *js_marshal_return(SwigType *rt, const char *expr, Node *context = 0) {
    if (!rt)
      return NewString(expr);
    Parm *fake = NewParm(rt, context ? Getattr(context, "name") : 0, 0);
    Setattr(fake, "lname", "result");
    Swig_typemap_attach_parms("jsout", fake, 0);
    String *tm = Getattr(fake, "tmap:jsout");
    String *r;
    if (tm) {
      r = Copy(tm);
      Replaceall(r, "$call", expr);
    } else {
      /* Resolve to a registered JS class name via the canonical helper
         (handles cv, reference and pointer qualifiers stripping, typedef-resolution, namestr form, and
         last-'::' namespace fallback in one place).  Class-typed returns
         are now wrapped C++-side in SWIG_WASMJS_NewPointerObj (consults
         swig_type_info::clientdata, calls M.__wrap_<JsName>); the
         EM_VAL coming back already carries the typed proxy, so we just
         unbox via __from_handle.  No JS-side 'new Cls(__PRIVATE_CTOR,
         ...)' rewrap needed. */
      String *jsname = lookup_js_class(rt);
      if (jsname && Len(jsname) > 0) {
        r = NewStringf("__from_handle(%s)", expr);
      } else {
        /* WASM_JS_DEBUG_WRAP=1 logs lookup misses for tuning the
           pre-pass keyset.  Useful when extending the .i file with new
           class types. */
        if (getenv("WASM_JS_DEBUG_WRAP")) {
          String *cname = SwigType_str(rt, 0);
          Printf(stderr, "[wasm_js wrap miss] %s\n", cname);
          Delete(cname);
        }
        r = NewString(expr);
      }
    }
    Delete(fake);
    return r;
  }

  String *cpp_return_type(SwigType *rt, Node *context = 0) {
    if (!rt)
      return NewString("void");
    String *ts = SwigType_str(rt, 0);
    if (Cmp(ts, "void") == 0)
      return ts;
    Parm *fake = NewParm(rt, context ? Getattr(context, "name") : 0, 0);
    Setattr(fake, "lname", "result");
    Swig_typemap_attach_parms("ctype", fake, 0);
    String *tm = Getattr(fake, "tmap:ctype");
    String *r;
    if (tm) {
      r = Copy(tm);
      Delete(ts);
    } else {
      /* Resolve typedefs before classifying.  Without resolving,
         typedef-aliased primitives like 'std::vector<T>::size_type'
         (which is 'unsigned long') get tagged T_USER and routed
         through the heap-box path -- wrong for primitives. */
      SwigType *resolved = SwigType_typedef_resolve_all(rt);
      SwigType *effective = resolved ? resolved : rt;
      int t = SwigType_type(effective);
      if (t == T_USER) {
        /* Class-shaped types not covered by a ctype typemap fall back to
           the host handle type.  EM_VAL is the wasm-js equivalent of
           PyObject* / mxArray*: an i32 handle into JS's value table. */
        r = NewString("EM_VAL");
        Delete(ts);
      } else {
        r = ts;
      }
      if (resolved)
        Delete(resolved);
    }
    Delete(fake);
    return r;
  }

  /* ======================================================================== */
  /* TypeScript stubs: ports python.cxx's stub system (pickStub / */
  /* resolveStub / stubWriteSignature / stubEmitFunction) and renders */
  /* Python type expressions (read from 'pystub_in' / 'pystub_out' */

  /* type annotations. */
  /* ======================================================================== */

  String *enum_ts_type(Node *node) {
    SwigType *base = Getattr(node, "enumbase");
    if (!base && !GetFlag(node, "scopedenum"))
      return NewString("number | bigint");
    SwigType *resolved = base ? SwigType_typedef_resolve_all(base) : 0;
    int kind = resolved ? SwigType_type(resolved) : T_INT;
    Delete(resolved);
    return NewString(kind == T_LONGLONG || kind == T_ULONGLONG ? "bigint" : "number");
  }

  String *cpp_to_ts(const String *cpp_in) {
    if (!cpp_in || Len(cpp_in) == 0)
      return NewString("any");
    const char *s = Char((String *)cpp_in);
    int n = Len(cpp_in);
    /* Strip whitespace + leading "const" + trailing '& / * / " const"'. */
    while (n > 0 && (s[0] == ' ' || s[0] == '\t')) {
      s++;
      n--;
    }
    while (n > 0 && (s[n - 1] == ' ' || s[n - 1] == '\t'))
      n--;
    if (n > 6 && strncmp(s, "const ", 6) == 0) {
      s += 6;
      n -= 6;
    }
    for (;;) {
      while (n > 0 && (s[n - 1] == '&' || s[n - 1] == '*' || s[n - 1] == ' ' || s[n - 1] == '\t'))
        n--;
      if (n > 6 && strncmp(s + n - 6, " const", 6) == 0) {
        n -= 6;
        continue;
      }
      break;
    }

    String *cpp = NewStringWithSize(s, n);
    Node *enum_node = enumLookup(cpp);
    if (enum_node) {
      String *result = enum_ts_type(enum_node);
      Delete(cpp);
      return result;
    }

    if (Strcmp(cpp, "bool") == 0) {
      Delete(cpp);
      return NewString("boolean");
    }
    if (Strcmp(cpp, "int") == 0 || Strcmp(cpp, "short") == 0 || Strcmp(cpp, "unsigned short") == 0 || Strcmp(cpp, "signed char") == 0 ||
        Strcmp(cpp, "unsigned char") == 0) {
      Delete(cpp);
      return NewString("number");
    }
    if (Strcmp(cpp, "double") == 0) {
      Delete(cpp);
      return NewString("number");
    }
    if (Strcmp(cpp, "float") == 0) {
      Delete(cpp);
      return NewString("number");
    }
    if (Strcmp(cpp, "long") == 0) {
      Delete(cpp);
      return NewString("number");
    }
    if (Strcmp(cpp, "long long") == 0) {
      Delete(cpp);
      return NewString("bigint");
    }
    if (Strcmp(cpp, "unsigned long") == 0) {
      Delete(cpp);
      return NewString("number");
    }
    if (Strcmp(cpp, "unsigned long long") == 0) {
      Delete(cpp);
      return NewString("bigint");
    }
    if (Strcmp(cpp, "unsigned int") == 0) {
      Delete(cpp);
      return NewString("number");
    }
    if (Strcmp(cpp, "unsigned") == 0) {
      Delete(cpp);
      return NewString("number");
    }
    if (Strcmp(cpp, "size_t") == 0) {
      Delete(cpp);
      return NewString("number");
    }
    if (Strcmp(cpp, "std::string") == 0) {
      Delete(cpp);
      return NewString("string");
    }
    if (Strcmp(cpp, "string") == 0) {
      Delete(cpp);
      return NewString("string");
    }
    if (Strcmp(cpp, "std::size_t") == 0) {
      Delete(cpp);
      return NewString("number");
    }
    if (Strcmp(cpp, "void") == 0) {
      Delete(cpp);
      return NewString("void");
    }
    if (Strcmp(cpp, "char") == 0 || Strncmp(cpp, "enum ", 5) == 0) {
      Delete(cpp);
      return NewString("number");
    }
    /* Standard library streams aren't crossed across the wasm boundary -- bind any. */
    if (Strcmp(cpp, "std::istream") == 0 || Strcmp(cpp, "istream") == 0 || Strcmp(cpp, "std::ostream") == 0 || Strcmp(cpp, "ostream") == 0) {
      Delete(cpp);
      return NewString("any");
    }

    /* Render native container shapes recursively, ignoring allocator/comparator parameters. */
    const char *cs = Char(cpp);
    int cn = Len(cpp);
    const char *opening = strchr(cs, '<');
    if (opening && cn > 0 && cs[cn - 1] == '>') {
      String *container = NewStringWithSize(cs, opening - cs);
      bool sequence = Equal(container, "std::vector") || Equal(container, "std::list") || Equal(container, "std::deque") || Equal(container, "std::array");
      bool mapping = Equal(container, "std::map") || Equal(container, "std::multimap") || Equal(container, "std::unordered_map");
      bool set = Equal(container, "std::set") || Equal(container, "std::multiset") || Equal(container, "std::unordered_set");
      bool pair = Equal(container, "std::pair");
      Delete(container);
      if (sequence || mapping || set || pair) {
        List *arguments = NewList();
        const char *start = opening + 1;
        int depth = 0;
        for (const char *at = start; at < cs + cn; ++at) {
          if ((*at == ',' && depth == 0) || at == cs + cn - 1) {
            String *argument = NewStringWithSize(start, at - start);
            Append(arguments, argument);
            Delete(argument);
            start = at + 1;
          } else if (*at == '<') {
            ++depth;
          } else if (*at == '>') {
            --depth;
          }
        }
        if (Len(arguments) >= ((mapping || pair) ? 2 : 1)) {
          String *first = cpp_to_ts(Getitem(arguments, 0));
          String *second = (mapping || pair) ? cpp_to_ts(Getitem(arguments, 1)) : 0;
          String *result = sequence  ? NewStringf("Array<%s>", first)
                           : set     ? NewStringf("Set<%s>", first)
                           : mapping ? NewStringf("Map<%s, %s>", first, second)
                                     : NewStringf("[%s, %s]", first, second);
          Delete(first);
          Delete(second);
          Delete(arguments);
          Delete(cpp);
          return result;
        }
        Delete(arguments);
      }
    }
    String *registered = lookup_bare(cpp);
    if (registered) {
      String *result = Copy(registered);
      Delete(cpp);
      return result;
    }

    /* Pointer / reference suffix: drop -- types cross the wasm
       boundary as opaque references in JS, no '*'/'&' markers. */
    if (cn > 0 && (cs[cn - 1] == '*' || cs[cn - 1] == '&')) {
      String *base = NewStringWithSize(cs, cn - 1);
      String *r = cpp_to_ts(base);
      Delete(base);
      Delete(cpp);
      return r;
    }

    /* Anything still carrying '::' or '<>' is a template instantiation
       or qualified name we don't have a clean TS mapping for -- emit
       'any' rather than invalid TS.  The user can refine via
       %typemap(in/out, tsstub_in/tsstub_out=...) on a per-type basis. */
    bool has_template = false, has_qualifier = false;
    for (int i = 0; i < cn; ++i) {
      if (cs[i] == '<' || cs[i] == '>')
        has_template = true;
      if (cs[i] == ':')
        has_qualifier = true;
    }
    if (has_template || has_qualifier) {
      Delete(cpp);
      return NewString("any");
    }

    return cpp; /* class name, hopefully matching the emitted JS proxy */
  }

  Hash *ts_alias_in_set;
  Hash *ts_alias_out_set;

  /* Drain a '%insert("ts_alias_in")' / '%insert("ts_alias_out")' buffer
     into the named hash.  Each non-blank, non-'#' line contributes one
     identifier whose value gets rewritten to '_<identifier>' when seen
     in a tsstub_* string.  Idempotent: after drain the buffer is
     cleared so subsequent calls are no-ops. */
  void ts_drain_alias_slot(const char *slot, Hash **dst) {
    if (!*dst)
      *dst = NewHash();
    File *f = Swig_filebyname(NewString(slot));
    if (!f || Len((String *)f) == 0)
      return;
    String *s = (String *)f;
    const char *c = Char(s);
    int n = Len(s);
    int start = 0;
    for (int i = 0; i <= n; ++i) {
      if (i == n || c[i] == '\n') {
        /* Trim leading whitespace; skip blank / comment lines. */
        const char *ls = c + start;
        const char *le = c + i;
        while (ls < le && (*ls == ' ' || *ls == '\t'))
          ++ls;
        if (ls < le && *ls != '#') {
          /* First whitespace-delimited token is the identifier. */
          const char *e = ls;
          while (e < le && *e != ' ' && *e != '\t')
            ++e;
          if (e > ls) {
            String *ident = NewStringWithSize(ls, e - ls);
            Setattr(*dst, ident, "1");
            Delete(ident);
          }
        }
        start = i + 1;
      }
    }
    Clear(s); /* idempotent */
  }

  String *ts_apply_aliases(const String *expr, bool is_output) {
    if (!expr || Len(expr) == 0)
      return NewString("any");
    /* Lazy-drain on every call so user .i files can populate the slot
       after the first stub emission. */
    ts_drain_alias_slot("ts_alias_in", &ts_alias_in_set);
    ts_drain_alias_slot("ts_alias_out", &ts_alias_out_set);
    Hash *alias_set = is_output ? ts_alias_out_set : ts_alias_in_set;
    if (!alias_set || Len(alias_set) == 0) {
      /* Empty alias set -- pass through verbatim. */
      return Copy(expr);
    }
    String *out = NewString("");
    const char *s = Char((String *)expr);
    int n = Len(expr);
    int i = 0;
    while (i < n) {
      if (isalpha((unsigned char)s[i]) || s[i] == '_') {
        int j = i;
        while (j < n && (isalnum((unsigned char)s[j]) || s[j] == '_'))
          j++;
        String *ident = NewStringWithSize(s + i, j - i);
        if (Getattr(alias_set, ident)) {
          Printf(out, "_%s", Char(ident));
        } else {
          Printv(out, ident, NIL);
        }
        Delete(ident);
        i = j;
      } else {
        char tmp[2] = {s[i], 0};
        Printv(out, tmp, NIL);
        i++;
      }
    }
    return out;
  }

  String *type_to_ts(SwigType *type, bool output) {
    SwigType *resolved = SwigType_typedef_resolve_all(type);
    SwigType *effective = resolved ? resolved : type;
    String *name = SwigType_str(effective, 0);
    String *native = cpp_to_ts(name);
    String *proxy = lookup_js_class(type);
    bool container = Strncmp(native, "Array<", 6) == 0 || Strncmp(native, "Map<", 4) == 0 || Strncmp(native, "Set<", 4) == 0 || Strncmp(native, "[", 1) == 0;
    Parm *mapped = NewParm(type, 0, 0);
    Swig_typemap_attach_parms(output ? "out" : "in", mapped, 0);
    bool proxy_map = GetFlag(mapped, output ? "tmap:out:tsstub_proxy" : "tmap:in:tsstub_proxy");
    bool nullable = GetFlag(mapped, output ? "tmap:out:tsstub_nullable" : "tmap:in:tsstub_nullable");
    Delete(mapped);
    bool pointer = SwigType_ispointer(effective);
    bool mutable_reference = false;
    if (SwigType_isreference(effective)) {
      SwigType *referent = Copy(effective);
      SwigType_del_reference(referent);
      mutable_reference = !SwigType_isconst(referent);
      Delete(referent);
    }
    if (container && proxy && (pointer || mutable_reference || proxy_map)) {
      Delete(native);
      native = Copy(proxy);
    } else if (container && proxy && !output) {
      String *input = NewStringf("%s | %s", native, proxy);
      Delete(native);
      native = input;
    }
    if (container && !output && !pointer && !mutable_reference && Strncmp(native, "Map<string, ", 12) == 0) {
      String *shape = cpp_to_ts(name);
      String *record = Copy(shape);
      Replace(record, "Map<", "Record<", DOH_REPLACE_FIRST);
      Printf(native, " | %s", record);
      Delete(record);
      Delete(shape);
    }
    if (nullable)
      Append(native, " | null");
    Delete(name);
    Delete(resolved);
    return native;
  }

  String *pick_ts_stub(Parm *pj, bool is_output) {
    const char *attr = is_output ? "tmap:in:tsstub_out" : "tmap:in:tsstub_in";
    String *raw = Getattr(pj, attr);
    String *base = 0;
    if (raw && Len(raw) > 0) {
      base = Copy(raw);
    } else {
      /* Fallback: render the parm's C++ type through cpp_to_ts. */
      SwigType *t = Getattr(pj, "type");
      if (t) {
        base = type_to_ts(t, is_output);
      } else {
        base = NewString("any");
      }
    }
    String *widened = ts_apply_aliases(base, is_output);
    Delete(base);
    return widened;
  }

  /* Emit a TypeScript signature line for one (overload of a) function-like
     node.  Indent = whitespace prefix (4-space inside classes).
     kind: 0=free fn, 1=member, 2=static member, 3=constructor.
     For TS: 'name(arg: T, ...): RetT;' ; constructors are unnamed
     ('constructor(...);').  Static members are prefixed 'static '. */
  void stub_write_signature(String *f, const String *indent, Node *ni, int kind) {
    String *name = Getattr(ni, "sym:name");
    Node *alias = Getattr(ni, "defaultargs");
    Node *source = alias ? alias : ni;

    String *doc = Getattr(ni, "feature:docstring");
    if (!doc)
      doc = Getattr(source, "feature:docstring");
    if (doc && Len(doc) > 0) {
      Printv(f, indent, "/**\n", NIL);
      /* Split on newlines.  Trim leading whitespace from each line to
         normalise the indentation; the JSDoc ' * ' prefix supplies its
         own structure. */
      String *src = NewString(doc);
      List *lines = Split(src, '\n', -1);
      for (int li = 0; li < Len(lines); ++li) {
        String *ln = (String *)Getitem(lines, li);
        const char *s = Char(ln);
        while (*s == ' ' || *s == '\t')
          ++s;
        /* Escape any star-slash sequence inside the docstring so it
           doesn't prematurely close our JSDoc block. */
        Printv(f, indent, " * ", NIL);
        for (const char *p = s; *p; ++p) {
          if (p[0] == '*' && p[1] == '/') {
            Printv(f, "* /", NIL);
            ++p;
          } else {
            char tmp[2] = {*p, 0};
            Printv(f, tmp, NIL);
          }
        }
        Printv(f, "\n", NIL);
      }
      Printv(f, indent, " */\n", NIL);
      Delete(lines);
      Delete(src);
    }

    Printv(f, indent, NIL);
    if (kind == 2)
      Printv(f, "static ", NIL);
    if (kind == 3)
      Printv(f, "constructor(", NIL);
    else if (kind == 0)
      Printv(f, "export function ", name, "(", NIL);
    else
      Printv(f, name, "(", NIL);

    bool first = true;
    Parm *pj = Getattr(source, "wrap:parms");
    if (!pj)
      pj = Getattr(source, "parms");
    /* Attach 'in' typemap to populate tmap:in:pystub_in / pystub_out
       attributes pick_ts_stub() reads.  Idempotent.  Also 'argout' so
       we can detect output-by-reference parms and promote them into
       the return type (the '&OUTPUT' / 'SWIG_OUTPUT' convention used
       by Function::call etc.). */
    if (pj) {
      Swig_typemap_attach_parms("in", pj, 0);
      Swig_typemap_attach_parms("argout", pj, 0);
    }
    /* Collect TS types for 'argout' parms (output-by-reference).  These
       contribute to the return type, not the input list.  Matches
       python.cxx's 'out_types' accumulator. */
    List *argout_ts = NewList();
    /* Detect duplicate parm names so we can rename collisions to
       _arg<N>.  Common with overload-typemap parms that share a name
       ('xType &INOUT' -> all named "INOUT" after typemap apply). */
    Hash *seen_names = NewHash();
    for (Parm *q = pj; q; q = nextSibling(q)) {
      String *nm = Getattr(q, "name");
      if (nm && Len(nm) > 0) {
        if (Getattr(seen_names, nm))
          Setattr(seen_names, nm, "dup");
        else
          Setattr(seen_names, nm, "1");
      }
    }
    int auto_idx = 0;
    while (pj) {
      bool is_input = !checkAttribute(pj, "tmap:in:numinputs", "0");
      bool is_argout = Getattr(pj, "tmap:argout") != 0;
      if (is_argout && !is_input) {

        String *resolved = pick_ts_stub(pj, true);
        Append(argout_ts, resolved);
      } else if (is_input) {
        String *pname = Getattr(pj, "name");
        if (!pname)
          pname = Getattr(pj, "lname");
        bool is_self = pname && Strcmp(pname, "self") == 0;
        if (!is_self) {
          String *ts = pick_ts_stub(pj, false);
          if (!first)
            Printv(f, ", ", NIL);
          /* Duplicate-name collision (e.g. multiple '&INOUT' parms): use
             positional _argN. */
          bool dup = pname && Strcmp((String *)Getattr(seen_names, pname), "dup") == 0;
          if (dup) {
            Printf(f, "_arg%d", auto_idx);
          } else if (pname && Len(pname) > 0 && Strcmp(pname, "self") != 0) {

            if (Strcmp(pname, "var") == 0 || Strcmp(pname, "function") == 0 || Strcmp(pname, "default") == 0 || Strcmp(pname, "class") == 0 ||
                Strcmp(pname, "new") == 0 || Strcmp(pname, "delete") == 0 || Strcmp(pname, "in") == 0 || Strcmp(pname, "of") == 0 ||
                Strcmp(pname, "return") == 0 || Strcmp(pname, "package") == 0 || Strcmp(pname, "private") == 0 || Strcmp(pname, "public") == 0 ||
                Strcmp(pname, "protected") == 0 || Strcmp(pname, "enum") == 0 || Strcmp(pname, "interface") == 0 || Strcmp(pname, "let") == 0 ||
                Strcmp(pname, "const") == 0 || Strcmp(pname, "yield") == 0 || Strcmp(pname, "import") == 0 || Strcmp(pname, "export") == 0) {
              Printf(f, "%s_", pname);
            } else {
              Printv(f, pname, NIL);
            }
          } else {
            Printf(f, "_arg%d", auto_idx);
          }
          String *pvalue = Getattr(pj, "value");
          if (pvalue && Len(pvalue) > 0)
            Printv(f, "?", NIL);
          Printv(f, ": ", ts, NIL);
          Delete(ts);
          first = false;
          if (is_argout) {
            /* INOUT: input AND contributes to return. */
            String *resolved = pick_ts_stub(pj, true);
            Append(argout_ts, resolved);
          }
        }
      }
      auto_idx++;
      Parm *pk = Getattr(pj, "tmap:in:next");
      pj = pk ? pk : nextSibling(pj);
    }

    Delete(seen_names);

    if (kind == 3) {
      Printv(f, ");\n", NIL); /* constructors have no return clause */
    } else {
      Printv(f, "): ", NIL);
      bool is_void = checkAttribute(source, "type", "void");
      int n_argout = Len(argout_ts);
      /* Resolve the natural return type (or "void").  Run the result
         through ts_apply_aliases(is_output=true) so types whose runtime
         marshaling unwraps to a JS primitive (e.g. GenericType)
         render as their '_<name>' union form on output too. */
      String *ret_ts = 0;
      if (!is_void) {
        SwigType *rt = Getattr(source, "type");
        String *po = 0;
        Parm *out_fake = 0;
        if (rt) {
          out_fake = NewParm(rt, Getattr(source, "name"), 0);
          Setattr(out_fake, "lname", "result");
          Swig_typemap_attach_parms("out", out_fake, 0);
          po = Getattr(out_fake, "tmap:out:tsstub_out");
        }
        String *raw = 0;
        if (po && Len(po) > 0) {
          raw = Copy(po);
        } else {
          if (rt) {
            raw = type_to_ts(rt, true);
          } else {
            raw = NewString("any");
          }
        }
        ret_ts = ts_apply_aliases(raw, true);
        Delete(raw);
        if (out_fake)
          Delete(out_fake);
      }
      /* Aggregate (natural return, argout[0], argout[1], ...) into the
         TS return type.  0 things → void; 1 thing → bare; >1 → tuple. */
      int total = (is_void ? 0 : 1) + n_argout;
      if (total == 0) {
        Printv(f, "void", NIL);
      } else if (total == 1) {
        if (!is_void)
          Printv(f, ret_ts, NIL);
        else
          Printv(f, (String *)Getitem(argout_ts, 0), NIL);
      } else {
        Printv(f, "[", NIL);
        bool first_ret = true;
        if (!is_void) {
          Printv(f, ret_ts, NIL);
          first_ret = false;
        }
        for (int i = 0; i < n_argout; ++i) {
          if (!first_ret)
            Printv(f, ", ", NIL);
          Printv(f, (String *)Getitem(argout_ts, i), NIL);
          first_ret = false;
        }
        Printv(f, "]", NIL);
      }
      if (ret_ts)
        Delete(ret_ts);
      Printv(f, ";\n", NIL);
    }
    Delete(argout_ts);
  }

  /* Snapshot the supplied parameters while named typemaps are in scope.
     Default-argument dispatch entries rank only their supplied arguments. */
  void set_dispatch_rank(Hash *entry, Node *source, ParmList *parameters, int arity) {
    Node *node = NewHash();
    Setfile(node, Getfile(source));
    Setline(node, Getline(source));
    Setattr(node, "name", Getattr(source, "name"));
    Setattr(node, "decl", Getattr(source, "decl"));
    Setattr(node, "wrap:name", "wasm_dispatch");
    Setattr(node, "dispatch_source", Getattr(source, "defaultargs") ? Getattr(source, "defaultargs") : source);
    String *argument_count = NewStringf("%d", arity);
    Setattr(node, "dispatch_arity", argument_count);
    Delete(argument_count);
    ParmList *parms = 0;
    Parm *last = 0;
    for (Parm *p = parameters; p && arity; p = nextSibling(p)) {
      if (is_in_numinputs0(p))
        continue;
      Parm *copy = NewParm(Getattr(p, "type"), Getattr(p, "name"), source);
      Setattr(copy, "tmap:in:numinputs", "1");
      Swig_typemap_attach_parms("typecheck", copy, 0);
      if (GetFlag(copy, "tmap:typecheck:wasmjs_enum")) {
        Node *enum_node = enumLookup(Getattr(copy, "type"));
        SwigType *base = enum_node ? Getattr(enum_node, "enumbase") : 0;
        if (base) {
          Parm *underlying = NewParm(base, 0, source);
          Swig_typemap_attach_parms("typecheck", underlying, 0);
          String *precedence = Getattr(underlying, "tmap:typecheck:precedence");
          if (precedence)
            Setattr(copy, "tmap:typecheck:precedence", precedence);
          Delete(underlying);
        }
      }
      if (last) {
        set_nextSibling(last, copy);
        Delete(copy);
      } else {
        parms = copy;
      }
      last = copy;
      --arity;
    }
    Setattr(node, "wrap:parms", parms);
    Setattr(entry, "rank_node", node);
    Delete(parms);
    Delete(node);
  }

  /* Use the common ranker for every callable kind, including subtype
     precedence and lexicographic multi-argument typecheck precedence. */
  void rank_dispatch_entries(List *entries) {
    /* The parser's default-argument copies can duplicate our truncated
       entries. Keep a single entry before asking the common ranker. */
    for (int i = 0; i < Len(entries); ++i) {
      Node *node = Getattr(Getitem(entries, i), "rank_node");
      for (int j = i + 1; j < Len(entries);) {
        Node *other = Getattr(Getitem(entries, j), "rank_node");
        if (Getattr(node, "dispatch_source") == Getattr(other, "dispatch_source") && Equal(Getattr(node, "dispatch_arity"), Getattr(other, "dispatch_arity")))
          Delitem(entries, j);
        else
          ++j;
      }
    }
    if (Len(entries) < 2)
      return;
    Node *first = Getattr(Getitem(entries, 0), "rank_node");
    for (int i = 0; i < Len(entries); ++i) {
      Node *node = Getattr(Getitem(entries, i), "rank_node");
      Setattr(node, "sym:overloaded", first);
      if (i + 1 < Len(entries))
        Setattr(node, "sym:nextSibling", Getattr(Getitem(entries, i + 1), "rank_node"));
      Setattr(node, "dispatch_entry", Getitem(entries, i));
    }
    List *ranked = Swig_overload_rank(first, true);
    List *ordered = NewList();
    for (int i = 0; ranked && i < Len(ranked); ++i)
      Append(ordered, Getattr(Getitem(ranked, i), "dispatch_entry"));
    for (int i = 0; i < Len(entries); ++i) {
      Node *node = Getattr(Getitem(entries, i), "rank_node");
      Delattr(node, "sym:overloaded");
      Delattr(node, "sym:nextSibling");
      Delattr(node, "dispatch_entry");
    }
    Clear(entries);
    for (int i = 0; i < Len(ordered); ++i)
      Append(entries, Getitem(ordered, i));
    Delete(ordered);
    Delete(ranked);
  }

  /* Strip SWIG's __SWIG_<N> overload-numbering suffix from a sym:name. */
  String *stub_bare_jsname(const String *symname) {
    String *bare = NewString(symname);
    const char *suf = Strstr(bare, "__SWIG_");
    if (suf)
      Delslice(bare, suf - Char(bare), DOH_END);
    return bare;
  }

  void stub_emit_function(Node *n, const String *indent, int kind) {
    if (!stubs || !f_stubs)
      return;
    List *dispatch = Swig_overload_rank(n, true);
    int nfunc = dispatch ? Len(dispatch) : 0;
    List *single = 0;
    if (nfunc == 0) {
      single = NewList();
      Append(single, n);
      dispatch = single;
      nfunc = 1;
    }
    for (int i = 0; i < nfunc; ++i) {
      Node *ni = Getitem(dispatch, i);
      if (kind == 0) {
        /* Free function: bucket per jsname for sorted emission at
           top()-end.  Per-call writes to f_stubs are out of order
           (each %template instantiation emits a separate cdecl in
           C++-parse order, not by precedence), and TS picks the
           FIRST matching overload -- so we need most-specific first. */
        if (!stub_free_fn_buckets) {
          stub_free_fn_buckets = NewHash();
          stub_free_fn_order = NewList();
        }
        String *body = NewString("");
        stub_write_signature(body, indent, ni, kind);
        String *symname = Getattr(ni, "sym:name");
        String *bare = symname ? stub_bare_jsname(symname) : NewString("");
        List *bucket = (List *)Getattr(stub_free_fn_buckets, bare);
        if (!bucket) {
          bucket = NewList();
          Setattr(stub_free_fn_buckets, bare, bucket);
          Append(stub_free_fn_order, Copy(bare));
        }
        Hash *entry = NewHash();
        ParmList *parms = Getattr(ni, "parms");
        set_dispatch_rank(entry, ni, parms, parm_arity_js(parms));
        Setattr(entry, "body", body);
        Append(bucket, entry);
        Delete(bare);
        Delete(entry);
      } else {
        if (!stub_method_buckets) {
          stub_method_buckets = NewHash();
          stub_method_order = NewList();
        }
        String *bare = stub_bare_jsname(Getattr(ni, "sym:name"));
        String *key = NewStringf("%s::%d::%s", class_jsname, kind, bare);
        List *bucket = Getattr(stub_method_buckets, key);
        if (!bucket) {
          bucket = NewList();
          Setattr(stub_method_buckets, key, bucket);
          Append(stub_method_order, key);
          Delete(bucket);
        }
        Hash *entry = NewHash();
        ParmList *parms = Getattr(ni, "parms");
        set_dispatch_rank(entry, ni, parms, parm_arity_js(parms));
        String *body = NewString("");
        stub_write_signature(body, indent, ni, kind);
        Setattr(entry, "body", body);
        Delete(body);
        Setattr(entry, "class", class_jsname);
        if (kind == 2) {
          String *instance = NewString("");
          stub_write_signature(instance, indent, ni, 1);
          Setattr(entry, "instance_body", instance);
          String *instance_key = NewStringf("%s::%s", class_jsname, bare);
          Setattr(entry, "instance_key", instance_key);
          Delete(instance_key);
          Delete(instance);
        }
        Append(bucket, entry);
        Delete(entry);
        Delete(key);
        Delete(bare);
      }
    }
    if (single)
      Delete(single);
  }

  void stub_drain_method_buckets() {
    for (int i = 0; stub_method_order && i < Len(stub_method_order); ++i) {
      List *bucket = Getattr(stub_method_buckets, Getitem(stub_method_order, i));
      if (!Len(bucket) || !Equal(Getattr(Getitem(bucket, 0), "class"), class_jsname))
        continue;
      rank_dispatch_entries(bucket);
      for (int j = 0; j < Len(bucket); ++j) {
        Hash *entry = Getitem(bucket, j);
        Printv(f_stubs_class_body, Getattr(entry, "body"), NIL);
        if (Getattr(entry, "instance_body")) {
          if (!stub_static_instance_pending)
            stub_static_instance_pending = NewHash();
          String *key = Getattr(entry, "instance_key");
          String *body = Getattr(stub_static_instance_pending, key);
          if (!body) {
            body = NewString("");
            Setattr(stub_static_instance_pending, key, body);
            Delete(body);
          }
          Append(body, Getattr(entry, "instance_body"));
        }
      }
      Clear(bucket);
    }
  }

  /* Drain free-function declarations in canonical overload order at
     module end, after all template instantiations have been visited. */
  void stub_drain_free_fn_buckets() {
    if (!stub_free_fn_buckets || !stub_free_fn_order || !f_stubs_module)
      return;
    Printv(f_stubs_module, "\n// --- Free functions (overloads sorted most-specific first for TS) ---\n", NIL);
    int nb = Len(stub_free_fn_order);
    for (int i = 0; i < nb; ++i) {
      String *name = (String *)Getitem(stub_free_fn_order, i);
      List *bucket = (List *)Getattr(stub_free_fn_buckets, name);
      if (!bucket)
        continue;
      rank_dispatch_entries(bucket);
      for (int a = 0; a < Len(bucket); ++a) {
        Hash *e = Getitem(bucket, a);
        Printv(f_stubs_module, Getattr(e, "body"), NIL);
      }
    }
  }

  /* Member-variable annotation: 'name: T;' (or readonly if appropriate). */
  void stub_emit_variable(Node *n, const String *indent) {
    if (!stubs || !f_stubs)
      return;
    String *symname = Getattr(n, "sym:name");
    if (!symname)
      return;
    String *ts = 0;
    SwigType *t = Getattr(n, "type");
    Parm *out_fake = 0;
    String *po = 0;
    if (t) {
      out_fake = NewParm(t, Getattr(n, "name"), 0);
      Setattr(out_fake, "lname", "result");
      Swig_typemap_attach_parms("out", out_fake, 0);
      po = Getattr(out_fake, "tmap:out:tsstub_out");
    }
    String *raw = 0;
    if (po && Len(po) > 0) {
      raw = Copy(po);
    } else if (t) {
      raw = type_to_ts(t, true);
    } else {
      raw = NewString("any");
    }
    ts = ts_apply_aliases(raw, true);
    Delete(raw);
    Printv(f_stubs, indent, GetFlag(n, "feature:immutable") || SwigType_isconst(t) ? "readonly " : "", symname, ": ", ts, ";\n", NIL);
    if (out_fake)
      Delete(out_fake);
    Delete(ts);
  }

  /* Build the full C-wrapper body: locals, in typemaps, call, out typemap,
     freearg, return.  call_expr should use the lnames (arg1, arg2, ...)
     declared by the in typemaps.  For void returns the call is just
     emitted as a statement. */
  /* True if rt is a genuine user-defined type (class/struct) after
     typedef resolution.  A typedef-aliased primitive like
     'std::vector<T>::size_type' (resolves to 'unsigned long') has
     SwigType_type == T_USER pre-resolve, but it's a primitive and
     shouldn't be heap-boxed. */
  bool is_genuinely_user_type(SwigType *rt) {
    if (!rt)
      return false;
    if (SwigType_type(rt) != T_USER)
      return false;
    SwigType *resolved = SwigType_typedef_resolve_all(rt);
    SwigType *t = resolved ? resolved : rt;
    bool ok = (SwigType_type(t) == T_USER);
    if (resolved)
      Delete(resolved);
    return ok;
  }

  /* Count parms carrying an 'argout' typemap (e.g. 'xType &OUTPUT').
     These contribute extra outputs that the wrapper packs into its
     return value.  Idempotent attach. */
  int count_argouts(ParmList *p) {
    Swig_typemap_attach_parms("argout", p, 0);
    int n = 0;
    for (Parm *q = p; q; q = nextSibling(q)) {
      String *tm = Getattr(q, "tmap:argout");
      if (tm && Len(tm) > 0)
        ++n;
    }
    return n;
  }

  /* Emit each parm's argout typemap body, with $1 substituted to the
     parm's lname.  Bodies use the SWIGWASMJS %append_output expansion
     (defined in wasm_js.swg) which writes into _argouts. */
  String *emit_argout_bodies(ParmList *p) {
    Swig_typemap_attach_parms("argout", p, 0);
    String *out = NewString("");
    for (Parm *q = p; q; q = nextSibling(q)) {
      String *tm = Getattr(q, "tmap:argout");
      if (!tm || Len(tm) == 0)
        continue;
      String *body = Copy(tm);
      String *lname = Getattr(q, "lname");
      if (lname)
        Replaceall(body, "$1", lname);
      Printf(out, "  %s\n", body);
      Delete(body);
    }
    return out;
  }

  /* When the function has argouts, the JS-visible "return" is no
     longer the C++ rt -- it's the (single) argout's type for n=1.
     Used by handlers building the JS call site so js_marshal_return
     wraps the right proxy class.  For multi-argout or rt-and-argouts
     cases the wrapper packs into a heap void**; JS-side unpacking is
     emitted by the caller. */
  SwigType *effective_js_return_type(SwigType *rt, ParmList *p) {
    int n = count_argouts(p);
    if (n == 0)
      return rt;
    String *ts = rt ? SwigType_str(rt, 0) : 0;
    bool is_void = !rt || (ts && Cmp(ts, "void") == 0);
    if (ts)
      Delete(ts);
    if (n == 1 && is_void) {
      for (Parm *q = p; q; q = nextSibling(q)) {
        String *tm = Getattr(q, "tmap:argout");
        if (tm && Len(tm) > 0)
          return Getattr(q, "type");
      }
    }
    return 0; /* multi-argout / rt+argout: caller emits unpacker */
  }

  /* The wrapper's actual C return type, accounting for argouts.
       - rt void  + 0 argouts -> "void"
       - rt void  + >=1 argouts -> "void*"  (single ptr or heap array)
       - rt T     + 0 argouts -> cpp_return_type(rt)  (existing)
       - rt T     + >=1 argouts -> "void*"  (packed)
     Callers (memberfunctionHandler etc.) use this to emit the
     EMSCRIPTEN_KEEPALIVE wrapper signature. */
  String *effective_return_ctype(SwigType *rt, ParmList *p, Node *context = 0) {
    int n_argouts = count_argouts(p);
    if (n_argouts == 0) {
      if (!rt)
        return NewString("void");
      String *ts = SwigType_str(rt, 0);
      if (Cmp(ts, "void") == 0)
        return ts;
      Delete(ts);
      return cpp_return_type(rt, context);
    }
    return NewString("void*");
  }

  /* Use the common extension helper generator while retaining the wasm call ABI. */
  String *extension_call(Node *n, SwigType *rt, const String *args, bool receiver, const String *fallback) {
    if (!GetFlag(n, "feature:extend") || (Getattr(n, "template") && !GetFlag(n, "isextendmember")))
      return Copy(fallback);
    Node *source = Getattr(n, "defaultargs");
    if (!source)
      source = n;
    String *helper = Getattr(source, "wasm:extend:helper");
    if (!helper) {
      String *member;
      if (Equal(nodeType(n), "constructor"))
        member = Swig_name_construct(0, class_cname);
      else if (Equal(nodeType(n), "destructor"))
        member = Swig_name_destroy(0, class_cname);
      else
        member = Swig_name_member(0, class_cname, Getattr(n, "name"));
      helper = Swig_name_mangle_string(member);
      Delete(member);
      String *code = Getattr(source, "code");
      if (code && Getattr(source, "sym:overloaded"))
        Append(helper, Getattr(source, "sym:overname"));
      Setattr(source, "wasm:extend:helper", helper);
      if (code) {
        ParmList *parameters = CopyParmList(Getattr(source, "parms"));
        if (receiver) {
          SwigType *type = Copy(class_cname);
          String *qualifier = Getattr(n, "qualifier");
          if (qualifier)
            SwigType_push(type, qualifier);
          SwigType_add_pointer(type);
          Parm *self = NewParm(type, "self", n);
          set_nextSibling(self, parameters);
          Delete(parameters);
          parameters = self;
          Delete(type);
        }
        Swig_add_extension_code(source, helper, parameters, rt, code, CPlusPlus, "self");
        Printv(Swig_filebyname("header"), Getattr(source, "wrap:code"), NIL);
        Setattr(source, "wrap:code:done", Swig_filebyname("header"));
        Delete(parameters);
      }
      Delete(helper);
      helper = Getattr(source, "wasm:extend:helper");
    }
    return NewStringf("%s(%s%s%s)", helper, receiver ? "self" : "", receiver && Len(args) ? ", " : "", args);
  }

  String *owned_input_handles(ParmList *parms) {
    Swig_typemap_attach_parms("ctype", parms, 0);
    Swig_typemap_attach_parms("in", parms, 0);
    String *guards = NewString("");
    int index = 0;
    for (Parm *p = parms; p; p = nextSibling(p)) {
      if (is_in_numinputs0(p))
        continue;
      if (Equal(Getattr(p, "tmap:ctype"), "EM_VAL"))
        Printf(guards, "  emscripten::val _input%d = obj%d ? emscripten::val::take_ownership(obj%d) : emscripten::val::undefined();\n", index, index, index);
      ++index;
    }
    return guards;
  }

  String *cpp_call_body(Node *n, ParmList *p, SwigType *rt, const String *call_expr, bool own_inputs = true) {
    String *out = own_inputs ? owned_input_handles(p) : NewString("");

    Printf(out, "  {\n");

    /* Locals + in conversions. */
    String *prologue = parm_prologue(p);
    Printv(out, prologue, NIL);
    Delete(prologue);

    /* Argout handling: count, declare a fixed-size slot array, emit the
       per-parm 'argout' body (uses wasm_js.swg's %append_output macro
       that writes into _argouts via _argout_idx). */
    int n_argouts = count_argouts(p);
    if (n_argouts > 0) {
      Printf(out, "  void* _argouts[%d] = {0};\n", n_argouts);
      Printf(out, "  int _argout_idx = 0;\n");
    }

    /* void return + no argouts: emit call as statement, run freearg, return. */
    String *ts = rt ? SwigType_str(rt, 0) : NewString("void");
    bool is_void_rt = (!rt || Cmp(ts, "void") == 0);
    Delete(ts);
    if (is_void_rt && n_argouts == 0) {
      Printf(out, "  %s;\n", call_expr);
      Printf(out, "  return;\n");
      Printf(out, "  }\n"); /* close the body-wrap block */
      emit_fail_label(out, rt, p, n);
      return out;
    }

    /* void return + argouts: call as statement, emit argout bodies,
       pack and return.  Skip the rest of the result-binding logic. */
    if (is_void_rt) {
      Printf(out, "  %s;\n", call_expr);
      String *argouts_body = emit_argout_bodies(p);
      Printv(out, argouts_body, NIL);
      Delete(argouts_body);
      /* Pack: single output returned directly; multiple packed into a
         heap void** with caller responsible for freeing each + the
         array (JS-side proxy handles cleanup). */
      if (n_argouts == 1) {
        Printf(out, "  return _argouts[0];\n");
      } else {
        Printf(out, "  void** _packed = (void**)malloc(%d * sizeof(void*));\n", n_argouts);
        Printf(out, "  for (int _i = 0; _i < %d; ++_i) _packed[_i] = _argouts[_i];\n", n_argouts);
        Printf(out, "  return (void*)_packed;\n");
      }
      Printf(out, "  }\n"); /* close the body-wrap block */
      emit_fail_label(out, rt, p, n);
      return out;
    }

    /* Non-void: declare result, run call, run out typemap, freearg, return.
       Use SWIG core's Swig_cresult() to build the assignment line — it
       dispatches on SwigType_type(rt) to insert '& <cast>' for
       T_REFERENCE returns (matching matlab.cxx's 'result = (T *) &foo()'
       pattern) and a plain '=' for T_USER value returns.

       For value class returns we wrap with SwigValueWrapper<T> (the
       Fulton transform): cplus_value_type returns that wrapper for any
       class without a public default ctor or that isn't copy-assignable,
       and null for "normal" types (where the original type works).  This
       matches emit_return_variable() in Source/Modules/emit.cxx and is
       what matlab.cxx ends up with via Swig_typemap_lookup_out + the
       standard "out" typemap library. */
    SwigType *vt = cplus_value_type(rt);
    SwigType *tt = vt ? vt : rt;
    SwigType *ltype = SwigType_ltype(tt);
    String *result_decl = SwigType_str(ltype, NewString("result"));
    if (SwigType_ispointer(ltype)) {
      Printf(out, "  %s = 0;\n", result_decl);
    } else {
      Printf(out, "  %s;\n", result_decl);
    }
    Delete(result_decl);
    Delete(ltype);
    if (vt)
      Delete(vt);
    /* Swig_cresult emits 'result = (T*) & <call>;' for refs,
       'result = <call>;' for user values, etc. — matlab pattern. */
    String *cres = Swig_cresult(rt, NewString("result"), call_expr);
    Printf(out, "  %s\n", cres);
    Delete(cres);

    /* out typemap: $1 substituted to "result" by attach (lname=result).
       $result substituted manually to "_outv". */
    Parm *fake = NewParm(rt, Getattr(n, "name"), 0);
    Setattr(fake, "lname", "result");
    Swig_typemap_attach_parms("out", fake, 0);
    String *tm = Getattr(fake, "tmap:out");
    String *ctype = cpp_return_type(rt, n);
    Printf(out, "  %s _outv;\n", ctype);
    if (tm) {
      String *body = Copy(tm);
      Replaceall(body, "$result", "_outv");
      Replaceall(body, "$owner", GetFlag(n, "feature:new") ? "SWIG_POINTER_OWN" : "0");
      Printf(out, "  %s\n", body);
      Delete(body);
    } else if (is_genuinely_user_type(rt)) {

      SwigType *lt = SwigType_ltype(rt);
      String *lt_str = SwigType_str(lt, 0);
      /* T_USER + no explicit 'out' typemap: heap-clone the result and
         wrap as an EM_VAL via SWIG_NewPointerObj.  Pass the proper
         swig_type_info* (looked up by SWIG-mangled pointer name) so
         the runtime's clientdata branch fires and produces a
         fully-typed JS proxy via M.__wrap_<JsName>(ptr), instead of
         a bare '{_ptr}' carrier.  Without this, 'opti.solve()' etc.
         return raw carriers and downstream '.value()' calls fail
         with "method is not a function".  Stash the 'new' result in
         a local first: lt_str may contain template commas (e.g.
         std::pair<A, B>), which the C preprocessor would otherwise
         tokenize as multiple macro args.  __ti is function-local
         static so the SWIG_TypeQuery hash lookup happens once. */
      SwigType *ptr_t = Copy(rt);
      SwigType_add_pointer(ptr_t);
      String *mangled = SwigType_manglestr(ptr_t);
      Printf(out, "  %s* _heap = new %s(result);\n", lt_str, lt_str);
      Printf(out,
             "  static swig_type_info* __out_ti = SWIG_TypeQuery(\"%s\");\n"
             "  _outv = SWIG_NewPointerObj(_heap, __out_ti, SWIG_POINTER_OWN);\n",
             mangled);
      Delete(mangled);
      Delete(ptr_t);
      Delete(lt_str);
      Delete(lt);
    } else {
      Printf(out, "  _outv = result;\n"); /* identity default */
    }
    Delete(fake);
    Delete(ctype);

    /* Argout bodies fire after the call (operate on populated arg
       locals) but before freearg.  Their %append_output expansion
       writes into _argouts[]. */
    if (n_argouts > 0) {
      String *argouts_body = emit_argout_bodies(p);
      Printv(out, argouts_body, NIL);
      Delete(argouts_body);
    }

    /* Return packing:
         - 0 argouts: just _outv.
         - argouts present: pack (_outv, _argouts...) into heap void**.
           The wrapper-level effective_return_ctype is void* in this case. */
    if (n_argouts == 0) {
      Printf(out, "  return _outv;\n");
    } else {
      int total = n_argouts + 1;
      Printf(out, "  void** _packed = (void**)malloc(%d * sizeof(void*));\n", total);
      Printf(out, "  _packed[0] = (void*)_outv;\n");
      Printf(out, "  for (int _i = 0; _i < %d; ++_i) _packed[1+_i] = _argouts[_i];\n", n_argouts);
      Printf(out, "  return (void*)_packed;\n");
    }
    Printf(out, "  }\n"); /* close the body-wrap block */
    /* fail: label.  Reached via SWIG_fail / SWIG_exception_fail from
       any in-typemap that fails conversion.  Returns a zero sentinel
       (null EM_VAL / NULL pointer / 0 numeric).  JS-side dispatcher
       checks '_swig_last_error_code()' after the call and throws. */
    emit_fail_label(out, rt, p, n);
    return out;
  }

  /* Append 'fail: return <sentinel>;' to the wrapper body.  The sentinel
     is ';' for void returns and '(ret_t)0;' for everything else (EM_VAL,
     void*, int, double, const char*, enums — the C-style cast handles
     them all uniformly).  The label is emitted unconditionally; wrappers
     with no SWIG_fail-using typemaps will warn "unused label" but compile
     cleanly. */
  void emit_fail_label(String *out, SwigType *rt, ParmList *p, Node *n) {
    String *ret_t = effective_return_ctype(rt, p, n);
    bool is_void = (Cmp(ret_t, "void") == 0);
    Printf(out, "fail:\n");
    if (is_void) {
      Printf(out, "  return;\n");
    } else {
      Printf(out, "  return (%s)0;\n", ret_t);
    }
    Delete(ret_t);
  }
};

int WASM_JS::classDirectorInit(Node *n) {
  String *declaration = Swig_director_declaration(n);
  Printf(f_directors_h, "\n%s\npublic:\n", declaration);
  Delete(declaration);
  return Language::classDirectorInit(n);
}

int WASM_JS::classDirectorEnd(Node *n) {
  Printf(f_directors_h, "};\n\n");
  return Language::classDirectorEnd(n);
}

int WASM_JS::classDirectorConstructor(Node *n) {
  Node *parent = Getattr(n, "parentNode");
  String *supername = Swig_class_name(parent);
  String *classname = NewStringf("SwigDirector_%s", supername);
  String *decl = Getattr(n, "decl");

  /* Build parm list: prepend 'EM_VAL js_self' to the user ctor's parms. */
  ParmList *superparms = Getattr(n, "parms");
  ParmList *parms = CopyParmList(superparms);
  SwigType *self_type = NewString("EM_VAL");
  Parm *self_p = NewParm(self_type, NewString("js_self"), n);
  set_nextSibling(self_p, parms);
  parms = self_p;

  if (!Getattr(n, "defaultargs")) {
    /* Implementation. */
    Wrapper *w = NewWrapper();
    String *target = Swig_method_decl(0, decl, classname, parms, 0);
    String *call = Swig_csuperclass_call(0, Getattr(parent, "classtype"), superparms);
    Printf(w->def, "%s::%s : %s, Swig::Director(js_self) { }\n\n", classname, target, call);
    Wrapper_print(w, f_directors);
    Delete(target);
    Delete(call);
    DelWrapper(w);
    /* Header decl. */
    String *hdr = Swig_method_decl(0, decl, classname, parms, 1);
    Printf(f_directors_h, "    %s;\n", hdr);
    Delete(hdr);

    /* C-linkage wrapper for the default ctor overload: superparms == 0
       (no user parms besides js_self).  JS-side new.target hook calls
       this when constructing the director instance. */
    if (ParmList_len(superparms) == 0) {
      Printf(f_cpp_wrappers,
             "EMSCRIPTEN_KEEPALIVE void* swig_new_SwigDirector_%s(EM_VAL js_self) {\n"
             "  emscripten::val _self_owner = emscripten::val::take_ownership(js_self);\n"
             "  return static_cast<void*>(new %s(js_self));\n"
             "}\n",
             supername,
             classname);
      Printf(f_out_exports, "_swig_new_SwigDirector_%s\n", supername);
      if (!director_classes)
        director_classes = NewHash();
      Setattr(director_classes, Getattr(parent, "name"), "1");
    }
  }

  Delete(classname);
  Delete(supername);
  Delete(self_type);
  Delete(parms);
  return Language::classDirectorConstructor(n);
}

int WASM_JS::classDirectorDefaultConstructor(Node *n) {
  String *classname = Swig_class_name(n);
  Node *parent = Swig_methodclass(n);
  String *basetype = Getattr(parent, "classtype");
  (void)basetype;

  Wrapper *w = NewWrapper();
  Printf(w->def, "SwigDirector_%s::SwigDirector_%s(EM_VAL js_self) : Swig::Director(js_self) { }\n\n", classname, classname);
  Wrapper_print(w, f_directors);
  DelWrapper(w);

  Printf(f_directors_h, "    SwigDirector_%s(EM_VAL js_self);\n", classname);

  /* C-linkage wrapper exposing the director ctor to JS.  The JS proxy
     class's ctor calls this when new.target detects a JS subclass.
     Emitted into f_cpp_wrappers so it lands inside the extern "C" block. */
  String *export_name = NewStringf("_swig_new_SwigDirector_%s", classname);
  Printf(f_cpp_wrappers,
         "EMSCRIPTEN_KEEPALIVE void* swig_new_SwigDirector_%s(EM_VAL js_self) {\n"
         "  emscripten::val _self_owner = emscripten::val::take_ownership(js_self);\n"
         "  return static_cast<void*>(new SwigDirector_%s(js_self));\n"
         "}\n",
         classname,
         classname);
  Printf(f_out_exports, "%s\n", export_name);
  Delete(export_name);

  /* Record director-enablement keyed by C++ classname so classHandler
     can inject the JS-side new.target detection at ctor emission time. */
  if (!director_classes)
    director_classes = NewHash();
  Setattr(director_classes, Getattr(parent, "name"), "1");

  Delete(classname);
  return Language::classDirectorDefaultConstructor(n);
}

int WASM_JS::classDirectorMethod(Node *n, Node *parent, String *super) {
  (void)super;
  String *name = Getattr(n, "name");
  String *classname = Getattr(parent, "sym:name");
  String *c_classname = Getattr(parent, "name");
  SwigType *returntype = Getattr(n, "type");
  ParmList *l = Getattr(n, "parms");
  String *decl = Getattr(n, "decl");
  String *storage = Getattr(n, "storage");
  String *value = Getattr(n, "value");
  bool pure_virtual = (Cmp(storage, "virtual") == 0) && (value && Cmp(value, "0") == 0);
  bool is_void = (Cmp(returntype, "void") == 0);
  int status = SWIG_OK;

  /* Build the override signature.  Use Swig_method_decl with the */
  /* qualified name "SwigDirector_<C>::<name>" for the impl, and the */
  /* unqualified name for the header decl. */
  SwigType *rtype = Getattr(n, "conversion_operator") ? 0 : Getattr(n, "classDirectorMethods:type");
  String *pclassname = NewStringf("SwigDirector_%s", classname);
  String *qualname = NewStringf("%s::%s", pclassname, name);
  String *impl_sig = Swig_method_decl(rtype, decl, qualname, l, 0);
  String *hdr_sig = Swig_method_decl(rtype, decl, name, l, 1);
  bool is_const = SwigType_isconst(decl);

  /* Attach in / directorin typemaps so the per-parm bodies (and the */
  /* 'tmap:in:numinputs' attribute used to skip server-side filled */
  /* parms) are available below.  directorout is looked up downstream */
  /* via Swig_typemap_lookup (single value -- not per-parm). */
  Swig_director_parms_fixup(l);
  Swig_typemap_attach_parms("in", l, 0);
  Swig_typemap_attach_parms("directorin", l, 0);

  Wrapper *w = NewWrapper();
  Printf(w->def, "%s%s {\n", impl_sig, is_const ? "" : "");

  /* Prologue: ask the JS proxy whether the subclass actually overrides */
  /* this method.  Walk up the prototype chain until we hit the SWIG- */
  /* generated base proto (recorded as 'M.__base_proto_<C>'); if we find */
  /* an own-property match on '<name>' first, dispatch to JS.  Otherwise */
  /* fall through to the C++ base impl (no JS-side roundtrip). */
  Printf(w->code,
         "  emscripten::val __js_self = this->swig_get_self();\n"
         "  bool __overridden = false;\n"
         "  if (!__js_self.isUndefined() && !__js_self.isNull()) {\n"
         "    emscripten::val __proto = emscripten::val::global(\"Object\")"
         ".call<emscripten::val>(\"getPrototypeOf\", __js_self);\n"
         "    emscripten::val __base = emscripten::val::module_property(\"__base_proto_%s\");\n"
         "    while (!__proto.isUndefined() && !__proto.isNull()) {\n"
         "      if (!__base.isUndefined() && __proto.strictlyEquals(__base)) break;\n"
         "      if (__proto.call<emscripten::val>(\"hasOwnProperty\", emscripten::val(\"%s\")).as<bool>()) { __overridden = true; break; }\n"
         "      __proto = emscripten::val::global(\"Object\")"
         ".call<emscripten::val>(\"getPrototypeOf\", __proto);\n"
         "    }\n"
         "  }\n",
         classname,
         name);

  Printf(w->code, "  if (!__overridden) {\n");
  if (pure_virtual) {
    Printf(w->code, "    Swig::DirectorPureVirtualException::raise(\"%s::%s\");\n", classname, name);
    if (!is_void) {
      String *rt_str = SwigType_str(returntype, 0);
      Printf(w->code, "    return %s();\n", rt_str);
      Delete(rt_str);
    }
  } else {
    if (is_void) {
      Printf(w->code, "    %s::%s(", c_classname, name);
    } else {
      Printf(w->code, "    return %s::%s(", c_classname, name);
    }
    int comma = 0;
    for (Parm *p = l; p; p = nextSibling(p)) {
      String *pname = Getattr(p, "name");
      if (!pname || Len(pname) == 0)
        continue;
      if (comma)
        Printf(w->code, ", ");
      Printf(w->code, "%s", pname);
      comma = 1;
    }
    Printf(w->code, ");\n");
    if (is_void)
      Printf(w->code, "    return;\n");
  }
  Printf(w->code, "  }\n");

  /* Per-parm directorin bodies.  Each parm becomes one EM_VAL local */
  /* populated by the typemap body, then pushed onto __args (a JS array) */
  /* wrapped in val::take_ownership.  numinputs=0 parms (server-side */
  /* filled argouts) skip the JS side entirely.  Locals from typemap */
  /* bodies are scoped with a fresh '{ }' block so name collisions */
  /* across parms don't matter. */
  String *args_build = NewString("");
  Printf(args_build, "    emscripten::val __args = emscripten::val::array();\n");
  int idx = 0;
  for (Parm *p = l; p; p = nextSibling(p)) {
    if (checkAttribute(p, "tmap:in:numinputs", "0"))
      continue;
    SwigType *pt = Getattr(p, "type");
    String *tm = Getattr(p, "tmap:directorin");
    if (!tm) {
      Swig_warning(WARN_TYPEMAP_DIRECTORIN_UNDEF,
                   input_file,
                   line_number,
                   "Unable to use type %s as a function argument in director method %s::%s (skipping method).\n",
                   SwigType_str(pt, 0),
                   SwigType_namestr(c_classname),
                   SwigType_namestr(name));
      status = SWIG_NOWRAP;
      break;
    }
    String *oname = NewStringf("__obj%d", idx++);
    String *body = Copy(tm);
    Replaceall(body, "$input", oname);
    Printf(args_build, "    EM_VAL %s = 0;\n", oname);
    Printf(args_build, "    {\n      %s\n    }\n", body);
    Printf(args_build, "    __args.call<void>(\"push\", emscripten::val::take_ownership(%s));\n", oname);
    Delete(oname);
    Delete(body);
  }

  /* Return-value directorout body (skipped for void returns). */
  /* classDirectorMethod declares '<lstr> c_result;' then releases */
  /* ownership of __ret into __ret_handle (an EM_VAL).  The typemap body */
  /* reads $input=__ret_handle and assigns $result=c_result. */
  String *ret_marshal = NewString("");
  if (status == SWIG_OK && !is_void) {
    String *tm = Swig_typemap_lookup("directorout", n, Swig_cresult_name(), 0);
    if (!tm) {
      Swig_warning(WARN_TYPEMAP_DIRECTOROUT_UNDEF,
                   input_file,
                   line_number,
                   "Unable to use return type %s in director method %s::%s (skipping method).\n",
                   SwigType_str(returntype, 0),
                   SwigType_namestr(c_classname),
                   SwigType_namestr(name));
      status = SWIG_NOWRAP;
    } else {
      String *cres = SwigType_lstr(returntype, "c_result");
      Printf(ret_marshal, "    %s;\n", cres);
      Delete(cres);
      Printf(ret_marshal, "    EM_VAL __ret_handle = __ret.release_ownership();\n");
      Replaceall(tm, "$input", "__ret_handle");
      Replaceall(tm, "$result", "c_result");
      Printf(ret_marshal, "    %s\n", tm);
      Printf(ret_marshal, "    return c_result;\n");
      Delete(tm);
    }
  }

  if (status == SWIG_OK) {
    Printf(w->code, "  try {\n");
    Printv(w->code, args_build, NIL);
    Printf(w->code, "    emscripten::val __ret = __js_self[\"%s\"].call<emscripten::val>(\"apply\", __js_self, __args);\n", name);
    if (is_void) {
      Printf(w->code, "    (void)__ret;\n");
      Printf(w->code, "    return;\n");
    } else {
      Printv(w->code, ret_marshal, NIL);
    }
    Printf(w->code, "  } catch (const std::exception &__e) {\n");
    Printf(w->code, "    throw std::runtime_error(std::string(\"JS director: \") + __e.what());\n");
    Printf(w->code, "  }\n");
  }
  Printf(w->code, "}\n\n");

  if (status == SWIG_OK) {
    Printf(f_directors_h, "    virtual %s;\n", hdr_sig);
    Wrapper_print(w, f_directors);
    /* Remember that this class is director-enabled, so classHandler / */
    /* top() can emit the C-linkage ctor wrapper and the JS-side shim. */
    if (!director_classes)
      director_classes = NewHash();
    Setattr(director_classes, Getattr(parent, "name"), "1");
  }

  Delete(args_build);
  Delete(ret_marshal);
  Delete(impl_sig);
  Delete(hdr_sig);
  Delete(qualname);
  Delete(pclassname);
  DelWrapper(w);
  return SWIG_OK;
}

/* ============================ main / top ==================================== */

void WASM_JS::main(int argc, char *argv[]) {
  for (int i = 1; i < argc; ++i) {
    if (!argv[i])
      continue;
    if (strcmp(argv[i], "-help") == 0) {
      fputs(usage, stdout);
    } else if (strcmp(argv[i], "-stubs") == 0) {
      stubs = 1;

      Preprocessor_define("SWIG_STUBS_ENABLED", 0);
      Swig_mark_arg(i);
    }
  }
  SWIG_library_directory("wasm_js");
  Preprocessor_define("SWIGWASMJS 1", 0);
  SWIG_config_file("wasm_js.swg");
  allow_overloading();
}

int WASM_JS::top(Node *n) {
  if (!CPlusPlus) {
    Swig_error(input_file, line_number, "The -wasm-js target requires -c++.\n");
    return SWIG_ERROR;
  }
  String *module_name = Getattr(n, "name");
  String *outfile = Getattr(n, "outfile");

  Node *optionsNode = Getattr(n, "options");
  if (optionsNode && Getattr(optionsNode, "directors")) {
    allow_directors();
  }
  /* When directors are enabled, splice the wasm-js director runtime
     (Swig::Director base + exception classes) into f_cpp_runtime so
     SwigDirector_<C> bodies compile.  Mirrors matlab.cxx:459 pattern.
     f_cpp_runtime isn't allocated until below; insert into a temp
     buffer first, then 'Append'. */
  bool emit_director_runtime = Swig_directors_enabled();

  f_out_cpp = NewFile(outfile, "w", SWIG_output_files());
  if (!f_out_cpp) {
    FileErrorDisplay(outfile);
    Exit(EXIT_FAILURE);
  }

  String *jsfile = NewString(outfile);
  String *ext = Swig_file_extension(jsfile);
  if (ext && Len(ext))
    Delslice(jsfile, Len(jsfile) - Len(ext), DOH_END);
  Append(jsfile, ".js");
  f_out_js = NewFile(jsfile, "w", SWIG_output_files());
  if (!f_out_js) {
    FileErrorDisplay(jsfile);
    Exit(EXIT_FAILURE);
  }

  String *exportfile = NewStringf("%s.exports", outfile);
  f_out_exports = NewFile(exportfile, "w", SWIG_output_files());
  if (!f_out_exports) {
    FileErrorDisplay(exportfile);
    Exit(EXIT_FAILURE);
  }

  /* TypeScript stubs: open <outfile-without-cpp>.d.ts and register
     "stubs" file slot for collecting declarations.  Mirrors
     python.cxx's -stubs / .pyi handling (lines 733-760). */
  if (stubs) {
    String *dtsfile = NewString(outfile);
    String *dext = Swig_file_extension(dtsfile);
    if (dext && Len(dext))
      Delslice(dtsfile, Len(dtsfile) - Len(dext), DOH_END);
    Append(dtsfile, ".d.ts");
    f_stubs_dts = NewFile(dtsfile, "w", SWIG_output_files());
    if (!f_stubs_dts) {
      FileErrorDisplay(dtsfile);
      Exit(EXIT_FAILURE);
    }
    Delete(dtsfile);
    f_stubs_module = NewString("");
    f_stubs = f_stubs_module;
    f_stubs_class_body = 0;
    Swig_register_filebyname("stubs", f_stubs_module);
    /* Stub-alias tables exist for python compatibility — user .i files
       may target them via %insert("stubs_alias_in_table") etc.  We
       drain them in resolveStub() below, same protocol as python. */
    String *f_alias_in = NewString("");
    String *f_alias_out = NewString("");
    String *f_preamble = NewString("");
    Swig_register_filebyname("stubs_alias_in_table", f_alias_in);
    Swig_register_filebyname("stubs_alias_out_table", f_alias_out);
    Swig_register_filebyname("stubs_preamble", f_preamble);

    String *f_ts_alias_in = NewString("");
    String *f_ts_alias_out = NewString("");
    Swig_register_filebyname("ts_alias_in", f_ts_alias_in);
    Swig_register_filebyname("ts_alias_out", f_ts_alias_out);
    /* Stash for top()-end retrieval. */
    Setattr(n, "wasm_js:f_stubs_alias_in", f_alias_in);
    Setattr(n, "wasm_js:f_stubs_alias_out", f_alias_out);
    Setattr(n, "wasm_js:f_stubs_preamble", f_preamble);
    Setattr(n, "wasm_js:f_ts_alias_in", f_ts_alias_in);
    Setattr(n, "wasm_js:f_ts_alias_out", f_ts_alias_out);
  }

  f_cpp_runtime = NewString("");
  f_cpp_header = NewString("");
  Printf(f_cpp_header,
         "#include <utility>\n"
         "namespace swig_wasmjs {\n"
         "template <class F> class cleanup_guard {\n"
         "  F action; bool active;\n"
         "public:\n"
         "  explicit cleanup_guard(F f) : action(std::move(f)), active(true) {}\n"
         "  cleanup_guard(cleanup_guard&& other) : action(std::move(other.action)), active(other.active) { other.active = false; }\n"
         "  cleanup_guard(const cleanup_guard&) = delete;\n"
         "  ~cleanup_guard() { if (active) action(); }\n"
         "};\n"
         "template <class F> cleanup_guard<F> make_cleanup(F f) { return cleanup_guard<F>(std::move(f)); }\n"
         "}\n");
  f_cpp_wrappers = NewString("");
  f_cpp_init = NewString("");
  f_directors = NewString("");
  f_directors_h = NewString("");
  f_js_pre = NewString("");
  f_js_classes = NewString("");
  f_js_module = NewString("");
  f_js_user = NewString("");
  /* "js" slot: user .i files do '%insert("js") %{ ... %}' to patch the
     SWIG-emitted JS classes (e.g. extend a method to accept more arg
     shapes).  Emitted between f_js_classes and the module return at the
     end of top(). */
  Swig_register_filebyname("js", f_js_user);

  /* Splice Lib/wasm_js/director.swg into f_cpp_runtime so generated
     SwigDirector_<C> classes can reference Swig::Director.  Done
     after f_cpp_runtime is allocated and before the SWIG core fills
     it via %insert(runtime). */
  if (emit_director_runtime) {
    Swig_insert_file("director.swg", f_cpp_runtime);
  }

  /* Standard SWIG file-slot wiring (matches matlab.cxx ordering).
     "runtime" receives swigrun.swg + wasm_jsrun.swg via %insert(runtime)
     from Lib/wasm_js/wasm_jsruntime.swg.  "header" gathers user
     %{...%} blocks.  "wrapper" is the main accumulator for per-class /
     per-function generated wrappers — but wasm-js generates wrappers
     itself into f_cpp_wrappers via the handlers below, so the wrapper
     slot is unused in practice.  "init" + "begin" are unused for
     wasm-js (no MEX-style entry point). */
  Swig_register_filebyname("runtime", f_cpp_runtime);
  Swig_register_filebyname("header", f_cpp_header);
  Swig_register_filebyname("wrapper", f_cpp_wrappers);
  Swig_register_filebyname("init", f_cpp_init);
  Swig_register_filebyname("begin", f_cpp_runtime);

  Swig_register_filebyname("director", f_directors);
  Swig_register_filebyname("director_h", f_directors_h);

  /* Always-on runtime exports: malloc/free for JS-side buffer alloc,
     and the SWIG_fail error-readback pair (defined in wasm_jsrun.swg).
     The dispatcher / call-site emitters reference the latter to surface
     C++-side typemap-conversion failures as JS exceptions. */
  Printf(f_out_exports, "_malloc\n_free\n_swig_last_error_code\n_swig_last_error_msg\n");

  /* Shared sentinel that lets derived ctors pass a pre-allocated ptr up to
     their base ctor through super(), avoiding double-allocation. */
  Printf(f_js_pre, "  const __PRIVATE_CTOR = Symbol('swig-private-ctor');\n\n");

  /* JS <-> wasm handle bridge (the wasm-js analog of mxArray * / PyObject *).
     Class-typed parameters and returns flow as EM_VAL handles -- i32
     indices into Embind's value table.  __unwrap converts a JS proxy
     instance (which carries '_ptr') to an EM_VAL via the embind
     translator '__swig_take_handle' (registered by wasm_jsrun.swg).
     __from_handle is the reverse for returns: pulls the JS-side value
     back out of an EM_VAL via '__swig_release_handle'.  Since
     SWIG_WASMJS_NewPointerObj now consults swig_type_info::clientdata
     and calls M.__wrap_<JsName>(ptr) C++-side, the EM_VAL already
     carries a fully-wrapped proxy instance -- __from_handle just
     unboxes it, no JS-side rewrap required. */
  Printf(f_js_pre,
         "  const __unwrap      = a => M.__swig_take_handle(a);\n"
         "  const __from_handle = h => M.__swig_release_handle(h);\n"
         "  const __unwrap_args = (...args) => args.map(__unwrap);\n"
         "  // Error-readback wrapper.  Every wasm call site is wrapped in\n"
         "  // __chk() so a typemap conversion failure on the C++ side (which\n"
         "  // gotos `fail:` and returns the zero sentinel) surfaces as a JS\n"
         "  // Error instead of silently propagating a bogus value.\n"
         "  const __chk = (v) => {\n"
         "    const c = M._swig_last_error_code();\n"
         "    if (c !== 0) {\n"
         "      const m = M.UTF8ToString(M._swig_last_error_msg());\n"
         "      throw new Error(`SWIG error (${c}): ${m || 'conversion failed'}`);\n"
         "    }\n"
         "    return v;\n"
         "  };\n\n");

  /* Array <-> vector marshalling.  Users only ever pass / receive plain
     JS arrays; the XVector classes are an internal SWIG implementation
     detail.  __arr_to_vec builds a temp vector from a JS array (or
     accepts an already-built XVector pass-through).  __vec_to_arr is
     the reverse for returns: drains the vector into a JS array and
     deletes it.  Mirrors Python/MATLAB list/cell idioms. */
  Printf(f_js_pre,
         "  function __arr_to_vec(arr, VecClass) {\n"
         "    if (arr && arr.constructor && arr.constructor.name === VecClass.name) return arr;\n"
         "    const v = new VecClass();\n"
         "    if (arr) for (const x of arr) v.push_back(x);\n"
         "    return v;\n"
         "  }\n"
         "  function __vec_to_arr(vec) {\n"
         "    if (Array.isArray(vec)) return vec;\n"
         "    if (!vec) return [];\n"
         "    const n = Number(vec.size());\n"
         "    const out = new Array(n);\n"
         "    for (let i = 0; i < n; ++i) out[i] = vec.at(i);\n"
         "    if (vec.delete) vec.delete();\n"
         "    return out;\n"
         "  }\n\n");

  /* Non-throwing destructor path for the FinalizationRegistries.  A GC
     sweep at interpreter shutdown can free objects after the wasm
     module's C++ statics are torn down; a throw out of a
     FinalizationRegistry callback aborts the process, and a failed
     free in a destructor is not actionable from JS anyway -- warn
     (outside shutdown) instead of throwing. */
  Printf(f_js_pre,
         "  let __shutting_down = false;\n"
         "  if (typeof process !== \"undefined\" && typeof process.on === \"function\") {\n"
         "    process.on(\"beforeExit\", () => { __shutting_down = true; });\n"
         "    process.on(\"exit\", () => { __shutting_down = true; });\n"
         "  }\n"
         "  const __safe_free = (del, p) => {\n"
         "    try { return del(p); }\n"
         "    catch (e) {\n"
         "      if (!__shutting_down && typeof console !== \"undefined\")\n"
         "        console.warn(\"ignored error freeing wasm object:\", (e && e.message) || e);\n"
         "    }\n"
         "  };\n\n");

  /* Callable-instance support.  __callable_class(Orig, fr, makeInvoke)\n
     wraps a proxy class so constructed instances are directly invocable
     JS functions: instances keep the full method API via setPrototypeOf,
     the FinalizationRegistry registration is transferred to the callable,
     and own-property collisions with function built-ins ('name', ...)
     are re-pointed at the class methods.  Prototype and static methods
     returning bare instances are re-wrapped (ES6 method bodies bind the
     inner class name, bypassing the outer wrapper binding).  Interface
     files opt a class in from %insert("js") with:
       Cls = __m.Cls = __callable_class(Cls, __fr_<mangled>, (self) => function (...args) { ... });
   */
  Printf(f_js_pre,
         "  function __callable_class(Orig, fr, makeInvoke) {\n"
         "    const builtins = Object.getOwnPropertyNames(function () {});\n"
         "    const collisions = Object.getOwnPropertyNames(Orig.prototype)\n"
         "      .filter((n) => n !== \"constructor\" && builtins.includes(n));\n"
         "    const adopt = (inst) => {\n"
         "      const callable = function (...args) { return makeInvoke(callable)(...args); };\n"
         "      Object.setPrototypeOf(callable, Orig.prototype);\n"
         "      callable._ptr = inst._ptr;\n"
         "      if (fr.unregister(inst)) fr.register(callable, inst._ptr, callable);\n"
         "      inst._ptr = 0;\n"
         "      for (const k of collisions)\n"
         "        Object.defineProperty(callable, k,\n"
         "          { value: Orig.prototype[k], writable: false, configurable: true });\n"
         "      return callable;\n"
         "    };\n"
         "    const rewrap = (orig) => function (...args) {\n"
         "      const r = orig.apply(this, args);\n"
         "      return (r && typeof r === \"object\" && typeof r !== \"function\"\n"
         "              && r instanceof Orig && r._ptr !== 0) ? adopt(r) : r;\n"
         "    };\n"
         "    for (const k of Object.getOwnPropertyNames(Orig.prototype)) {\n"
         "      if (k === \"constructor\") continue;\n"
         "      const d = Object.getOwnPropertyDescriptor(Orig.prototype, k);\n"
         "      if (d && typeof d.value === \"function\")\n"
         "        Object.defineProperty(Orig.prototype, k, { ...d, value: rewrap(d.value) });\n"
         "    }\n"
         "    function Wrapped(...args) { return adopt(new Orig(...args)); }\n"
         "    Wrapped.prototype = Orig.prototype;\n"
         "    Wrapped.prototype.constructor = Wrapped;\n"
         "    for (const k of Object.getOwnPropertyNames(Orig)) {\n"
         "      if (k === \"length\" || k === \"name\" || k === \"prototype\") continue;\n"
         "      const d = Object.getOwnPropertyDescriptor(Orig, k);\n"
         "      if (!d) continue;\n"
         "      Object.defineProperty(Wrapped, k,\n"
         "        typeof d.value === \"function\" ? { ...d, value: rewrap(d.value) } : d);\n"
         "    }\n"
         "    return Wrapped;\n"
         "  }\n\n");

  Printf(f_js_pre,
         "  function __can(arg, ClassName) {\n"
         "    if (arg == null) return true;\n"
         "    return arg && typeof arg === 'object' && arg.constructor && arg.constructor.name === ClassName;\n"
         "  }\n"
         "  function __can_vec(arg, ElemClassName, VecClassName) {\n"
         "    if (arg == null) return true;\n"
         "    if (Array.isArray(arg)) { return arg.length === 0 || (arg[0] && arg[0].constructor && arg[0].constructor.name === ElemClassName); }\n"
         "    return arg.constructor && arg.constructor.name === VecClassName;\n"
         "  }\n\n");

  Printf(f_js_pre,
         "  function __mixin(D, ...Bs) {\n"
         "    for (const B of Bs) {\n"
         "      if (!B) continue;\n"
         "      for (const k of Object.getOwnPropertyNames(B)) {\n"
         "        if (k === 'length' || k === 'name' || k === 'prototype') continue;\n"
         "        if (Object.prototype.hasOwnProperty.call(D, k)) continue;\n"
         "        Object.defineProperty(D, k, Object.getOwnPropertyDescriptor(B, k));\n"
         "      }\n"
         "      if (!B.prototype) continue;\n"
         "      for (const k of Object.getOwnPropertyNames(B.prototype)) {\n"
         "        if (k === 'constructor') continue;\n"
         "        if (Object.prototype.hasOwnProperty.call(D.prototype, k)) continue;\n"
         "        Object.defineProperty(D.prototype, k, Object.getOwnPropertyDescriptor(B.prototype, k));\n"
         "      }\n"
         "    }\n"
         "  }\n\n");

  /* Pre-walk the AST to collect all class declarations into
     cpp_to_js_class.  Without this, js_marshal_return misses class
     types that haven't been classHandler'd yet -- e.g. 'static sym'
     methods of GenericMatrix<Matrix<SXElem>> emit before
     classHandler for Matrix<SXElem> (= SX) runs.  Pre-population
     fixes the ordering so any method's return type can be wrapped
     regardless of declaration order. */
  if (!cpp_to_js_class)
    cpp_to_js_class = NewHash();
  prepopulate_class_names(n);

  Language::top(n);

  if (director_classes) {
    Iterator dit = First(director_classes);
    while (dit.key) {
      String *cpp_cn = (String *)dit.key;
      String *js_cn = (String *)Getattr(cpp_to_js_class, cpp_cn);
      if (js_cn) {
        Printf(f_js_classes, "  M.__base_proto_%s = %s.prototype;\n", js_cn, js_cn);
      }
      dit = Next(dit);
    }
  }

  if (cpp_to_js_class) {
    Iterator cit = First(cpp_to_js_class);
    while (cit.key) {
      String *js_cn = (String *)cit.item;
      if (js_cn && Strncmp(js_cn, "__dummy_", 8) != 0) {
        /* 'owns' arg threaded through from SWIG_WASMJS_NewPointerObj:
           1 if the C++ caller passed SWIG_POINTER_OWN (value returns,
           heap-cloned via 'new T(result)'), 0 for borrowed returns
           (references to internal storage).  The ctor's PRIVATE_CTOR
           branch FR-registers only when owns=1.  Without this, owning
           returns leak; without the borrow-skip, borrowed returns
           double-free. */
        if (indexed_classes && Getattr(indexed_classes, js_cn))
          Printf(f_js_classes, "  M.__wrap_%s = (p, owns) => __mkIndex(new %s(__PRIVATE_CTOR, p, owns));\n", js_cn, js_cn);
        else
          Printf(f_js_classes, "  M.__wrap_%s = (p, owns) => new %s(__PRIVATE_CTOR, p, owns);\n", js_cn, js_cn);
      }
      cit = Next(cit);
    }
  }

  /* Emit free-function dispatchers from global_overloads.  For each
     jsname with multiple overloads, pick at runtime by first-arg JS
     class name (e.g. MXVector -> the MX overload).  Single-overload
     names emit the body inline -- no dispatch overhead. */
  if (global_overloads) {
    Iterator it = First(global_overloads);
    while (it.key) {
      String *jsn = (String *)it.key;
      List *overloads = (List *)it.item;
      rank_dispatch_entries(overloads);
      int nover = Len(overloads);
      if (nover == 1) {
        Hash *e = (Hash *)Getitem(overloads, 0);
        Printf(f_js_module,
               "    %s(...args) {\n      if (args.length !== %s) throw new TypeError('Wrong argument count');\n      const [%s] = args;\n%s    },\n",
               jsn,
               Getattr(e, "arity"),
               (String *)Getattr(e, "jsargs"),
               (String *)Getattr(e, "body"));
      } else {
        /* Multi-overload free-function dispatcher.  Preferred path:
           use the per-entry 'type_checks' (full per-arg discrim) +
           arity gate.  Fall back to the legacy 'arg0_class' slot when
           type_checks is empty (only happens for entries from older
           emit paths -- shouldn't occur with current handler).
           Bodies were built with arg names a0/a1/...; remap via
           destructuring per branch. */
        Printf(f_js_module, "    %s(...args) {\n", jsn);
        for (int i = 0; i < nover; ++i) {
          Hash *e = (Hash *)Getitem(overloads, i);
          String *jsargs_e = (String *)Getattr(e, "jsargs");
          String *body = (String *)Getattr(e, "body");
          String *ar = (String *)Getattr(e, "arity");
          String *tc = (String *)Getattr(e, "type_checks");
          String *arg0c = (String *)Getattr(e, "arg0_class");
          String *cond;
          if (tc && Len(tc) > 0) {
            cond = NewStringf("args.length === %s && %s", ar ? Char(ar) : "0", Char(tc));
          } else if (arg0c && Len(arg0c) > 0) {
            register_probe(arg0c);
            cond = NewStringf("args.length === %s && M._swig_can_%s(__unwrap(args[0]))", ar ? Char(ar) : "0", arg0c);
          } else {
            cond = NewStringf("args.length === %s", ar ? Char(ar) : "0");
          }
          Printf(f_js_module,
                 "      if (%s) {\n"
                 "        const [%s] = args;\n"
                 "%s"
                 "      }\n",
                 cond,
                 jsargs_e,
                 body);
          Delete(cond);
        }
        Printf(f_js_module,
               "      throw new TypeError(`%s: no overload matches arg types`);\n"
               "    },\n",
               jsn);
      }
      it = Next(it);
    }
  }

  /* Emit the SWIG type table BEFORE the probe wrappers so the probe
     wrappers can reference the static swig_type_info symbols directly
     (the type table emits them with 'static' linkage; forward-declaring
     via 'extern' would conflict).  f_cpp_wrappers is passed as the
     scope context for SwigType_emit_type_table. */
  SwigType_emit_type_table(f_cpp_runtime, f_cpp_wrappers);

  emit_probe_wrappers();
  emit_typecheck_probe_wrappers();

  Printf(f_cpp_wrappers,
         "\n/* Phase 3.2: link cast chains so SWIG_WASMJS_ConvertPtr can\n"
         "   validate type identity via the static cast tables, AND\n"
         "   populate `swig_types[]` so the SWIGTYPE_p_<X> macros (which\n"
         "   index `swig_types[i]`) resolve to non-null type-info pointers.\n"
         "   Iterate by swig_module.size -- the static arrays are NOT\n"
         "   NULL-terminated, only the size field is authoritative.\n"
         "\n"
         "   Runs eagerly at program startup via a static constructor\n"
         "   object: `SWIGTYPE_p_<X>` is evaluated at the wrapper call site\n"
         "   (an `swig_types[i]` array access), so a lazy first-ConvertPtr\n"
         "   init would be too late -- the caller already read the slot.\n"
         "   Static-init order between the type-info tables (constant init)\n"
         "   and our constructor (dynamic init) is well-defined: constant\n"
         "   init runs first, so the table data is ready by the time the\n"
         "   constructor fires. */\n"
         "/* Phase 4.3: separate sorted type-info array for SWIG_TypeQuery's\n"
         "   binary search.  CANNOT sort swig_types[] in place: the\n"
         "   SWIGTYPE_p_<X> macros hard-code indices into swig_types, so\n"
         "   shuffling would break every wrapper.  Same size as swig_types. */\n"
         "static swig_type_info *swig_types_sorted[sizeof(swig_types)/sizeof(swig_types[0])];\n");

  /* Emit the (mangled_pointer_type, JS class name) table used by
     init_cast_chains to populate swig_type_info::clientdata.  Once
     clientdata is set, SWIG_WASMJS_NewPointerObj returns fully-wrapped
     JS proxy instances via M.__wrap_<JsName>(ptr) -- matching the
     matlabrun.swg/SWIG_Matlab_NewPointerObj approach where C++ owns
     the wrap, JS doesn't post-decorate. */
  Printf(f_cpp_wrappers,
         "static const struct { const char *sname; const char *jsname; } "
         "swig_js_classes[] = {\n");
  if (mangle_to_jsname) {
    Iterator mit = First(mangle_to_jsname);
    while (mit.key) {
      Printf(f_cpp_wrappers, "  { \"%s\", \"%s\" },\n", (String *)mit.key, (String *)mit.item);
      mit = Next(mit);
    }
  }
  Printf(f_cpp_wrappers,
         "  { 0, 0 }\n"
         "};\n");

  Printf(f_cpp_wrappers,
         "SWIGRUNTIME swig_type_info* SWIG_WASMJS_LookupByJsName(const char* js_name) {\n"
         "  if (!js_name) return 0;\n"
         "  for (size_t i = 0; i < swig_module.size; ++i) {\n"
         "    if (swig_type_initial[i] && swig_type_initial[i]->clientdata\n"
         "        && strcmp((const char*)swig_type_initial[i]->clientdata, js_name) == 0) {\n"
         "      return swig_type_initial[i];\n"
         "    }\n"
         "  }\n"
         "  return 0;\n"
         "}\n");

  Printf(f_cpp_wrappers,
         "void SWIG_WASMJS_init_cast_chains() {\n"
         "  for (size_t i = 0; i < swig_module.size; ++i) {\n"
         "    if (swig_type_initial[i] && swig_cast_initial[i] && swig_cast_initial[i]->type) {\n"
         "      swig_type_initial[i]->cast = swig_cast_initial[i];\n"
         "    }\n"
         "    swig_types[i] = swig_type_initial[i];\n"
         "    swig_types_sorted[i] = swig_type_initial[i];\n"
         "    /* Wire clientdata to the JS class name (string-match by\n"
         "       swig_type_info::name).  Linear scan -- n is small (~60).\n"
         "       Types without a registered JS class leave clientdata null;\n"
         "       SWIG_WASMJS_NewPointerObj falls back to a bare {_ptr} carrier\n"
         "       for those. */\n"
         "    if (swig_type_initial[i] && swig_type_initial[i]->name) {\n"
         "      for (size_t j = 0; swig_js_classes[j].sname; ++j) {\n"
         "        if (strcmp(swig_type_initial[i]->name, swig_js_classes[j].sname) == 0) {\n"
         "          swig_type_initial[i]->clientdata = (void *)swig_js_classes[j].jsname;\n"
         "          break;\n"
         "        }\n"
         "      }\n"
         "    }\n"
         "  }\n"
         "  /* Insertion sort the COPY by name (n=61, runs once). */\n"
         "  for (size_t i = 1; i < swig_module.size; ++i) {\n"
         "    swig_type_info *t = swig_types_sorted[i];\n"
         "    size_t j = i;\n"
         "    while (j > 0 && swig_types_sorted[j-1]->name && t->name\n"
         "           && strcmp(swig_types_sorted[j-1]->name, t->name) > 0) {\n"
         "      swig_types_sorted[j] = swig_types_sorted[j-1];\n"
         "      --j;\n"
         "    }\n"
         "    swig_types_sorted[j] = t;\n"
         "  }\n"
         "  /* Wire the sorted view into swig_module so SWIG_TypeQuery works. */\n"
         "  swig_module.types = swig_types_sorted;\n"
         "  swig_module.type_initial = swig_type_initial;\n"
         "  swig_module.cast_initial = swig_cast_initial;\n"
         "  swig_module.next = &swig_module;  /* self-loop, do/while termination */\n"
         "}\n"
         "static struct SWIGWasmJSInit { SWIGWasmJSInit() {\n"
         "  SWIG_WASMJS_init_cast_chains();\n"
         "} } _swig_wasmjs_init;\n");

  /* C++ output.  Runtime block (swigrun.swg + wasm-js runtime + type */
  /* table) is dumped first, BEFORE the extern "C" wrapper section, so */
  /* SWIG_ConvertPtr / swig_type_info* table are declared in scope of */
  /* every wrapper.  The user %{...%} header block follows runtime so */
  /* user code can reference runtime APIs.  Wrappers live inside an */
  /* extern "C" block so emscripten exports get C linkage. */
  /* Director-class declarations + implementations live in C++ linkage
     between the user header block and the extern "C" wrappers, so the
     SwigDirector_<C> classes are visible to any per-class glue but the
     EMSCRIPTEN_KEEPALIVE wrappers themselves stay C-linkage. */
  Printf(f_out_cpp,
         "// Generated by SWIG -wasm-js. Do not edit.\n\n"
         "#include <emscripten.h>\n"
         "#include <cstdlib>\n"
         "#include <cstring>\n"
         "#include <string>\n"
         "%s\n"
         "%s\n"
         "%s\n"
         "%s\n"
         "extern \"C\" {\n\n%s\n} // extern \"C\"\n",
         f_cpp_runtime,
         f_cpp_header,
         f_directors_h,
         f_directors,
         f_cpp_wrappers);

  /* JS output -- strip directory + extension to get sibling name for require() */
  String *base = NewString(outfile);
  String *bext = Swig_file_extension(base);
  if (bext && Len(bext))
    Delslice(base, Len(base) - Len(bext), DOH_END);
  /* Strip leading directory components */
  const char *bc = Char(base);
  const char *slash = strrchr(bc, '/');
  if (slash) {
    String *bn = NewString(slash + 1);
    Delete(base);
    base = bn;
  }

  Printf(f_out_js,
         "// Generated by SWIG -wasm-js. Do not edit.\n"
         "//\n"
         "// Compile <name>.cpp with em++:\n"
         "//   em++ -O3 -fwasm-exceptions -lembind <name>.cpp libfoo.a \\\n"
         "//     -s MODULARIZE=1 -s EXPORT_NAME=createWasm \\\n"
         "//     -s EXPORTED_RUNTIME_METHODS='[\"UTF8ToString\"]' \\\n"
         "//     -s EXPORTED_FUNCTIONS=@<name>.exports \\\n"
         "//     -o <name>_wasm.js\n\n"
         "const createWasm = require('./%s_wasm.js');\n"
         "const __path = require('path');\n\n"
         "module.exports = async function create%s() {\n"
         "  /* Resolve .wasm / .data file lookups relative to THIS file rather\n"
         "     than process.cwd(), so the module is callable from any cwd.\n"
         "     Critical for the MAIN_MODULE build where --preload-file plugins\n"
         "     ship as a sibling .data file. */\n"
         "  const M = await createWasm({\n"
         "    locateFile: (p, prefix) => __path.join(__dirname, p),\n"
         "  });\n"
         "  /* Optional plugin registration entry point.  Defined when the\n"
         "     module was linked with statically-bundled plugins.  Absent in\n"
         "     the standard MAIN_MODULE build, which loads plugins via the\n"
         "     dlopen path against preloaded SIDE_MODULE .so files. */\n"
         "  if (typeof M._swig_wasm_load_plugins === 'function') M._swig_wasm_load_plugins();\n\n"
         "%s"
         "%s"
         "  const __m = {\n"
         "%s"
         "  };\n"
         "%s"
         "  return __m;\n"
         "};\n",
         base,
         module_name,
         f_js_pre,
         f_js_classes,
         f_js_module,
         f_js_user);

  /* TypeScript stubs: dump module body to .d.ts and close.  Do NOT
     emit the stubs_preamble slot: it's populated by python-syntax
     %stub_alias_in expansions ('_DM = bool | int | float | ...') that
     aren't valid TypeScript.  Auto-generated stubs already translate
     PEP-484 types via py_to_ts; the alias-table widening is a python-
     specific refinement we skip for now. */
  if (stubs && f_stubs_dts) {
    /* Append sorted free-function overloads (bucketed during emission)
       to the module body before flushing to file. */
    stub_drain_free_fn_buckets();
    Printv(f_stubs_dts,
           "// Generated by SWIG -wasm-js -stubs. Do not edit.\n\n"
           "declare function createModule(): Promise<{ [K in keyof typeof createModule]: (typeof createModule)[K] }>;\n"
           "declare namespace createModule {\n",
           NIL);
    if (f_stubs_module && Len(f_stubs_module) > 0)
      Printv(f_stubs_dts, f_stubs_module, NIL);
    Printv(f_stubs_dts, "}\nexport = createModule;\n", NIL);
    Delete(f_stubs_dts);
    f_stubs_dts = 0;
    Delete(f_stubs_module);
    f_stubs_module = 0;
    String *preamble = (String *)Getattr(n, "wasm_js:f_stubs_preamble");
    if (preamble)
      Delete(preamble);
    String *ain = (String *)Getattr(n, "wasm_js:f_stubs_alias_in");
    String *aout = (String *)Getattr(n, "wasm_js:f_stubs_alias_out");
    if (ain)
      Delete(ain);
    if (aout)
      Delete(aout);
  }

  Delete(base);
  Delete(f_cpp_runtime);
  Delete(f_cpp_header);
  Delete(f_cpp_wrappers);
  Delete(f_cpp_init);
  Delete(f_directors);
  Delete(f_directors_h);
  Delete(f_js_pre);
  Delete(f_js_classes);
  Delete(f_js_module);
  Delete(f_js_user);
  Delete(f_out_cpp);
  Delete(f_out_js);
  Delete(f_out_exports);
  return SWIG_OK;
}

/* =========================== Class machinery ================================ */

int WASM_JS::classHandler(Node *n) {
  class_jsname = Getattr(n, "sym:name");
  SwigType *t = Getattr(n, "name");
  String *cname = SwigType_str(t, 0);
  class_cname = cname;

  /* Remember classes even when they occur only as container element types. */
  SwigType *pointer_type = Copy(t);
  SwigType_add_pointer(pointer_type);
  SwigType_remember(pointer_type);
  String *descriptor = SwigType_manglestr(pointer_type);
  Printf(f_cpp_header,
         "namespace swig_wasmjs { template <> struct type_descriptor< %s > {\n"
         "  static swig_type_info *get() { return SWIG_TypeQuery(\"%s\"); }\n"
         "}; }\n",
         cname,
         descriptor);
  Delete(descriptor);
  Delete(pointer_type);

  if (!cpp_to_js_class)
    cpp_to_js_class = NewHash();
  Setattr(cpp_to_js_class, cname, class_jsname);

  if (Swig_scopename_check(cname)) {
    String *bare = Swig_scopename_last(cname);
    Setattr(cpp_to_js_class, bare, class_jsname);
    Delete(bare);
  }
  /* And the SwigType_namestr form (camel-cased, no spaces around <>). */
  String *nstr = SwigType_namestr(t);
  if (nstr && Strcmp(nstr, cname) != 0) {
    Setattr(cpp_to_js_class, nstr, class_jsname);
    if (Swig_scopename_check(nstr)) {
      String *bare = Swig_scopename_last(nstr);
      Setattr(cpp_to_js_class, bare, class_jsname);
      Delete(bare);
    }
  }
  if (nstr)
    Delete(nstr);

  class_cpp_section = NewString("");
  class_js_body = NewString("");
  ctor_arities_seen = NewHash();
  ctor_overloads = NewList();
  ctor_overload_count = 0;
  member_names_seen = NewHash();
  member_overload_counts = NewHash();
  class_has_base = (Getattr(n, "bases") && Len(Getattr(n, "bases")) > 0);

  /* TS stubs: route emission to a per-class body buffer for the
     duration of children visit, then wrap with 'export class X { ... }'
     after.  Saves the outer (module-level) buffer for restore. */
  String *saved_stubs = 0;
  if (stubs) {
    saved_stubs = f_stubs;
    f_stubs_class_body = NewString("");
    f_stubs = f_stubs_class_body;
  }

  Language::classHandler(n);

  if (stubs) {
    stub_drain_method_buckets();
    /* Match the runtime's first public base. Merge instance members from other bases
       through an interface, since TypeScript classes only support one base class. */
    String *base_clause_ts = NewString("");
    String *static_bases_ts = NewString("");
    String *seen_static_keys = NewStringf("keyof typeof %s__class", class_jsname);
    String *iface_clause_ts = 0;
    List *bases = Getattr(n, "bases");
    if (bases && Len(bases) > 0) {
      Node *primary = Getitem(bases, 0);
      List *secondary = NewList();
      /* All other bases land in secondary. */
      for (int bi = 0; bi < Len(bases); ++bi) {
        Node *b = Getitem(bases, bi);
        if (b != primary)
          Append(secondary, b);
      }

      String *bjsname = Getattr(primary, "sym:name");
      if (bjsname)
        Printf(base_clause_ts, " extends %s", bjsname);

      if (Len(secondary) > 0) {
        iface_clause_ts = NewString(" extends ");
        bool first = true;
        for (int bi = 0; bi < Len(secondary); ++bi) {
          Node *b = Getitem(secondary, bi);
          String *bn = Getattr(b, "sym:name");
          if (!bn)
            continue;
          Printf(static_bases_ts, " & Pick<typeof %s, Exclude<keyof typeof %s, %s>>", bn, bn, seen_static_keys);
          Printf(seen_static_keys, " | keyof typeof %s", bn);
          if (!first)
            Printv(iface_clause_ts, ", ", NIL);
          Printv(iface_clause_ts, bn, NIL);
          first = false;
        }
        if (first) {
          Delete(iface_clause_ts);
          iface_clause_ts = 0;
        }
      }
      Delete(secondary);
    }

    /* 'export declare class' + 'export interface' for declaration-
       merge: TS requires both halves to share 'export' modifiers
       (TS2395 otherwise).  'export declare const' for the value
       (initializerless, ambient). */
    /* Type the instance-callable form of this class's statics (the
       runtime emits matching prototype forwarders below), unless a
       real instance method owns the name. */
    if (stub_static_instance_pending) {
      Iterator pit = First(stub_static_instance_pending);
      while (pit.key) {
        const char *ks = Char((String *)pit.key);
        const char *pp = strstr(ks, "::");
        if (pp && (size_t)(pp - ks) == (size_t)Len(class_jsname) && strncmp(ks, Char(class_jsname), pp - ks) == 0 &&
            (!member_overloads || !Getattr(member_overloads, pit.key))) {
          Printv(f_stubs_class_body, (String *)pit.item, NIL);
        }
        pit = Next(pit);
      }
    }
    Printv(saved_stubs, "export class ", class_jsname, "__class", base_clause_ts, " {\n", f_stubs_class_body, "}\n", NIL);
    if (iface_clause_ts) {
      Printv(saved_stubs, "export interface ", class_jsname, "__class", iface_clause_ts, " {}\n", NIL);
      Delete(iface_clause_ts);
    }
    Printv(saved_stubs, "export type ", class_jsname, " = ", class_jsname, "__class;\n", NIL);
    Printv(saved_stubs,
           "export const ",
           class_jsname,
           ": typeof ",
           class_jsname,
           "__class",
           static_bases_ts,
           " & { (...args: any[]): ",
           class_jsname,
           "__class };\n",
           NIL);
    Printv(saved_stubs, "\n", NIL);
    Delete(base_clause_ts);
    Delete(static_bases_ts);
    Delete(seen_static_keys);
    Delete(f_stubs_class_body);
    f_stubs_class_body = 0;
    f_stubs = saved_stubs;
  }

  /* Abstract bases (no public ctors registered) -- emit a PRIVATE_CTOR-
     only constructor anyway.  Subclasses' 'super(__PRIVATE_CTOR, ptr)'
     needs SOMEONE in the parent chain to set 'this._ptr'; without an
     explicit constructor here, JS provides an implicit
     'constructor(...args) {}' that swallows the args silently and
     'this._ptr' stays undefined.  Affects classes like SerializerBase
     -- subclasses StringSerializer / StringDeserializer would then
     have undefined '_ptr' and every method call would fail
     'self conversion failed'. */
  if (Len(ctor_overloads) == 0) {
    String *cmangle = mangle(cname);
    /* PRIVATE_CTOR (called from M.__wrap_<C>(ptr, owns)) sets _ptr
       and, when owns=1, registers in __fr_<C>.  Super-call uses
       owns=0 so only the MOST-DERIVED class's FR fires (the
       virtual-dtor wrapper handles the full destruction chain);
       letting every base also register would double-free. */
    Printf(class_js_body,
           "    constructor(...args) {\n"
           "      if (args[0] === __PRIVATE_CTOR) {\n"
           "        %s\n"
           "        if (args[2]) __fr_%s.register(this, args[1], this);\n"
           "        return;\n"
           "      }\n"
           "      throw new Error(`%s: abstract base, no public constructor`);\n"
           "    }\n",
           class_has_base ? "super(__PRIVATE_CTOR, args[1], 0);" : "this._ptr = args[1];",
           cmangle,
           class_jsname);
    Delete(cmangle);
  }

  /* Emit a single JS constructor that dispatches on (args.length, then
     args[N]?.constructor?.name for the first non-string arg) to the
     right wasm-export ctor.  All overloads of the same arity have a
     C export emitted; the dispatcher's per-arity branch tries each
     in declaration order until one matches the arg shape. */
  if (Len(ctor_overloads) > 0) {
    rank_dispatch_entries(ctor_overloads);
    String *cmangle = mangle(cname);
    String *ctor_js = NewString("");
    Printf(ctor_js, "    constructor(...args) {\n");
    /* PRIVATE_CTOR called from M.__wrap_<C>(ptr, owns): set _ptr and
       FR-register when owns=1 (ownership-flag wiring -- see
       wasm_jsrun.swg::SWIG_WASMJS_NewPointerObj).  Super-call uses
       owns=0 so only this (most-derived) class's FR fires; letting
       every base register would double-free via virtual dtor. */
    if (class_has_base) {
      Printf(ctor_js,
             "      if (args[0] === __PRIVATE_CTOR) { super(__PRIVATE_CTOR, args[1], 0); "
             "if (args[2]) __fr_%s.register(this, args[1], this); return; }\n",
             cmangle);
    } else {
      Printf(ctor_js,
             "      if (args[0] === __PRIVATE_CTOR) { this._ptr = args[1]; "
             "if (args[2]) __fr_%s.register(this, args[1], this); return; }\n",
             cmangle);
    }

    if (director_classes && Getattr(director_classes, cname)) {
      if (class_has_base) {
        Printf(ctor_js,
               "      if (new.target !== %s) {\n"
               "        super(__PRIVATE_CTOR, 0);\n"
               "        const __h = M.__swig_take_handle(this);\n"
               "        const __dptr = M._swig_new_SwigDirector_%s(__h);\n"
               "        this._ptr = __dptr;\n"
               "        __fr_%s.register(this, __dptr, this);\n"
               "        return;\n"
               "      }\n",
               class_jsname,
               class_jsname,
               mangle(cname));
      } else {
        Printf(ctor_js,
               "      if (new.target !== %s) {\n"
               "        const __h = M.__swig_take_handle(this);\n"
               "        const __dptr = M._swig_new_SwigDirector_%s(__h);\n"
               "        this._ptr = __dptr;\n"
               "        __fr_%s.register(this, __dptr, this);\n"
               "        return;\n"
               "      }\n",
               class_jsname,
               class_jsname,
               mangle(cname));
      }
    }
    Printf(ctor_js, "      let __ptr;\n      switch (args.length) {\n");
    /* Group overloads by arity, emit one 'case N:' per arity with
       sequential type-matching tries. */
    Hash *arity_groups = NewHash();
    for (int i = 0; i < Len(ctor_overloads); ++i) {
      Hash *e = (Hash *)Getitem(ctor_overloads, i);
      String *ar = (String *)Getattr(e, "arity");
      List *grp = (List *)Getattr(arity_groups, ar);
      if (!grp) {
        grp = NewList();
        Setattr(arity_groups, ar, grp);
      }
      Append(grp, e);
    }
    Iterator ait = First(arity_groups);
    while (ait.key) {
      String *arity_key = ait.key;
      List *grp = (List *)ait.item;
      Printf(ctor_js, "        case %s: {\n", arity_key);
      Hash *fallback = 0;
      for (int index = 0; index < Len(grp); ++index) {
        Hash *entry = Getitem(grp, index);
        String *checks = Getattr(entry, "type_checks");
        if (checks && Len(checks)) {
          Printf(ctor_js, "          if (%s) { __ptr = (() => {\n%s          })(); break; }\n", checks, Getattr(entry, "js_body"));
        } else if (!fallback) {
          fallback = entry;
        }
      }
      if (fallback)
        Printf(ctor_js, "          __ptr = (() => {\n%s          })(); break;\n", Getattr(fallback, "js_body"));
      else
        Printf(ctor_js, "          throw new TypeError(`%s: arg-type mismatch at length %s`);\n", class_jsname, arity_key);
      Printf(ctor_js, "        }\n");
      ait = Next(ait);
    }
    Delete(arity_groups);
    Printf(ctor_js,
           "        default: throw new Error(`%s: no ctor for ${args.length} args`);\n"
           "      }\n",
           class_jsname);
    if (class_has_base) {
      Printf(ctor_js, "      super(__PRIVATE_CTOR, __ptr);\n");
    } else {
      Printf(ctor_js, "      this._ptr = __ptr;\n");
    }
    Printf(ctor_js,
           "      __fr_%s.register(this, __ptr, this);\n"
           "    }\n",
           cmangle);

    /* Prepend the constructor before the rest of the body. */
    String *new_body = NewStringf("%s%s", ctor_js, class_js_body);
    Delete(class_js_body);
    class_js_body = new_body;
    Delete(ctor_js);
    Delete(cmangle);
  }

  /* Emit member-method dispatchers (same shape as static; without
     'static' keyword).  Lets Sparsity.row() (no arg, returns
     vector) and Sparsity.row(k) (k-th entry) coexist via
     args.length dispatch. */
  if (member_overloads) {
    String *member_js = NewString("");
    Iterator mit = First(member_overloads);
    while (mit.key) {
      String *key = (String *)mit.key;
      const char *ks = Char(key);
      const char *p = strstr(ks, "::");
      if (p) {
        size_t plen = p - ks;
        if (plen == (size_t)Len(class_jsname) && strncmp(ks, Char(class_jsname), plen) == 0) {
          List *lst = (List *)mit.item;
          rank_dispatch_entries(lst);
          const char *jsname = p + 2;
          int nover = Len(lst);
          if (nover == 1) {
            Hash *e = (Hash *)Getitem(lst, 0);
            String *ja = (String *)Getattr(e, "jsargs");
            String *bd = (String *)Getattr(e, "js_body");
            Printf(member_js,
                   "    %s(...args) {\n      if (args.length !== %s) throw new TypeError('Wrong argument count');\n      const [%s] = args;\n%s    }\n",
                   jsname,
                   Getattr(e, "arity"),
                   ja ? Char(ja) : "",
                   bd ? Char(bd) : "");
          } else {
            /* Multi-overload: same type-discriminating dispatch as the
               static-method block below.  Without it, SerializerBase.pack
               (which has DM/MX/SX/Sparsity overloads at arity 1) picks
               first-wins-per-arity and 'ss.pack(M.DM(5))' fails because
               the Sparsity overload was emitted first. */
            Printf(member_js, "    %s(...args) {\n", jsname);
            Printf(member_js, "      switch (args.length) {\n");
            Hash *byArity = NewHash();
            for (int i = 0; i < nover; ++i) {
              Hash *e = (Hash *)Getitem(lst, i);
              String *ar = (String *)Getattr(e, "arity");
              List *grp = (List *)Getattr(byArity, ar);
              if (!grp) {
                grp = NewList();
                Setattr(byArity, ar, grp);
              }
              Append(grp, e);
            }
            Iterator ait = First(byArity);
            while (ait.key) {
              String *ar = (String *)ait.key;
              List *grp = (List *)ait.item;
              if (Len(grp) == 1) {
                Hash *e = (Hash *)Getitem(grp, 0);
                String *ja = (String *)Getattr(e, "jsargs");
                String *bd = (String *)Getattr(e, "js_body");
                Printf(member_js,
                       "        case %s: {\n"
                       "          const [%s] = args;\n"
                       "%s"
                       "        }\n",
                       ar,
                       ja ? Char(ja) : "",
                       bd ? Char(bd) : "");
              } else {
                Printf(member_js, "        case %s: {\n", ar);
                Hash *fallback = 0;
                for (int gi = 0; gi < Len(grp); ++gi) {
                  Hash *e = (Hash *)Getitem(grp, gi);
                  String *tc = (String *)Getattr(e, "type_checks");
                  if (tc && Len(tc) > 0) {
                    String *ja = (String *)Getattr(e, "jsargs");
                    String *bd = (String *)Getattr(e, "js_body");
                    Printf(member_js,
                           "          if (%s) {\n"
                           "            const [%s] = args;\n"
                           "%s"
                           "          }\n",
                           Char(tc),
                           ja ? Char(ja) : "",
                           bd ? Char(bd) : "");
                  } else if (!fallback) {
                    fallback = e;
                  }
                }
                if (fallback) {
                  String *ja = (String *)Getattr(fallback, "jsargs");
                  String *bd = (String *)Getattr(fallback, "js_body");
                  Printf(member_js,
                         "          {\n"
                         "            const [%s] = args;\n"
                         "%s"
                         "          }\n",
                         ja ? Char(ja) : "",
                         bd ? Char(bd) : "");
                } else {
                  Printf(member_js, "          throw new TypeError(`%s.%s: no overload matches arg types at arity %s`);\n", class_jsname, jsname, ar);
                }
                Printf(member_js, "        }\n");
              }
              ait = Next(ait);
            }
            Delete(byArity);
            Printf(member_js,
                   "        default: throw new Error(`%s.%s: no overload for ${args.length} args`);\n"
                   "      }\n"
                   "    }\n",
                   class_jsname,
                   jsname);
          }
        }
      }
      mit = Next(mit);
    }
    /* Append member methods after static (static_js is prepended
       below). */
    Printv(class_js_body, member_js, NIL);
    Delete(member_js);
  }

  /* Emit static-method dispatchers for this class.  Each (class, jsname)
     entry in static_overloads collected by staticmemberfunctionHandler
     is rendered into one 'static jsname(...args)' body that switches on
     args.length.  Default-arg phantom overloads (sym(name),
     sym(name, n), sym(name, n, m)) each get their own arity case.
     If only one arity exists, emit a flat call without the switch. */
  if (static_overloads) {
    String *static_js = NewString("");
    Iterator sit = First(static_overloads);
    while (sit.key) {
      String *key = (String *)sit.key;
      /* Filter to this class -- keys are "<class_jsname>::<method>". */
      const char *ks = Char(key);
      size_t plen = 0;
      const char *p = strstr(ks, "::");
      if (p) {
        plen = p - ks;
        if (plen == (size_t)Len(class_jsname) && strncmp(ks, Char(class_jsname), plen) == 0) {
          List *lst = (List *)sit.item;
          rank_dispatch_entries(lst);
          const char *jsname = p + 2;
          int nover = Len(lst);
          if (nover == 1) {
            Hash *e = (Hash *)Getitem(lst, 0);
            String *ja = (String *)Getattr(e, "jsargs");
            String *bd = (String *)Getattr(e, "js_body");
            Printf(static_js,
                   "    static %s(...args) {\n      if (args.length !== %s) throw new TypeError('Wrong argument count');\n      const [%s] = args;\n%s    }\n",
                   jsname,
                   Getattr(e, "arity"),
                   ja ? Char(ja) : "",
                   bd ? Char(bd) : "");
          } else {
            /* Multi-arity: switch on args.length, then type-discriminate
               within each arity when multiple overloads share it.
               Without the within-arity dispatch, 'Function.deserialize(str)'
               (and similar) hit the first-wins-per-arity trap and pick
               the wrong C++ overload (e.g. the istream-taking one). */
            Printf(static_js, "    static %s(...args) {\n", jsname);
            Printf(static_js, "      switch (args.length) {\n");
            /* Group by arity -- but keep ALL entries per arity, not
               just the first. */
            Hash *byArity = NewHash();
            for (int i = 0; i < nover; ++i) {
              Hash *e = (Hash *)Getitem(lst, i);
              String *ar = (String *)Getattr(e, "arity");
              List *grp = (List *)Getattr(byArity, ar);
              if (!grp) {
                grp = NewList();
                Setattr(byArity, ar, grp);
              }
              Append(grp, e);
            }
            Iterator ait = First(byArity);
            while (ait.key) {
              String *ar = (String *)ait.key;
              List *grp = (List *)ait.item;
              if (Len(grp) == 1) {
                /* Single overload at this arity: flat call. */
                Hash *e = (Hash *)Getitem(grp, 0);
                String *ja = (String *)Getattr(e, "jsargs");
                String *bd = (String *)Getattr(e, "js_body");
                Printf(static_js,
                       "        case %s: {\n"
                       "          const [%s] = args;\n"
                       "%s"
                       "        }\n",
                       ar,
                       ja ? Char(ja) : "",
                       bd ? Char(bd) : "");
              } else {
                /* Multiple overloads at this arity: emit type-checks
                   in turn.  Bodies with 'type_checks' come first
                   (most specific); the entry without any type_checks
                   is the fallback.  Iterate in order. */
                Printf(static_js, "        case %s: {\n", ar);
                Hash *fallback = 0;
                for (int gi = 0; gi < Len(grp); ++gi) {
                  Hash *e = (Hash *)Getitem(grp, gi);
                  String *tc = (String *)Getattr(e, "type_checks");
                  if (tc && Len(tc) > 0) {
                    String *ja = (String *)Getattr(e, "jsargs");
                    String *bd = (String *)Getattr(e, "js_body");
                    Printf(static_js,
                           "          if (%s) {\n"
                           "            const [%s] = args;\n"
                           "%s"
                           "          }\n",
                           Char(tc),
                           ja ? Char(ja) : "",
                           bd ? Char(bd) : "");
                  } else if (!fallback) {
                    fallback = e;
                  }
                }
                if (fallback) {
                  String *ja = (String *)Getattr(fallback, "jsargs");
                  String *bd = (String *)Getattr(fallback, "js_body");
                  Printf(static_js,
                         "          {\n"
                         "            const [%s] = args;\n"
                         "%s"
                         "          }\n",
                         ja ? Char(ja) : "",
                         bd ? Char(bd) : "");
                } else {
                  Printf(static_js, "          throw new TypeError(`%s.%s: no overload matches arg types at arity %s`);\n", class_jsname, jsname, ar);
                }
                Printf(static_js, "        }\n");
              }
              ait = Next(ait);
            }
            Delete(byArity);
            Printf(static_js,
                   "        default: throw new Error(`%s.%s: no overload for ${args.length} args`);\n"
                   "      }\n"
                   "    }\n",
                   class_jsname,
                   jsname);
          }
          /* Statics are callable on instances, mirroring Python/MATLAB
             -- unless a real instance method owns the name. */
          if (!member_overloads || !Getattr(member_overloads, key))
            Printf(static_js, "    %s(...args) { return %s.%s(...args); }\n", jsname, class_jsname, jsname);
        }
      }
      sit = Next(sit);
    }
    /* Prepend static methods to class_js_body. */
    if (Len(static_js) > 0) {
      String *nb = NewStringf("%s%s", static_js, class_js_body);
      Delete(class_js_body);
      class_js_body = nb;
    }
    Delete(static_js);
  }

  Printf(f_cpp_wrappers, "// --- class %s (%s) ---\n%s\n", class_jsname, cname, class_cpp_section);

  /* Inheritance: take the first public base if any -- 'class D extends B'. */
  /* For multi-inheritance the additional bases are merged in via */
  /* __mixin() (emitted just below the class) so users see a unified */
  /* interface without having to know about template-parent helpers. */
  String *base_clause = NewString("");
  List *bases = Getattr(n, "bases");
  if (bases && Len(bases) > 0) {
    Node *b = Getitem(bases, 0);
    String *bjsname = Getattr(b, "sym:name");
    if (bjsname)
      Printf(base_clause, " extends %s", bjsname);
  }

  /* Per-class FinalizationRegistry: GC of the JS wrapper triggers */
  /* _swig_<C>_delete on the underlying WASM pointer. Manual .delete() */
  /* is still available below as an opt-in early-release. */
  String *cmangle = mangle(cname);
  Printf(f_js_classes,
         "  const __fr_%s = new FinalizationRegistry(p => __safe_free(M._swig_%s_delete, p));\n"
         "  class %s%s {\n%s  }\n",
         cmangle,
         cmangle,
         class_jsname,
         base_clause,
         class_js_body);

  /* SWIG_WASMJS_ConvertPtr to validate type identity against the */
  /* expected 'swig_type_info::cast' chain. */
  {
    SwigType *ptr_t = Copy(t);
    SwigType_add_pointer(ptr_t);
    String *swig_tag = SwigType_manglestr(ptr_t);
    Printf(f_js_classes,
           "  %s.prototype._swig_type = '%s';\n"
           /* Standard JS string/inspect hooks: forward to the wrapped C++
              str() repr when present.  Generic (any class exposing str());
              no language-specific knowledge here. */
           "  if (!Object.prototype.hasOwnProperty.call(%s.prototype, 'toString'))\n"
           "    %s.prototype.toString = function () { return (typeof this.str === 'function') ? this.str() : Object.prototype.toString.call(this); };\n"
           "  %s.prototype[Symbol.for('nodejs.util.inspect.custom')] = function () { return this.toString(); };\n",
           class_jsname,
           swig_tag,
           class_jsname,
           class_jsname,
           class_jsname);
    /* Record 'swig_tag -> JS class name' so top() can emit a static
       table that SWIG_WASMJS_init_cast_chains uses to wire
       swig_type_info::clientdata.  Once clientdata is set,
       SWIG_WASMJS_NewPointerObj returns fully-typed proxy instances
       directly, eliminating the JS-side 'new <Cls>(__PRIVATE_CTOR, ...)'
       rewrap. */
    if (!mangle_to_jsname)
      mangle_to_jsname = NewHash();
    Setattr(mangle_to_jsname, swig_tag, class_jsname);
    Delete(swig_tag);
    Delete(ptr_t);
  }

  /* Multi-inheritance shim: pull non-first bases' static + prototype */

  /* because GenericMatrix<Matrix<SXElem>> (= GenSX) is one of SX's C++ */
  /* bases and 'static sym' lives there.  Skips bases[0] (already linked */
  /* via 'extends') and any base whose JS name we can't resolve. */
  if (bases && Len(bases) > 1) {
    String *mixin_args = NewString("");
    bool any = false;
    for (int i = 1; i < Len(bases); ++i) {
      Node *b = Getitem(bases, i);
      String *bjsname = Getattr(b, "sym:name");
      if (!bjsname || Len(bjsname) == 0)
        continue;
      Printf(mixin_args, ", %s", bjsname);
      any = true;
    }
    if (any) {
      Printf(f_js_classes, "  __mixin(%s%s);\n", class_jsname, mixin_args);
    }
    Delete(mixin_args);
  }

  Delete(cmangle);
  Delete(base_clause);

  /* Export the class as a Proxy so users get Python-style factory call
     syntax: 'M.MX(2)' is equivalent to 'new M.MX(2)'.  The Proxy's
     'apply' trap forwards to 'Reflect.construct(target, args)'; the
     default 'construct' trap leaves 'new M.MX(...)' working unchanged.
     instanceof / static-method access pass through transparently. */
  if (Getattr(n, "feature:wasmjs:index")) {

    if (!indexed_classes)
      indexed_classes = NewHash();
    Setattr(indexed_classes, class_jsname, "1");
    Printf(
      f_js_module,
      "    %s: new Proxy(%s, { apply(t,_s,a){ return __mkIndex(Reflect.construct(t,a)); }, construct(t,a){ return __mkIndex(Reflect.construct(t,a)); } }),\n",
      class_jsname,
      class_jsname);
  } else {
    Printf(f_js_module, "    %s: new Proxy(%s, { apply(t, _self, a) { return Reflect.construct(t, a); } }),\n", class_jsname, class_jsname);
  }

  Delete(class_cpp_section);
  class_cpp_section = 0;
  Delete(class_js_body);
  class_js_body = 0;
  Delete(ctor_arities_seen);
  ctor_arities_seen = 0;
  if (ctor_overloads) {
    Delete(ctor_overloads);
    ctor_overloads = 0;
  }
  Delete(member_names_seen);
  member_names_seen = 0;
  Delete(member_overload_counts);
  member_overload_counts = 0;
  Delete(cname);
  class_cname = 0;
  class_jsname = 0;
  return SWIG_OK;
}

int WASM_JS::constructorHandler(Node *n) {
  if (!class_cname)
    return Language::constructorHandler(n);
  ParmList *p = Getattr(n, "parms");
  bool skip = false;

  if (!skip) {
    String *cmangle = mangle(class_cname);
    String *swig_name = NewStringf("swig_%s_new_%d", cmangle, ctor_overload_count++);
    name_parms(p);
    String *decls = parm_decls(p);
    String *args = parm_args(p);
    String *prologue = parm_prologue(p);
    String *frees = NewString("");
    String *guards = owned_input_handles(p);
    SwigType *pointer_type = Copy(class_cname);
    SwigType_add_pointer(pointer_type);
    String *native_call = NewStringf("new %s(%s)", class_cname, args);
    String *call = extension_call(n, pointer_type, args, false, native_call);
    Delete(native_call);
    Delete(pointer_type);

    /* Body wrapped in '{ }' so prologue locals are out of scope at the
       'fail:' label (otherwise C++ rejects the goto with "bypasses
       initialization").  Same shape as cpp_call_body. */
    Printf(class_cpp_section,
           "EMSCRIPTEN_KEEPALIVE %s* %s(%s) {\n"
           "%s"
           "  {\n"
           "%s"
           "    %s* _outv = %s;\n"
           "%s"
           "    return _outv;\n"
           "  }\n"
           "fail:\n"
           "  return 0;\n"
           "}\n",
           class_cname,
           swig_name,
           decls,
           guards,
           prologue,
           class_cname,
           call,
           frees);
    Delete(call);
    Delete(guards);
    register_export(Char(swig_name));

    int maximum = parm_arity_js(p);
    int first_default = first_default_arity(p);
    for (int count = first_default < 0 ? maximum : first_default; count <= maximum; ++count) {
      Hash *entry = NewHash();
      set_dispatch_rank(entry, n, p, count);
      String *arity = NewStringf("%d", count);
      String *checks = NewString("");
      String *names = NewString("");
      int index = 0;
      for (Parm *parameter = p; parameter && index < count; parameter = nextSibling(parameter)) {
        if (is_in_numinputs0(parameter))
          continue;
        String *check = build_arg_check(parameter, index);
        if (check && Len(check)) {
          if (Len(checks))
            Append(checks, " && ");
          Append(checks, check);
        }
        Delete(check);
        Printf(names, "%sa%d", index ? ", " : "", index);
        ++index;
      }
      String *defaults = build_defaults_prologue(p, count);
      String *call_body = emit_js_body(p, 0, swig_name, "", n, false);
      String *body = NewStringf("            const [%s] = args;\n%s%s", names, defaults, call_body);
      Setattr(entry, "arity", arity);
      Setattr(entry, "type_checks", checks);
      Setattr(entry, "js_body", body);
      Append(ctor_overloads, entry);
      Delete(body);
      Delete(call_body);
      Delete(defaults);
      Delete(names);
      Delete(checks);
      Delete(arity);
      Delete(entry);
    }

    Delete(swig_name);
    Delete(decls);
    Delete(args);
    Delete(cmangle);
    Delete(prologue);
    Delete(frees);
  }
  /* TS stub: one 'constructor(...)' line per overload (TS supports
     overloaded constructor signatures natively in .d.ts). */
  stub_emit_function(n, "  ", 3);
  return Language::constructorHandler(n);
}

int WASM_JS::destructorHandler(Node *n) {
  if (class_cname) {
    String *cmangle = mangle(class_cname);
    String *swig_name = NewStringf("swig_%s_delete", cmangle);
    SwigType *void_type = NewString("void");
    String *no_args = NewString("");
    String *native_call = NewString("delete self");
    String *call = extension_call(n, void_type, no_args, true, native_call);
    Printf(class_cpp_section, "EMSCRIPTEN_KEEPALIVE void %s(%s* self) { %s; }\n", swig_name, class_cname, call);
    Delete(call);
    Delete(native_call);
    Delete(no_args);
    Delete(void_type);
    register_export(Char(swig_name));
    /* Optional manual release; unregister from FinalizationRegistry to */
    /* avoid double-free when GC eventually runs. */
    Printf(class_js_body,
           "    delete() {\n"
           "      if (this._ptr === 0) return;\n"
           "      if (__fr_%s.unregister(this)) M._%s(this._ptr);\n"
           "      this._ptr = 0;\n"
           "    }\n",
           cmangle,
           swig_name);
    if (stubs && f_stubs)
      Printf(f_stubs, "  delete(): void;\n");
    Delete(swig_name);
    Delete(cmangle);
  }
  return Language::destructorHandler(n);
}

int WASM_JS::memberfunctionHandler(Node *n) {
  if (!class_cname)
    return Language::memberfunctionHandler(n);

  String *jsraw_raw = Getattr(n, "sym:name");
  String *mname = Getattr(n, "name");
  if (Strstr(mname, "operator"))
    return Language::memberfunctionHandler(n);

  /* Strip __SWIG_N suffix so all overloads share the same JS-facing name. */
  String *jsraw = NewString(jsraw_raw);
  const char *suf = Strstr(jsraw, "__SWIG_");
  if (suf)
    Delslice(jsraw, suf - Char(jsraw), DOH_END);

  ParmList *p = Getattr(n, "parms");
  SwigType *rt = Getattr(n, "type");
  String *cmangle = mangle(class_cname);
  /* Per-(class, mname) overload index; unique across all overloads. */
  int idx = next_index(member_overload_counts, mname);
  String *swig_name = NewStringf("swig_%s_%s_%d", cmangle, mname, idx);

  String *self_q = NewString("");
  String *q = Getattr(n, "qualifier");
  if (q && Strstr(q, "const"))
    Printf(self_q, "const ");
  name_parms(p);
  String *decls = parm_decls(p);
  String *args = parm_args(p);
  String *jsargs = js_arg_names(p);
  String *ret_t = effective_return_ctype(rt, p, n);
  String *native_call = NewStringf("self->%s(%s)", mname, args);
  String *call_e = extension_call(n, rt, args, true, native_call);
  Delete(native_call);
  String *body = cpp_call_body(n, p, rt, call_e, false);
  String *guards = owned_input_handles(p);

  SwigType *self_ptr_t = NewString(class_cname);
  SwigType_add_pointer(self_ptr_t);
  String *self_mangled = SwigType_manglestr(self_ptr_t);
  /* Use SWIG_TypeQuery so types not present in the swig_types[] table
     (e.g. unregistered std::vector instantiations like DoubleVector)
     fall back to NULL gracefully -- same behavior as pre-Phase-4.3,
     no cast-chain conversion but the wrapper still works.  Cache the
     descriptor in a function-local static so each wrapper pays the
     hash lookup only on the first call. */
  Printf(class_cpp_section,
         "EMSCRIPTEN_KEEPALIVE %s %s(EM_VAL self_handle%s%s) {\n"
         "%s"
         "  emscripten::val _self_owner = self_handle ? emscripten::val::take_ownership(self_handle) : emscripten::val::undefined();\n"
         "  static swig_type_info* __self_ti = SWIG_TypeQuery(\"%s\");\n"
         "  %s%s* self = 0;\n"
         "  {\n"
         "    void* _self_raw = 0;\n"
         "    if (!SWIG_IsOK(SWIG_ConvertPtr(self_handle, &_self_raw, __self_ti, 0))) "
         "SWIG_exception_fail(SWIG_TypeError, \"self conversion failed\");\n"
         "    self = static_cast<%s%s*>(_self_raw);\n"
         "  }\n"
         "%s}\n",
         ret_t,
         swig_name,
         Len(decls) > 0 ? ", " : "",
         decls,
         guards,
         self_mangled,
         self_q,
         class_cname,
         self_q,
         class_cname,
         body);
  Delete(self_ptr_t);
  Delete(self_mangled);
  register_export(Char(swig_name));

  SwigType *eff_rt = effective_js_return_type(rt, p);

  /* Emit one entry per virtual arity from 'first_default_idx' up to
     'max_arity' inclusive (matches staticmemberfunctionHandler).  This
     gives e.g. 'opti.variable()' / '.variable(rows,cols)' /
     '.variable(rows,cols,type)' all working when the C++ signature is
     'variable(rows=1, cols=1, type="symmetric")'.  Without phantom
     truncations, only the full-arity entry was registered and the
     user-facing dispatcher would throw "no overload for 0 args". */
  int max_arity = parm_arity_js(p);
  int first_default_idx = -1;
  {
    int js_idx = 0;
    for (Parm *q2 = p; q2; q2 = nextSibling(q2)) {
      if (is_in_numinputs0(q2))
        continue;
      String *v = Getattr(q2, "value");
      if (v && Len(v) > 0) {
        if (first_default_idx == -1)
          first_default_idx = js_idx;
      } else {
        first_default_idx = -1;
      }
      ++js_idx;
    }
  }

  if (!member_overloads)
    member_overloads = NewHash();
  String *key = NewStringf("%s::%s", class_jsname, jsraw);
  List *lst = (List *)Getattr(member_overloads, key);
  if (!lst) {
    lst = NewList();
    Setattr(member_overloads, key, lst);
  }

  int lo_arity = (first_default_idx >= 0) ? first_default_idx : max_arity;
  for (int trunc = lo_arity; trunc <= max_arity; ++trunc) {
    Hash *entry = NewHash();
    set_dispatch_rank(entry, n, p, trunc);
    Setattr(entry, "swig_name", Copy(swig_name));
    char ar_str[16];
    snprintf(ar_str, sizeof(ar_str), "%d", trunc);
    Setattr(entry, "arity", NewString(ar_str));

    /* Truncated jsargs (only the present positions). */
    String *trunc_jsargs = NewString("");
    int s = 0;
    for (Parm *q2 = p; q2; q2 = nextSibling(q2)) {
      if (is_in_numinputs0(q2))
        continue;
      if (s < trunc) {
        if (Len(trunc_jsargs) > 0)
          Printv(trunc_jsargs, ", ", NIL);
        Printf(trunc_jsargs, "a%d", s);
      }
      ++s;
    }
    Setattr(entry, "jsargs", trunc_jsargs);

    /* JS body: full body (using a0..a<max-1>) prepended with defaults
       prologue ('const aN = <C++-default>;' for N >= trunc).  Same
       pattern as staticmemberfunctionHandler. */
    String *defaults_prologue = build_defaults_prologue(p, trunc);
    String *body_full = emit_js_body(p, eff_rt ? eff_rt : rt, swig_name, "__unwrap(this)", n);
    String *body_with_defaults = NewStringf("%s%s", Char(defaults_prologue), Char(body_full));
    Setattr(entry, "js_body", body_with_defaults);
    Delete(body_full);
    Delete(defaults_prologue);

    /* Type-discriminator: only the PRESENT (non-default-filled) args
       need probing.  Args at indices >= trunc are filled by the
       defaults prologue so the type discriminator can't probe them
       anyway. */
    {
      String *type_checks = NewString("");
      int pi2 = 0;
      for (Parm *q2 = p; q2; q2 = nextSibling(q2)) {
        if (is_in_numinputs0(q2))
          continue;
        if (pi2 >= trunc)
          break;
        String *check = build_arg_check(q2, pi2);
        if (check) {
          if (Len(type_checks) > 0)
            Printv(type_checks, " && ", NIL);
          Printv(type_checks, check, NIL);
          Delete(check);
        }
        ++pi2;
      }
      if (Len(type_checks) > 0)
        Setattr(entry, "type_checks", type_checks);
      else
        Delete(type_checks);
    }

    Append(lst, entry);
  }
  Delete(key);

  /* TS stub: emit per overload while f_stubs_class_body is the
     active receiver. */
  stub_emit_function(n, "  ", 1);

  Delete(swig_name);
  Delete(cmangle);
  Delete(self_q);
  Delete(jsraw);
  Delete(decls);
  Delete(args);
  Delete(jsargs);
  Delete(ret_t);
  Delete(call_e);
  Delete(body);
  Delete(guards);
  return Language::memberfunctionHandler(n);
}

int WASM_JS::membervariableHandler(Node *n) {
  if (!class_cname)
    return Language::membervariableHandler(n);
  String *jsname = Getattr(n, "sym:name");
  String *fname = Getattr(n, "name");
  String *cmangle = mangle(class_cname);
  String *get_n = NewStringf("swig_%s_%s_get", cmangle, fname);
  String *set_n = NewStringf("swig_%s_%s_set", cmangle, fname);
  SwigType *ft = Getattr(n, "type");
  String *ret = cpp_return_type(ft, n);
  String *expression = NewStringf("self->%s", fname);
  String *body = cpp_call_body(n, 0, ft, expression);
  Printf(class_cpp_section, "EMSCRIPTEN_KEEPALIVE %s %s(const %s* self) {\n%s}\n", ret, get_n, class_cname, body);
  register_export(Char(get_n));
  String *jsbody = emit_js_body(0, ft, get_n, "this._ptr", n);
  Printf(class_js_body, "    get %s() {\n      if (!this._ptr) throw new Error('Object has been deleted');\n%s    }\n", jsname, jsbody);
  Delete(jsbody);
  Delete(body);
  Delete(expression);
  Delete(ret);

  if (!GetFlag(n, "feature:immutable") && !SwigType_isconst(ft)) {
    Parm *value = NewParm(ft, "value", n);
    name_parms(value);
    String *decls = parm_decls(value);
    String *args = parm_args(value);
    SwigType *void_type = NewString("void");
    expression = NewStringf("self->%s = %s", fname, args);
    body = cpp_call_body(n, value, void_type, expression);
    Printf(class_cpp_section, "EMSCRIPTEN_KEEPALIVE void %s(%s* self, %s) {\n%s}\n", set_n, class_cname, decls, body);
    register_export(Char(set_n));
    jsbody = emit_js_body(value, void_type, set_n, "this._ptr", n);
    Printf(class_js_body, "    set %s(a0) {\n      if (!this._ptr) throw new Error('Object has been deleted');\n%s    }\n", jsname, jsbody);
    Delete(jsbody);
    Delete(body);
    Delete(expression);
    Delete(void_type);
    Delete(args);
    Delete(decls);
    Delete(value);
  }
  stub_emit_variable(n, "  ");
  Delete(get_n);
  Delete(set_n);
  Delete(cmangle);
  return Language::membervariableHandler(n);
}

int WASM_JS::staticmemberfunctionHandler(Node *n) {
  if (!class_cname)
    return Language::staticmemberfunctionHandler(n);

  String *jsraw = Getattr(n, "sym:name");
  String *mname = Getattr(n, "name");
  if (Strstr(mname, "operator"))
    return Language::staticmemberfunctionHandler(n);
  String *jsname = NewString(jsraw);
  const char *suf = Strstr(jsname, "__SWIG_");
  if (suf)
    Delslice(jsname, suf - Char(jsname), DOH_END);
  ParmList *p = Getattr(n, "parms");
  SwigType *rt = Getattr(n, "type");
  String *cmangle = mangle(class_cname);
  String *static_key = NewStringf("static_%s", mname);
  int idx = next_index(member_overload_counts, static_key);
  Delete(static_key);
  String *swig_name = NewStringf("swig_%s_static_%s_%d", cmangle, mname, idx);

  name_parms(p);
  String *decls = parm_decls(p);
  String *args = parm_args(p);
  String *jsargs = js_arg_names(p);
  String *ret_t = effective_return_ctype(rt, p, n);
  String *native_call = NewStringf("%s::%s(%s)", class_cname, mname, args);
  String *call_e = extension_call(n, rt, args, false, native_call);
  Delete(native_call);
  String *body = cpp_call_body(n, p, rt, call_e);

  Printf(class_cpp_section, "EMSCRIPTEN_KEEPALIVE %s %s(%s) {\n%s}\n", ret_t, swig_name, decls, body);
  register_export(Char(swig_name));

  /* Collect all overloads per (class, jsname) so the dispatcher can
     route by args.length (default-arg phantoms vs real overloads).
     JS body emission is deferred to the end of classHandler; TS stub
     emission stays here because f_stubs_class_body is only the
     active receiver during Language::classHandler's child walk.
     Build per-arity entries so e.g. MX.sym("x") dispatches to a
     1-arg wrapper that fills in C++ defaults (nrow=1, ncol=1). */
  /* Discover default values: SWIG sets 'value' on parms with defaults
     under compactdefaultargs (the C++ default expression as a
     string).  Build a defaults block per truncation point. */
  int max_arity = parm_arity_js(p);
  /* Walk parms in JS-visible order (skipping numinputs=0 parms) and
     find the index of the first consecutive-defaulted suffix.  Each
     virtual truncation between that and max_arity becomes an extra
     overload that fills in the missing args with their literal
     defaults. */
  int first_default_idx = -1;
  {
    int js_idx = 0;
    for (Parm *q = p; q; q = nextSibling(q)) {
      if (is_in_numinputs0(q))
        continue;
      String *v = Getattr(q, "value");
      if (v && Len(v) > 0) {
        if (first_default_idx == -1)
          first_default_idx = js_idx;
      } else {
        /* A non-defaulted parm appears after a defaulted one --
           shouldn't happen with C++ default-arg semantics, but reset
           to be safe. */
        first_default_idx = -1;
      }
      ++js_idx;
    }
  }

  if (!static_overloads)
    static_overloads = NewHash();
  String *key = NewStringf("%s::%s", class_jsname, jsname);
  List *lst = (List *)Getattr(static_overloads, key);
  if (!lst) {
    lst = NewList();
    Setattr(static_overloads, key, lst);
  }

  /* Emit one entry per virtual arity from 'first_default_idx' up to
     'max_arity' inclusive (max_arity is always emitted, and each
     prefix where the suffix is all-defaulted becomes a phantom). */
  int lo_arity = (first_default_idx >= 0) ? first_default_idx : max_arity;
  for (int trunc = lo_arity; trunc <= max_arity; ++trunc) {
    Hash *entry = NewHash();
    set_dispatch_rank(entry, n, p, trunc);
    Setattr(entry, "swig_name", Copy(swig_name));
    char ar_str[16];
    snprintf(ar_str, sizeof(ar_str), "%d", trunc);
    Setattr(entry, "arity", NewString(ar_str));

    /* Build a truncated jsargs list (only the present args) and a
       defaults prologue (the missing trailing args, with their C++
       defaults translated to JS literals).  Reuses the global
       'build_defaults_prologue' helper for consistency. */
    String *trunc_jsargs = NewString("");
    int s = 0;
    for (Parm *q = p; q; q = nextSibling(q)) {
      if (is_in_numinputs0(q))
        continue;
      if (s < trunc) {
        if (Len(trunc_jsargs) > 0)
          Printv(trunc_jsargs, ", ", NIL);
        Printf(trunc_jsargs, "a%d", s);
      }
      ++s;
    }
    String *defaults_prologue = build_defaults_prologue(p, trunc);
    Setattr(entry, "jsargs", trunc_jsargs);
    String *body_full = emit_js_body(p, rt, swig_name, "", n);
    String *body_with_defaults = NewStringf("%s%s", Char(defaults_prologue), Char(body_full));
    Setattr(entry, "js_body", body_with_defaults);
    Delete(body_full);
    Delete(defaults_prologue);

    /* Per-arg type-discriminator string -- used by the static-method
       dispatcher emitter (in classHandler) to route same-arity
       overloads (e.g. Function::deserialize takes std::istream& or
       const char* or DeserializingStream&; all arity-1, all in
       static_overloads's same list).  Without this we hit the
       first-wins-per-arity dispatcher trap. */
    {
      String *type_checks = NewString("");
      int pi2 = 0;
      for (Parm *q2 = p; q2; q2 = nextSibling(q2)) {
        if (is_in_numinputs0(q2))
          continue;
        if (pi2 >= trunc)
          break;
        String *check = build_arg_check(q2, pi2);
        if (check) {
          if (Len(type_checks) > 0)
            Printv(type_checks, " && ", NIL);
          Printv(type_checks, check, NIL);
          Delete(check);
        }
        ++pi2;
      }
      if (Len(type_checks) > 0) {
        Setattr(entry, "type_checks", type_checks);
      } else {
        Delete(type_checks);
      }
    }

    Append(lst, entry);
  }

  Delete(key);

  /* TS stub: one line per overload (TS supports overloaded static
     signatures natively in .d.ts).  Must emit while
     f_stubs_class_body is active. */
  stub_emit_function(n, "  ", 2);

  Delete(swig_name);
  Delete(jsname);
  Delete(cmangle);
  Delete(decls);
  Delete(args);
  Delete(jsargs);
  Delete(ret_t);
  Delete(call_e);
  Delete(body);
  return Language::staticmemberfunctionHandler(n);
}

int WASM_JS::globalfunctionHandler(Node *n) {
  if (class_cname)
    return Language::globalfunctionHandler(n);

  String *jsraw = Getattr(n, "sym:name");
  String *fname = Getattr(n, "name");
  if (Strstr(fname, "operator"))
    return Language::globalfunctionHandler(n);
  /* Strip __SWIG_N suffix from JS name */
  String *jsname = NewString(jsraw);
  const char *suf = Strstr(jsname, "__SWIG_");
  if (suf)
    Delslice(jsname, suf - Char(jsname), DOH_END);

  ParmList *p = Getattr(n, "parms");
  SwigType *rt = Getattr(n, "type");
  if (!global_overload_counts)
    global_overload_counts = NewHash();
  int idx = next_index(global_overload_counts, fname);
  /* C export symbol must be a valid C identifier. For free functions in */

  String *fmangle = mangle(fname);
  String *swig_name = NewStringf("swig_%s_%d", fmangle, idx);

  name_parms(p);
  String *decls = parm_decls(p);
  String *args = parm_args(p);
  String *jsargs = js_arg_names(p);
  String *ret_t = effective_return_ctype(rt, p, n);
  String *call_e = NewStringf("%s(%s)", fname, args);
  String *body = cpp_call_body(n, p, rt, call_e);

  Printf(f_cpp_wrappers, "EMSCRIPTEN_KEEPALIVE %s %s(%s) {\n%s}\n", ret_t, swig_name, decls, body);
  register_export(Char(swig_name));

  /* Record this overload into global_overloads so end-of-top() can
     emit a single dispatcher per jsname.  Dispatcher picks via the
     first arg's JS class name (e.g. 'args[0].constructor.name ===
     'MXVector''); arity is a coarser tiebreaker.  Stub emission still
     happens per-overload because TS .d.ts uses overload chains. */
  if (!global_overloads)
    global_overloads = NewHash();
  List *overloads = (List *)Getattr(global_overloads, jsname);
  if (!overloads) {
    overloads = NewList();
    Setattr(global_overloads, jsname, overloads);
  }
  String *js_body = emit_js_body(p, rt, swig_name, "", n);
  /* Resolve arg0's expected JS class name for the dispatcher's
     constructor.name check (kept for backwards-compat with the
     dispatcher's arg0_class slot).  Replaced by 'type_checks' below
     for the actual dispatch (multi-arg type discrimination). */
  String *arg0_class = NewString("");
  Parm *first = p;
  while (first && is_in_numinputs0(first))
    first = nextSibling(first);
  if (first) {
    SwigType *t = Getattr(first, "type");
    String *hit = t ? lookup_js_class(t) : 0;
    if (hit)
      Append(arg0_class, hit);
  }

  /* Register one entry per truncated-arity phantom overload, so e.g.
     M.cross(a, b) (2 args) routes to the same wrapper as
     M.cross(a, b, -1n) (3 args, with the C++ default dim=-1 filled).
     Note: jsargs is always the FULL-arity arg list; the truncated
     entries inject 'const aN = <default>;' so the body's reference to
     'aN' resolves. */
  int max_arity = parm_arity_js(p);
  int first_def = first_default_arity(p);
  int lo_arity = (first_def >= 0) ? first_def : max_arity;
  for (int trunc = lo_arity; trunc <= max_arity; ++trunc) {
    Hash *entry = NewHash();
    set_dispatch_rank(entry, n, p, trunc);
    /* Build truncated jsargs list for this arity. */
    String *trunc_jsargs = NewString("");
    {
      int s2 = 0;
      for (Parm *q2 = p; q2; q2 = nextSibling(q2)) {
        if (is_in_numinputs0(q2))
          continue;
        if (s2 < trunc) {
          if (Len(trunc_jsargs) > 0)
            Printv(trunc_jsargs, ", ", NIL);
          Printf(trunc_jsargs, "a%d", s2);
        }
        ++s2;
      }
    }
    String *defaults_prologue = build_defaults_prologue(p, trunc);
    /* The js_body uses a0..a<max-1>; prepend the defaults so any
       missing trailing args are bound to literal defaults. */
    String *body_with_defaults = NewStringf("%s%s", Char(defaults_prologue), Char(js_body));
    Setattr(entry, "body", body_with_defaults);
    Setattr(entry, "arg0_class", Copy(arg0_class));
    char arity_buf[16];
    snprintf(arity_buf, sizeof(arity_buf), "%d", trunc);
    Setattr(entry, "arity", NewString(arity_buf));
    Setattr(entry, "jsargs", trunc_jsargs);

    /* Full per-arg type discriminator (mirrors static/member handler).
       Only the PRESENT (non-default-filled) args at indices 0..trunc-1
       contribute checks. */
    {
      String *type_checks = NewString("");
      int pi2 = 0;
      for (Parm *q2 = p; q2; q2 = nextSibling(q2)) {
        if (is_in_numinputs0(q2))
          continue;
        if (pi2 >= trunc)
          break;
        String *check = build_arg_check(q2, pi2);
        if (check) {
          if (Len(type_checks) > 0)
            Printv(type_checks, " && ", NIL);
          Printv(type_checks, check, NIL);
          Delete(check);
        }
        ++pi2;
      }
      if (Len(type_checks) > 0)
        Setattr(entry, "type_checks", type_checks);
      else
        Delete(type_checks);
    }

    Append(overloads, entry);
    Delete(defaults_prologue);
  }

  /* TS stub emission stays per-overload (TS supports overload chains
     in .d.ts directly, unlike runtime JS). */
  stub_emit_function(n, "", 0);

  Delete(js_body);
  Delete(arg0_class);
  Delete(fmangle);
  Delete(swig_name);
  Delete(jsname);
  Delete(decls);
  Delete(args);
  Delete(jsargs);
  Delete(ret_t);
  Delete(call_e);
  Delete(body);
  return Language::globalfunctionHandler(n);
}

int WASM_JS::constantWrapper(Node *n) {
  if (enum_cname)
    return SWIG_OK;
  String *name = Getattr(n, "sym:name");
  String *value = Getattr(n, "value");
  if (!value)
    value = Getattr(n, "name");
  SwigType *type = Getattr(n, "type");
  String *mangled = mangle(name);
  String *wrapper = NewStringf("swig_constant_%s", mangled);
  String *ctype = cpp_return_type(type, n);
  String *body = cpp_call_body(n, 0, type, value);
  Printf(f_cpp_wrappers, "EMSCRIPTEN_KEEPALIVE %s %s() {\n%s}\n", ctype, wrapper, body);
  register_export(Char(wrapper));
  String *jsbody = emit_js_body(0, type, wrapper, "", n);
  Printf(f_js_module, "    get %s() {\n%s    },\n", name, jsbody);
  if (stubs) {
    Parm *mapped = NewParm(type, Getattr(n, "name"), n);
    Swig_typemap_attach_parms("out", mapped, 0);
    String *annotation = Getattr(mapped, "tmap:out:tsstub_out");
    String *ts = annotation ? Copy(annotation) : type_to_ts(type, true);
    Printf(f_stubs_module, "export const %s: %s;\n", name, ts);
    Delete(ts);
    Delete(mapped);
  }
  Delete(jsbody);
  Delete(body);
  Delete(ctype);
  Delete(wrapper);
  Delete(mangled);
  return SWIG_OK;
}

int WASM_JS::enumDeclaration(Node *n) {
  String *jsname = Getattr(n, "sym:name");
  String *cname = Getattr(n, "name");
  if (!cname || Len(cname) == 0)
    return Language::enumDeclaration(n);

  enum_cname = cname;
  enum_js_body = NewString("");

  if (stubs)
    Printf(f_stubs_module, "export const %s: {\n", jsname);
  Language::enumDeclaration(n);
  if (stubs)
    Printf(f_stubs_module, "};\n");

  Printf(f_js_module, "    %s: Object.freeze({\n%s    }),\n", jsname, enum_js_body);

  Delete(enum_js_body);
  enum_js_body = 0;
  enum_cname = 0;
  return SWIG_OK;
}

int WASM_JS::enumvalueDeclaration(Node *n) {
  if (!enum_cname)
    return Language::enumvalueDeclaration(n);
  String *jsname = Getattr(n, "sym:name");
  String *vname = Getattr(n, "name");
  String *emangle = mangle(enum_cname);
  String *swig_name = NewStringf("swig_enum_%s_%s", emangle, vname);

  String *override_type = Getattr(n, "feature:wasmjs:enum_int_type");
  if (!override_type)
    override_type = Getattr(parentNode(n), "feature:wasmjs:enum_int_type");
  SwigType *resolved_override = override_type && Len(override_type) ? SwigType_typedef_resolve_all(override_type) : 0;
  String *override_cpp = resolved_override ? SwigType_str(resolved_override, 0) : 0;
  if (override_cpp) {
    Printf(f_cpp_wrappers,
           "EMSCRIPTEN_KEEPALIVE EM_VAL %s() { return emscripten::val(static_cast<%s>(%s::%s)).release_ownership(); }\n",
           swig_name,
           override_cpp,
           enum_cname,
           vname);
  } else {
    Printf(f_cpp_wrappers,
           "EMSCRIPTEN_KEEPALIVE EM_VAL %s() { return swig_wasmjs::enum_conversion<%s>::write(%s::%s).release_ownership(); }\n",
           swig_name,
           enum_cname,
           enum_cname,
           vname);
  }
  register_export(Char(swig_name));
  Printf(enum_js_body, "      %s: __from_handle(M._%s()),\n", jsname, swig_name);
  if (stubs) {
    String *type = override_cpp ? cpp_to_ts(override_cpp) : enum_ts_type(parentNode(n));
    Printf(f_stubs_module, "  readonly %s: %s;\n", jsname, type);
    Delete(type);
  }
  Delete(override_cpp);
  Delete(resolved_override);
  Delete(swig_name);
  Delete(emangle);
  return Language::enumvalueDeclaration(n);
}

static Language *new_swig_wasm_js() {
  return new WASM_JS();
}
extern "C" Language *swig_wasm_js(void) {
  return new_swig_wasm_js();
}
