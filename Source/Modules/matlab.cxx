/* -----------------------------------------------------------------------------
 * This file is part of SWIG, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at http://www.swig.org/legal.html.
 *
 * matlab.cxx
 *
 * Matlab language module for SWIG.
 * ----------------------------------------------------------------------------- */

#include "swigmod.h"
#include "cparse.h"

//#define MATLABPRINTFUNCTIONENTRY
static int CMD_MAXLENGTH = 256;

static const char *usage = (char *) "\
Matlab Options (available with -matlab)\n\
     -globals <name> - Set <name> used to access C global variables [default: 'cvar']\n\
                       Use '.' to load C global variables into module namespace\n\
     -opprefix <str> - Prefix <str> for global operator functions [default: 'op_']\n\
     -pkgname <str> - Prefix <str> for package name ' [default: '<module_name>']\n\
\n";

class MATLAB : public Language {
public:
  MATLAB();
  virtual void main(int argc, char *argv[]);
  virtual int top(Node *n);
  virtual int functionWrapper(Node *n);
  virtual int variableWrapper(Node *n);
  virtual int constantWrapper(Node *n);
  virtual int nativeWrapper(Node *n);
  virtual int enumDeclaration(Node *n);
  virtual int enumvalueDeclaration(Node *n);
  virtual int classHandler(Node *n);
  virtual int memberfunctionHandler(Node *n);
  virtual int membervariableHandler(Node *n);
  virtual int constructorHandler(Node *n);
  virtual int destructorHandler(Node *n);
  virtual int staticmemberfunctionHandler(Node *n);
  virtual int memberconstantHandler(Node *n);
  virtual int staticmembervariableHandler(Node *n);
protected:
  File* f_wrap_m;
  File *f_gateway;
  File *f_begin;
  File *f_runtime;
  File *f_header;
  File *f_doc;
  File *f_wrappers;
  File *f_init;
  File *f_initbeforefunc;
  File *f_directors;
  File *f_directors_h;
  String* class_name;
  String* mex_fcn;
  String* base_init;
  String* get_field;
  String* set_field;
  String* static_methods;

  Hash *docs;
  bool have_constructor;
  bool have_destructor;
  //String *constructor_name;

  // Options
  String *global_name;
  String *op_prefix;
  String *pkg_name;
  String *pkg_name_fullpath;

  // Helper functions
  static void nameUnnamedParams(ParmList *parms, bool all);
  String *getOverloadedName(Node *n);
  void initGateway();
  void toGateway(String *fullname, String *wname);
  void finalizeGateway();
  void createSwigRef();
  void process_autodoc(Node *n);
  void make_autodocParmList(Node *n, String *decl_str, String *args_str);
  void addMissingParameterNames(ParmList *plist, int arg_offset);
  String* convertValue(String *v, SwigType *t);
  const char* get_implicitconv_flag(Node *n);
  void dispatchFunction(Node *n);
  String* texinfo_name(Node* n, const char* defval = "0");
  bool is_empty_doc_node(Node* n);
  void emit_doc_texinfo();
  String* texinfo_escape(String *_s);
  void wrapConstructor(String *symname, String *fullname);
};

extern "C" Language *swig_matlab(void) {
  return new MATLAB();
}

// Only implementations from here on

MATLAB::MATLAB() : 
  f_wrap_m(0),
  f_gateway(0),
  f_begin(0),
  f_runtime(0),
  f_header(0),
  f_doc(0),
  f_wrappers(0),
  f_init(0),
  f_initbeforefunc(0),
  f_directors(0),
  f_directors_h(0),
  class_name(0),
  mex_fcn(0),
  base_init(0),
  get_field(0),
  set_field(0),
  static_methods(0),
  docs(0),
  have_constructor(false),
  have_destructor(false),
  global_name(0),
  op_prefix(0),
  pkg_name(0),
  pkg_name_fullpath(0)
{
#ifdef MATLABPRINTFUNCTIONENTRY
  Printf(stderr,"Entering MATLAB()\n");
#endif
  /* Add code to manage protected constructors and directors */
  director_prot_ctor_code = NewString("");
  Printv(director_prot_ctor_code,
         "if ( $comparison ) { /* subclassed */\n",
         "  $director_new \n",
         "} else {\n", "  error(\"accessing abstract class or protected constructor\"); \n", "  SWIG_fail;\n", "}\n", NIL);

  enable_cplus_runtime_mode();
  allow_overloading();
  director_multiple_inheritance = 1;
  director_language = 1;
  docs = NewHash();
}

void MATLAB::main(int argc, char *argv[]){
#ifdef MATLABPRINTFUNCTIONENTRY
  Printf(stderr,"Entering main\n");
#endif
  for (int i = 1; i < argc; i++) {
    if (argv[i]) {
      if (strcmp(argv[i], "-help") == 0) {
        fputs(usage, stdout);
      } else if (strcmp(argv[i], "-global") == 0 ||
                 strcmp(argv[i], "-noglobal") == 0) {
        Printv(stderr,
               "*** -global/-noglobal are no longer supported\n"
               "*** global load behaviour is now determined at module load\n"
               "*** see the Perl section in the manual for details.\n", NIL);
        SWIG_exit(EXIT_FAILURE);
      } else if (strcmp(argv[i], "-globals") == 0) {
        if (argv[i + 1]) {
          global_name = NewString(argv[i + 1]);
          Swig_mark_arg(i);
          Swig_mark_arg(i + 1);
          i++;
        } else {
          Swig_arg_error();
        }
      } else if (strcmp(argv[i], "-opprefix") == 0) {
        if (argv[i + 1]) {
          op_prefix = NewString(argv[i + 1]);
          Swig_mark_arg(i);
          Swig_mark_arg(i + 1);
          i++;
        } else {
          Swig_arg_error();
        }
      } else if (strcmp(argv[i], "-pkgname") == 0) {
        if (argv[i + 1]) {
          pkg_name = NewString(argv[i + 1]);
          Swig_mark_arg(i);
          Swig_mark_arg(i + 1);
          i++;
        } else {
          Swig_arg_error();
        }
      }
    }
  }
    
  if (!global_name)
    global_name = NewString("cvar");
  if (!op_prefix)
    op_prefix = NewString("op_");
    
  SWIG_library_directory("matlab");
  Preprocessor_define("SWIGMATLAB 1", 0);
  SWIG_config_file("matlab.swg");
  SWIG_typemap_lang("matlab");
  allow_overloading();

  // Matlab API is C++, so output must be C++ compatibile even when wrapping C code
  //    if (!cparse_cplusplus)
  //      Swig_cparse_cplusplusout(1);
}

