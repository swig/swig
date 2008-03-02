/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * octave.cxx
 *
 * Octave language module for SWIG.
 * ----------------------------------------------------------------------------- */

char cvsroot_octave_cxx[] = "$Id$";

#include "swigmod.h"
#include <string>

static const char *usage = (char *) "\
Octave Options (available with -octave)\n\
     (none yet)\n\n";


class OCTAVE:public Language {
private:

  File *f_runtime;
  File *f_header;
  File *f_wrappers;
  File *f_init;
  File *f_initbeforefunc;
  File *f_directors;
  File *f_directors_h;
  String *s_global_tab;
  String *s_members_tab;
  String *class_name;

  int have_constructor;
  int have_destructor;
  String *constructor_name;

public:

  OCTAVE() : f_runtime(0),f_header(0),f_wrappers(0),
	     f_init(0),f_initbeforefunc(0),
	     f_directors(0),f_directors_h(0),
	     s_global_tab(0),
	     s_members_tab(0),class_name(0) {
    allow_overloading();
    director_multiple_inheritance = 1;
    director_language = 1;
  }
  
  virtual void main(int argc, char *argv[]) {
    for (int i = 1; i < argc; i++) {
      if (argv[i]) {
	if (strcmp(argv[i], "-help") == 0) {
	  fputs(usage, stderr);
	}
      }
    }

    SWIG_library_directory("octave");
    Preprocessor_define("SWIGOCTAVE 1", 0);
    SWIG_config_file("octave.swg");
    SWIG_typemap_lang("octave");
    allow_overloading();
  }

  virtual int top(Node *n) {
    {
      Node *mod = Getattr(n, "module");
      if (mod) {
	Node *options = Getattr(mod, "options");
	if (options) {
	  int dirprot = 0;
	  if (Getattr(options, "dirprot")) {
	    dirprot = 1;
	  }
	  if (Getattr(options, "nodirprot")) {
	    dirprot = 0;
	  }
	  if (Getattr(options, "directors")) {
	    allow_directors();
	    if (dirprot)
	      allow_dirprot();
	  }
	}
      }
    }


    String *module = Getattr(n, "name");
    String *outfile = Getattr(n, "outfile");
    f_runtime = NewFile(outfile, "w");
    if (!f_runtime) {
      FileErrorDisplay(outfile);
      SWIG_exit(EXIT_FAILURE);
    }
    f_header = NewString("");
    f_wrappers = NewString("");
    f_init = NewString("");
    f_initbeforefunc = NewString("");
    f_directors_h = NewString("");
    f_directors = NewString("");
    s_global_tab = NewString("");
    Swig_register_filebyname("runtime", f_runtime);
    Swig_register_filebyname("header", f_header);
    Swig_register_filebyname("wrapper", f_wrappers);
    Swig_register_filebyname("init", f_init);
    Swig_register_filebyname("initbeforefunc", f_initbeforefunc);
    Swig_register_filebyname("director", f_directors);
    Swig_register_filebyname("director_h", f_directors_h);
    Swig_banner(f_runtime);
    Printf(f_runtime, "#define SWIG_name_d      \"%s\"\n", module);
    Printf(f_runtime, "#define SWIG_name        %s\n", module);

    if (directorsEnabled()) {
      Swig_banner(f_directors_h);
      if (dirprot_mode()) {
	//	Printf(f_directors_h, "#include <map>\n");
	//	Printf(f_directors_h, "#include <string>\n\n");
      }
    }


    Printf(s_global_tab, "\nstatic const struct swig_octave_member swig_globals[] = {\n");
    Printf(f_init, "void SWIG_init_user(octave_swig_type* module_ns)\n{\n");

    Language::top(n);

    if (directorsEnabled())
      Swig_insert_file("director.swg", f_runtime);

    Printf(f_init, "}\n");
    Printf(s_global_tab, "{0,0,0,0,0}\n};\n");
    Printf(s_global_tab, "static swig_octave_class swig_module_globals = {"
	   "SWIG_name_d,0,0,0,0,swig_globals,0};\n");

    Printv(f_wrappers, s_global_tab, NIL);
    SwigType_emit_type_table(f_runtime, f_wrappers);
    Dump(f_header, f_runtime);
    if (directorsEnabled()) {
      Dump(f_directors_h, f_runtime);
      Dump(f_directors, f_runtime);
    }
    Dump(f_wrappers, f_runtime);
    Dump(f_initbeforefunc, f_runtime);
    Wrapper_pretty_print(f_init, f_runtime);

    Delete(s_global_tab);
    Delete(f_initbeforefunc);
    Delete(f_init);
    Delete(f_wrappers);
    Delete(f_header);
    Delete(f_directors);
    Delete(f_directors_h);
    Close(f_runtime);
    Delete(f_runtime);

    return SWIG_OK;
  }

