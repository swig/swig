/* -----------------------------------------------------------------------------
 * This file is part of SWIG, which is licensed as a whole under version 3
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at https://www.swig.org/legal.html.
 *
 * julia.cxx
 *
 * Julia language module for SWIG.  Emits a flat extern-"C" C++ wrapper
 * (consumed via ccall) plus a Julia module source file (<module>.jl) with
 * proxy types, finalizers and typed methods. Overloads use Julia dispatch,
 * with conversion probes where signatures would otherwise be ambiguous.
 *
 * Conversions are typemap-driven (Lib/julia/julia.swg): standard names
 * (ctype/in/out/freearg) shape the extern-"C" boundary; julia-prefixed
 * names (jltype/jlparam/jlout) shape the generated .jl methods.
 *
 * Error protocol: every wrapper clears a thread_local error slot on entry
 * and fills it from catch(...); the Julia side checks the slot after each
 * ccall (raising target-side keeps C++ unwinding sane -- never longjmp/
 * jl_throw across C++ frames).
 * ----------------------------------------------------------------------------- */

#include "swigmod.h"
#include <cctype>

class JULIA : public Language {
  File *f_begin;
  String *f_runtime;
  String *f_header;
  String *f_wrappers;
  String *f_init;
  String *f_jl_types;
  String *f_jl_body;
  String *f_jl_exports;
  String *f_directors;   /* SwigDirector_<C> method bodies */
  String *f_directors_h; /* SwigDirector_<C> class decls */

  String *module_name;
  String *f_type_init;   /* body of _swig_jl_init_types() */
  String *f_proxy_pairs; /* ("Name", Name), entries for _proxy_types */
  Hash *jl_methods;      /* "fname|sig-types" -> List of Hash{sig,body,probe,argnames} */
  List *jl_method_order;
  Hash *class_statics;  /* class jlname -> Hash of static fnames */
  Hash *class_members;  /* class jlname -> List of method-line templates (@SELF@) */
  Hash *class_methods;  /* class jlname -> Hash of instance method fname -> "1" */
  Hash *class_bases;    /* class jlname -> List of base jlnames */
  String *class_jlname; /* sym:name of class being processed, 0 outside */
  String *bare_symname; /* unqualified member name captured pre-transform */
  Hash *derived_types;
  Hash *enum_seen;        /* @enum type names already emitted (dedup) */
  Hash *director_classes; /* C++ classname -> "1" for director-enabled classes */
  bool in_ctor, in_static;
  bool class_has_destructor;
  bool class_has_copyctor; /* a copy ctor was wrapped for the current class */
  int n_skipped;

public:
  JULIA() :
    f_begin(0),
    f_runtime(0),
    f_header(0),
    f_wrappers(0),
    f_init(0),
    f_jl_types(0),
    f_jl_body(0),
    f_jl_exports(0),
    f_directors(0),
    f_directors_h(0),
    module_name(0),
    f_type_init(0),
    f_proxy_pairs(0),
    jl_methods(0),
    jl_method_order(0),
    class_statics(0),
    class_members(0),
    class_methods(0),
    class_bases(0),
    class_jlname(0),
    bare_symname(0),
    derived_types(0),
    enum_seen(0),
    director_classes(0),
    in_ctor(false),
    in_static(false),
    class_has_destructor(false),
    class_has_copyctor(false),
    n_skipped(0) {
  }

  virtual void main(int argc, char *argv[]) {
    (void)argc;
    (void)argv;
    SWIG_library_directory("julia");
    Preprocessor_define("SWIGJULIA 1", 0);
    SWIG_config_file("julia.swg");
    allow_overloading();
    directorLanguage(); /* enable %feature("director"); gated per-module in top() */
    /* normal ctors always build the plain class; director subclassing goes
       through a dedicated _swig_new_SwigDirector_<C> wrapper (emitted in
       classDirectorConstructor) so the leading jl_self arg stays explicit. */
    Delete(none_comparison);
    none_comparison = NewString("0");
  }

  /* proxy name for a (possibly ref/ptr) class type, or 0 if not wrapped */
  String *proxy_name(SwigType *t) {
    SwigType *r = SwigType_typedef_resolve_all(t);
    SwigType *base = Copy(r);
    if (SwigType_isreference(base))
      SwigType_del_reference(base);
    else if (SwigType_ispointer(base))
      SwigType_del_pointer(base);
    if (SwigType_isqualifier(base))
      SwigType_del_qualifier(base);
    Node *cls = classLookup(base);
    String *res = cls ? Copy(Getattr(cls, "sym:name")) : 0;
    Delete(base);
    Delete(r);
    return res;
  }

  /* split a Julia method signature ("a::A, b::Any, opts::Integer=Dict()") into
     per-parameter (name, type, hasdefault) triples.  Splitting on top-level
     commas only -- a type annotation may itself contain commas (e.g.
     Union{Integer,Enum}, AbstractVector{<:Real}).  When 'defs' is non-null it
     receives each slot's default literal ("" when none). */
  void split_signature(String *sig, List *names, List *types, List *hasdef, List *defs = 0) {
    const char *s = Char(sig);
    int depth = 0, start = 0, i = 0;
    for (;; ++i) {
      char c = s[i];
      if (c == '{' || c == '(')
        depth++;
      else if (c == '}' || c == ')')
        depth--;
      else if ((c == ',' && depth == 0) || c == '\0') {
        if (i > start) {
          String *part = NewStringWithSize(s + start, i - start);
          String *t = part;
          while (*Char(t) == ' ') {
            String *t2 = NewString(Char(t) + 1);
            if (t != part)
              Delete(t);
            t = t2;
          }
          const char *cc = Strstr(t, "::");
          String *nm = cc ? NewStringWithSize(Char(t), (int)(cc - Char(t))) : Copy(t);
          Replaceall(nm, " ", "");
          String *ty = cc ? NewString(cc + 2) : NewString("Any");
          const char *eq = Strstr(ty, "=");
          int hd = eq ? 1 : 0;
          String *dv = eq ? NewString(eq + 1) : NewString("");
          if (eq) {
            String *t2 = NewStringWithSize(Char(ty), (int)(eq - Char(ty)));
            Delete(ty);
            ty = t2;
          }
          Append(names, nm);
          Append(types, ty);
          Append(hasdef, NewStringf("%d", hd));
          if (defs)
            Append(defs, dv);
          else
            Delete(dv);
          if (t != part)
            Delete(t);
          Delete(part);
        }
        start = i + 1;
        if (c == '\0')
          break;
      }
    }
  }

  /* a "wildcard" Julia parameter type imposes no dispatch constraint: a call
     with a concrete value still matches it.  Two overloads that disagree only
     by having a concrete type where the other has a wildcard, in complementary
     positions, are mutually ambiguous under multiple dispatch. */
  bool is_wildcard_type(String *t) {
    return Strcmp(t, "Any") == 0;
  }

  /* same-arity signatures are mutually ambiguous when, position by position,
     every slot is "compatible" (equal, or one side wildcard) AND each side is
     strictly more specific than the other in at least one slot.  Then neither
     subsumes the other and a call hitting their intersection is ambiguous. */
  /* same arity and identical type in every slot */
  bool sigs_equal(List *ta, List *tb) {
    if (Len(ta) != Len(tb))
      return false;
    for (int i = 0; i < Len(ta); ++i)
      if (Strcmp((String *)Getitem(ta, i), (String *)Getitem(tb, i)) != 0)
        return false;
    return true;
  }

  bool sigs_ambiguous(List *ta, List *tb) {
    if (Len(ta) != Len(tb))
      return false;
    bool a_tighter = false, b_tighter = false;
    for (int i = 0; i < Len(ta); ++i) {
      String *x = (String *)Getitem(ta, i), *y = (String *)Getitem(tb, i);
      if (Strcmp(x, y) == 0)
        continue;
      bool xw = is_wildcard_type(x), yw = is_wildcard_type(y);
      if (xw && !yw)
        b_tighter = true; /* b constrains slot i, a does not */
      else if (yw && !xw)
        a_tighter = true; /* a constrains slot i, b does not */
      else
        return false; /* two distinct concrete types: incomparable */
    }
    return a_tighter && b_tighter;
  }

  /* same arity and no slot holds two distinct concrete types (so generalising
     the disagreeing slots to Any yields a single well-defined signature) */
  bool sigs_compatible(List *ta, List *tb) {
    if (Len(ta) != Len(tb))
      return false;
    for (int i = 0; i < Len(ta); ++i) {
      String *x = (String *)Getitem(ta, i), *y = (String *)Getitem(tb, i);
      if (Strcmp(x, y) == 0)
        continue;
      if (!is_wildcard_type(x) && !is_wildcard_type(y))
        return false;
    }
    return true;
  }

  /* does any slot impose no dispatch constraint? */
  bool has_wildcard(List *t) {
    for (int i = 0; i < Len(t); ++i)
      if (is_wildcard_type((String *)Getitem(t, i)))
        return true;
    return false;
  }

  /* replace the bare Julia identifier 'nm' with 'rep' wherever it appears as a
     call/preserve argument token (",-", "( ", " " or trailing ")") -- the same
     token shapes the drain's arg-rename pass relies on. */
  void replace_arg_token(String *buf, String *nm, String *rep) {
    Replace(buf, nm, rep, DOH_REPLACE_ID);
  }

  /* rebuild jl_methods / jl_method_order so each collected method with trailing
     default args becomes one entry per reachable arity (default-free). */
  void expand_default_arg_arities() {
    if (!jl_method_order)
      return;
    Hash *nm = NewHash();
    List *norder = NewList();
    for (int oi = 0; oi < Len(jl_method_order); ++oi) {
      List *lst = (List *)Getattr(jl_methods, (String *)Getitem(jl_method_order, oi));
      for (int ei = 0; lst && ei < Len(lst); ++ei) {
        Hash *e = (Hash *)Getitem(lst, ei);
        List *names = NewList(), *types = NewList(), *hd = NewList(), *defs = NewList();
        split_signature(Getattr(e, "sig"), names, types, hd, defs);
        int total = Len(names), req = total;
        for (int i = total - 1; i >= 0; --i) {
          if (Strcmp((String *)Getitem(hd, i), "1") == 0)
            req = i;
          else
            break;
        }
        for (int a = req; a <= total; ++a) {
          /* signature for arity a: first a params, defaults stripped */
          String *sig = NewString("");
          String *stypes = NewString("");
          for (int i = 0; i < a; ++i) {
            if (i > 0)
              Printf(sig, ", ");
            Printf(sig, "%s::%s", (String *)Getitem(names, i), (String *)Getitem(types, i));
            Printf(stypes, "%s,", (String *)Getitem(types, i));
          }
          /* body/preserve/jccall_args: splice dropped trailing params back as
             their default literals so the C wrapper still gets all arguments. */
          String *body = Copy(Getattr(e, "body"));
          String *pres = Copy(Getattr(e, "preserve"));
          String *jargs = Copy(Getattr(e, "jccall_args"));
          for (int i = a; i < total; ++i) {
            String *pn = (String *)Getitem(names, i), *dv = (String *)Getitem(defs, i);
            replace_arg_token(body, pn, dv);
            replace_arg_token(jargs, pn, dv);
            /* a dropped param can't still be GC-preserved (it has no binding) */
            String *pp = NewStringf("%s ", pn);
            Replaceall(pres, pp, "");
            Delete(pp);
          }
          Hash *ne = NewHash();
          Setattr(ne, "fname", Copy(Getattr(e, "fname")));
          Setattr(ne, "sig", sig);
          Setattr(ne, "body", body);
          Setattr(ne, "preserve", pres);
          Setattr(ne, "wname", Copy(Getattr(e, "wname")));
          Setattr(ne, "jccall_types", Copy(Getattr(e, "jccall_types")));
          Setattr(ne, "jccall_args", jargs);
          if (Getattr(e, "has_probe"))
            Setattr(ne, "has_probe", "1");
          String *key = NewStringf("%s|%s", Getattr(e, "fname"), stypes);
          List *nl = (List *)Getattr(nm, key);
          if (!nl) {
            nl = NewList();
            Setattr(nm, key, nl);
            Append(norder, Copy(key));
          }
          Append(nl, ne);
          Delete(key);
          Delete(stypes);
        }
        Delete(names);
        Delete(types);
        Delete(hd);
        Delete(defs);
      }
    }
    Delete(jl_methods);
    Delete(jl_method_order);
    jl_methods = nm;
    jl_method_order = norder;
  }