int MATLAB::top(Node *n) {
#ifdef MATLABPRINTFUNCTIONENTRY
  Printf(stderr,"Entering top\n");
#endif

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

  // Create swigRef abstract base class
  createSwigRef();

  String *module = Getattr(n, "name");
  String *outfile = Getattr(n, "outfile");

  // Add default package prefix
  if (!pkg_name){
    pkg_name = Copy(module);
  }

  // Create subdirectory
  const String* basedirectory = SWIG_output_directory();
  pkg_name_fullpath = NewString("+");
  Append(pkg_name_fullpath,pkg_name);
  (void)Replace(pkg_name_fullpath,".","+/",DOH_REPLACE_ANY);
  Swig_new_subdirectory((String*)basedirectory,pkg_name_fullpath);

  // Create output (mex) file
  f_begin = NewFile(outfile, "w", SWIG_output_files());
  if (!f_begin) {
    FileErrorDisplay(outfile);
    SWIG_exit(EXIT_FAILURE);
  }

  /* To get the name the mex function (when calling from Matlab), we remove the suffix */
  mex_fcn=NewString(outfile);
  char *suffix = Strchr(mex_fcn,'.');
  char *suffix_end = Char(mex_fcn)+Len(mex_fcn);
  while(suffix!=suffix_end) *suffix++ = ' '; // Replace suffix with whitespaces
  Chop(mex_fcn); // Remove trailing whitespaces

  f_gateway = NewString("");
  f_runtime = NewString("");
  f_header = NewString("");
  f_doc = NewString("");
  f_wrappers = NewString("");
  f_init = NewString("");
  f_initbeforefunc = NewString("");
  f_directors_h = NewString("");
  f_directors = NewString("");
  Swig_register_filebyname("gateway", f_gateway);
  Swig_register_filebyname("begin", f_begin);
  Swig_register_filebyname("runtime", f_runtime);
  Swig_register_filebyname("header", f_header);
  Swig_register_filebyname("doc", f_doc);
  Swig_register_filebyname("wrapper", f_wrappers);
  Swig_register_filebyname("init", f_init);
  Swig_register_filebyname("initbeforefunc", f_initbeforefunc);
  Swig_register_filebyname("director", f_directors);
  Swig_register_filebyname("director_h", f_directors_h);

  Swig_banner(f_begin);

  Printf(f_runtime, "\n");
  Printf(f_runtime, "#define SWIGMATLAB\n");
  Printf(f_runtime, "#define SWIG_name_d      \"%s\"\n", module);
  Printf(f_runtime, "#define SWIG_name        %s\n", module);

  Printf(f_runtime, "\n");
  Printf(f_runtime, "#define SWIG_global_name      \"%s\"\n", global_name);
  Printf(f_runtime, "#define SWIG_op_prefix        \"%s\"\n", op_prefix);
  Printf(f_runtime, "#define SWIG_pkg_name        \"%s\"\n", pkg_name);

  if (directorsEnabled()) {
    Printf(f_runtime, "#define SWIG_DIRECTORS\n");
    Swig_banner(f_directors_h);
    if (dirprot_mode()) {
      //      Printf(f_directors_h, "#include <map>\n");
      //      Printf(f_directors_h, "#include <string>\n\n");
    }
  }

  Printf(f_runtime, "\n");

  if (!CPlusPlus)
    Printf(f_header,"extern \"C\" {\n");

  // Mex-file gateway
  initGateway();

  /* Emit code for children */
  Language::top(n);
    
  // Finalize Mex-file gate way
  finalizeGateway();

  if (!CPlusPlus)
    Printf(f_header,"}\n");

  if (Len(docs))
    emit_doc_texinfo();

  //  if (directorsEnabled())
  //    Swig_insert_file("director.swg", f_runtime);


  SwigType_emit_type_table(f_runtime, f_wrappers);
  Dump(f_runtime, f_begin);
  Dump(f_header, f_begin);
  Dump(f_doc, f_begin);
  if (directorsEnabled()) {
    Dump(f_directors_h, f_begin);
    Dump(f_directors, f_begin);
  }
  Dump(f_wrappers, f_begin);
  Dump(f_initbeforefunc, f_begin);
  Wrapper_pretty_print(f_init, f_begin);
  Dump(f_gateway, f_begin);

  Delete(f_initbeforefunc);
  Delete(f_init);
  Delete(f_wrappers);
  Delete(f_doc);
  Delete(f_header);
  Delete(f_directors);
  Delete(f_directors_h);
  Delete(f_runtime);
  Delete(f_begin);
  Delete(f_gateway);
  if(pkg_name) Delete(pkg_name);
  if(pkg_name_fullpath) Delete(pkg_name_fullpath);
  if(global_name) Delete(global_name);
  if(op_prefix) Delete(op_prefix);

  return SWIG_OK;
}

void MATLAB::process_autodoc(Node *n) {
  String *iname = Getattr(n, "sym:name");
  String *name = Getattr(n, "name");
  String *wname = Swig_name_wrapper(iname);
  String *str = Getattr(n, "feature:docstring");
  bool autodoc_enabled = !Cmp(Getattr(n, "feature:autodoc"), "1");
  Node* d = Getattr(docs, wname);
  if (!d) {
    d = NewHash();
    Setattr(d, "synopsis", NewString(""));
    Setattr(d, "decl_info", NewString(""));
    Setattr(d, "cdecl_info", NewString(""));
    Setattr(d, "args_info", NewString(""));
    Setattr(docs, wname, d);
  }

  String *synopsis = Getattr(d, "synopsis");
  String *decl_info = Getattr(d, "decl_info");
  //    String *cdecl_info = Getattr(d, "cdecl_info");
  String *args_info = Getattr(d, "args_info");

  // * couldn't we just emit the docs here?

  if (autodoc_enabled) {
    String *decl_str = NewString("");
    String *args_str = NewString("");
    make_autodocParmList(n, decl_str, args_str);
    Append(decl_info, "@deftypefn {Loadable Function} ");

    SwigType *type = Getattr(n, "type");
    if (type && Strcmp(type, "void")) {
      Node *nn = classLookup(Getattr(n, "type"));
      String *type_str = nn ? Copy(Getattr(nn, "sym:name")) : SwigType_str(type, 0);
      Append(decl_info, "@var{retval} = ");
      Printf(args_str, "%s@var{retval} is of type %s. ", args_str, type_str);
      Delete(type_str);
    }

    Append(decl_info, name);
    Append(decl_info, " (");
    Append(decl_info, decl_str);
    Append(decl_info, ")\n");
    Append(args_info, args_str);
    Delete(decl_str);
    Delete(args_str);
  }

  if (str && Len(str) > 0) {
    // strip off {} if necessary
    char *t = Char(str);
    if (*t == '{') {
      Delitem(str, 0);
      Delitem(str, DOH_END);
    }

    // emit into synopsis section
    Append(synopsis, str);
  }
}