  virtual int importDirective(Node *n) {
    return Language::importDirective(n);
  }

  virtual int functionWrapper(Node *n) {
    Wrapper *f = NewWrapper();
    Parm *p;
    String *tm;
    int j;

    String *nodeType = Getattr(n, "nodeType");
    //    int constructor = (!Cmp(nodeType, "constructor"));
    int destructor = (!Cmp(nodeType, "destructor"));

    bool overloaded=!!Getattr(n, "sym:overloaded");
    bool last_overload=overloaded&&!Getattr(n, "sym:nextSibling");
    String *iname = Getattr(n, "sym:name");
    String *wname = Swig_name_wrapper(iname);
    String *overname = Copy(wname);
    SwigType *d = Getattr(n, "type");
    ParmList *l = Getattr(n, "parms");

    if (!overloaded&&!addSymbol(iname, n))
      return SWIG_ERROR;

    if (overloaded)
      Append(overname, Getattr(n, "sym:overname"));

    Printv(f->def, "static octave_value_list ", overname, 
	   " (const octave_value_list& args, int nargout) {", NIL);
    if (!overloaded||last_overload)
      Printf(s_global_tab,"{\"%s\",%s,0,0,2},\n",iname,wname);

    emit_args(d, l, f);
    emit_attach_parmmaps(l, f);
    Setattr(n, "wrap:parms", l);

    int num_arguments = emit_num_arguments(l);
    int num_required = emit_num_required(l);
    char source[64];

    Printf(f->code, "if (!SWIG_check_num_args(\"%s\",args.length(),%i,%i)) "
	   "{\n return octave_value_list();\n }\n",
	   iname,num_arguments,num_required);

    // * typecheck, check, memberin, memberout, freearg typemaps..?

    // * varargs?

    for (j=0,p=l;j<num_arguments;++j) {
      while (checkAttribute(p, "tmap:in:numinputs", "0")) {
	p = Getattr(p, "tmap:in:next");
      }

      SwigType *pt = Getattr(p, "type");

      String *tm = Getattr(p, "tmap:in");
      if (tm) {
	if (!tm||checkAttribute(p,"tmap:in:numinputs","0")) {
	  p = nextSibling(p);
	  continue;
	}

	sprintf(source,"args(%d)",j);
	Setattr(p, "emit:input", source);
	
	Replaceall(tm, "$source", Getattr(p,"emit:input"));
	Replaceall(tm, "$input", Getattr(p,"emit:input"));
	Replaceall(tm, "$target", Getattr(p, "lname"));

	if (Getattr(p, "wrap:disown") || (Getattr(p, "tmap:in:disown"))) {
	  Replaceall(tm, "$disown", "SWIG_POINTER_DISOWN");
	} else {
	  Replaceall(tm, "$disown", "0");
	}

	String *getargs=NewString("");
	if (j >= num_required)
	  Printf(getargs,"if (%d<args.length()) {\n%s\n}",j,tm);
	else
	  Printv(getargs,tm,NIL);
	Printv(f->code, getargs, "\n", NIL);
	Delete(getargs);

	p = Getattr(p, "tmap:in:next");
	continue;
      } else {
	Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, 
		     "Unable to use type %s as a function argument.\n", 
		     SwigType_str(pt, 0));
	break;
      }
    }

    // Insert argument output code
    String* outarg=NewString("");
    for (p = l; p;) {
      if ((tm = Getattr(p, "tmap:argout"))) {
	Replaceall(tm, "$source", Getattr(p, "lname"));
	Replaceall(tm, "$target", "_outp");
	Replaceall(tm, "$result", "_outp");
	Replaceall(tm, "$arg", Getattr(p, "emit:input"));
	Replaceall(tm, "$input", Getattr(p, "emit:input"));
	Printv(outarg, tm, "\n", NIL);
	p = Getattr(p, "tmap:argout:next");
      } else {
	p = nextSibling(p);
      }
    }

    int director_method = is_member_director(n) && !is_smart_pointer() && !destructor;
    if (director_method) {
      Wrapper_add_local(f, "upcall", "bool upcall = false");
      Append(f->code, "upcall = !!dynamic_cast<Swig::Director*>(arg1);\n");
    }