  /* Emit Julia methods for the collected groups.  Overloads that share an
     exact typed signature (several C++ overloads collapsed to Any params), and
     overloads whose Julia signatures would be MUTUALLY AMBIGUOUS under multiple
     dispatch (a concrete type and an Any wildcard in complementary positions),
     are merged into one method whose ambiguous slots are generalised to Any and
     whose correct C wrapper is selected at runtime via _swig_can_ probes.
     'methods'/'order' are mutated (consumed groups emptied). */
  void emit_method_groups(File *jf, Hash *methods, List *order) {
    if (!order)
      return;
    for (int oi = 0; oi < Len(order); ++oi) {
      String *key = (String *)Getitem(order, oi);
      List *lst = (List *)Getattr(methods, key);
      if (!lst || Len(lst) == 0)
        continue; /* claimed by an earlier merge */
      /* Merge overloads whose Julia signatures would collide under multiple
         dispatch.  Only signatures with a wildcard (Any) slot can collide --
         a wildcard fails to separate them, and a sibling overload with a
         concrete type in that slot, plus a wildcard elsewhere, is mutually
         ambiguous.  Seed a cluster from a wildcard-bearing group and fold in
         every same-fname, same-arity, compatible group that also bears a
         wildcard, generalising disagreeing slots to Any.  Fully concrete
         groups (e.g. (A,A)) are never merged: distinct concretes can't
         collide, and Julia resolves them against the generalised method by
         specificity, so they keep their fast direct method.  Iterating to a
         fixpoint collapses (A,Any),(Any,A),(B,Any),(Any,B),(Any,Any),...
         -- regardless of declaration order -- into one method. */
      {
        String *fname0 = Getattr((Hash *)Getitem(lst, 0), "fname");
        List *members = NewList(); /* per cluster-group: its split type list */
        List *gen = NewList();
        {
          List *n0 = NewList(), *t0 = NewList(), *d0 = NewList();
          split_signature(Getattr((Hash *)Getitem(lst, 0), "sig"), n0, t0, d0);
          Append(members, t0);
          for (int pi = 0; pi < Len(t0); ++pi)
            Append(gen, Copy((String *)Getitem(t0, pi)));
          Delete(n0);
          Delete(d0);
        }
        {
          /* Phase A -- ambiguity-transitive closure.  Fold a later group if it
             is MUTUALLY AMBIGUOUS (complementary wildcards) with any member
             already in the cluster.  Comparing against members (not the
             widened gen) keeps the chain connected: (Any,A) bridges (A,Any)
             to (B,Any) even after gen has become (Any,Any).  A fully concrete
             group like (A,A) is ambiguous with none, so it stays out. */
          bool changed = true;
          while (changed) {
            changed = false;
            for (int oj = oi + 1; oj < Len(order); ++oj) {
              String *k2 = (String *)Getitem(order, oj);
              List *l2 = (List *)Getattr(methods, k2);
              if (!l2 || Len(l2) == 0)
                continue;
              Hash *r2 = (Hash *)Getitem(l2, 0);
              if (Strcmp(fname0, Getattr(r2, "fname")) != 0)
                continue;
              List *nb = NewList(), *tb = NewList(), *db = NewList();
              split_signature(Getattr(r2, "sig"), nb, tb, db);
              bool amb = false;
              for (int mi = 0; mi < Len(members) && !amb; ++mi)
                if (sigs_ambiguous((List *)Getitem(members, mi), tb))
                  amb = true;
              if (amb) {
                for (int z = 0; z < Len(l2); ++z)
                  Append(lst, Getitem(l2, z));
                Append(members, Copy(tb));
                for (int pi = 0; pi < Len(gen); ++pi) /* widen gen by this group */
                  if (Strcmp((String *)Getitem(gen, pi), (String *)Getitem(tb, pi)) != 0)
                    Setitem(gen, pi, NewString("Any"));
                Setattr(methods, k2, NewList()); /* mark consumed */
                changed = true;
              }
              Delete(nb);
              Delete(tb);
              Delete(db);
            }
          }
          /* Phase B -- absorb any remaining group whose signature already
             equals the cluster's generalised signature (e.g. an all-Any
             (vector,vector) overload).  It would otherwise re-define the
             merged method.  Only meaningful once gen carries a wildcard. */
          if (has_wildcard(gen)) {
            changed = true;
            while (changed) {
              changed = false;
              for (int oj = oi + 1; oj < Len(order); ++oj) {
                String *k2 = (String *)Getitem(order, oj);
                List *l2 = (List *)Getattr(methods, k2);
                if (!l2 || Len(l2) == 0)
                  continue;
                Hash *r2 = (Hash *)Getitem(l2, 0);
                if (Strcmp(fname0, Getattr(r2, "fname")) != 0)
                  continue;
                List *nb = NewList(), *tb = NewList(), *db = NewList();
                split_signature(Getattr(r2, "sig"), nb, tb, db);
                if (sigs_equal(gen, tb)) {
                  for (int z = 0; z < Len(l2); ++z)
                    Append(lst, Getitem(l2, z));
                  Append(members, Copy(tb));
                  Setattr(methods, k2, NewList()); /* mark consumed */
                  changed = true;
                }
                Delete(nb);
                Delete(tb);
                Delete(db);
              }
            }
          }
          for (int mi = 0; mi < Len(members); ++mi)
            Delete(Getitem(members, mi));
          Delete(members);
        }
        Delete(gen);
      }
      if (Len(lst) == 1) {
        Hash *e = (Hash *)Getitem(lst, 0);
        String *pv = Getattr(e, "preserve");
        if (Len(pv) > 0)
          Printf(jf, "%s(%s) = GC.@preserve %sbegin %s end\n", Getattr(e, "fname"), Getattr(e, "sig"), pv, Getattr(e, "body"));
        else
          Printf(jf, "%s(%s) = %s\n", Getattr(e, "fname"), Getattr(e, "sig"), Getattr(e, "body"));
      } else {
        Hash *e0 = (Hash *)Getitem(lst, 0);
        /* outer signature: per slot, the common type across all entries; a slot
           the entries disagree on is generalised to Any so no two merged
           methods can subsume one another. */
        List *names0 = NewList(), *types0 = NewList(), *def0 = NewList();
        split_signature(Getattr(e0, "sig"), names0, types0, def0);
        List *outtypes = NewList();
        for (int pi = 0; pi < Len(types0); ++pi)
          Append(outtypes, Copy((String *)Getitem(types0, pi)));
        for (int ei = 1; ei < Len(lst); ++ei) {
          List *ne = NewList(), *te = NewList(), *de = NewList();
          split_signature(Getattr((Hash *)Getitem(lst, ei), "sig"), ne, te, de);
          for (int pi = 0; pi < Len(outtypes) && pi < Len(te); ++pi)
            if (Strcmp((String *)Getitem(outtypes, pi), (String *)Getitem(te, pi)) != 0) {
              Setitem(outtypes, pi, NewString("Any"));
            }
          Delete(ne);
          Delete(te);
          Delete(de);
        }
        /* No trailing defaults on a merged method: a default would also make it
           match shorter arities, colliding with the separately-merged method
           for those (each C++ default-arg arity is its own entry). */
        String *osig = NewString("");
        for (int pi = 0; pi < Len(names0); ++pi) {
          if (pi > 0)
            Printf(osig, ", ");
          Printf(osig, "%s::%s", (String *)Getitem(names0, pi), (String *)Getitem(outtypes, pi));
        }
        Printf(jf, "function %s(%s)\n", Getattr(e0, "fname"), osig);
        for (int ei = 0; ei < Len(lst); ++ei) {
          Hash *e = (Hash *)Getitem(lst, ei);
          String *body = Copy(Getattr(e, "body"));
          String *pv = Copy(Getattr(e, "preserve"));
          String *jargs = Copy(Getattr(e, "jccall_args"));
          { /* rename this entry's args to entry-0 names (body, preserve, and
               the can-probe arg-list must all use the merged positional names) */
            List *names = NewList(), *types = NewList(), *defaults = NewList();
            split_signature(Getattr(e, "sig"), names, types, defaults);
            for (int pi = 0; pi < Len(names) && pi < Len(names0); ++pi) {
              String *name = Getitem(names, pi);
              String *replacement = Getitem(names0, pi);
              if (!Equal(name, replacement)) {
                String *temporary = NewStringf("__swig_argument_%d", pi);
                replace_arg_token(body, name, temporary);
                replace_arg_token(pv, name, temporary);
                replace_arg_token(jargs, name, temporary);
                Delete(temporary);
              }
            }
            for (int pi = 0; pi < Len(names0); ++pi) {
              String *temporary = NewStringf("__swig_argument_%d", pi);
              replace_arg_token(body, temporary, Getitem(names0, pi));
              replace_arg_token(pv, temporary, Getitem(names0, pi));
              replace_arg_token(jargs, temporary, Getitem(names0, pi));
              Delete(temporary);
            }
            Delete(names);
            Delete(types);
            Delete(defaults);
          }
          bool last = (ei == Len(lst) - 1);
          if (!last && Getattr(e, "has_probe")) {
            Printf(jf,
                   "    %s ccall((:_swig_can_%s, _lib), Cint, (%s), %s) != 0\n",
                   ei == 0 ? "if" : "elseif",
                   Getattr(e, "wname"),
                   Getattr(e, "jccall_types"),
                   jargs);
          } else if (!last) {
            Printf(jf, "    %s true\n", ei == 0 ? "if" : "elseif");
          } else {
            Printf(jf, "    else\n");
          }
          if (Len(pv) > 0)
            Printf(jf, "        return GC.@preserve %sbegin %s end\n", pv, body);
          else
            Printf(jf, "        return %s\n", body);
          Delete(body);
          Delete(pv);
          Delete(jargs);
        }
        Printf(jf, "    end\nend\n");
        Delete(names0);
        Delete(types0);
        Delete(def0);
        Delete(outtypes);
        Delete(osig);
      }
    }
  }

  /* Collect class 'cls''s own instance-method names plus those inherited from
     all transitive bases into 'out' (a Set-like Hash of fname -> "1"). */
  void collect_flattened_methods(String *cls, Hash *out, Hash *seen) {
    if (Getattr(seen, cls))
      return;
    Setattr(seen, cls, "1");
    Hash *own = class_methods ? (Hash *)Getattr(class_methods, cls) : 0;
    if (own) {
      Iterator mi = First(own);
      while (mi.key) {
        Setattr(out, mi.key, "1");
        mi = Next(mi);
      }
    }
    List *bb = class_bases ? (List *)Getattr(class_bases, cls) : 0;
    if (bb)
      for (int i = 0; i < Len(bb); ++i)
        collect_flattened_methods((String *)Getitem(bb, i), out, seen);
  }

  /* Same as collect_flattened_methods but for STATIC method names, mirroring
     the base-class static forwarders so an inherited static is reachable as
     Derived.static(...) wherever Derived's getproperty is consulted. */
  void collect_flattened_statics(String *cls, Hash *out, Hash *seen) {
    if (Getattr(seen, cls))
      return;
    Setattr(seen, cls, "1");
    Hash *own = class_statics ? (Hash *)Getattr(class_statics, cls) : 0;
    if (own) {
      Iterator si = First(own);
      while (si.key) {
        Setattr(out, si.key, "1");
        si = Next(si);
      }
    }
    List *bb = class_bases ? (List *)Getattr(class_bases, cls) : 0;
    if (bb)
      for (int i = 0; i < Len(bb); ++i)
        collect_flattened_statics((String *)Getitem(bb, i), out, seen);
  }