// virtual int importDirective(Node *n) {
//   String *modname = Getattr(n, "module");
//   if (modname)
//     Printf(f_init, "if (!SWIG_Matlab_LoadModule(\"%s\")) return false;\n", modname);
//   return Language::importDirective(n);
// }

// const char *get_implicitconv_flag(Node *n) {
//   int conv = 0;
//   if (n && GetFlag(n, "feature:implicitconv")) {
//     conv = 1;
//   }
//   return conv ? "SWIG_POINTER_IMPLICIT_CONV" : "0";
// }

void MATLAB::addMissingParameterNames(ParmList *plist, int arg_offset) {
  Parm *p = plist;
  int i = arg_offset;
  while (p) {
    if (!Getattr(p, "lname")) {
      String *pname = Swig_cparm_name(p, i);
      Delete(pname);
    }
    i++;
    p = nextSibling(p);
  }
}

void MATLAB::make_autodocParmList(Node *n, String *decl_str, String *args_str) {
  String *pdocs = 0;
  ParmList *plist = CopyParmList(Getattr(n, "parms"));
  Parm *p;
  Parm *pnext;
  int start_arg_num = is_wrapping_class() ? 1 : 0;

  addMissingParameterNames(plist, start_arg_num); // for $1_name substitutions done in Swig_typemap_attach_parms

  Swig_typemap_attach_parms("in", plist, 0);
  Swig_typemap_attach_parms("doc", plist, 0);

  for (p = plist; p; p = pnext) {

    String *tm = Getattr(p, "tmap:in");
    if (tm) {
      pnext = Getattr(p, "tmap:in:next");
      if (checkAttribute(p, "tmap:in:numinputs", "0")) {
        continue;
      }
    } else {
      pnext = nextSibling(p);
    }

    String *name = 0;
    String *type = 0;
    String *value = 0;
    String *pdoc = Getattr(p, "tmap:doc");
    if (pdoc) {
      name = Getattr(p, "tmap:doc:name");
      type = Getattr(p, "tmap:doc:type");
      value = Getattr(p, "tmap:doc:value");
    }

    // Note: the generated name should be consistent with that in kwnames[]
    name = name ? name : Getattr(p, "name");
    name = name ? name : Getattr(p, "lname");
    name = Swig_name_make(p, 0, name, 0, 0); // rename parameter if a keyword

    type = type ? type : Getattr(p, "type");
    value = value ? value : Getattr(p, "value");

    if (SwigType_isvarargs(type))
      break;

    String *tex_name = NewString("");
    if (name)
      Printf(tex_name, "@var{%s}", name);
    else
      Printf(tex_name, "@var{?}");

    if (Len(decl_str))
      Append(decl_str, ", ");
    Append(decl_str, tex_name);

    if (value) {
      String *new_value = convertValue(value, Getattr(p, "type"));
      if (new_value) {
        value = new_value;
      } else {
        Node *lookup = Swig_symbol_clookup(value, 0);
        if (lookup)
          value = Getattr(lookup, "sym:name");
      }
      Printf(decl_str, " = %s", value);
    }

    Node *nn = classLookup(Getattr(p, "type"));
    String *type_str = nn ? Copy(Getattr(nn, "sym:name")) : SwigType_str(type, 0);
    Printf(args_str, "%s is of type %s. ", tex_name, type_str);

    Delete(type_str);
    Delete(tex_name);
    Delete(name);
  }
  if (pdocs)
    Setattr(n, "feature:pdocs", pdocs);
  Delete(plist);
}

String* MATLAB::convertValue(String *v, SwigType *t) {
  if (v && Len(v) > 0) {
    char fc = (Char(v))[0];
    if (('0' <= fc && fc <= '9') || '\'' == fc || '"' == fc) {
      /* number or string (or maybe NULL pointer) */
      if (SwigType_ispointer(t) && Strcmp(v, "0") == 0)
        return NewString("None");
      else
        return v;
    }
    if (Strcmp(v, "NULL") == 0 || Strcmp(v, "nullptr") == 0)
      return SwigType_ispointer(t) ? NewString("nil") : NewString("0");
    if (Strcmp(v, "true") == 0 || Strcmp(v, "TRUE") == 0)
      return NewString("true");
    if (Strcmp(v, "false") == 0 || Strcmp(v, "FALSE") == 0)
      return NewString("false");
  }
  return 0;
}