    Setattr(n,"wrap:name",overname);

    emit_action(n, f);

    Wrapper_add_local(f, "_out", "octave_value_list _out");
    Wrapper_add_local(f, "_outp", "octave_value_list *_outp=&_out");
    Wrapper_add_local(f, "_outv", "octave_value _outv");

    // Return the function value
    if ((tm = Swig_typemap_lookup_new("out", n, "result", 0))) {
      Replaceall(tm, "$source", "result");
      Replaceall(tm, "$target", "_outv");
      Replaceall(tm, "$result", "_outv");

      if (GetFlag(n, "feature:new"))
	Replaceall(tm, "$owner", "1");
      else
	Replaceall(tm, "$owner", "0");

      Printf(f->code, "%s\n", tm);
      Printf(f->code, "if (_outv.is_defined()) _outp = "
	     "SWIG_Octave_AppendOutput(_outp, _outv);\n");
      Delete(tm);
    } else {
      Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, 
		   "Unable to use return type %s in function %s.\n", SwigType_str(d, 0), iname);
    }

    Printv(f->code,outarg,NIL);

    Printf(f->code, "fail:\n"); // we should free locals etc if this happens
    Printf(f->code, "return _out;\n");
    Printf(f->code, "}\n");

    Replaceall(f->code, "$symname", iname);

    Wrapper_print(f, f_wrappers);
    DelWrapper(f);
    Delete(overname);
    Delete(wname);
    Delete(outarg);

    if (last_overload)
      dispatchFunction(n);

    return SWIG_OK;
  }

  void dispatchFunction(Node *n) {
    Wrapper *f = NewWrapper();

    String *iname = Getattr(n, "sym:name");
    String *wname = Swig_name_wrapper(iname);
    int maxargs;
    String *dispatch = Swig_overload_dispatch
      (n, "return %s(args, nargout);", &maxargs);
    String *tmp = NewString("");

    Printv(f->def, "static octave_value_list ", wname, 
	   " (const octave_value_list& args, int nargout) {", NIL);
    Wrapper_add_local(f, "argc", "int argc = args.length()");
    Printf(tmp,"octave_value_ref argv[%d]={",maxargs);
    for (int j=0;j<maxargs;++j)
      Printf(tmp,"%soctave_value_ref(args,%d)",j?",":" ",j);
    Printf(tmp,"}");
    Wrapper_add_local(f, "argv", tmp);
    Printv(f->code, dispatch, "\n", NIL);
    Printf(f->code, "error(\"No matching function for overload\");\n", iname);
    Printf(f->code, "return octave_value_list();\n");
    Printv(f->code, "}\n", NIL);

    Wrapper_print(f, f_wrappers);
    Delete(tmp);
    DelWrapper(f);
    Delete(dispatch);
    Delete(wname);
  }

  virtual int variableWrapper(Node *n) {
    Language::variableWrapper(n);

    String *iname = Getattr(n, "sym:name");
    String *gname = Swig_name_wrapper(Swig_name_get(iname));

    bool assignable=is_assignable(n) ? true : false;
    SwigType *type = Getattr(n, "type");
    String *tm = Swig_typemap_lookup_new("globalin", n, iname, 0);
    if (!tm && SwigType_isarray(type))
      assignable=false;
    Delete(tm);

    String *sname = assignable ? 
      Swig_name_wrapper(Swig_name_set(iname)) : 
      NewString("octave_set_immutable");

    Printf(s_global_tab, "{\"%s\",0,%s,%s,2},\n", iname, gname, sname);

    Delete(sname);
    Delete(gname);
    return SWIG_OK;
  }

  virtual int constantWrapper(Node *n) {
    String *name = Getattr(n, "name");
    String *iname = Getattr(n, "sym:name");
    SwigType *type = Getattr(n, "type");
    String *rawval = Getattr(n, "rawval");
    String *value = rawval ? rawval : Getattr(n, "value");
    String *tm;

    if (!addSymbol(iname, n))
      return SWIG_ERROR;

    if (SwigType_type(type) == T_MPOINTER) {
      String *wname = Swig_name_wrapper(iname);
      String *str = SwigType_str(type, wname);
      Printf(f_header, "static %s = %s;\n", str, value);
      Delete(str);
      value = wname;
    }
    if ((tm = Swig_typemap_lookup_new("constcode", n, name, 0))) {
      Replaceall(tm, "$source", value);
      Replaceall(tm, "$target", name);
      Replaceall(tm, "$value", value);
      Replaceall(tm, "$nsname", iname);
      Printf(f_init, "%s\n", tm);
    } else {
      Swig_warning(WARN_TYPEMAP_CONST_UNDEF,input_file,line_number,
		   "Unsupported constant value.\n");
      return SWIG_NOWRAP;
    }

    return SWIG_OK;
  }

  virtual int nativeWrapper(Node *n) {
    return Language::nativeWrapper(n);
  }

  virtual int enumDeclaration(Node *n) {
    return Language::enumDeclaration(n);
  }

  virtual int enumvalueDeclaration(Node *n) {
    return Language::enumvalueDeclaration(n);
  }

  virtual int classDeclaration(Node *n) {
    return Language::classDeclaration(n);
  }

  virtual int classHandler(Node *n) {
    have_constructor=0;
    have_destructor=0;
    constructor_name=0;

    class_name = Getattr(n, "sym:name");

    if (!addSymbol(class_name, n))
      return SWIG_ERROR;

    assert(!s_members_tab);
    s_members_tab = NewString("");
    Printv(s_members_tab, "static swig_octave_member swig_", class_name, 
	   "_members[] = {\n", NIL);

    Language::classHandler(n);

    SwigType *t = Copy(Getattr(n, "name"));
    SwigType_add_pointer(t);

    String *wrap_class = NewStringf("&_wrap_class_%s", class_name);
    SwigType_remember_clientdata(t, wrap_class);

    // * this is 1-to-n map : swig_type -> octave_class

    int use_director = Swig_directorclass(n);
    if (use_director) {
      String *disown_shadow=NewString("");
      Printf(disown_shadow,"static octave_value_list _wrap_disown_%s_shadow "
	     "(const octave_value_list& args, int nargout) {\n", class_name);
      Printf(disown_shadow,"  if (args.length()!=1) {\n");
      Printf(disown_shadow,"    error(\"disown takes no arguments\");\n");
      Printf(disown_shadow,"    return octave_value_list();\n");
      Printf(disown_shadow,"  }\n");
      Printf(disown_shadow,"  _wrap_disown_%s (args, nargout);\n", class_name);
      Printf(disown_shadow,"  return args;\n");
      Printf(disown_shadow,"}\n");
      Printv(f_wrappers,disown_shadow,NIL);
      Delete(disown_shadow);
      Printf(s_members_tab, "{\"__disown\",_wrap_disown_%s_shadow,0,0,0},\n",
	     class_name);
    }

    Printf(s_members_tab, "{0,0,0,0}\n};\n");
    Printv(f_wrappers, s_members_tab, NIL);

    String *base_class_names = NewString("");
    String *base_class = NewString("");
    List *baselist = Getattr(n, "bases");
    if (baselist && Len(baselist)) {
      Iterator b;
      int index = 0;
      b = First(baselist);
      while (b.item) {
	String *bname = Getattr(b.item, "name");
	if ((!bname) || GetFlag(b.item, "feature:ignore") || 
	    (!Getattr(b.item, "module"))) {
	  b = Next(b);
	  continue;
	}

	String* bname_mangled = SwigType_manglestr(SwigType_add_pointer(Copy(bname)));
	Printf(base_class_names, "\"%s\",", bname_mangled);
	Printf(base_class, "0,");
	b = Next(b);
	index++;
	Delete(bname_mangled);
      }
    }

    Printv(f_wrappers, "static const char *swig_", class_name, 
	   "_base_names[] = {", base_class_names, "0};\n", NIL);
    Printv(f_wrappers, "static const swig_type_info *swig_", class_name, 
	   "_base[] = {", base_class, "0};\n", NIL);
    Printv(f_wrappers, "static swig_octave_class _wrap_class_", 
	   class_name, " = {\"", class_name,"\", &SWIGTYPE", 
	   SwigType_manglestr(t), ",", NIL);
    Printv(f_wrappers, Swig_directorclass(n)?"1,":"0,", NIL);
    if (have_constructor) {
      String *cname=Swig_name_construct(constructor_name);
      String *wcname=Swig_name_wrapper(cname);
      Printf(f_wrappers,"%s,",wcname);
      Delete(wcname);
      Delete(cname);
    }
    else
      Printv(f_wrappers, "0", ",", NIL);
    if (have_destructor)
      Printv(f_wrappers, "_wrap_delete_", class_name, ",", NIL);
    else
      Printv(f_wrappers, "0", ",", NIL);
    Printf(f_wrappers, "swig_%s_members,swig_%s_base_names,swig_%s_base };\n\n",
	   class_name, class_name, class_name);

    Delete(base_class);
    Delete(base_class_names);
    Delete(wrap_class);
    Delete(t);
    Delete(s_members_tab);
    s_members_tab=0;
    class_name=0;

    return SWIG_OK;
  }

  virtual int memberfunctionHandler(Node *n) {
    Language::memberfunctionHandler(n);

    assert(s_members_tab);
    assert(class_name);
    String *name = Getattr(n, "name");
    String *iname = GetChar(n, "sym:name");
    String *realname = iname ? iname : name;
    String *rname = Swig_name_wrapper(Swig_name_member(class_name, realname));

    if (!Getattr(n,"sym:nextSibling"))
      Printf(s_members_tab,"{\"%s\",%s,0,0,0},\n",realname,rname);

    Delete(rname);
    return SWIG_OK;
  }

  virtual int membervariableHandler(Node *n) {
    Language::membervariableHandler(n);

    assert(s_members_tab);
    assert(class_name);
    String *symname = Getattr(n, "sym:name");
    String *gname=Swig_name_wrapper(Swig_name_get(Swig_name_member(class_name,symname)));
    String *sname=GetFlag(n,"feature:immutable")?
      NewString("octave_set_immutable"):
      Swig_name_wrapper(Swig_name_set(Swig_name_member(class_name,symname)));
    assert(s_members_tab);

    Printf(s_members_tab,"{\"%s\",0,%s,%s,0},\n",symname,gname,sname);

    Delete(gname);
    Delete(sname);
    return SWIG_OK;
  }

  virtual int constructorHandler(Node *n) {
    have_constructor=1;
    if (!constructor_name)
      constructor_name=NewString(Getattr(n,"sym:name"));

    int use_director = Swig_directorclass(n);
    if (use_director) {
      Parm *parms = Getattr(n, "parms");
      Parm *self;
      String *name = NewString("self");
      String *type = NewString("void");
      SwigType_add_pointer(type);
      self = NewParm(type, name);
      Delete(type);
      Delete(name);
      Setattr(self, "lname", "self_obj");
      if (parms)
	set_nextSibling(self, parms);
      Setattr(n, "parms", self);
      Setattr(n, "wrap:self", "1");
      Setattr(n, "hidden", "1");
      Delete(self);
    }

    return Language::constructorHandler(n);;
  }

  virtual int destructorHandler(Node *n) {
    have_destructor=1;
    return Language::destructorHandler(n);;
  }

  virtual int staticmemberfunctionHandler(Node *n) {
    Language::staticmemberfunctionHandler(n);

    assert(s_members_tab);
    assert(class_name);
    String *name = Getattr(n, "name");
    String *iname = GetChar(n, "sym:name");
    String *realname = iname ? iname : name;
    String *rname = Swig_name_wrapper(Swig_name_member(class_name, realname));

    if (!Getattr(n,"sym:nextSibling"))
      Printf(s_members_tab,"{\"%s\",%s,0,0,1},\n",realname,rname);

    Delete(rname);
    return SWIG_OK;
  }

  virtual int memberconstantHandler(Node *n) {
    return Language::memberconstantHandler(n);
  }

  virtual int staticmembervariableHandler(Node *n) {
    Language::staticmembervariableHandler(n);

    if (!GetFlag(n, "wrappedasconstant")) {
      assert(s_members_tab);
      assert(class_name);
      String *symname = Getattr(n, "sym:name");
      String *gname=Swig_name_wrapper(Swig_name_get(Swig_name_member(class_name,symname)));
      String *sname=GetFlag(n,"feature:immutable")?
	NewString("octave_set_immutable"):
	Swig_name_wrapper(Swig_name_set(Swig_name_member(class_name,symname)));
      assert(s_members_tab);

      Printf(s_members_tab,"{\"%s\",0,%s,%s,1},\n",symname,gname,sname);

      Delete(gname);
      Delete(sname);
    }
    return SWIG_OK;
  }

  int classDirectorInit(Node *n) {
    String *declaration = Swig_director_declaration(n);
    Printf(f_directors_h, "\n");
    Printf(f_directors_h, "%s\n", declaration);
    Printf(f_directors_h, "public:\n");
    Delete(declaration);
    return Language::classDirectorInit(n);
  }

  int classDirectorEnd(Node *n) {
    Printf(f_directors_h, "};\n\n");
    return Language::classDirectorEnd(n);
  }

  int classDirectorConstructor(Node *n) {
    Node *parent = Getattr(n, "parentNode");
    String *sub = NewString("");
    String *decl = Getattr(n, "decl");
    String *supername = Swig_class_name(parent);
    String *classname = NewString("");
    Printf(classname, "SwigDirector_%s", supername);

    // insert self parameter
    Parm *p;
    ParmList *superparms = Getattr(n, "parms");
    ParmList *parms = CopyParmList(superparms);
    String *type = NewString("void");
    SwigType_add_pointer(type);
    p = NewParm(type, NewString("self"));
    set_nextSibling(p, parms);
    parms = p;

    if (!Getattr(n, "defaultargs")) {
      // constructor
      {
	Wrapper *w = NewWrapper();
	String *call;
	String *basetype = Getattr(parent, "classtype");
	String *target = Swig_method_decl(0, decl, classname, parms, 0, 0);
	call = Swig_csuperclass_call(0, basetype, superparms);
	Printf(w->def, "%s::%s: %s,"
	       "\nSwig::Director(static_cast<%s*>(this)) { \n", 
	       classname, target, call, basetype);
	Append(w->def, "}\n");
	Delete(target);
	Wrapper_print(w, f_directors);
	Delete(call);
	DelWrapper(w);
      }

      // constructor header
      {
	String *target = Swig_method_decl(0, decl, classname, parms, 0, 1);
	Printf(f_directors_h, "    %s;\n", target);
	Delete(target);
      }
    }

    Delete(sub);
    Delete(classname);
    Delete(supername);
    Delete(parms);
    return Language::classDirectorConstructor(n);
  }

  int classDirectorDefaultConstructor(Node *n) {
    String *classname = Swig_class_name(n);
    {
      Wrapper *w = NewWrapper();
      Printf(w->def, "SwigDirector_%s::SwigDirector_%s(void* self) :"
	     "\nSwig::Director((octave_swig_type*)self,static_cast<%s*>(this)) { \n", 
	     classname, classname, classname);
      Append(w->def, "}\n");
      Wrapper_print(w, f_directors);
      DelWrapper(w);
    }
    Printf(f_directors_h, "    SwigDirector_%s(octave_swig_type* self);\n", classname);
    Delete(classname);
    return Language::classDirectorDefaultConstructor(n);
  }

  int classDirectorMethod(Node *n, Node *parent, String *super) {
    int is_void = 0;
    int is_pointer = 0;
    String *decl;
    String *type;
    String *name;
    String *classname;
    String *c_classname = Getattr(parent, "name");
    String *declaration;
    ParmList *l;
    Wrapper *w;
    String *tm;
    String *wrap_args = NewString("");
    String *return_type;
    String *value = Getattr(n, "value");
    String *storage = Getattr(n, "storage");
    bool pure_virtual = false;
    int status = SWIG_OK;
    int idx;
    bool ignored_method = GetFlag(n, "feature:ignore") ? true : false;

    if (Cmp(storage, "virtual") == 0) {
      if (Cmp(value, "0") == 0) {
	pure_virtual = true;
      }
    }

    classname = Getattr(parent, "sym:name");
    type = Getattr(n, "type");
    name = Getattr(n, "name");

    w = NewWrapper();
    declaration = NewString("");

    // determine if the method returns a pointer
    decl = Getattr(n, "decl");
    is_pointer = SwigType_ispointer_return(decl);
    is_void = (!Cmp(type, "void") && !is_pointer);

    // form complete return type
    return_type = Copy(type);
    {
      SwigType *t = Copy(decl);
      SwigType *f = 0;
      f = SwigType_pop_function(t);
      SwigType_push(return_type, t);
      Delete(f);
      Delete(t);
    }

    // virtual method definition
    l = Getattr(n, "parms");
    String *target;
    String *pclassname = NewStringf("SwigDirector_%s", classname);
    String *qualified_name = NewStringf("%s::%s", pclassname, name);
    SwigType *rtype = Getattr(n, "conversion_operator") ? 0 : type;
    target = Swig_method_decl(rtype, decl, qualified_name, l, 0, 0);
    Printf(w->def, "%s", target);
    Delete(qualified_name);
    Delete(target);

    // header declaration
    target = Swig_method_decl(rtype, decl, name, l, 0, 1);
    Printf(declaration, "    virtual %s", target);
    Delete(target);

    // Get any exception classes in the throws typemap
    ParmList *throw_parm_list = 0;

    if ((throw_parm_list = Getattr(n, "throws")) || Getattr(n, "throw")) {
      Parm *p;
      int gencomma = 0;

      Append(w->def, " throw(");
      Append(declaration, " throw(");

      if (throw_parm_list)
	Swig_typemap_attach_parms("throws", throw_parm_list, 0);
      for (p = throw_parm_list; p; p = nextSibling(p)) {
	if ((tm = Getattr(p, "tmap:throws"))) {
	  if (gencomma++) {
	    Append(w->def, ", ");
	    Append(declaration, ", ");
	  }
	  String *str = SwigType_str(Getattr(p, "type"), 0);
	  Append(w->def, str);
	  Append(declaration, str);
	  Delete(str);
	}
      }

      Append(w->def, ")");
      Append(declaration, ")");
    }

    Append(w->def, " {");
    Append(declaration, ";\n");

    // declare method return value 
    // if the return value is a reference or const reference, a specialized typemap must
    // handle it, including declaration of c_result ($result).
    if (!is_void) {
      if (!(ignored_method && !pure_virtual)) {
	String *cres = SwigType_lstr(return_type, "c_result");
	Printf(w->code, "%s;\n", cres);
	Delete(cres);
      }
    }

    if (ignored_method) {
      if (!pure_virtual) {
	if (!is_void)
	  Printf(w->code, "return ");
	String *super_call = Swig_method_call(super, l);
	Printf(w->code, "%s;\n", super_call);
	Delete(super_call);
      } else {
	Printf(w->code, "Swig::DirectorPureVirtualException::raise(\"Attempted to invoke pure virtual method %s::%s\");\n", SwigType_namestr(c_classname),
	       SwigType_namestr(name));
      }
    } else {
      // attach typemaps to arguments (C/C++ -> Python)
      String *parse_args = NewString("");

      Swig_typemap_attach_parms("in", l, 0);
      Swig_typemap_attach_parms("directorin", l, 0);
      Swig_typemap_attach_parms("directorargout", l, w);

      Parm *p;

      int outputs = 0;
      if (!is_void)
	outputs++;

      // build argument list and type conversion string
      idx = 0;
      p = l;
      int use_parse = 0;
      while (p != NULL) {
	if (checkAttribute(p, "tmap:in:numinputs", "0")) {
	  p = Getattr(p, "tmap:in:next");
	  continue;
	}

	if (Getattr(p, "tmap:directorargout") != 0)
	  outputs++;

	String *pname = Getattr(p, "name");
	String *ptype = Getattr(p, "type");
	Wrapper_add_local(w, "tmpv", "octave_value tmpv");

	if ((tm = Getattr(p, "tmap:directorin")) != 0) {
	  String *parse = Getattr(p, "tmap:directorin:parse");
	  if (!parse) {
	    Replaceall(tm, "$input", "tmpv");
	    Replaceall(tm, "$owner", "0");
	    Printv(wrap_args, tm, "\n", NIL);
	    Printf(wrap_args, "args.append(tmpv);\n");
	    Putc('O', parse_args);
	  } else {
	    use_parse = 1;
	    Append(parse_args, parse);
	    Replaceall(tm, "$input", pname);
	    Replaceall(tm, "$owner", "0");
	    if (Len(tm) == 0)
	      Append(tm, pname);
	  }
	  p = Getattr(p, "tmap:directorin:next");
	  continue;
	} else if (Cmp(ptype, "void")) {
	  Swig_warning(WARN_TYPEMAP_DIRECTORIN_UNDEF, input_file, line_number,
		       "Unable to use type %s as a function argument in director method %s::%s (skipping method).\n", SwigType_str(ptype, 0),
		       SwigType_namestr(c_classname), SwigType_namestr(name));
	  status = SWIG_NOWRAP;
	  break;
	}
	p = nextSibling(p);
      }

      String *method_name = Getattr(n, "sym:name");

      Printv(w->code, wrap_args, NIL);

      // emit method invocation
      Wrapper_add_local(w, "args", "octave_value_list args");
      Wrapper_add_local(w, "out", "octave_value_list out");
      Wrapper_add_local(w, "idx", "std::list<octave_value_list> idx");
      Printf(w->code, "idx.push_back(octave_value_list(\"%s\"));\n",method_name);
      Printf(w->code, "idx.push_back(args);\n");
      Printf(w->code, "out=swig_get_self()->subsref(\".(\",idx,%d);\n",outputs);

      String *cleanup = NewString("");
      String *outarg = NewString("");
      idx = 0;

      // marshal return value
      if (!is_void) {
	Printf(w->code, "if (out.length()<%d) {\n",outputs);
	Printf(w->code, "Swig::DirectorTypeMismatchException::raise(\"Octave "
	       "method %s.%s failed to return the required number "
	       "of arguments.\");\n", classname, method_name);
	Printf(w->code, "}\n");

	Setattr(n, "type", return_type);
	tm = Swig_typemap_lookup_new("directorout", n, "result", w);
	Setattr(n, "type", type);
	if (tm == 0) {
	  String *name = NewString("result");
	  tm = Swig_typemap_search("directorout", return_type, name, NULL);
	  Delete(name);
	}
	if (tm != 0) {
	  char temp[24];
	  sprintf(temp, "out(%d)", idx);
	  Replaceall(tm, "$input", temp);
	  //	Replaceall(tm, "$argnum", temp);
	  Replaceall(tm, "$disown", 
		     Getattr(n, "wrap:disown") ? "SWIG_POINTER_DISOWN" : "0");
	  Replaceall(tm, "$result", "c_result");
	  Printv(w->code, tm, "\n", NIL);
	  Delete(tm);
	} else {
	  Swig_warning(WARN_TYPEMAP_DIRECTOROUT_UNDEF, input_file, line_number,
		       "Unable to use return type %s in director method %s::%s (skipping method).\n", 
		       SwigType_str(return_type, 0), SwigType_namestr(c_classname),
		       SwigType_namestr(name));
	  status = SWIG_ERROR;
	}
      }
      idx++;

      // marshal outputs
      for (p = l; p;) {
	if ((tm = Getattr(p, "tmap:directorargout")) != 0) {
	  char temp[24];
	  sprintf(temp, "out(%d)", idx);
	  Replaceall(tm, "$input", temp);
	  Replaceall(tm, "$result", Getattr(p, "name"));
	  Printv(w->code, tm, "\n", NIL);
	  p = Getattr(p, "tmap:directorargout:next");
	} else {
	  p = nextSibling(p);
	}
      }

      Delete(parse_args);
      Delete(cleanup);
      Delete(outarg);
    }

    if (!is_void) {
      if (!(ignored_method && !pure_virtual)) {
	String *rettype = SwigType_str(return_type, 0);
	if (!SwigType_isreference(return_type)) {
	  Printf(w->code, "return (%s) c_result;\n", rettype);
	} else {
	  Printf(w->code, "return (%s) *c_result;\n", rettype);
	}
	Delete(rettype);
      }
    }

    Append(w->code, "}\n");

    // We expose protected methods via an extra public inline method which makes a straight call to the wrapped class' method
    String *inline_extra_method = NewString("");
    if (dirprot_mode() && !is_public(n) && !pure_virtual) {
      Printv(inline_extra_method, declaration, NIL);
      String *extra_method_name = NewStringf("%sSwigPublic", name);
      Replaceall(inline_extra_method, name, extra_method_name);
      Replaceall(inline_extra_method, ";\n", " {\n      ");
      if (!is_void)
	Printf(inline_extra_method, "return ");
      String *methodcall = Swig_method_call(super, l);
      Printv(inline_extra_method, methodcall, ";\n    }\n", NIL);
      Delete(methodcall);
      Delete(extra_method_name);
    }

    // emit the director method
    if (status == SWIG_OK) {
      if (!Getattr(n, "defaultargs")) {
	Wrapper_print(w, f_directors);
	Printv(f_directors_h, declaration, NIL);
	Printv(f_directors_h, inline_extra_method, NIL);
      }
    }

    // clean up
    Delete(wrap_args);
    Delete(return_type);
    Delete(pclassname);
    DelWrapper(w);
    return status;
  }

  String *runtimeCode() {
    String *s = NewString("");
    String *srun = Swig_include_sys("octrun.swg");
    if (!srun) {
      Printf(stderr, "*** Unable to open 'octrun.swg'\n");
    } else {
      Append(s, srun);
      Delete(srun);
    }
    return s;
  }

  String *defaultExternalRuntimeFilename() {
    return NewString("swigoctaverun.h");
  }
};

extern "C" Language *swig_octave(void) {
  return new OCTAVE();
}