  /* For every proxy class with at least one instance method (own or inherited),
     emit a 'const Set{Symbol}' of its method names, plus a 'Base.getproperty'
     that maps 'obj.method(args...)' to 'method(obj, args...)'.  Struct fields
     ('ptr', ...) short-circuit to 'getfield' FIRST and the function is '@inline'
     so generated-code 'self.ptr' constant-folds to a plain field load. */
  void emit_method_style_getproperty(File *jf) {
    /* union of all classes that have own methods or that have bases */
    Hash *classes = NewHash();
    if (class_methods) {
      Iterator ci = First(class_methods);
      while (ci.key) {
        Setattr(classes, ci.key, "1");
        ci = Next(ci);
      }
    }
    if (class_bases) {
      Iterator ci = First(class_bases);
      while (ci.key) {
        Setattr(classes, ci.key, "1");
        ci = Next(ci);
      }
    }
    if (Len(classes) == 0) {
      Delete(classes);
      return;
    }
    Printf(jf, "\n# method-style property access: obj.method(args...) -> method(obj, args...)\n");
    Iterator ci = First(classes);
    while (ci.key) {
      String *cls = (String *)ci.key;
      Hash *flat = NewHash();
      Hash *seen = NewHash();
      collect_flattened_methods(cls, flat, seen);
      Delete(seen);
      if (Len(flat) > 0) {
        String *set = NewString("");
        Iterator mi = First(flat);
        bool first = true;
        while (mi.key) {
          Printf(set, "%s:%s", first ? "" : ", ", mi.key);
          first = false;
          mi = Next(mi);
        }
        Printf(jf, "const _swigjl_methods_%s = Set{Symbol}([%s])\n", cls, set);
        Printf(jf,
               "@inline function Base.getproperty(x::%s, s::Symbol)\n"
               "    s in fieldnames(%s) && return getfield(x, s)\n"
               "    if s in _swigjl_methods_%s\n"
               "        f = getfield(@__MODULE__, s)\n"
               "        return (args...; kw...) -> f(x, args...; kw...)\n"
               "    end\n"
               "    return getfield(x, s)\n"
               "end\n",
               cls,
               cls,
               cls);
        Delete(set);
      }
      Delete(flat);
      ci = Next(ci);
    }
    Delete(classes);
  }

  /* For every proxy class with at least one static method (own or inherited),
     emit a 'Base.getproperty(::Type{T}, s::Symbol)' mapping 'T.static(args...)'
     to 'static(T, args...)' (the '::Type{T}' dispatch form already emitted).
     A literal-'===' chain (not a Set/'in') is used deliberately so the compiler
     CONST-FOLDS for literal symbols: 'T.name', 'T.parameters' etc. still infer
     to the exact DataType field type with zero overhead.  Any name not matched
     falls through to 'getfield(T, s)', so DataType reflection/printing is
     unaffected.  Classes with zero statics emit nothing. */
  void emit_static_method_style_getproperty(File *jf) {
    Hash *classes = NewHash();
    if (class_statics) {
      Iterator ci = First(class_statics);
      while (ci.key) {
        Setattr(classes, ci.key, "1");
        ci = Next(ci);
      }
    }
    if (class_bases) {
      Iterator ci = First(class_bases);
      while (ci.key) {
        Setattr(classes, ci.key, "1");
        ci = Next(ci);
      }
    }
    if (Len(classes) == 0) {
      Delete(classes);
      return;
    }
    Printf(jf, "\n# static method-style access: T.static(args...) -> static(T, args...)\n");
    Iterator ci = First(classes);
    while (ci.key) {
      String *cls = (String *)ci.key;
      Hash *flat = NewHash();
      Hash *seen = NewHash();
      collect_flattened_statics(cls, flat, seen);
      Delete(seen);
      if (Len(flat) > 0) {
        Printf(jf, "@inline function Base.getproperty(::Type{%s}, s::Symbol)\n", cls);
        Iterator si = First(flat);
        bool first = true;
        while (si.key) {
          Printf(jf,
                 "    %s s === :%s\n"
                 "        return (args...; kw...) -> %s(%s, args...; kw...)\n",
                 first ? "if" : "elseif",
                 si.key,
                 si.key,
                 cls);
          first = false;
          si = Next(si);
        }
        Printf(jf, "    end\n    return getfield(%s, s)\nend\n", cls);
      }
      Delete(flat);
      ci = Next(ci);
    }
    Delete(classes);
  }

  void collect_derived_types(Node *n) {
    if (Equal(nodeType(n), "class") && !GetFlag(n, "feature:ignore")) {
      List *bases = Getattr(n, "bases");
      List *queue = bases ? Copy(bases) : NewList();
      Hash *seen = NewHash();
      for (int i = 0; i < Len(queue); ++i) {
        Node *base = Getitem(queue, i);
        String *name = Getattr(base, "sym:name");
        if (!name || Getattr(seen, name))
          continue;
        Setattr(seen, name, "1");
        List *children = Getattr(derived_types, name);
        if (!children) {
          children = NewList();
          Setattr(derived_types, name, children);
          Delete(children);
        }
        Append(children, Getattr(n, "sym:name"));
        List *ancestors = Getattr(base, "bases");
        for (int j = 0; ancestors && j < Len(ancestors); ++j)
          Append(queue, Getitem(ancestors, j));
      }
      Delete(queue);
      Delete(seen);
    }
    for (Node *child = firstChild(n); child; child = nextSibling(child))
      collect_derived_types(child);
  }

  virtual int top(Node *n) {
    if (!CPlusPlus) {
      Swig_error(Getfile(n), Getline(n), "Julia wrappers require the -c++ option.\n");
      return SWIG_ERROR;
    }
    derived_types = NewHash();
    collect_derived_types(n);
    module_name = Copy(Getattr(n, "name"));
    String *outfile = Getattr(n, "outfile");
    f_begin = NewFile(outfile, "w", SWIG_output_files());
    if (!f_begin) {
      FileErrorDisplay(outfile);
      Exit(EXIT_FAILURE);
    }
    f_runtime = NewString("");
    f_header = NewString("");
    f_wrappers = NewString("");
    f_init = NewString("");
    f_type_init = NewString("");
    f_proxy_pairs = NewString("");
    f_jl_types = NewString("");
    f_jl_body = NewString("");
    f_jl_exports = NewString("");
    f_directors = NewString("");
    f_directors_h = NewString("");

    /* per-module directors=1 option flips director emission on */
    Node *opts = Getattr(n, "options");
    if (opts && Getattr(opts, "directors"))
      allow_directors();

    Swig_register_filebyname("begin", f_begin);
    Swig_register_filebyname("runtime", f_runtime);
    Swig_register_filebyname("header", f_header);
    Swig_register_filebyname("wrapper", f_wrappers);
    Swig_register_filebyname("init", f_init);
    Swig_register_filebyname("julia", f_jl_body);
    Swig_register_filebyname("director", f_directors);
    Swig_register_filebyname("director_h", f_directors_h);
    /* director runtime (Swig::Director base) before the core fills runtime */
    if (Swig_directors_enabled())
      Swig_insert_file("director.swg", f_runtime);

    Swig_banner(f_begin);
    Printf(f_runtime,
           "#include <string>\n#include <cstring>\n#include <cstdlib>\n#include <cstddef>\n"
           "#include <exception>\n#include <stdexcept>\n#include <julia.h>\n#include <functional>\n#include <new>\n\n"
           "struct swig_jl_cleanup {\n"
           "  std::function<void()> action;\n"
           "  explicit swig_jl_cleanup(const std::function<void()>& fn) : action(fn) {}\n"
           "  ~swig_jl_cleanup() { try { action(); } catch (...) {} }\n"
           "};\n"
           "struct swig_jl_gc_scope {\n"
           "  jl_gcframe_t *saved;\n"
           "  swig_jl_gc_scope() : saved(jl_pgcstack) {}\n"
           "  ~swig_jl_gc_scope() { jl_pgcstack = saved; }\n"
           "};\n"
           "static thread_local int  swig_jl_err_code = 0;\n"
           "static thread_local std::string swig_jl_err_msg;\n"
           "#define SWIG_JL_ENTER() swig_jl_gc_scope _gc_scope; swig_jl_err_code = 0\n"
           "#define SWIG_JL_CATCH(ret) \\\n"
           "  catch (const std::exception& e) { swig_jl_err_code = 1; swig_jl_err_msg = e.what(); return ret; } \\\n"
           "  catch (...) { swig_jl_err_code = 1; swig_jl_err_msg = \"unknown C++ exception\"; return ret; }\n"
           "static inline char* swig_jl_strdup(const std::string& s) { char* p = (char*)malloc(s.size()+1); if (!p) throw std::bad_alloc(); memcpy(p, "
           "s.c_str(), s.size()+1); return p; }\n"
           "extern \"C\" {\n"
           "int swig_jl_last_error_code() { return swig_jl_err_code; }\n"
           "const char* swig_jl_last_error_msg() { return swig_jl_err_msg.c_str(); }\n"
           "void swig_jl_str_free(char* p) { free(p); }\n"
           "}\n\n");

    Language::top(n);

    SwigType_emit_type_table(f_runtime, f_wrappers);
    Printf(f_init, "extern \"C\" void _swig_jl_init_types() {\n  SWIG_InitializeModule(0);\n%s}\n", f_type_init);

    Dump(f_runtime, f_begin);
    Dump(f_header, f_begin);
    Dump(f_directors_h, f_begin);
    Dump(f_directors, f_begin);
    Dump(f_wrappers, f_begin);
    Dump(f_init, f_begin);

    String *jlfile = NewStringf("%s%s.jl", SWIG_output_directory(), module_name);
    File *jf = NewFile(jlfile, "w", SWIG_output_files());
    if (!jf) {
      FileErrorDisplay(jlfile);
      Exit(EXIT_FAILURE);
    }
    Printf(jf, "# Generated by SWIG -julia. Do not edit.\n");
    Printf(jf, "module %s\n\n", module_name);
    Printf(jf, "using Libdl\nconst _lib = joinpath(@__DIR__, \"lib%s_wrap.\" * Libdl.dlext)\n\n", module_name);
    Printf(jf,
           "function __init__()\n    ccall((:_swig_jl_init_types, _lib), Cvoid, ())\n    for (n, t) in _proxy_types\n        "
           "ccall((:swig_jl_register_proxy_type, _lib), Cvoid, (Cstring, Any), n, t)\n    end\n");
    if (Swig_directors_enabled())
      Printf(jf, "    ccall((:swig_jl_set_module, _lib), Cvoid, (Any,), @__MODULE__)\n");
    Printf(jf, "end\n\n");
    Printf(jf,
           "_swig_wrap(T, p, own, owner) = p == C_NULL ? nothing : T(p, own, owner)\n\n"
           "struct SwigError <: Exception\n    msg::String\nend\n"
           "Base.showerror(io::IO, e::SwigError) = print(io, \"%s error: \", e.msg)\n\n"
           "function _check(v)\n"
           "    if ccall((:swig_jl_last_error_code, _lib), Cint, ()) != 0\n"
           "        throw(SwigError(unsafe_string(ccall((:swig_jl_last_error_msg, _lib), Cstring, ()))))\n"
           "    end\n    v\nend\n\n"
           "function _takestr(p::Ptr{UInt8})\n"
           "    _check(p)\n    s = unsafe_string(p)\n"
           "    ccall((:swig_jl_str_free, _lib), Cvoid, (Ptr{UInt8},), p)\n    s\nend\n\n",
           module_name);
    if (Swig_directors_enabled())
      Printf(jf,
             "struct _SwigNoOverride end\nconst _swig_director_no_override = _SwigNoOverride()\n"
             "const _swig_director_roots = Base.IdDict{Any,Any}()\n\n");
    Dump(f_jl_types, jf);
    Printf(jf, "\nconst _proxy_types = [\n%s]\n\n", f_proxy_pairs);
    Dump(f_jl_body, jf);
    /* Expand every collected method that carries trailing default arguments
       into one entry per reachable arity, dropping the Julia-level default.
       A C++ default-arg overload f(a, b, opts=...) otherwise becomes a single
       Julia method matching two arities, and its shorter arity can collide
       with a different overload's longer arity (e.g. conditional / to_function
       below).  Per-arity entries expose those collisions to the merge pass and
       let it disambiguate each arity independently.  The trailing dropped
       parameters are spliced back into the body/preserve as their default
       literals, so the chosen C wrapper still receives every argument. */
    expand_default_arg_arities();
    /* drain collected methods */
    emit_method_groups(jf, jl_methods, jl_method_order);
    /* Julia structs do not inherit: forward static methods from base proxies. */
    if (class_bases) {
      Printf(jf, "\n# base-class static forwarders\n");
      Iterator ci = First(class_bases);
      while (ci.key) {
        String *derived = (String *)ci.key;
        /* transitive base walk */
        List *queue = Copy((List *)ci.item);
        Hash *seen = NewHash();
        /* collect inherited member entries into a fresh per-derived group set,
           then run the same expand+merge+emit as for globals so the flattened
           overloads are disambiguated for the derived class too. */
        Hash *dmeth = NewHash();
        List *dorder = NewList();
        /* Collision keys of the derived class's OWN members. A base-class
           forwarder must not be emitted for a signature the derived class
           already defines: its own definition is emitted earlier, so the
           forwarder would silently overwrite the override (and, since Julia
           1.12, break precompilation outright -- "Method overwriting is not
           permitted during Module precompilation"). The statics path below
           already guards this way. */
        Hash *ownkeys = NewHash();
        {
          List *oml = class_members ? (List *)Getattr(class_members, derived) : 0;
          if (oml) {
            for (int mi = 0; mi < Len(oml); ++mi) {
              Hash *src = (Hash *)Getitem(oml, mi);
              List *nn = NewList(), *tt = NewList(), *dd = NewList();
              split_signature(Getattr(src, "sig"), nn, tt, dd);
              String *st = NewString("");
              for (int z = 0; z < Len(tt); ++z)
                Printf(st, "%s,", (String *)Getitem(tt, z));
              String *key = NewStringf("%s|%s", Getattr(src, "fname"), st);
              Setattr(ownkeys, key, "1");
              Delete(nn);
              Delete(tt);
              Delete(dd);
              Delete(st);
              Delete(key);
            }
          }
        }
        for (int qi = 0; qi < Len(queue); ++qi) {
          String *b = (String *)Getitem(queue, qi);
          if (Getattr(seen, b))
            continue;
          Setattr(seen, b, "1");
          List *ml = class_members ? (List *)Getattr(class_members, b) : 0;
          if (ml) {
            for (int mi = 0; mi < Len(ml); ++mi) {
              Hash *src = (Hash *)Getitem(ml, mi);
              /* rebind self::<base> to self::<derived> in the signature */
              String *sig = Copy(Getattr(src, "sig"));
              String *selfpat = NewStringf("self::%s", Getattr(src, "selftype"));
              String *selfrep = NewStringf("self::%s", derived);
              Replaceall(sig, selfpat, selfrep);
              Delete(selfpat);
              Delete(selfrep);
              Hash *de = NewHash();
              Setattr(de, "fname", Copy(Getattr(src, "fname")));
              Setattr(de, "sig", sig);
              Setattr(de, "body", Copy(Getattr(src, "body")));
              Setattr(de, "preserve", Copy(Getattr(src, "preserve")));
              Setattr(de, "wname", Copy(Getattr(src, "wname")));
              Setattr(de, "jccall_types", Copy(Getattr(src, "jccall_types")));
              Setattr(de, "jccall_args", Copy(Getattr(src, "jccall_args")));
              if (Getattr(src, "has_probe"))
                Setattr(de, "has_probe", "1");
              /* collision key: fname + per-arg TYPES of the rebound signature */
              List *nn = NewList(), *tt = NewList(), *dd = NewList();
              split_signature(sig, nn, tt, dd);
              String *st = NewString("");
              for (int z = 0; z < Len(tt); ++z)
                Printf(st, "%s,", (String *)Getitem(tt, z));
              String *key = NewStringf("%s|%s", Getattr(src, "fname"), st);
              if (Getattr(ownkeys, key)) { /* derived overrides it; keep its own */
                Delete(de);
                Delete(nn);
                Delete(tt);
                Delete(dd);
                Delete(st);
                Delete(key);
                continue;
              }
              List *gl = (List *)Getattr(dmeth, key);
              if (!gl) {
                gl = NewList();
                Setattr(dmeth, key, gl);
                Append(dorder, Copy(key));
              }
              Append(gl, de);
              Delete(nn);
              Delete(tt);
              Delete(dd);
              Delete(st);
              Delete(key);
            }
          }
          Hash *set = class_statics ? (Hash *)Getattr(class_statics, b) : 0;
          if (set) {
            Iterator si = First(set);
            while (si.key) {
              Hash *own = class_statics ? (Hash *)Getattr(class_statics, derived) : 0;
              if (!own || !Getattr(own, si.key))
                Printf(jf, "%s(::Type{%s}, args...) = %s(%s, args...)\n", si.key, derived, si.key, b);
              si = Next(si);
            }
          }
          List *bb = (List *)Getattr(class_bases, b);
          if (bb)
            for (int k = 0; k < Len(bb); ++k)
              Append(queue, Getitem(bb, k));
        }
        /* expand default-arg arities for this derived set, then merge+emit */
        {
          Hash *save_m = jl_methods;
          List *save_o = jl_method_order;
          jl_methods = dmeth;
          jl_method_order = dorder;
          expand_default_arg_arities();
          emit_method_groups(jf, jl_methods, jl_method_order);
          Delete(jl_methods);
          Delete(jl_method_order);
          jl_methods = save_m;
          jl_method_order = save_o;
        }
        Delete(queue);
        Delete(seen);
        Delete(ownkeys);
        ci = Next(ci);
      }
    }
    emit_method_style_getproperty(jf);
    emit_static_method_style_getproperty(jf);
    if (Len(f_jl_exports) > 0)
      Printf(jf, "export %s\n", f_jl_exports);
    Printf(jf, "\nend # module %s\n", module_name);
    Delete(jf);

    if (n_skipped > 0)
      Printf(stderr, "swig -julia: skipped %d declaration(s) with unsupported types\n", n_skipped);

    Delete(f_begin);
    return SWIG_OK;
  }