int MATLAB::functionWrapper(Node *n){
#ifdef MATLABPRINTFUNCTIONENTRY
  Printf(stderr,"Entering functionWrapper\n");
#endif

  Parm *p;
  String *tm;
  int j;

  String *nodeType = Getattr(n, "nodeType");
  int constructor = (!Cmp(nodeType, "constructor"));
  int destructor = (!Cmp(nodeType, "destructor"));
  String *storage = Getattr(n, "storage");

  bool overloaded = !!Getattr(n, "sym:overloaded");
  bool last_overload = overloaded && !Getattr(n, "sym:nextSibling");
  String *iname = Getattr(n, "sym:name");
  String *wname = Swig_name_wrapper(iname);
  String *overname = Copy(wname);
  SwigType *d = Getattr(n, "type");
  ParmList *l = Getattr(n, "parms");

  if (!overloaded && !addSymbol(iname, n))
    return SWIG_ERROR;

  if (overloaded)
    Append(overname, Getattr(n, "sym:overname"));

  if (!overloaded || last_overload)
    process_autodoc(n);

  Wrapper *f = NewWrapper();
  Printf(f->def, "void %s (int resc, mxArray *resv[], int argc, mxArray *argv[]) {", overname);

  emit_parameter_variables(l, f);
  emit_attach_parmmaps(l, f);
  Setattr(n, "wrap:parms", l);

  int num_arguments = emit_num_arguments(l);
  int num_required = emit_num_required(l);
  int varargs = emit_isvarargs(l);
  char source[64];

  Printf(f->code, "if (!SWIG_check_num_args(\"%s\",argc,%i,%i,%i)) " 
         "{\n SWIG_fail;\n }\n", iname, num_arguments, num_required, varargs);

  if (constructor && num_arguments == 1 && num_required == 1) {
    if (Cmp(storage, "explicit") == 0) {
      Node *parent = Swig_methodclass(n);
      if (GetFlag(parent, "feature:implicitconv")) {
        String *desc = NewStringf("SWIGTYPE%s", SwigType_manglestr(Getattr(n, "type")));
        Printf(f->code, "if (SWIG_CheckImplicit(%s)) SWIG_fail;\n", desc);
        Delete(desc);
      }
    }
  }

  for (j = 0, p = l; j < num_arguments; ++j) {
    while (checkAttribute(p, "tmap:in:numinputs", "0")) {
      p = Getattr(p, "tmap:in:next");
    }

    SwigType *pt = Getattr(p, "type");

    String *tm = Getattr(p, "tmap:in");
    if (tm) {
      if (!tm || checkAttribute(p, "tmap:in:numinputs", "0")) {
        p = nextSibling(p);
        continue;
      }

      sprintf(source, "argv[%d]", j);
      Setattr(p, "emit:input", source);

      Replaceall(tm, "$source", Getattr(p, "emit:input"));
      Replaceall(tm, "$input", Getattr(p, "emit:input"));
      Replaceall(tm, "$target", Getattr(p, "lname"));

      if (Getattr(p, "wrap:disown") || (Getattr(p, "tmap:in:disown"))) {
        Replaceall(tm, "$disown", "SWIG_POINTER_DISOWN");
      } else {
        Replaceall(tm, "$disown", "0");
      }

      if (Getattr(p, "tmap:in:implicitconv")) {
        const char *convflag = "0";
        if (!Getattr(p, "hidden")) {
          SwigType *ptype = Getattr(p, "type");
          convflag = get_implicitconv_flag(classLookup(ptype));
        }
        Replaceall(tm, "$implicitconv", convflag);
        Setattr(p, "implicitconv", convflag);
      }

      String *getargs = NewString("");
      if (j >= num_required)
        Printf(getargs, "if (%d<argc) {\n%s\n}", j, tm);
      else
        Printv(getargs, tm, NIL);
      Printv(f->code, getargs, "\n", NIL);
      Delete(getargs);

      p = Getattr(p, "tmap:in:next");
      continue;
    } else {
      Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, "Unable to use type %s as a function argument.\n", SwigType_str(pt, 0));
      break;
    }
  }

  // Check for trailing varargs
  if (varargs) {
    if (p && (tm = Getattr(p, "tmap:in"))) {
      Replaceall(tm, "$input", "varargs");
      Printv(f->code, tm, "\n", NIL);
    }
  }

  // Insert constraint checking code
  for (p = l; p;) {
    if ((tm = Getattr(p, "tmap:check"))) {
      Replaceall(tm, "$target", Getattr(p, "lname"));
      Printv(f->code, tm, "\n", NIL);
      p = Getattr(p, "tmap:check:next");
    } else {
      p = nextSibling(p);
    }
  }

  // Insert cleanup code
  String *cleanup = NewString("");
  for (p = l; p;) {
    if ((tm = Getattr(p, "tmap:freearg"))) {
      if (Getattr(p, "tmap:freearg:implicitconv")) {
        const char *convflag = "0";
        if (!Getattr(p, "hidden")) {
          SwigType *ptype = Getattr(p, "type");
          convflag = get_implicitconv_flag(classLookup(ptype));
        }
        if (strcmp(convflag, "0") == 0) {
          tm = 0;
        }
      }
      if (tm && (Len(tm) != 0)) {
        Replaceall(tm, "$source", Getattr(p, "lname"));
        Printv(cleanup, tm, "\n", NIL);
      }
      p = Getattr(p, "tmap:freearg:next");
    } else {
      p = nextSibling(p);
    }
  }

  // Insert argument output code
  String *outarg = NewString("");
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

  Setattr(n, "wrap:name", overname);

  Swig_director_emit_dynamic_cast(n, f);
  String *actioncode = emit_action(n);

  Wrapper_add_local(f, "_out", "mxArray * _out");
    
  // Return the function value
  if ((tm = Swig_typemap_lookup_out("out", n, Swig_cresult_name(), f, actioncode))) {
    Replaceall(tm, "$source", Swig_cresult_name());
    Replaceall(tm, "$target", "_out");
    Replaceall(tm, "$result", "_out");

    if (GetFlag(n, "feature:new"))
      Replaceall(tm, "$owner", "1");
    else
      Replaceall(tm, "$owner", "0");

    Printf(f->code, "%s\n", tm);


    Printf(f->code, "if(resc>0) *resv = _out;\n");
    Delete(tm);
  } else {
    Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to use return type %s in function %s.\n", SwigType_str(d, 0), iname);
  }
  emit_return_variable(n, d, f);

  Printv(f->code, outarg, NIL);
  Printv(f->code, cleanup, NIL);

  if (GetFlag(n, "feature:new")) {
    if ((tm = Swig_typemap_lookup("newfree", n, Swig_cresult_name(), 0))) {
      Replaceall(tm, "$source", Swig_cresult_name());
      Printf(f->code, "%s\n", tm);
    }
  }

  if ((tm = Swig_typemap_lookup("ret", n, Swig_cresult_name(), 0))) {
    Replaceall(tm, "$source", Swig_cresult_name());
    Replaceall(tm, "$result", "_outv");
    Printf(f->code, "%s\n", tm);
    Delete(tm);
  }

  Printf(f->code, "return;\n");
  Printf(f->code, "fail:\n");	// we should free locals etc if this happens
  Printf(f->code, "mexErrMsgTxt(\"Failure in function %s.\");\n", iname);
  Printv(f->code, cleanup, NIL);
  Printf(f->code, "}\n");

  /* Substitute the cleanup code */
  Replaceall(f->code, "$cleanup", cleanup);

  Replaceall(f->code, "$symname", iname);
  Wrapper_print(f, f_wrappers);
  DelWrapper(f);

  if (last_overload)
    dispatchFunction(n);

  Delete(overname);
  Delete(wname);
  Delete(cleanup);
  Delete(outarg);

  return SWIG_OK;
}

int MATLAB::variableWrapper(Node *n){
#ifdef MATLABPRINTFUNCTIONENTRY
  Printf(stderr,"Entering variableWrapper\n");
#endif
  return Language::variableWrapper(n);
}