  void add_export(const String *name) {
    String *probe = NewStringf("|%s|", name);
    String *hay = NewStringf("|%s|", f_jl_exports);
    Replaceall(hay, ", ", "|");
    bool present = Strstr(hay, probe) != 0;
    Delete(probe);
    Delete(hay);
    if (present)
      return;
    if (Len(f_jl_exports) > 0)
      Printv(f_jl_exports, ", ", NIL);
    Printv(f_jl_exports, name, NIL);
  }

  /* a usable Julia identifier: [A-Za-z_][A-Za-z0-9_]*, not a reserved word */
  static bool jl_identifier(const String *s) {
    const char *p = Char(s);
    if (!p || !*p || (!isalpha((unsigned char)*p) && *p != '_'))
      return false;
    for (; *p; ++p)
      if (!isalnum((unsigned char)*p) && *p != '_')
        return false;
    static const char *kw[] = {"end",     "begin",    "function",  "module", "baremodule", "if",       "else",  "elseif", "while",  "for",
                               "try",     "catch",    "finally",   "return", "do",         "let",      "local", "global", "const",  "struct",
                               "mutable", "abstract", "primitive", "type",   "quote",      "macro",    "using", "import", "export", "in",
                               "isa",     "where",    "true",      "false",  "break",      "continue", 0};
    for (int i = 0; kw[i]; ++i)
      if (Strcmp(s, kw[i]) == 0)
        return false;
    return true;
  }

  void skip(Node *n, const char *why) {
    ++n_skipped;
    Swig_warning(WARN_TYPEMAP_UNDEF, Getfile(n), Getline(n), "Julia: cannot wrap %s (%s).\n", Getattr(n, "sym:name"), why);
  }

  /* C expression boxing a scalar/string/class element 'expr' (of resolved
     type 'et') into a jl_value_t*, or 0 if the element kind is unsupported.
     The std::vector<SWIGTYPE>/std::pair<SWIGTYPE,SWIGTYPE> typemaps in
     julia.swg only fire when the matcher generalises template args -- which
     it does not for instantiated templates -- so the backend synthesises the
     marshaling here for std::vector and std::pair returns. */
  String *elem_box(SwigType *et, const char *expr) {
    SwigType *r = SwigType_typedef_resolve_all(et);
    String *res = 0;
    String *s = SwigType_str(r, 0);
    if (Strcmp(s, "double") == 0 || Strcmp(s, "float") == 0)
      res = NewStringf("jl_box_float64((double)(%s))", expr);
    else if (Strcmp(s, "bool") == 0)
      res = NewStringf("jl_box_bool((%s) ? 1 : 0)", expr);
    else if (SwigType_isenum(r))
      res = NewStringf("swig_jl_enum_box(%s)", expr);
    else if (SwigType_type(r) == T_INT || SwigType_type(r) == T_UINT || SwigType_type(r) == T_LONG || SwigType_type(r) == T_ULONG ||
             SwigType_type(r) == T_LONGLONG || SwigType_type(r) == T_ULONGLONG || SwigType_type(r) == T_SHORT || SwigType_type(r) == T_USHORT ||
             SwigType_type(r) == T_CHAR || SwigType_type(r) == T_SCHAR || SwigType_type(r) == T_UCHAR || Strcmp(s, "size_t") == 0)
      res = NewStringf("swig_jl_integer_box(%s)", expr);
    else if (Strcmp(s, "std::string") == 0 || Strcmp(s, "string") == 0)
      res = NewStringf("jl_pchar_to_string((%s).data(), (%s).size())", expr, expr);
    else if (classLookup(r)) { /* class element: heap-copy + proxy wrap */
      SwigType *pt = Copy(r);
      SwigType_add_pointer(pt);
      SwigType_remember(pt);
      String *mangled = SwigType_manglestr(pt);
      String *ct = SwigType_str(r, 0);
      res = NewStringf("SWIG_NewPointerObj(new %s(%s), SWIGTYPE%s, SWIG_POINTER_OWN)", ct, expr, mangled);
      Delete(mangled);
      Delete(pt);
      Delete(ct);
    }
    Delete(s);
    Delete(r);
    return res;
  }

  /* Julia element-type name for a resolved scalar/string SwigType, or 0 if
     the kind has no concrete Julia eltype (used for empty-literal defaults). */
  String *julia_eltype(SwigType *et) {
    SwigType *r = SwigType_typedef_resolve_all(et);
    String *s = SwigType_str(r, 0);
    String *res = 0;
    if (Strcmp(s, "double") == 0 || Strcmp(s, "float") == 0)
      res = NewString("Float64");
    else if (Strcmp(s, "bool") == 0)
      res = NewString("Bool");
    else if (SwigType_isenum(r) || Strcmp(s, "int") == 0 || Strcmp(s, "long") == 0 || Strcmp(s, "long long") == 0 || Strcmp(s, "short") == 0 ||
             Strcmp(s, "size_t") == 0 || Strstr(s, "unsigned"))
      res = NewString("Int64");
    else if (Strcmp(s, "std::string") == 0 || Strcmp(s, "string") == 0)
      res = NewString("String");
    Delete(s);
    Delete(r);
    return res;
  }

  /* Empty Julia literal for a default-constructed std::vector<E>/std::map<K,V>
     argument.  With a known element kind, emit the precise typed literal
     ("Float64[]", "Dict{String,Int64}()", "Dict{String,Vector{String}}()");
     otherwise -- only when 'permissive' (the Julia annotation is 'Any', so an
     untyped literal still type-checks) -- emit the bare "[]" / "Dict()".
     Returns 0 (no default) if the type is neither vector nor map, or the
     element kind is unknown and the annotation is not permissive. */
  String *julia_empty_default(SwigType *t, bool permissive) {
    SwigType *r = SwigType_typedef_resolve_all(t);
    if (SwigType_isreference(r))
      SwigType_del_reference(r);
    if (SwigType_isqualifier(r))
      SwigType_del_qualifier(r);
    String *res = 0;
    if (SwigType_istemplate(r)) {
      String *prefix = SwigType_templateprefix(r);
      List *targs = SwigType_parmlist(r);
      if (Strcmp(prefix, "std::vector") == 0 && Len(targs) >= 1) {
        String *e = julia_eltype((SwigType *)Getitem(targs, 0));
        if (e) {
          res = NewStringf("%s[]", e);
          Delete(e);
        } else if (permissive)
          res = NewString("[]");
      } else if (Strcmp(prefix, "std::map") == 0 && Len(targs) == 2) {
        String *k = julia_eltype((SwigType *)Getitem(targs, 0));
        String *v = julia_eltype((SwigType *)Getitem(targs, 1));
        if (!v) { /* value may itself be a vector/map: recurse for its literal type */
          String *inner = julia_empty_default((SwigType *)Getitem(targs, 1), false);
          if (inner) {
            /* derive the Julia eltype from the literal: "T[]" -> "Vector{T}" */
            const char *ic = Char(inner);
            size_t il = Len(inner);
            if (il >= 2 && ic[il - 1] == ']' && ic[il - 2] == '[') {
              String *base = NewStringWithSize(ic, (int)(il - 2));
              v = NewStringf("Vector{%s}", base);
              Delete(base);
            }
            Delete(inner);
          }
        }
        if (k && v)
          res = NewStringf("Dict{%s,%s}()", k, v);
        else if (permissive)
          res = NewString("Dict()");
        if (k)
          Delete(k);
        if (v)
          Delete(v);
      }
      Delete(prefix);
      Delete(targs);
    }
    Delete(r);
    return res;
  }