int MATLAB::constantWrapper(Node *n){
#ifdef MATLABPRINTFUNCTIONENTRY
  Printf(stderr,"Entering constantWrapper\n");
#endif
  return Language::constantWrapper(n);
}

int MATLAB::nativeWrapper(Node *n) {
#ifdef MATLABPRINTFUNCTIONENTRY
  Printf(stderr,"Entering nativeWrapper\n");
#endif
  return Language::nativeWrapper(n);
}

int MATLAB::enumDeclaration(Node *n) {
#ifdef MATLABPRINTFUNCTIONENTRY
  Printf(stderr,"Entering enumDeclaration\n");
#endif
  return Language::enumDeclaration(n);
}

int MATLAB::enumvalueDeclaration(Node *n) {
#ifdef MATLABPRINTFUNCTIONENTRY
  Printf(stderr,"Entering enumvalueDeclaration\n");
#endif
  return Language::enumvalueDeclaration(n);
}

int MATLAB::classHandler(Node *n) {
#ifdef MATLABPRINTFUNCTIONENTRY
  Printf(stderr,"Entering classHandler\n");
#endif
  // Typedef C name for the class
  //    Printf(f_wrap_h,"typedef void* _%s;\n", Getattr(n,"sym:name"));

  // Save current class name
  if(class_name) SWIG_exit(EXIT_FAILURE);
  class_name = Getattr(n, "sym:name");

  // No destructor or constructor found yet
  have_constructor = false;
  have_destructor = false;

  // Name of wrapper .m file
  String* mfile=NewString(pkg_name_fullpath);
  Append(mfile,"/");
  Append(mfile,class_name);
  Append(mfile,".m");

  // Create wrapper .m file
  if(f_wrap_m) SWIG_exit(EXIT_FAILURE);
  f_wrap_m = NewFile(mfile, "w", SWIG_output_files());
  if (!f_wrap_m){
    FileErrorDisplay(mfile);
    SWIG_exit(EXIT_FAILURE);
  }

  // Declare MATLAB class
  Printf(f_wrap_m,"classdef %s < ", Getattr(n,"sym:name"));

  // Initialization of base classes
  base_init=NewString("");

  // Declare base classes, if any
  List *baselist = Getattr(n, "bases");
  int base_count = 0;
  if(baselist){
    // Loop over base classes
    for (Iterator b = First(baselist); b.item; b = Next(b)) {
      // Get base class name, possibly ignore
      String *bname = Getattr(b.item, "name");
      if(!bname || GetFlag(b.item,"feature:ignore")) continue;
      base_count++;
        
      // Separate multiple base classes with &
      if(base_count>1) Printf(f_wrap_m," & ");
      
      // Add to list of bases
      Printf(f_wrap_m,"%s.%s",pkg_name,bname);

      // Add to initialization
      Printf(base_init,"      self@%s.%s('_swigCreate',uint64(0),false);\n",pkg_name,bname);
    }
  }

  // Getters and setters for fields
  get_field=NewString("");
  set_field=NewString("");
  
  // Static methods
  static_methods=NewString("");

  // If no bases, top level class
  if(base_count==0){
    Printf(f_wrap_m,"SwigRef");
  }
    
  // End of class def
  Printf(f_wrap_m,"\n");

  // Declare class methods
  Printf(f_wrap_m,"  methods\n");

  // Emit member functions
  Language::classHandler(n);

  // Add constructor, if none added
  if(!have_constructor){
    wrapConstructor(class_name,0);
    have_constructor = true;
  }

  // Add subscripted reference
  Printf(f_wrap_m,"    function [v,ok] = swig_fieldsref(self,i)\n");
  Printf(f_wrap_m,"      v = [];\n");
  Printf(f_wrap_m,"      ok = false;\n");
  Printf(f_wrap_m,"      switch i\n");
  Printf(f_wrap_m,"%s",get_field);
  Printf(f_wrap_m,"      end\n");

  // Fallback to base class (does not work with multiple overloading)
  for (Iterator b = First(baselist); b.item; b = Next(b)) {
      String *bname = Getattr(b.item, "name");
      if(!bname || GetFlag(b.item,"feature:ignore")) continue;
      Printf(f_wrap_m,"      [v,ok] = swig_fieldsref@%s.%s(self,i);\n",pkg_name,bname);
      Printf(f_wrap_m,"      if ok\n");
      Printf(f_wrap_m,"        return\n");
      Printf(f_wrap_m,"      end\n");
  }
  Printf(f_wrap_m,"    end\n");

  // Add subscripted assignment
  Printf(f_wrap_m,"    function [self,ok] = swig_fieldasgn(self,i,v)\n");
  Printf(f_wrap_m,"      switch i\n");
  Printf(f_wrap_m,"%s",set_field);
  Printf(f_wrap_m,"      end\n");

  // Fallback to base class (does not work with multiple overloading)
  for (Iterator b = First(baselist); b.item; b = Next(b)) {
      String *bname = Getattr(b.item, "name");
      if(!bname || GetFlag(b.item,"feature:ignore")) continue;
      Printf(f_wrap_m,"      [self,ok] = swig_fieldasgn@%s.%s(self,i,v);\n",pkg_name,bname);
      Printf(f_wrap_m,"      if ok\n");
      Printf(f_wrap_m,"        return\n");
      Printf(f_wrap_m,"      end\n");
  }
  Printf(f_wrap_m,"    end\n");

  // End of non-static methods
  Printf(f_wrap_m,"  end\n");

  // Add static methods
  Printf(f_wrap_m,"  methods(Static)\n");
  Printf(f_wrap_m,"%s",static_methods);
  Printf(f_wrap_m,"  end\n");

  // Finalize file
  Printf(f_wrap_m,"end\n");

  // Tidy up
  Delete(base_init);
  base_init=0;
  Delete(f_wrap_m);
  f_wrap_m = 0;
  Delete(class_name);
  class_name=0;
  Delete(mfile);
  Delete(get_field);
  get_field = 0;
  Delete(set_field);
  set_field = 0;
  Delete(static_methods);
  static_methods = 0;
  return SWIG_OK;
}