  /* If 'rt' is std::vector<E> or std::pair<A,B> with marshallable elements,
     fill ct/jt/jlout and a C 'out' body ($1 -> $result); return true. */
  bool synth_template_return(SwigType *rt, String **ct, String **jt, String **jlout, String **outcode) {
    SwigType *r = SwigType_typedef_resolve_all(rt);
    if (SwigType_isreference(r))
      SwigType_del_reference(r);
    if (SwigType_isqualifier(r))
      SwigType_del_qualifier(r);
    bool done = false;
    if (SwigType_istemplate(r)) {
      String *prefix = SwigType_templateprefix(r);
      List *targs = SwigType_parmlist(r);
      bool is_vec = Strcmp(prefix, "std::vector") == 0 && Len(targs) >= 1;
      bool is_pair = Strcmp(prefix, "std::pair") == 0 && Len(targs) == 2;
      bool ref = SwigType_isreference(SwigType_typedef_resolve_all(rt));
      const char *deref = ref ? "(*$1)" : "$1";
      String *rs = SwigType_str(r, 0); /* concrete container type, e.g. std::vector<Widget> */
      /* bind a typed const-ref to $1: a SwigValueWrapper return converts
         implicitly to const T&, but member access on it would not. */
      String *bind = NewStringf("const %s& __r = %s;", rs, deref);
      if (is_vec) {
        SwigType *et = (SwigType *)Getitem(targs, 0);
        String *probe = elem_box(et, "__r[0]"); /* probe only: validate element kind */
        if (probe) {
          *ct = NewString("jl_value_t*");
          *jt = NewString("Any");
          *jlout = NewString("_check($call)::Vector");
          String *es = SwigType_str(SwigType_typedef_resolve_all(et), 0);
          String *box = elem_box(et, "__e");
          *outcode = NewString("");
          Printf(*outcode,
                 "  { %s\n"
                 "    jl_value_t* __a = jl_apply_array_type((jl_value_t*)jl_any_type, 1);\n"
                 "    jl_array_t* __ja = jl_alloc_array_1d(__a, __r.size());\n"
                 "    JL_GC_PUSH1(&__ja);\n"
                 "    for (size_t __i=0; __i<__r.size(); ++__i) {\n"
                 "      const %s& __e = __r[__i];\n"
                 "      swig_jl_aset((jl_value_t*)__ja, __i, %s);\n"
                 "    }\n"
                 "    JL_GC_POP();\n    $result = (jl_value_t*)__ja; }",
                 bind,
                 es,
                 box);
          Delete(es);
          Delete(box);
          Delete(probe);
          done = true;
        }
      } else if (is_pair) {
        SwigType *t1 = (SwigType *)Getitem(targs, 0);
        SwigType *t2 = (SwigType *)Getitem(targs, 1);
        String *b1 = elem_box(t1, "__r.first");
        String *b2 = elem_box(t2, "__r.second");
        if (b1 && b2) {
          *ct = NewString("jl_value_t*");
          *jt = NewString("Any");
          *jlout = NewString("_check($call)::Tuple");
          *outcode = NewStringf("  { %s\n"
                                "    jl_value_t *first = 0, *second = 0;\n"
                                "    JL_GC_PUSH2(&first, &second);\n"
                                "    first = %s;\n    second = %s;\n"
                                "    $result = swig_jl_make_tuple2(first, second);\n"
                                "    JL_GC_POP();\n  }",
                                bind,
                                b1,
                                b2);
          done = true;
        }
        if (b1)
          Delete(b1);
        if (b2)
          Delete(b2);
      }
      Delete(rs);
      Delete(bind);
      Delete(prefix);
      Delete(targs);
    }
    Delete(r);
    if (done)
      Swig_fragment_emit(NewString("SwigJlRuntime")); /* julia.h + helpers */
    return done;
  }

  /* ---- the single emission point: every callable lands here ---- */