int MATLAB::memberfunctionHandler(Node *n) {
#ifdef MATLABPRINTFUNCTIONENTRY
  Printf(stderr,"Entering memberfunctionHandler\n");
#endif
  bool overloaded = !!Getattr(n, "sym:overloaded");
  bool last_overload = overloaded && !Getattr(n, "sym:nextSibling");

  if(!overloaded || last_overload){
    // Add function to .m wrapper
    String *symname = Getattr(n, "sym:name");
    String *fullname = Swig_name_member(NSPACE_TODO, class_name, symname);
    Printf(f_wrap_m,"    function varargout = %s(self,varargin)\n",symname);
    Printf(f_wrap_m,"      [varargout{1:nargout}] = %s('%s',self,varargin{:});\n",mex_fcn,fullname);
    Printf(f_wrap_m,"    end\n");

    // Add to function switch
    String *wname = Swig_name_wrapper(fullname);
    toGateway(fullname,wname);
    Delete(wname);
    Delete(fullname);
  }

  return Language::memberfunctionHandler(n);
}

void MATLAB::initGateway(){
  if(CPlusPlus) Printf(f_gateway,"extern \"C\"\n");
  Printf(f_gateway,"void mexFunction(int resc, mxArray *resv[], int argc, const mxArray *argv[]){\n");
  
  // Load module if first call
  Printf(f_gateway,"  if(!is_loaded){\n");
  Printf(f_gateway,"    SWIG_Matlab_LoadModule(SWIG_name_d);\n");
  Printf(f_gateway,"    is_loaded=true;\n");
  Printf(f_gateway,"  }\n");

  // The first argument is always the function name
  Printf(f_gateway,"  char cmd[%d];\n",CMD_MAXLENGTH);
  Printf(f_gateway,"  if(argc < 1 || mxGetString(argv[0], cmd, sizeof(cmd)))\n");
  Printf(f_gateway,"    mexWarnMsgTxt(\"First input should be a command string less than %d characters long.\");\n  ",CMD_MAXLENGTH);
}

void MATLAB::toGateway(String *fullname, String *wname){
  if(Len(fullname)>CMD_MAXLENGTH){
    SWIG_exit(EXIT_FAILURE);
  }
  Printf(f_gateway,"if(!strcmp(\"%s\",cmd)){\n",fullname);
  Printf(f_gateway,"    %s(resc,resv,argc-1,(mxArray**)(argv+1));\n",wname);
  Printf(f_gateway,"  } else ");
}

void MATLAB::finalizeGateway(){
  Printf(f_gateway," {\n");
  Printf(f_gateway,"    mexWarnMsgIdAndTxt(\"SWIG\",\"No command %%s.\",cmd);\n");
  Printf(f_gateway,"  }\n");
  Printf(f_gateway,"}\n");
}

int MATLAB::membervariableHandler(Node *n) {
#ifdef MATLABPRINTFUNCTIONENTRY
  Printf(stderr,"Entering membervariableHandler\n");
#endif
  
  // Name of variable
  String *symname = Getattr(n, "sym:name");

  // Name getter function
  String *getname = Swig_name_get(NSPACE_TODO, Swig_name_member(NSPACE_TODO, class_name, symname));
  String *getwname = Swig_name_wrapper(getname);

  // Add getter function
  Printf(get_field,"        case '%s'\n",symname);
  Printf(get_field,"          v = %s('%s',self);\n",mex_fcn,getname);
  Printf(get_field,"          ok = true;\n");
  Printf(get_field,"          return\n");

  // Add to function switch
  toGateway(getname,getwname);

  // Tidy up
  Delete(getname);
  Delete(getwname);

  // Name setter function
  String *setname = Swig_name_set(NSPACE_TODO, Swig_name_member(NSPACE_TODO, class_name, symname));
  String *setwname = Swig_name_wrapper(setname);
  
  // Add setter function
  Printf(set_field,"        case '%s'\n",symname);
  Printf(set_field,"          %s('%s',self,v);\n",mex_fcn,setname);
  Printf(set_field,"          ok = true;\n");
  Printf(set_field,"          return\n");

  // Add to function switch
  toGateway(setname,setwname);

  // Tidy up
  Delete(setname);
  Delete(setwname);

  return Language::membervariableHandler(n);
}

void MATLAB::wrapConstructor(String *symname, String *fullname){
    Printf(f_wrap_m,"    function self = %s(varargin)\n",symname);
    Printf(f_wrap_m,"%s",base_init);
    Printf(f_wrap_m,"      if nargin==3 && ischar(varargin{1}) && strcmp(varargin{1},'_swigCreate')\n");
    Printf(f_wrap_m,"        self.swigCPtr = varargin{2};\n");
    Printf(f_wrap_m,"        self.swigOwn = varargin{3};\n");
    Printf(f_wrap_m,"      else\n");
    if(fullname==0){
      Printf(f_wrap_m,"        error('No matching constructor');\n");
    } else {
      Printf(f_wrap_m,"        %% How to get working on C side? Commented out, replaed by hack below\n");
      Printf(f_wrap_m,"        %%self.swigCPtr = %s('%s',varargin{:});\n",mex_fcn,fullname);
      Printf(f_wrap_m,"        %%self.swigOwn = true;\n");
      Printf(f_wrap_m,"        tmp = %s('%s',varargin{:}); %% FIXME\n",mex_fcn,fullname);
      Printf(f_wrap_m,"        self.swigCPtr = tmp.swigCPtr;\n");
      Printf(f_wrap_m,"        self.swigOwn = tmp.swigOwn;\n");
      Printf(f_wrap_m,"        tmp.swigOwn = false;\n");
    }
    Printf(f_wrap_m,"      end\n");
    Printf(f_wrap_m,"    end\n");
}

int MATLAB::constructorHandler(Node *n) {
#ifdef MATLABPRINTFUNCTIONENTRY
  Printf(stderr,"Entering constructorHandler\n");
#endif
  have_constructor = true;
  bool overloaded = !!Getattr(n, "sym:overloaded");
  bool last_overload = overloaded && !Getattr(n, "sym:nextSibling");

  if(!overloaded || last_overload){
    // Add function to .m wrapper
    String *symname = Getattr(n, "sym:name");
    String *fullname = Swig_name_construct(NSPACE_TODO, symname);

    // Add to .m file
    wrapConstructor(symname,fullname);

    // Add to function switch
    String *wname = Swig_name_wrapper(fullname);
    toGateway(fullname,wname);
    Delete(wname);
    Delete(fullname);
  }
  return Language::constructorHandler(n);
}

int MATLAB::destructorHandler(Node *n) {
#ifdef MATLABPRINTFUNCTIONENTRY
  Printf(stderr,"Entering destructorHandler\n");
#endif
  have_destructor = true;
  Printf(f_wrap_m,"    function delete(self)\n");
  String *symname = Getattr(n, "sym:name");
  String *fullname = Swig_name_destroy(NSPACE_TODO, symname);
  Printf(f_wrap_m,"      if self.swigOwn\n");
  Printf(f_wrap_m,"        %s('%s',self);\n",mex_fcn,fullname);
  Printf(f_wrap_m,"      end\n");
  Printf(f_wrap_m,"    end\n");

  // Add to function switch
  String *wname = Swig_name_wrapper(fullname);
  toGateway(fullname,wname);
  Delete(wname);
  Delete(fullname);
  
  return Language::destructorHandler(n);
}

int MATLAB::staticmemberfunctionHandler(Node *n) {
#ifdef MATLABPRINTFUNCTIONENTRY
  Printf(stderr,"Entering staticmemberfunctionHandler\n");
#endif

  bool overloaded = !!Getattr(n, "sym:overloaded");
  bool last_overload = overloaded && !Getattr(n, "sym:nextSibling");

  if(!overloaded || last_overload){
    // Add function to .m wrapper
    String *symname = Getattr(n, "sym:name");
    String *fullname = Swig_name_member(NSPACE_TODO, class_name, symname);
    Printf(static_methods,"    function varargout = %s(varargin)\n",symname);
    Printf(static_methods,"      [varargout{1:nargout}] = %s('%s',varargin{:});\n",mex_fcn,fullname);
    Printf(static_methods,"    end\n");

    // Add to function switch
    String *wname = Swig_name_wrapper(fullname);
    toGateway(fullname,wname);
    Delete(wname);
    Delete(fullname);
  }

  return Language::staticmemberfunctionHandler(n);
}

int MATLAB::memberconstantHandler(Node *n) {
#ifdef MATLABPRINTFUNCTIONENTRY
  Printf(stderr,"Entering memberconstantHandler\n");
#endif
  return Language::memberconstantHandler(n);
}

int MATLAB::staticmembervariableHandler(Node *n) {
#ifdef MATLABPRINTFUNCTIONENTRY
  Printf(stderr,"Entering staticmembervariableHandler\n");
#endif

  // Name of variable
  String *symname = Getattr(n, "sym:name");

  // Name getter function
  String *getname = Swig_name_get(NSPACE_TODO, Swig_name_member(NSPACE_TODO, class_name, symname));
  String *getwname = Swig_name_wrapper(getname);

  // Name setter function
  String *setname = Swig_name_set(NSPACE_TODO, Swig_name_member(NSPACE_TODO, class_name, symname));
  String *setwname = Swig_name_wrapper(setname);

  // Add getter/setter function
  Printf(static_methods,"    function varargout = %s(varargin)\n",symname);  
  Printf(static_methods,"      narginchk(0,1)\n");
  Printf(static_methods,"      if nargin==0\n");
  Printf(static_methods,"        nargoutchk(0,1)\n");
  Printf(static_methods,"        varargout{1} = %s('%s');\n",mex_fcn,getname);
  Printf(static_methods,"      else\n");
  Printf(static_methods,"        nargoutchk(0,0)\n");
  Printf(static_methods,"        %s('%s',varargin{1});\n",mex_fcn,setname);
  Printf(static_methods,"      end\n");
  Printf(static_methods,"    end\n");

  // Add to function switch
  toGateway(getname,getwname);
  toGateway(setname,setwname);

  // Tidy up
  Delete(getname);
  Delete(getwname);
  Delete(setname);
  Delete(setwname);

  return Language::staticmembervariableHandler(n);
}

/*
  this function names unnamed parameters

  Security by obscurity! If user chooses swig_par_name_2 as a parameter name
  for the first parameter and does not name the second one, boom.
*/
void MATLAB::nameUnnamedParams(ParmList *parms, bool all) {
  Parm *p;
  int i;
  for (p = parms, i=1; p; p = nextSibling(p),i++) {
    if(all || !Getattr(p,"name")) {
      String* parname=NewStringf("swig_par_name_%d", i);
      Setattr(p,"name",parname);
    }

  }
}

String *MATLAB::getOverloadedName(Node *n) {
  String *overloaded_name = NewStringf("%s", Getattr(n, "sym:name"));
  if (Getattr(n, "sym:overloaded")) {
    Printv(overloaded_name, Getattr(n, "sym:overname"), NIL);
  }
  return overloaded_name;
}