  virtual int functionWrapper(Node *n) {
    String *symname = Getattr(n, "sym:name");
    String *overname = Getattr(n, "sym:overname");
    SwigType *returntype = Getattr(n, "type");
    ParmList *parms = Getattr(n, "parms");

    Wrapper *w = NewWrapper();
    String *wname = NewStringf("_swig_%s_%s%s", class_jlname ? Char(class_jlname) : "g", Char(symname), overname ? Char(overname) : "");
    Setattr(n, "wrap:name", wname);

    /* Resolve enum aliases for C++ locals without changing typemap lookup by the declared alias. */
    for (Parm *p = parms; p; p = nextSibling(p)) {
      SwigType *declared = Getattr(p, "type");
      SwigType *resolved = SwigType_typedef_resolve_all(declared);
      SwigType *base = SwigType_base(resolved);
      SwigType *value_type = Copy(resolved);
      if (SwigType_isreference(value_type))
        SwigType_del_reference(value_type);
      SwigType *unqualified = SwigType_strip_qualifiers(value_type);
      if (SwigType_isenum(unqualified) && (!SwigType_isreference(resolved) || SwigType_isconst(value_type))) {
        if (SwigType_isreference(resolved)) {
          SwigType_add_qualifier(base, "const");
          SwigType_add_reference(base);
        }
        Setattr(p, "julia:enum:declared", declared);
        Setattr(p, "julia:enum:resolved", base);
        Setattr(p, "type", base);
      }
      Delete(unqualified);
      Delete(value_type);
      Delete(base);
      Delete(resolved);
    }
    /* Predeclare corrected locals. The normal emission pass below reuses them because Wrapper_add_local deduplicates names. */
    Swig_cargs(w, parms);
    for (Parm *p = parms; p; p = nextSibling(p)) {
      if (SwigType *declared = Getattr(p, "julia:enum:declared"))
        Setattr(p, "type", declared);
    }
    /* All typemap lookup, including default and arginit, uses the original alias. */
    emit_parameter_variables(parms, w);
    emit_attach_parmmaps(parms, w);
    Swig_typemap_attach_parms("ctype", parms, w);
    Swig_typemap_attach_parms("jltype", parms, w);
    Swig_typemap_attach_parms("jlparam", parms, w);

    /* return-type typemaps via a fake parm (lname needed for $1 subst) */
    Parm *retp = NewParm(returntype, NewString("result"), n);
    Setattr(retp, "lname", Swig_cresult_name());
    Swig_typemap_attach_parms("ctype", retp, 0);
    Swig_typemap_attach_parms("jltype", retp, 0);
    Swig_typemap_attach_parms("jlout", retp, 0);

    String *ret_ct = Getattr(retp, "tmap:ctype:out");
    if (!ret_ct)
      ret_ct = Getattr(retp, "tmap:ctype");
    String *ret_jt = Getattr(retp, "tmap:jltype:out");
    if (!ret_jt)
      ret_jt = Getattr(retp, "tmap:jltype");
    String *ret_jlout = Getattr(retp, "tmap:jlout");
    String *ret_proxy = proxy_name(returntype);
    bool ret_is_class = ret_proxy != 0 && !ret_jlout;
    /* std::vector/std::pair returns: the typemap matcher won't generalise
       instantiated template args to SWIGTYPE, so synthesise the marshaling. */
    String *synth_out = 0;
    if (!ret_jlout && !ret_is_class) {
      String *sct = 0, *sjt = 0, *sjl = 0, *soc = 0;
      if (synth_template_return(returntype, &sct, &sjt, &sjl, &soc)) {
        ret_ct = sct;
        ret_jt = sjt;
        ret_jlout = sjl;
        synth_out = soc;
      }
    }
    if (!ret_ct || !ret_jt || (!ret_jlout && !ret_is_class)) {
      skip(n, "return type");
      DelWrapper(w);
      Delete(wname);
      return SWIG_NOWRAP;
    }

    /* ---- C side: signature + in-typemap marshaling ---- */
    String *csig = NewString("");
    String *jargs = NewString(""); /* Julia typed params */
    List *jarg_names = 0, *jarg_defaults = 0;
    String *jccall_types = NewString("");
    String *jccall_args = NewString("");
    String *preserve = NewString("");
    int idx = 0;
    bool ok = true;
    Parm *p = parms;
    while (p) {
      if (checkAttribute(p, "tmap:in:numinputs", "0")) {
        String *in = Getattr(p, "tmap:in");
        if (in)
          Printv(w->code, in, "\n", NIL);
        p = Getattr(p, "tmap:in:next");
        continue;
      }
      String *ct = Getattr(p, "tmap:ctype");
      String *in = Getattr(p, "tmap:in");
      String *jt = Getattr(p, "tmap:jltype");
      String *jp = Getattr(p, "tmap:jlparam");
      String *pproxy = proxy_name(Getattr(p, "type"));
      bool jl_any = jt && Strcmp(jt, "Any") == 0;
      if (!ct || !in || !jt || (!jp && !pproxy && !jl_any)) {
        ok = false;
        break;
      }

      String *inputvar = NewStringf("jarg%d", idx);
      Setattr(p, "emit:input", inputvar);
      if (Len(csig) > 0)
        Printf(csig, ", ");
      Printf(csig, "%s %s", ct, inputvar);
      String *inb = Copy(in);
      Replaceall(inb, "$input", inputvar);
      Printv(w->code, inb, "\n", NIL);
      Delete(inb);

      String *pname = Getattr(p, "name");
      String *an = (pname && jl_identifier(pname)) ? Copy(pname) : NewStringf("a%d", idx);
      Replaceall(an, "::", "_");
      { /* typemap-applied parms can share names (INOUT, ...): dedupe */
        String *probe = NewStringf("%s::", an);
        bool dup = false;
        if (jarg_names)
          for (int i = 0; i < Len(jarg_names); ++i)
            if (Strncmp((String *)Getitem(jarg_names, i), probe, Len(probe)) == 0) {
              dup = true;
              break;
            }
        if (dup) {
          Delete(an);
          an = NewStringf("a%d", idx);
        }
        Delete(probe);
      }
      if (!jarg_names) {
        jarg_names = NewList();
        jarg_defaults = NewList();
      }
      String *annotation = Copy(jp ? jp : (pproxy ? pproxy : NewString("Any")));
      if (!jp && pproxy && !Equal(pname, "self")) {
        List *derived = Getattr(derived_types, pproxy);
        SwigType *resolved = SwigType_typedef_resolve_all(Getattr(p, "type"));
        bool nullable = SwigType_ispointer(resolved);
        if (derived || nullable) {
          Clear(annotation);
          Printf(annotation, "Union{%s", pproxy);
          for (int i = 0; derived && i < Len(derived); ++i)
            Printf(annotation, ",%s", Getitem(derived, i));
          if (nullable)
            Append(annotation, ",Nothing");
          Append(annotation, "}");
        }
        Delete(resolved);
      }
      Append(jarg_names, NewStringf("%s::%s", an, annotation));
      Delete(annotation);
      { /* compactdefaultargs: literal + empty-container defaults, trailing run */
        String *dv = Getattr(p, "value");
        String *jdv = NewString("");
        if (dv && Len(dv) > 0) {
          const char *dc = Char(dv);
          size_t dl = Len(dv);
          if (Strcmp(dv, "true") == 0 || Strcmp(dv, "false") == 0)
            Printv(jdv, dv, NIL);
          else if (dl >= 2 && dc[0] == '"' && dc[dl - 1] == '"')
            Printv(jdv, dv, NIL);
          else if (dl >= 2 && dc[dl - 2] == '(' && dc[dl - 1] == ')') {
            /* default-constructed value, e.g. T(), std::vector<E>(), Dict():
               opaque-ptr class/container args (passed as '.ptr', see below)
               get the wrapped default ctor; by-value (jl_value_t*) containers
               get an empty Julia literal matching their jlparam annotation. */
            if (!jp && pproxy && !jl_any)
              Printf(jdv, "%s()", pproxy);
            else {
              String *lit = julia_empty_default(Getattr(p, "type"), jl_any);
              if (lit) {
                Printv(jdv, lit, NIL);
                Delete(lit);
              }
            }
          } else {
            bool numeric = Len(dv) > 0;
            for (const char *c = Char(dv); *c; ++c)
              if (!(isdigit(*c) || *c == '.' || *c == '-' || *c == '+' || *c == 'e')) {
                numeric = false;
                break;
              }
            if (numeric)
              Printv(jdv, dv, NIL);
          }
        }
        Append(jarg_defaults, jdv);
      }
      Printf(jccall_types, "%s, ", jt);
      if (!jp && pproxy && !jl_any) { /* opaque-ptr class param: pass .ptr */
        Printf(jccall_args, "%s.ptr, ", an);
        Printf(preserve, "%s ", an);
      } else {
        Printf(jccall_args, "%s, ", an);
      }
      Delete(an);
      Delete(inputvar);
      if (pproxy)
        Delete(pproxy);
      ++idx;
      p = Getattr(p, "tmap:in:next") ? Getattr(p, "tmap:in:next") : nextSibling(p);
    }
    if (!ok) {
      skip(n, "parameter type");
      DelWrapper(w);
      Delete(wname);
      Delete(csig);
      Delete(jargs);
      Delete(jccall_types);
      Delete(jccall_args);
      Delete(preserve);
      return SWIG_NOWRAP;
    }

    /* probe function from typecheck typemaps (overload-ladder support) */
    String *probe_body = NewString("");
    for (int i = 0; i < idx; ++i)
      Printf(probe_body, "  (void)jarg%d;\n", i);
    {
      Parm *q = parms;
      int qi = 0;
      for (; q;) {
        if (checkAttribute(q, "tmap:in:numinputs", "0")) {
          q = Getattr(q, "tmap:in:next");
          continue;
        }
        String *tc = Getattr(q, "tmap:typecheck");
        if (tc) {
          String *b = Copy(tc);
          String *iv = NewStringf("jarg%d", qi);
          Replaceall(b, "$input", iv);
          Replaceall(b, "$1", "_v");
          { /* typecheck was attached with lname substitution already */
            String *ln = Getattr(q, "lname");
            if (ln && Len(ln) > 0)
              Replaceall(b, ln, "_v");
          }
          Printf(probe_body, "  { int _v = 0;\n%s\n  if (!_v) return 0; }\n", b);
          Delete(b);
          Delete(iv);
        }
        ++qi;
        q = Getattr(q, "tmap:in:next") ? Getattr(q, "tmap:in:next") : nextSibling(q);
      }
    }
    bool has_probe = Len(probe_body) > 0;
    if (has_probe) {
      Printf(f_wrappers,
             "extern \"C\" int _swig_can_%s(%s) {\n  SWIG_JL_ENTER();\n  try {\n%s  return 1;\n  } SWIG_JL_CATCH(0)\n}\n\n",
             wname,
             Len(csig) ? Char(csig) : "void",
             probe_body);
    }
    Delete(probe_body);

    /* assemble the Julia parameter list; defaults only as a trailing run */
    if (jarg_names) {
      int first_def = Len(jarg_names);
      for (int i = Len(jarg_names) - 1; i >= 0; --i) {
        if (Len((String *)Getitem(jarg_defaults, i)) == 0)
          break;
        first_def = i;
      }
      for (int i = 0; i < Len(jarg_names); ++i) {
        if (i > 0)
          Printf(jargs, ", ");
        Printv(jargs, (String *)Getitem(jarg_names, i), NIL);
        if (i >= first_def)
          Printf(jargs, "=%s", (String *)Getitem(jarg_defaults, i));
      }
      Delete(jarg_names);
      Delete(jarg_defaults);
    }

    /* action: members/ctors/statics arrive pre-transformed by the Language
       base; plain globals need the default action built here. */
    if (!Getattr(n, "wrap:action")) {
      String *call = Swig_cfunction_call(Getattr(n, "name"), parms);
      Setattr(n, "wrap:action", Swig_cresult(returntype, Swig_cresult_name(), call));
    }
    /* collect argout parms (numinputs=0 + tmap:argout): void-returning
       functions hand them back as the Julia return value */
    List *argouts = NewList();
    for (Parm *q = parms; q; q = nextSibling(q)) {
      if (checkAttribute(q, "tmap:in:numinputs", "0") && Getattr(q, "tmap:argout"))
        Append(argouts, q);
    }
    bool is_void = Strcmp(ret_ct, "void") == 0;
    bool argout_mode = is_void && Len(argouts) > 0;
    if (argout_mode) {
      ret_ct = NewString("jl_value_t*");
      ret_jt = NewString("Any");
      is_void = false;
    }
    if (!is_void) {
      SwigType *resolved = SwigType_typedef_resolve_all(returntype);
      SwigType *unqualified = SwigType_strip_qualifiers(resolved);
      emit_return_variable(n, SwigType_isenum(unqualified) ? unqualified : returntype, w);
      Delete(unqualified);
      Delete(resolved);
    }
    String *original_action = Copy(Getattr(n, "wrap:action"));
    String *normalized_action = Copy(original_action);
    for (Parm *p = parms; p; p = nextSibling(p)) {
      if (SwigType *resolved = Getattr(p, "julia:enum:resolved")) {
        String *before = SwigType_rcaststr(Getattr(p, "type"), Getattr(p, "lname"));
        String *after = SwigType_rcaststr(resolved, Getattr(p, "lname"));
        Replaceall(normalized_action, before, after);
        SwigType *declared = SwigType_typedef_resolve_all(Getattr(p, "type"));
        String *expanded = SwigType_rcaststr(declared, Getattr(p, "lname"));
        Replaceall(normalized_action, expanded, after);
        Delete(expanded);
        Delete(declared);
        Delete(before);
        Delete(after);
        Delattr(p, "julia:enum:declared");
        Delattr(p, "julia:enum:resolved");
      }
    }
    SwigType *resolved_result = SwigType_typedef_resolve_all(returntype);
    SwigType *value_result = SwigType_strip_qualifiers(resolved_result);
    if (SwigType_isenum(value_result)) {
      String *before = Swig_cresult(returntype, Swig_cresult_name(), "$julia_call");
      String *after = Swig_cresult(value_result, Swig_cresult_name(), "$julia_call");
      Replaceall(before, "$julia_call;", "");
      Replaceall(after, "$julia_call;", "");
      Replaceall(normalized_action, before, after);
      Delete(before);
      Delete(after);
    }
    Delete(value_result);
    Delete(resolved_result);
    Setattr(n, "wrap:action", normalized_action);
    String *actioncode = emit_action(n);
    Setattr(n, "wrap:action", original_action);
    Delete(normalized_action);
    Delete(original_action);
    /* director member wrappers carry an 'if (upcall)' base-vs-virtual branch;
       the flat-C surface always calls the virtual (which dispatches to the
       Julia override when present), so pin upcall to false. */
    if (Strstr(actioncode, "upcall"))
      Wrapper_add_local(w, "upcall", "bool upcall = false");

    String *outtm = 0;
    if (argout_mode) {
      outtm = NewString("");
      for (int ai = 0; ai < Len(argouts); ++ai) {
        Parm *q = (Parm *)Getitem(argouts, ai);
        /* container output-args (std::vector<E>&, std::pair&): the generic
           argout body marshals via the interface's from_ptr, which has no
           Julia overload for primitive-element vectors -> reuse the synth
           return marshaling, appending the value to the result tuple. */
        String *sct = 0, *sjt = 0, *sjl = 0, *soc = 0;
        if (synth_template_return(Getattr(q, "type"), &sct, &sjt, &sjl, &soc)) {
          String *m = Copy(soc);
          Replaceall(m, "$1", Getattr(q, "lname"));
          Replaceall(m, "$result", "__ov");
          Printf(outtm, "  { jl_value_t* __ov = 0;\n%s\n    _outv = SWIG_AppendOutput(_outv, __ov); }\n", m);
          Delete(m);
          Delete(sct);
          Delete(sjt);
          Delete(sjl);
          Delete(soc);
          continue;
        }
        String *b = Copy(Getattr(q, "tmap:argout"));
        Replaceall(b, "%append_output(", "_outv = SWIG_AppendOutput(_outv, ");
        Replaceall(b, "$result", "_outv");
        Printv(outtm, b, "\n", NIL);
        Delete(b);
      }
    } else if (synth_out) {
      /* the standard 'out' path embeds the action in the typemap; the synth
         path supplies only the marshaling, so run the action first. */
      outtm = NewStringf("%s\n%s", actioncode, synth_out);
      Replaceall(outtm, "$1", Swig_cresult_name());
      Replaceall(outtm, "$result", "_outv");
    } else if (!is_void) {
      outtm = Swig_typemap_lookup_out("out", n, Swig_cresult_name(), w, actioncode);
      if (!outtm) {
        skip(n, "return conversion");
        DelWrapper(w);
        Delete(wname);
        return SWIG_NOWRAP;
      }
      Replaceall(outtm, "$result", "_outv");
    }

    Printf(f_wrappers, "extern \"C\" %s %s(%s) {\n  SWIG_JL_ENTER();\n  try {\n", ret_ct, wname, Len(csig) ? Char(csig) : "void");
    for (int i = 0; i < idx; ++i)
      Printf(f_wrappers, "  (void)jarg%d;\n", i);
    Printv(f_wrappers, w->locals, NIL);
    String *cleanup = NewString("");
    for (Parm *q = parms; q;) {
      String *code = Copy(Getattr(q, "tmap:freearg"));
      if (code) {
        String *input = Getattr(q, "emit:input");
        if (input)
          Replaceall(code, "$input", input);
        Append(cleanup, code);
        Delete(code);
      }
      q = Getattr(q, "tmap:freearg:next") ? Getattr(q, "tmap:freearg:next") : nextSibling(q);
    }
    if (Len(cleanup))
      Printf(f_wrappers, "  swig_jl_cleanup cleanup([&]() { %s });\n", cleanup);
    Delete(cleanup);
    if (!is_void)
      Printf(f_wrappers, "  %s _outv%s;\n", ret_ct, argout_mode ? " = 0" : "");
    if (argout_mode)
      Printf(f_wrappers, "  JL_GC_PUSH1(&_outv);\n");
    Printv(f_wrappers, w->code, NIL);
    if (is_void) {
      Printv(f_wrappers, actioncode, NIL);
      Printf(f_wrappers, "  return;\n");
    } else {
      if (argout_mode)
        Printv(f_wrappers, actioncode, NIL);
      Printv(f_wrappers, outtm, "\n", NIL);
      Printf(f_wrappers, "  return _outv;\n");
    }
    Printf(f_wrappers, "  } SWIG_JL_CATCH(%s)\n}\n\n", is_void ? "" : (Strstr(ret_ct, "*") ? "0" : (Strcmp(ret_ct, "double") == 0 ? "0.0" : "0")));

    /* ---- Julia side ---- */
    String *callcore = NewStringf("ccall((:%s, _lib), %s, (%s), %s)", wname, ret_jt, jccall_types, jccall_args);
    String *body = 0;
    if (argout_mode) {
      body = NewStringf("_check(%s)", callcore);
    } else if (in_ctor) {
      body = NewStringf("%s(_check(%s), true)", class_jlname, callcore);
    } else if (ret_is_class) {
      SwigType *resolved_return = SwigType_typedef_resolve_all(returntype);
      bool owned = GetFlag(n, "feature:new") || (!SwigType_ispointer(resolved_return) && !SwigType_isreference(resolved_return));
      body = NewStringf("_swig_wrap(%s, _check(%s), %s, (%s))", ret_proxy, callcore, owned ? "true" : "false", jccall_args);
      Delete(resolved_return);
    } else {
      body = Copy(ret_jlout);
      Replaceall(body, "$call", callcore);
    }

    String *fname = in_ctor ? Copy(class_jlname) : bare_symname ? Copy(bare_symname) : Copy(symname);
    /* eval/include are auto-bound in every Julia module and cannot be
       redefined or extended; suffix such method names to avoid the clash. */
    if (!in_ctor && (Strcmp(fname, "eval") == 0 || Strcmp(fname, "include") == 0)) {
      String *safe = NewStringf("%s_", fname);
      Delete(fname);
      fname = safe;
    }
    String *sig = NewString("");
    if (in_static)
      Printf(sig, "::Type{%s}%s", class_jlname, Len(jargs) ? ", " : "");
    Printv(sig, jargs, NIL);
    String *jline = NewString("");
    if (Len(preserve) > 0)
      Printf(jline, "%s(%s) = GC.@preserve %sbegin %s end\n", fname, sig, preserve, body);
    else
      Printf(jline, "%s(%s) = %s\n", fname, sig, body);
    /* collision key: name + per-arg TYPES (drop arg names and defaults) */
    String *sigtypes = NewString("");
    {
      List *names = NewList(), *types = NewList(), *defaults = NewList();
      split_signature(sig, names, types, defaults);
      for (int pi = 0; pi < Len(types); ++pi)
        Printf(sigtypes, "%s,", Getitem(types, pi));
      Delete(names);
      Delete(types);
      Delete(defaults);
    }
    {
      String *key = NewStringf("%s|%s", fname, sigtypes);
      if (!jl_methods) {
        jl_methods = NewHash();
        jl_method_order = NewList();
      }
      List *lst = (List *)Getattr(jl_methods, key);
      if (!lst) {
        lst = NewList();
        Setattr(jl_methods, key, lst);
        Append(jl_method_order, Copy(key));
      }
      Hash *e = NewHash();
      Setattr(e, "fname", Copy(fname));
      Setattr(e, "sig", Copy(sig));
      Setattr(e, "body", Copy(body));
      Setattr(e, "preserve", Copy(preserve));
      Setattr(e, "wname", Copy(wname));
      Setattr(e, "jccall_types", Copy(jccall_types));
      Setattr(e, "jccall_args", Copy(jccall_args));
      if (has_probe)
        Setattr(e, "has_probe", "1");
      Append(lst, e);
      Delete(key);
    }
    Delete(sigtypes);
    if (class_jlname && !in_static && !in_ctor) {
      /* member method: register a structured entry for derived-class
         flattening.  Stored entries flow through the same expand+merge+emit as
         globals (per derived class), so inherited overloads are disambiguated
         too.  'selftype' marks the leading self:: annotation to rewrite. */
      String *selfpat = NewStringf("self::%s", class_jlname);
      if (Strstr(sig, selfpat)) {
        Hash *me = NewHash();
        Setattr(me, "fname", Copy(fname));
        Setattr(me, "sig", Copy(sig));
        Setattr(me, "body", Copy(body));
        Setattr(me, "preserve", Copy(preserve));
        Setattr(me, "wname", Copy(wname));
        Setattr(me, "jccall_types", Copy(jccall_types));
        Setattr(me, "jccall_args", Copy(jccall_args));
        if (has_probe)
          Setattr(me, "has_probe", "1");
        Setattr(me, "selftype", Copy(class_jlname));
        if (!class_members)
          class_members = NewHash();
        List *lst = (List *)Getattr(class_members, class_jlname);
        if (!lst) {
          lst = NewList();
          Setattr(class_members, class_jlname, lst);
        }
        Append(lst, me);
        /* record this instance method name for method-style getproperty */
        if (!class_methods)
          class_methods = NewHash();
        Hash *ms = (Hash *)Getattr(class_methods, class_jlname);
        if (!ms) {
          ms = NewHash();
          Setattr(class_methods, class_jlname, ms);
        }
        Setattr(ms, fname, "1");
      }
      Delete(selfpat);
    }
    Delete(jline);
    if (!class_jlname || in_static || in_ctor)
      add_export(fname);
    if (in_static && class_jlname) {
      if (!class_statics)
        class_statics = NewHash();
      Hash *set = (Hash *)Getattr(class_statics, class_jlname);
      if (!set) {
        set = NewHash();
        Setattr(class_statics, class_jlname, set);
      }
      Setattr(set, fname, "1");
    }

    Delete(fname);
    Delete(sig);
    Delete(body);
    Delete(callcore);
    Delete(csig);
    Delete(jargs);
    Delete(jccall_types);
    Delete(jccall_args);
    Delete(preserve);
    Delete(wname);
    if (ret_proxy)
      Delete(ret_proxy);
    DelWrapper(w);
    return SWIG_OK;
  }