void MATLAB::createSwigRef(){
  // Create file
  String* mfile = NewString("SwigRef.m");
  if(f_wrap_m) SWIG_exit(EXIT_FAILURE);
  f_wrap_m = NewFile(mfile, "w", SWIG_output_files());
  if (!f_wrap_m){
    FileErrorDisplay(mfile);
    SWIG_exit(EXIT_FAILURE);
  }

  // Output SwigRef abstract base class
  Printf(f_wrap_m,"classdef SwigRef < handle\n");
  Printf(f_wrap_m,"  properties %% (GetAccess = protected, SetAccess = protected) %% FIXME: mxGetProperty not working with protected access \n");
  Printf(f_wrap_m,"    swigCPtr\n");
  Printf(f_wrap_m,"    swigOwn\n");
  Printf(f_wrap_m,"  end\n");
  Printf(f_wrap_m,"  methods\n");
  Printf(f_wrap_m,"    function v = subsref(self,S)\n");
  Printf(f_wrap_m,"      if numel(S)~=1\n");
  Printf(f_wrap_m,"        v = builtin('subsref',self,S);\n");
  Printf(f_wrap_m,"      else\n");
  Printf(f_wrap_m,"        if S.type=='.'\n");
  Printf(f_wrap_m,"          [v,ok] = swig_fieldsref(self,S.subs);\n");
  Printf(f_wrap_m,"        elseif S.type=='()'\n");
  Printf(f_wrap_m,"          [v,ok] = swig_parsref(self,S.subs);\n");
  Printf(f_wrap_m,"        else\n");  
  Printf(f_wrap_m,"          [v,ok] = swig_cursref(self,S.subs);\n");
  Printf(f_wrap_m,"        end\n");  
  Printf(f_wrap_m,"        if ~ok\n");
  Printf(f_wrap_m,"          error('No matching call')\n");
  Printf(f_wrap_m,"        end\n");
  Printf(f_wrap_m,"      end\n");
  Printf(f_wrap_m,"    end\n");
  Printf(f_wrap_m,"    function [v,ok] = swig_parsref(self,subs)\n");
  Printf(f_wrap_m,"      v = [];\n");
  Printf(f_wrap_m,"      ok = false;\n");
  Printf(f_wrap_m,"    end\n");
  Printf(f_wrap_m,"    function [v,ok] = swig_cursref(self,subs)\n");
  Printf(f_wrap_m,"      v = [];\n");
  Printf(f_wrap_m,"      ok = false;\n");
  Printf(f_wrap_m,"    end\n");
  Printf(f_wrap_m,"    function [v,ok] = swig_fieldsref(self,subs)\n");
  Printf(f_wrap_m,"      v = [];\n");
  Printf(f_wrap_m,"      ok = false;\n");
  Printf(f_wrap_m,"    end\n");
  Printf(f_wrap_m,"    function self = subsasgn(self,S,v)\n");
  Printf(f_wrap_m,"      if numel(S)~=1\n");
  Printf(f_wrap_m,"        self = builtin('subsasgn',self,S,v);\n");
  Printf(f_wrap_m,"      else\n");
  Printf(f_wrap_m,"        if S.type=='.'\n");
  Printf(f_wrap_m,"          [self,ok] = swig_fieldasgn(self,S.subs,v);\n");
  Printf(f_wrap_m,"        elseif S.type=='()'\n");
  Printf(f_wrap_m,"          [self,ok] = swig_parasgn(self,S.subs,v);\n");
  Printf(f_wrap_m,"        else\n");  
  Printf(f_wrap_m,"          [self,ok] = swig_curasgn(self,S.subs,v);\n");
  Printf(f_wrap_m,"        end\n");  
  Printf(f_wrap_m,"        if ~ok\n");
  Printf(f_wrap_m,"          error('No matching call')\n");
  Printf(f_wrap_m,"        end\n");
  Printf(f_wrap_m,"      end\n");
  Printf(f_wrap_m,"    end\n");
  Printf(f_wrap_m,"    function [self,ok] = swig_parasgn(self,i,v)\n");
  Printf(f_wrap_m,"      ok = false;\n");
  Printf(f_wrap_m,"    end\n");
  Printf(f_wrap_m,"    function [self,ok] = swig_curasgn(self,i,v)\n");
  Printf(f_wrap_m,"      ok = false;\n");
  Printf(f_wrap_m,"    end\n");
  Printf(f_wrap_m,"    function [self,ok] = swig_fieldasgn(self,i,v)\n");
  Printf(f_wrap_m,"      ok = false;\n");
  Printf(f_wrap_m,"    end\n");
  Printf(f_wrap_m,"  end\n");
  Printf(f_wrap_m,"end\n");

  // Tidy up
  Delete(f_wrap_m);
  Delete(mfile);
  f_wrap_m = 0;
}

const char* MATLAB::get_implicitconv_flag(Node *n) {
  int conv = 0;
  if (n && GetFlag(n, "feature:implicitconv")) {
    conv = 1;
  }
  return conv ? "SWIG_POINTER_IMPLICIT_CONV" : "0";
}

void MATLAB::dispatchFunction(Node *n) {
  Wrapper *f = NewWrapper();

  String *iname = Getattr(n, "sym:name");
  String *wname = Swig_name_wrapper(iname);
  int maxargs;
  String *dispatch = Swig_overload_dispatch(n, "return %s(resc,resv,argc,argv);", &maxargs);
  String *tmp = NewString("");

  Printf(f->def, "void %s (int resc, mxArray *resv[], int argc, mxArray *argv[]) {", wname);
  Printv(f->code, dispatch, "\n", NIL);
  Printf(f->code, "mexWarnMsgIdAndTxt(\"SWIG\",\"No matching function for overload\");\n", iname);
  Printf(f->code, "return;\n");
  Printv(f->code, "}\n", NIL);

  Wrapper_print(f, f_wrappers);
  Delete(tmp);
  DelWrapper(f);
  Delete(dispatch);
  Delete(wname);
}

String *MATLAB::texinfo_name(Node* n, const char* defval) {
  String *tname = NewString("");
  String *iname = Getattr(n, "sym:name");
  String *wname = Swig_name_wrapper(iname);
  Node* d = Getattr(docs, wname);

  if (is_empty_doc_node(d))
    Printf(tname, defval);
  else
    Printf(tname, "%s_texinfo", wname);

  return tname;
}

bool MATLAB::is_empty_doc_node(Node* n) {
  if (!n)
    return true;
  String *synopsis = Getattr(n, "synopsis");
  String *decl_info = Getattr(n, "decl_info");
  String *cdecl_info = Getattr(n, "cdecl_info");
  String *args_info = Getattr(n, "args_info");
  return !Len(synopsis) && !Len(decl_info) && 
    !Len(cdecl_info) && !Len(args_info);
}

void MATLAB::emit_doc_texinfo() {
  for (Iterator it = First(docs); it.key; it = Next(it)) {
    String *wrap_name = it.key;

    String *synopsis = Getattr(it.item, "synopsis");
    String *decl_info = Getattr(it.item, "decl_info");
    String *cdecl_info = Getattr(it.item, "cdecl_info");
    String *args_info = Getattr(it.item, "args_info");

    String *doc_str = NewString("");
    Printv(doc_str, synopsis, decl_info, cdecl_info, args_info, NIL);
    String *escaped_doc_str = texinfo_escape(doc_str);

    if (Len(doc_str)>0) {
      Printf(f_doc,"static const char* %s_texinfo = ",wrap_name);
      Printf(f_doc,"\"-*- texinfo -*-\\n\\\n%s", escaped_doc_str);
      if (Len(decl_info))
        Printf(f_doc,"\\n\\\n@end deftypefn");
      Printf(f_doc,"\";\n");
    }

    Delete(escaped_doc_str);
    Delete(doc_str);
    Delete(wrap_name);
  }
  Printf(f_doc,"\n");
}

String* MATLAB::texinfo_escape(String *_s) {
  const char* s=(const char*)Data(_s);
  while (*s&&(*s=='\t'||*s=='\r'||*s=='\n'||*s==' '))
    ++s;
  String *r = NewString("");
  for (int j=0;s[j];++j) {
    if (s[j] == '\n') {
      Append(r, "\\n\\\n");
    } else if (s[j] == '\r') {
      Append(r, "\\r");
    } else if (s[j] == '\t') {
      Append(r, "\\t");
    } else if (s[j] == '\\') {
      Append(r, "\\\\");
    } else if (s[j] == '\'') {
      Append(r, "\\\'");
    } else if (s[j] == '\"') {
      Append(r, "\\\"");
    } else
      Putc(s[j], r);
  }
  return r;
}