  /* ---- context plumbing around the Language base transforms ---- */

  virtual int classHandler(Node *n) {
    class_jlname = Getattr(n, "sym:name");
    String *cname = Getattr(n, "name");
    class_has_copyctor = false;
    class_has_destructor = false;

    Printf(f_jl_types,
           "mutable struct %s\n    ptr::Ptr{Cvoid}\n    owner::Any\n"
           "    function %s(p::Ptr{Cvoid}, own::Bool=false, owner=nothing)\n"
           "        x = new(p, owner)\n"
           "        finalizer(o -> (own && ccall((:_swig_%s_delete, _lib), Cvoid, (Ptr{Cvoid},), o.ptr); o.ptr = C_NULL; o.owner = nothing), x)\n"
           "        x\n    end\nend\n",
           class_jlname,
           class_jlname,
           class_jlname);
    add_export(class_jlname);

    String *cxxname = SwigType_namestr(cname);
    Printf(f_proxy_pairs, "    (\"%s\", %s),\n", class_jlname, class_jlname);
    {
      SwigType *ct = Copy(Getattr(n, "name"));
      SwigType_add_pointer(ct);
      SwigType_remember(ct);
      String *mangled = SwigType_manglestr(ct);
      Printf(f_type_init, "  swig_jl_register_proxy(\"%s\", SWIGTYPE%s);\n", class_jlname, mangled);
      Delete(mangled);
      Delete(ct);
    }

    {
      List *bases = Getattr(n, "bases");
      if (bases && Len(bases) > 0) {
        if (!class_bases)
          class_bases = NewHash();
        List *bl = NewList();
        for (int bi = 0; bi < Len(bases); ++bi) {
          String *bn = Getattr(Getitem(bases, bi), "sym:name");
          if (bn)
            Append(bl, Copy(bn));
        }
        Setattr(class_bases, class_jlname, bl);
      }
    }
    Language::classHandler(n);
    Printf(f_wrappers, "extern \"C\" void _swig_%s_delete(void *p) {\n  SWIG_JL_ENTER();\n  try {\n", class_jlname);
    if (class_has_destructor)
      Printf(f_wrappers, "    delete static_cast<%s*>(p);\n", cxxname);
    else
      Printf(f_wrappers, "    (void)p;\n");
    Printf(f_wrappers, "  } SWIG_JL_CATCH()\n}\n\n");
    Delete(cxxname);
    /* copy-constructible proxy: give Julia an independent copy/deepcopy
       (proxies otherwise alias one C++ object). */
    if (class_has_copyctor) {
      Printf(f_jl_body, "Base.copy(x::%s) = %s(x)\n", class_jlname, class_jlname);
      Printf(f_jl_body, "Base.deepcopy(x::%s) = %s(x)\n", class_jlname, class_jlname);
    }
    class_has_copyctor = false;
    class_jlname = 0;
    return SWIG_OK;
  }

  /* True if 'n' is a copy constructor of class 'cls': a single in-parameter
     whose type resolves (after stripping const/ref) to the class itself. */
  bool is_copy_constructor(Node *n, Node *cls) {
    ParmList *parms = Getattr(n, "parms");
    if (!parms || ParmList_len(parms) != 1)
      return false;
    SwigType *pt = Getattr(parms, "type");
    if (!pt)
      return false;
    SwigType *r = SwigType_typedef_resolve_all(pt);
    if (SwigType_isreference(r))
      SwigType_del_reference(r);
    if (SwigType_isqualifier(r))
      SwigType_del_qualifier(r);
    Node *pc = classLookup(r);
    bool same = pc && cls && Getattr(pc, "name") && Strcmp(Getattr(pc, "name"), Getattr(cls, "name")) == 0;
    Delete(r);
    return same;
  }

  virtual int constructorHandler(Node *n) {
    Node *cls = Swig_methodclass(n);
    if (cls && is_copy_constructor(n, cls))
      class_has_copyctor = true;
    in_ctor = true;
    int r = Language::constructorHandler(n);
    in_ctor = false;
    return r;
  }

  virtual int memberfunctionHandler(Node *n) {
    bare_symname = Copy(Getattr(n, "sym:name"));
    int r = Language::memberfunctionHandler(n);
    Delete(bare_symname);
    bare_symname = 0;
    return r;
  }

  virtual int staticmemberfunctionHandler(Node *n) {
    in_static = true;
    bare_symname = Copy(Getattr(n, "sym:name"));
    int r = Language::staticmemberfunctionHandler(n);
    Delete(bare_symname);
    bare_symname = 0;
    in_static = false;
    return r;
  }

  /* Named enums get a typed Julia @enum (instances named <Enum>_<member>);
     anonymous enums and plain constants fall through to integer consts. */
  virtual int enumDeclaration(Node *n) {
    if (ImportMode)
      return SWIG_OK;
    if (GetFlag(n, "feature:ignore"))
      return SWIG_OK;
    String *ename = Getattr(n, "sym:name");
    /* anonymous, $unnamed$, or already-emitted type: per-value consts only */
    if (!ename || !jl_identifier(ename))
      return Language::enumDeclaration(n);
    if (enum_seen && Getattr(enum_seen, ename))
      return Language::enumDeclaration(n);
    List *members = NewList();
    for (Node *c = firstChild(n); c; c = nextSibling(c)) {
      if (!Equal(nodeType(c), "enumitem") || GetFlag(c, "feature:ignore"))
        continue;
      String *mn = Getattr(c, "sym:name");
      if (!jl_identifier(mn)) {
        Delete(members);
        return Language::enumDeclaration(n);
      }
      Append(members, c);
    }
    if (!Len(members)) {
      Delete(members);
      return Language::enumDeclaration(n);
    }
    for (int i = 0; i < Len(members); ++i) {
      Node *c = Getitem(members, i);
      String *instance = NewStringf("%s_%s", ename, Getattr(c, "sym:name"));
      Setattr(c, "julia:enuminstance", instance);
      Delete(instance);
    }
    int result = Language::enumDeclaration(n);
    for (int i = Len(members) - 1; i >= 0; --i) {
      if (!Getattr(Getitem(members, i), "julia:enumgetter"))
        Delitem(members, i);
    }
    if (!Len(members)) {
      Delete(members);
      return result;
    }
    /* Values and representation come from C++, including expressions, aliases
       and implicit increments after ignored members. Julia requires unique
       values in '@enum'; additional C++ names become aliases afterwards. */
    Printf(f_jl_body, "let names = [");
    for (int i = 0; i < Len(members); ++i)
      Printf(f_jl_body, "%s:%s", i ? ", " : "", Getattr(Getitem(members, i), "julia:enuminstance"));
    Printf(f_jl_body, "], values = [");
    for (int i = 0; i < Len(members); ++i)
      Printf(f_jl_body, "%sccall((:%s, _lib), Any, ())", i ? ", " : "", Getattr(Getitem(members, i), "julia:enumgetter"));
    Printf(f_jl_body,
           "]\n  items = Expr[]\n  seen = Set()\n"
           "  for (name, value) in zip(names, values)\n"
           "    if !(value in seen)\n      push!(items, :($name = $value))\n      push!(seen, value)\n    end\n  end\n"
           "  @eval @enum %s::$(typeof(first(values))) $(items...)\n"
           "  empty!(seen)\n  for (name, value) in zip(names, values)\n"
           "    if value in seen\n      @eval const $name = %s($value)\n    end\n    push!(seen, value)\n  end\nend\n",
           ename,
           ename);
    for (int i = 0; i < Len(members); ++i)
      add_export(Getattr(Getitem(members, i), "julia:enuminstance"));
    add_export(ename);
    if (!enum_seen)
      enum_seen = NewHash();
    Setattr(enum_seen, ename, "1");
    Delete(members);
    return result;
  }

  virtual int constantWrapper(Node *n) {
    String *symname = Getattr(n, "sym:name");
    if (!jl_identifier(symname)) {
      skip(n, "name not a Julia identifier");
      return SWIG_OK;
    }
    String *value = Getattr(n, "value");
    SwigType *t = Getattr(n, "type");
    String *ts = SwigType_str(t, 0);
    /* class-scope: reference the fully-qualified C++ name in the getter */
    String *cref = (class_jlname && Getattr(n, "name")) ? Getattr(n, "name") : value;
    if (Equal(nodeType(n), "enumitem")) {
      String *getter = NewStringf("_swig_const_%s", symname);
      Printf(f_wrappers, "extern \"C\" jl_value_t *%s() { return swig_jl_enum_box(%s); }\n", getter, cref);
      Setattr(n, "julia:enumgetter", getter);
      if (!Equal(symname, Getattr(n, "julia:enuminstance"))) {
        Printf(f_jl_body, "const %s = ccall((:%s, _lib), Any, ())\n", symname, getter);
        add_export(symname);
      }
      Delete(getter);
    } else if (Strcmp(ts, "int") == 0 || Strcmp(ts, "long") == 0 || Strstr(ts, "long long")) {
      /* The value may be a qualified C++ name; emit a C getter. */
      Printf(f_wrappers, "extern \"C\" long long _swig_const_%s() { return (long long)(%s); }\n", symname, cref);
      Printf(f_jl_body, "const %s = Int(ccall((:_swig_const_%s, _lib), Clonglong, ()))\n", symname, symname);
      add_export(symname);
    } else if (Strcmp(ts, "double") == 0) {
      Printf(f_wrappers, "extern \"C\" double _swig_const_%s() { return (double)(%s); }\n", symname, cref);
      Printf(f_jl_body, "const %s = ccall((:_swig_const_%s, _lib), Cdouble, ())\n", symname, symname);
      add_export(symname);
    } else {
      skip(n, "constant type");
    }
    Delete(ts);
    return SWIG_OK;
  }

  /* ---- directors: subclass a C++ class from Julia ----
   *
   * Each director-marked class C gets a C++ 'SwigDirector_C : public C,
   * public Swig::Director'.  Its overridden virtuals marshal C++ args to
   * Julia (directorin), call the module generic function 'C_<method>(self,
   * args...)', and marshal the Julia return back (directorout).  The Julia
   * side: a user defines a struct + 'C_<method>(self::MySub, args...) = ...'
   * and constructs 'C(self)' -- the ctor wrapper builds a SwigDirector_C
   * holding 'self'.  Non-overridden methods fall through to the C++ base. */

  virtual int classDirectorInit(Node *n) {
    String *declaration = Swig_director_declaration(n);
    Printf(f_directors_h, "\n%s\npublic:\n", declaration);
    Delete(declaration);
    return Language::classDirectorInit(n);
  }

  virtual int classDirectorEnd(Node *n) {
    Printf(f_directors_h, "};\n\n");
    return Language::classDirectorEnd(n);
  }

  /* Emit the dedicated director-construction C wrapper + Julia entry for a
     class C: _swig_new_SwigDirector_C(jl_self) -> void*; Julia C(self) builds
     a SwigDirector_C rooting self.  The leading jl_value_t* self is defaulted
     so the (dead) auto-generated 'new SwigDirector_C()' branch also compiles. */
  void emit_director_construct(String *supername, String *cxxname) {
    Printf(f_wrappers,
           "extern \"C\" void* _swig_new_SwigDirector_%s(jl_value_t *self) {\n"
           "  SWIG_JL_ENTER();\n  try { return static_cast<void*>(static_cast<%s*>(new SwigDirector_%s(self))); }\n"
           "  SWIG_JL_CATCH(0)\n}\n\n",
           supername,
           cxxname,
           supername);
    /* construct a proxy from the director pointer (self rooted by Swig::Director) */
    Printf(f_jl_body, "%s(self) = %s(_check(ccall((:_swig_new_SwigDirector_%s, _lib), Ptr{Cvoid}, (Any,), self)), true)\n", supername, supername, supername);
    (void)cxxname;
  }

  /* ctor: prepend 'jl_value_t* jl_self=0' to the user ctor parms; base-init the
     C++ class and Swig::Director(jl_self). */
  virtual int classDirectorConstructor(Node *n) {
    Node *parent = Getattr(n, "parentNode");
    String *supername = Swig_class_name(parent);
    String *classname = NewStringf("SwigDirector_%s", supername);
    String *decl = Getattr(n, "decl");
    ParmList *superparms = Getattr(n, "parms");
    /* append a trailing, defaulted 'jl_value_t* jl_self=0'; trailing keeps the
       auto-generated 'new SwigDirector_C(args)' (dead, $comparison==0) legal. */
    ParmList *parms = CopyParmList(superparms);
    SwigType *self_type = NewString("jl_value_t *");
    Parm *self_p = NewParm(self_type, NewString("jl_self"), n);
    Setattr(self_p, "value", "0");
    if (!parms)
      parms = self_p;
    else {
      Parm *last = parms;
      while (nextSibling(last))
        last = nextSibling(last);
      set_nextSibling(last, self_p);
    }
    if (!Getattr(n, "defaultargs")) {
      Wrapper *w = NewWrapper();
      String *target = Swig_method_decl(0, decl, classname, parms, 0);
      String *call = Swig_csuperclass_call(0, Getattr(parent, "classtype"), superparms);
      Printf(w->def, "%s::%s : %s, Swig::Director(jl_self) { }\n\n", classname, target, call);
      Wrapper_print(w, f_directors);
      Delete(target);
      Delete(call);
      DelWrapper(w);
      String *hdr = Swig_method_decl(0, decl, classname, parms, 1);
      Printf(f_directors_h, "    %s;\n", hdr);
      Delete(hdr);
      if (ParmList_len(superparms) == 0)
        emit_director_construct(supername, Getattr(parent, "name"));
    }
    Delete(classname);
    Delete(supername);
    Delete(self_type);
    Delete(parms);
    return Language::classDirectorConstructor(n);
  }

  virtual int classDirectorDefaultConstructor(Node *n) {
    String *classname = Swig_class_name(n);
    Wrapper *w = NewWrapper();
    Printf(w->def, "SwigDirector_%s::SwigDirector_%s(jl_value_t *jl_self) : Swig::Director(jl_self) { }\n\n", classname, classname);
    Wrapper_print(w, f_directors);
    DelWrapper(w);
    Printf(f_directors_h, "    SwigDirector_%s(jl_value_t *jl_self = 0);\n", classname);
    emit_director_construct(classname, Getattr(n, "name"));
    Delete(classname);
    return Language::classDirectorDefaultConstructor(n);
  }

  virtual int classDirectorMethod(Node *n, Node *parent, String *super) {
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

    SwigType *rtype = Getattr(n, "conversion_operator") ? 0 : Getattr(n, "classDirectorMethods:type");
    String *pclassname = NewStringf("SwigDirector_%s", classname);
    String *qualname = NewStringf("%s::%s", pclassname, name);
    String *impl_sig = Swig_method_decl(rtype, decl, qualname, l, 0);
    String *hdr_sig = Swig_method_decl(rtype, decl, name, l, 1);

    Swig_director_parms_fixup(l);
    Swig_typemap_attach_parms("directorin", l, 0);

    Wrapper *w = NewWrapper();
    Printf(w->def, "%s {\n", impl_sig);

    /* the module dispatch function for this virtual; a per-arg jl_value_t[] */
    String *dispatch = NewStringf("%s_%s", classname, name);
    String *args_build = NewString("");
    int nargs = 0;
    for (Parm *p = l; p; p = nextSibling(p)) {
      if (checkAttribute(p, "tmap:in:numinputs", "0"))
        continue;
      String *tm = Getattr(p, "tmap:directorin");
      if (!tm) {
        Swig_warning(WARN_TYPEMAP_DIRECTORIN_UNDEF,
                     input_file,
                     line_number,
                     "Unable to use type %s as a function argument in director method %s::%s (skipping director method).\n",
                     SwigType_str(Getattr(p, "type"), 0),
                     SwigType_namestr(c_classname),
                     SwigType_namestr(name));
        status = SWIG_NOWRAP;
        break;
      }
      String *body = Copy(tm);
      Replaceall(body, "$input", NewStringf("__jargs[%d]", nargs + 1));
      Replaceall(body, "$1", Getattr(p, "name"));
      Printf(args_build, "    { %s }\n", body);
      ++nargs;
      Delete(body);
    }

    /* return marshaling (skipped for void) */
    String *ret_marshal = NewString("");
    if (status == SWIG_OK && !is_void) {
      String *tm = Swig_typemap_lookup("directorout", n, Swig_cresult_name(), 0);
      if (!tm) {
        Swig_warning(WARN_TYPEMAP_DIRECTOROUT_UNDEF,
                     input_file,
                     line_number,
                     "Unable to use return type %s in director method %s::%s (skipping director method).\n",
                     SwigType_str(returntype, 0),
                     SwigType_namestr(c_classname),
                     SwigType_namestr(name));
        status = SWIG_NOWRAP;
      } else {
        String *cres = SwigType_lstr(returntype, "c_result");
        Printf(ret_marshal, "      %s;\n", cres);
        Replaceall(tm, "$input", "__r");
        Replaceall(tm, "$result", "c_result");
        Printf(ret_marshal, "      { %s }\n", tm);
        Delete(cres);
        Delete(tm);
      }
    }

    if (status == SWIG_OK) {
      /* base-call expression for non-overridden / pure paths */
      String *basecall = NewString("");
      if (pure_virtual) {
        Printf(basecall, "Swig::DirectorPureVirtualException(\"%s::%s\")", classname, name);
      }
      Printf(w->code,
             "  swig_jl_gc_scope __gc_scope;\n"
             "  jl_value_t *__self = swig_get_self();\n"
             "  jl_value_t *__f = Swig::swig_director_fn(\"%s\");\n",
             dispatch);
      Printf(w->code, "  if (__self && __f) {\n");
      Printf(w->code, "    jl_value_t **__jargs;\n");
      Printf(w->code, "    JL_GC_PUSHARGS(__jargs, %d);\n", nargs + 2);
      Printf(w->code, "    __jargs[0] = __self;\n");
      Printv(w->code, args_build, NIL);
      Printf(w->code, "    jl_value_t *__r = jl_call(__f, __jargs, %d);\n", nargs + 1);
      Printf(w->code, "    __jargs[%d] = __r;\n", nargs + 1);
      /* upcall raised: surface the Julia exception's own message to C++ */
      Printf(w->code,
             "    if (!__r) {\n"
             "      std::string __em = Swig::swig_director_exception_msg();\n"
             "      JL_GC_POP();\n"
             "      throw std::runtime_error(\"Julia director %s threw: \" + __em);\n"
             "    }\n",
             dispatch);
      /* a non-overridden method returns the no-override sentinel -> fall to base */
      Printf(w->code, "    if (__r != Swig::swig_director_global(\"_swig_director_no_override\")) {\n");
      if (is_void) {
        Printf(w->code, "      (void)__r; JL_GC_POP(); return;\n");
      } else {
        Printv(w->code, ret_marshal, NIL);
        Printf(w->code, "      JL_GC_POP(); return c_result;\n");
      }
      Printf(w->code, "    }\n    JL_GC_POP();\n  }\n");
      /* fall-through: pure -> throw, else call the C++ base impl */
      if (pure_virtual) {
        Printf(w->code, "  throw %s;\n", basecall);
      } else {
        if (is_void)
          Printf(w->code, "  %s::%s(", c_classname, name);
        else
          Printf(w->code, "  return %s::%s(", c_classname, name);
        int comma = 0;
        for (Parm *p = l; p; p = nextSibling(p)) {
          String *pn = Getattr(p, "name");
          if (!pn || Len(pn) == 0)
            continue;
          if (comma)
            Printf(w->code, ", ");
          Printf(w->code, "%s", pn);
          comma = 1;
        }
        Printf(w->code, ");\n");
      }
      Printf(w->code, "}\n\n");
      Delete(basecall);

      Printf(f_directors_h, "    virtual %s;\n", hdr_sig);
      Wrapper_print(w, f_directors);
      if (!director_classes)
        director_classes = NewHash();
      Setattr(director_classes, c_classname, "1");
      /* module-level fallback dispatch method: returns the no-override sentinel
         unless the user adds a more-specific method for their subtype.  One per
         dispatch name (overloads/defaultargs share it). */
      if (!enum_seen)
        enum_seen = NewHash(); /* reuse dedup hash for dispatch names */
      String *dkey = NewStringf("__disp_%s", dispatch);
      if (!Getattr(enum_seen, dkey)) {
        Setattr(enum_seen, dkey, "1");
        Printf(f_jl_body, "%s(self, args...) = _swig_director_no_override\n", dispatch);
        add_export(dispatch);
      }
      Delete(dkey);
    }

    Delete(args_build);
    Delete(ret_marshal);
    Delete(dispatch);
    Delete(impl_sig);
    Delete(hdr_sig);
    Delete(qualname);
    Delete(pclassname);
    DelWrapper(w);
    return SWIG_OK;
  }

  virtual int destructorHandler(Node *) {
    class_has_destructor = true;
    return SWIG_OK;
  } /* emitted in classHandler */
};

static Language *new_swig_julia() {
  return new JULIA();
}
extern "C" Language *swig_julia(void) {
  return new_swig_julia();
}
