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
//#include "cparse.h"

//#define MATLABPRINTFUNCTIONENTRY

static String *global_name = 0;
static String *op_prefix   = 0;

static const char *usage = (char *) "\
Matlab Options (available with -matlab)\n\
     -globals <name> - Set <name> used to access C global variables [default: 'cvar']\n\
                       Use '.' to load C global variables into module namespace\n\
     -opprefix <str> - Prefix <str> for global operator functions [default: 'op_']\n\
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
  File *f_begin;
  File *f_runtime;
  File *f_header;
  File *f_wrappers;
  File *f_init;

  String* mex_fcn;
  String* class_name;

  // Helper functions
  static void nameUnnamedParams(ParmList *parms, bool all);
  String *getOverloadedName(Node *n);
};

extern "C" Language *swig_matlab(void) {
  return new MATLAB();
}

// Only implementations from here on

MATLAB::MATLAB() : 
  f_wrap_m(0),
  f_begin(0),
  f_runtime(0),
  f_header(0),
  f_wrappers(0),
  f_init(0),
  mex_fcn(0),
  class_name(0)
{
#ifdef MATLABPRINTFUNCTIONENTRY
    Printf(stderr,"Entering MATLAB()\n");
#endif
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

  // {
  //   Node *mod = Getattr(n, "module");
  //   if (mod) {
  //     Node *options = Getattr(mod, "options");
  //     if (options) {
  //       int dirprot = 0;
  //       if (Getattr(options, "dirprot")) {
  //         dirprot = 1;
  //       }
  //       if (Getattr(options, "nodirprot")) {
  //         dirprot = 0;
  //       }
  //       if (Getattr(options, "directors")) {
  //         allow_directors();
  //         if (dirprot)
  //           allow_dirprot();
  //       }
  //     }
  //   }
  // }

  /* Get the module name */
  String *module = Getattr(n, "name");

  /* Get the name of the .cxx wrapper file (i.e. the mex fine */
  String *mexfile = Getattr(n, "outfile");

  /* To get the name the mex function (when calling from Matlab), we remove the suffix */
  mex_fcn=NewString(mexfile);
  char *suffix = Strchr(mex_fcn,'.');
  char *suffix_end = Char(mex_fcn)+Len(mex_fcn);
  while(suffix!=suffix_end) *suffix++ = ' '; // Replace suffix with whitespaces
  Chop(mex_fcn); // Remove trailing whitespaces

  /* Initialize wrapper .c file  */
  f_begin = NewFile(mexfile, "w", SWIG_output_files());
  if (!f_begin) {
    FileErrorDisplay(mexfile);
    SWIG_exit(EXIT_FAILURE);
  }
  f_runtime = NewString("");
  f_header = NewString("");
  //   f_doc = NewString("");
  f_wrappers = NewString("");
  f_init = NewString("");
  //   f_initbeforefunc = NewString("");
  //   f_directors_h = NewString("");
  //   f_directors = NewString("");
  //   s_global_tab = NewString("");
    
  /* Register file targets with the SWIG file handler */
  Swig_register_filebyname("begin", f_begin);
  Swig_register_filebyname("runtime", f_runtime);
  Swig_register_filebyname("header", f_header);
  //   Swig_register_filebyname("doc", f_doc);
  Swig_register_filebyname("wrapper", f_wrappers);
  Swig_register_filebyname("init", f_init);
  //   Swig_register_filebyname("initbeforefunc", f_initbeforefunc);
  //   Swig_register_filebyname("director", f_directors);
  //   Swig_register_filebyname("director_h", f_directors_h);
    
  /* Output module initialization code */
  Swig_banner(f_begin);

  //   Printf(f_runtime, "\n");
  //   Printf(f_runtime, "#define SWIGMATLAB\n");
  //   Printf(f_runtime, "#define SWIG_name_d      \"%s\"\n", module);
  //   Printf(f_runtime, "#define SWIG_name        %s\n", module);

  //   Printf(f_runtime, "\n");
  //   Printf(f_runtime, "#define SWIG_global_name      \"%s\"\n", global_name);
  //   Printf(f_runtime, "#define SWIG_op_prefix        \"%s\"\n", op_prefix);

  //   if (directorsEnabled()) {
  //     Printf(f_runtime, "#define SWIG_DIRECTORS\n");
  //     Swig_banner(f_directors_h);
  //     if (dirprot_mode()) {
  //       //      Printf(f_directors_h, "#include <map>\n");
  //       //      Printf(f_directors_h, "#include <string>\n\n");
  //     }
  //   }

  //   Printf(f_runtime, "\n");

  //   Printf(s_global_tab, "\nstatic const struct swig_matlab_member swig_globals[] = {\n");
  //   Printf(f_init, "static bool SWIG_init_user(matlab_swig_type* module_ns)\n{\n");

  //   if (!CPlusPlus)
  //     Printf(f_header,"extern \"C\" {\n");

  /* Emit code for children */
  Language::top(n);

  //   if (!CPlusPlus)
  //     Printf(f_header,"}\n");

  //   if (Len(docs))
  //     emit_doc_texinfo();

  //   if (directorsEnabled())
  //     Swig_insert_file("director.swg", f_runtime);

  //   Printf(f_init, "return true;\n}\n");
  //   Printf(s_global_tab, "{0,0,0,0,0}\n};\n");

  //   Printv(f_wrappers, s_global_tab, NIL);
  //   SwigType_emit_type_table(f_runtime, f_wrappers);
  
  // Write .c file
  Dump(f_runtime, f_begin);
  Dump(f_header, f_begin);
  //   Dump(f_doc, f_begin);
  //   if (directorsEnabled()) {
  //     Dump(f_directors_h, f_begin);
  //     Dump(f_directors, f_begin);
  //   }
  Dump(f_wrappers, f_begin);
  //   Dump(f_initbeforefunc, f_begin);
  Wrapper_pretty_print(f_init, f_begin);

  /* Cleanup files */
  //   Delete(s_global_tab);
  //   Delete(f_initbeforefunc);
  Delete(f_init);
  Delete(f_wrappers);
  //   Delete(f_doc);
  Delete(f_header);
  //   Delete(f_directors);
  //   Delete(f_directors_h);
  Delete(f_runtime);
  Delete(f_begin);
  Delete(mex_fcn);
  return SWIG_OK;
}

// String* MATLAB::texinfo_escape(String *_s) {
//   const char* s=(const char*)Data(_s);
//   while (*s&&(*s=='\t'||*s=='\r'||*s=='\n'||*s==' '))
//     ++s;
//   String *r = NewString("");
//   for (int j=0;s[j];++j) {
//     if (s[j] == '\n') {
//       Append(r, "\\n\\\n");
//     } else if (s[j] == '\r') {
//       Append(r, "\\r");
//     } else if (s[j] == '\t') {
//       Append(r, "\\t");
//     } else if (s[j] == '\\') {
//       Append(r, "\\\\");
//     } else if (s[j] == '\'') {
//       Append(r, "\\\'");
//     } else if (s[j] == '\"') {
//       Append(r, "\\\"");
//     } else
//       Putc(s[j], r);
//   }
//   return r;
// }
// void emit_doc_texinfo() {
//   for (Iterator it = First(docs); it.key; it = Next(it)) {
//     String *wrap_name = it.key;

//     String *synopsis = Getattr(it.item, "synopsis");
//     String *decl_info = Getattr(it.item, "decl_info");
//     String *cdecl_info = Getattr(it.item, "cdecl_info");
//     String *args_info = Getattr(it.item, "args_info");

//     String *doc_str = NewString("");
//     Printv(doc_str, synopsis, decl_info, cdecl_info, args_info, NIL);
//     String *escaped_doc_str = texinfo_escape(doc_str);

//     if (Len(doc_str)>0) {
//       Printf(f_doc,"static const char* %s_texinfo = ",wrap_name);
//       Printf(f_doc,"\"-*- texinfo -*-\\n\\\n%s", escaped_doc_str);
//       if (Len(decl_info))
//         Printf(f_doc,"\\n\\\n@end deftypefn");
//       Printf(f_doc,"\";\n");
//     }

//     Delete(escaped_doc_str);
//     Delete(doc_str);
//     Delete(wrap_name);
//   }
//   Printf(f_doc,"\n");
// }
// bool is_empty_doc_node(Node* n) {
//   if (!n)
//     return true;
//   String *synopsis = Getattr(n, "synopsis");
//   String *decl_info = Getattr(n, "decl_info");
//   String *cdecl_info = Getattr(n, "cdecl_info");
//   String *args_info = Getattr(n, "args_info");
//   return !Len(synopsis) && !Len(decl_info) && 
//     !Len(cdecl_info) && !Len(args_info);
// }
// String *texinfo_name(Node* n, const char* defval = "0") {
//   String *tname = NewString("");
//   String *iname = Getattr(n, "sym:name");
//   String *wname = Swig_name_wrapper(iname);
//   Node* d = Getattr(docs, wname);

//   if (is_empty_doc_node(d))
//     Printf(tname, defval);
//   else
//     Printf(tname, "%s_texinfo", wname);

//   return tname;
// }
// void process_autodoc(Node *n) {
//   String *iname = Getattr(n, "sym:name");
//   String *name = Getattr(n, "name");
//   String *wname = Swig_name_wrapper(iname);
//   String *str = Getattr(n, "feature:docstring");
//   bool autodoc_enabled = !Cmp(Getattr(n, "feature:autodoc"), "1");
//   Node* d = Getattr(docs, wname);
//   if (!d) {
//     d = NewHash();
//     Setattr(d, "synopsis", NewString(""));
//     Setattr(d, "decl_info", NewString(""));
//     Setattr(d, "cdecl_info", NewString(""));
//     Setattr(d, "args_info", NewString(""));
//     Setattr(docs, wname, d);
//   }

//   String *synopsis = Getattr(d, "synopsis");
//   String *decl_info = Getattr(d, "decl_info");
//   //    String *cdecl_info = Getattr(d, "cdecl_info");
//   String *args_info = Getattr(d, "args_info");

//   // * couldn't we just emit the docs here?

//   if (autodoc_enabled) {
//     String *decl_str = NewString("");
//     String *args_str = NewString("");
//     make_autodocParmList(n, decl_str, args_str);
//     Append(decl_info, "@deftypefn {Loadable Function} ");

//     SwigType *type = Getattr(n, "type");
//     if (type && Strcmp(type, "void")) {
//       Node *nn = classLookup(Getattr(n, "type"));
//       String *type_str = nn ? Copy(Getattr(nn, "sym:name")) : SwigType_str(type, 0);
//       Append(decl_info, "@var{retval} = ");
//       Printf(args_str, "%s@var{retval} is of type %s. ", args_str, type_str);
//       Delete(type_str);
//     }

//     Append(decl_info, name);
//     Append(decl_info, " (");
//     Append(decl_info, decl_str);
//     Append(decl_info, ")\n");
//     Append(args_info, args_str);
//     Delete(decl_str);
//     Delete(args_str);
//   }

//   if (str && Len(str) > 0) {
//     // strip off {} if necessary
//     char *t = Char(str);
//     if (*t == '{') {
//       Delitem(str, 0);
//       Delitem(str, DOH_END);
//     }

//     // emit into synopsis section
//     Append(synopsis, str);
//   }
// }

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

// /* -----------------------------------------------------------------------------
//  * addMissingParameterNames()
//  *  For functions that have not had nameless parameters set in the Language class.
//  *
//  * Inputs: 
//  *   plist - entire parameter list
//  *   arg_offset - argument number for first parameter
//  * Side effects:
//  *   The "lname" attribute in each parameter in plist will be contain a parameter name
//  * ----------------------------------------------------------------------------- */

// void addMissingParameterNames(ParmList *plist, int arg_offset) {
//   Parm *p = plist;
//   int i = arg_offset;
//   while (p) {
//     if (!Getattr(p, "lname")) {
//       String *pname = Swig_cparm_name(p, i);
//       Delete(pname);
//     }
//     i++;
//     p = nextSibling(p);
//   }
// }

// void make_autodocParmList(Node *n, String *decl_str, String *args_str) {
//   String *pdocs = 0;
//   ParmList *plist = CopyParmList(Getattr(n, "parms"));
//   Parm *p;
//   Parm *pnext;
//   int start_arg_num = is_wrapping_class() ? 1 : 0;

//   addMissingParameterNames(plist, start_arg_num); // for $1_name substitutions done in Swig_typemap_attach_parms

//   Swig_typemap_attach_parms("in", plist, 0);
//   Swig_typemap_attach_parms("doc", plist, 0);

//   for (p = plist; p; p = pnext) {

//     String *tm = Getattr(p, "tmap:in");
//     if (tm) {
//       pnext = Getattr(p, "tmap:in:next");
//       if (checkAttribute(p, "tmap:in:numinputs", "0")) {
//         continue;
//       }
//     } else {
//       pnext = nextSibling(p);
//     }

//     String *name = 0;
//     String *type = 0;
//     String *value = 0;
//     String *pdoc = Getattr(p, "tmap:doc");
//     if (pdoc) {
//       name = Getattr(p, "tmap:doc:name");
//       type = Getattr(p, "tmap:doc:type");
//       value = Getattr(p, "tmap:doc:value");
//     }

//     // Note: the generated name should be consistent with that in kwnames[]
//     name = name ? name : Getattr(p, "name");
//     name = name ? name : Getattr(p, "lname");
//     name = Swig_name_make(p, 0, name, 0, 0); // rename parameter if a keyword

//     type = type ? type : Getattr(p, "type");
//     value = value ? value : Getattr(p, "value");

//     if (SwigType_isvarargs(type))
//       break;

//     String *tex_name = NewString("");
//     if (name)
//       Printf(tex_name, "@var{%s}", name);
//     else
//       Printf(tex_name, "@var{?}");

//     if (Len(decl_str))
//       Append(decl_str, ", ");
//     Append(decl_str, tex_name);

//     if (value) {
//       String *new_value = convertValue(value, Getattr(p, "type"));
//       if (new_value) {
//         value = new_value;
//       } else {
//         Node *lookup = Swig_symbol_clookup(value, 0);
//         if (lookup)
//           value = Getattr(lookup, "sym:name");
//       }
//       Printf(decl_str, " = %s", value);
//     }

//     Node *nn = classLookup(Getattr(p, "type"));
//     String *type_str = nn ? Copy(Getattr(nn, "sym:name")) : SwigType_str(type, 0);
//     Printf(args_str, "%s is of type %s. ", tex_name, type_str);

//     Delete(type_str);
//     Delete(tex_name);
//     Delete(name);
//   }
//   if (pdocs)
//     Setattr(n, "feature:pdocs", pdocs);
//   Delete(plist);
// }

// /* ------------------------------------------------------------
//  * convertValue()
//  *    Check if string v can be an Matlab value literal,
//  *    (eg. number or string), or translate it to an Matlab literal.
//  * ------------------------------------------------------------ */
// String *convertValue(String *v, SwigType *t) {
//   if (v && Len(v) > 0) {
//     char fc = (Char(v))[0];
//     if (('0' <= fc && fc <= '9') || '\'' == fc || '"' == fc) {
//       /* number or string (or maybe NULL pointer) */
//       if (SwigType_ispointer(t) && Strcmp(v, "0") == 0)
//         return NewString("None");
//       else
//         return v;
//     }
//     if (Strcmp(v, "NULL") == 0 || Strcmp(v, "nullptr") == 0)
//       return SwigType_ispointer(t) ? NewString("nil") : NewString("0");
//     if (Strcmp(v, "true") == 0 || Strcmp(v, "TRUE") == 0)
//       return NewString("true");
//     if (Strcmp(v, "false") == 0 || Strcmp(v, "FALSE") == 0)
//       return NewString("false");
//   }
//   return 0;
// }


int MATLAB::functionWrapper(Node *n){
#ifdef MATLABPRINTFUNCTIONENTRY
    Printf(stderr,"Entering functionWrapper\n");
#endif

  // Get useful attributes 
  String   *name   = Getattr(n,"sym:name");
  SwigType *type   = Getattr(n,"type");
  ParmList *parms  = Getattr(n,"parms");
  String *nodeType = Getattr(n, "nodeType");
  String *storage = Getattr(n, "storage");
  String *value = Getattr(n, "value");
  
  // Handle nameless parameters
  nameUnnamedParams(parms, false);
  String *parmprotostr = ParmList_protostr(parms);

  // Is it a pure virtual function?
  bool pure_virtual = Cmp(storage, "virtual") == 0 && Cmp(value, "0") == 0;
  
  // Deal with overloading 
  String *overname = NewString("");
  Printf(overname, "%s", getOverloadedName(n));
  String *wname = Swig_name_wrapper(overname);
  Setattr(n, "wrap:name", wname);

  // Create the wrapper object 
  Wrapper *f = NewWrapper();




  // Debug: Dump to file
  if(true){
    String   *parmstr= ParmList_str_defaultargs(parms); // to string
    String   *func   = SwigType_str(type, NewStringf("%s(%s)", name, parmstr));
    String   *action = Getattr(n,"wrap:action");
    Printf(f_wrappers,"functionWrapper   : %s\n", func);
    Printf(f_wrappers,"           action : %s\n", action);
  }


    
  // Write the wrapper function definition
  //   Matlab_begin_function(n, f->def, iname, overname, !overloaded);
  
  // If any additional local variable needed, add them now  
  // ..
  
  // Write the list of locals/arguments required
  // ..

  // Check arguments 
  // ..
  
  // Write typemaps(in) 
  // ..

  // Write constraints
  // ..

  // Emit the function call 
  // ..

  // return value if necessary 
  // ..

  // Write typemaps(out) 
  // ..
  
  // Add cleanup code
  // ..
  
  // Close the function(ok)
  // ..
  
  // Add the failure cleanup code
  // ..
  
  // Dump the function out  
  Wrapper_print(f, f_wrappers);

  // Tidy up
  DelWrapper(f);
  //   if (last_overload) dispatchFunction(n);
  //   if (!overloaded || last_overload) {
  //     String *tname = texinfo_name(n);
  //     Printf(s_global_tab, "{\"%s\",%s,0,0,2,%s},\n", iname, wname, tname);
  //     Delete(tname);
  //   }

  //   Delete(overname);
  Delete(wname);
  //   Delete(cleanup);
  //   Delete(outarg);
  return SWIG_OK;
}

// void MATLAB::dispatchFunction(Node *n) {
//   Wrapper *f = NewWrapper();

//   String *iname = Getattr(n, "sym:name");
//   String *wname = Swig_name_wrapper(iname);
//   int maxargs;
//   String *dispatch = Swig_overload_dispatch(n, "return %s(args, nargout);", &maxargs);
//   String *tmp = NewString("");

//   Matlab_begin_function(n, f->def, iname, wname, true);
//   Wrapper_add_local(f, "argc", "int argc = args.length()");
//   Printf(tmp, "matlab_value_ref argv[%d]={", maxargs);
//   for (int j = 0; j < maxargs; ++j)
//     Printf(tmp, "%smatlab_value_ref(args,%d)", j ? "," : " ", j);
//   Printf(tmp, "}");
//   Wrapper_add_local(f, "argv", tmp);
//   Printv(f->code, dispatch, "\n", NIL);
//   Printf(f->code, "error(\"No matching function for overload\");\n", iname);
//   Printf(f->code, "return matlab_value_list();\n");
//   Printv(f->code, "}\n", NIL);

//   Wrapper_print(f, f_wrappers);
//   Delete(tmp);
//   DelWrapper(f);
//   Delete(dispatch);
//   Delete(wname);
// }

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

    // Name of wrapper .m file
    String* mfile=NewString(class_name);
    Append(mfile,".m");

    // Create wrapper .m file
    if(f_wrap_m) SWIG_exit(EXIT_FAILURE);
    f_wrap_m = NewFile(mfile, "w", SWIG_output_files());
    if (!f_wrap_m){
      FileErrorDisplay(mfile);
      SWIG_exit(EXIT_FAILURE);
    }

    


    //    List *baselist = Getattr(n, "bases");

    // Declare class in .m file
    Printf(f_wrap_m, "classdef %s < handle\n\n", Getattr(n,"sym:name"));
    Printf(f_wrap_m, "properties (GetAccess = public, SetAccess = private)\n");
    Printf(f_wrap_m, "h\n");
    Printf(f_wrap_m, "end\n");
    Printf(f_wrap_m, "methods\n");

    // Emit member functions
    Language::classHandler(n);

    // Finalize file
    Printf(f_wrap_m, "end\n");
    Printf(f_wrap_m, "end\n");

    // Tidy up
    Delete(f_wrap_m);
    f_wrap_m = 0;
    Delete(class_name);
    class_name=0;
    Delete(mfile);

    return SWIG_OK;
}

int MATLAB::memberfunctionHandler(Node *n) {
#ifdef MATLABPRINTFUNCTIONENTRY
  Printf(stderr,"Entering memberfunctionHandler\n");
#endif
  String *symname = Getattr(n, "sym:name");
  String *fullname = Swig_name_member(NSPACE_TODO, class_name, symname);
  Printf(f_wrap_m,"function varargout = %s(this,varargin)\n",symname);
  Printf(f_wrap_m,"[varargout{1:nargout}] = %s('%s',this.h,varargin{:})\n",mex_fcn,fullname);
  Printf(f_wrap_m,"end\n");

  return Language::memberfunctionHandler(n);
}

int MATLAB::membervariableHandler(Node *n) {
#ifdef MATLABPRINTFUNCTIONENTRY
    Printf(stderr,"Entering membervariableHandler\n");
#endif
    return Language::membervariableHandler(n);
}

int MATLAB::constructorHandler(Node *n) {
#ifdef MATLABPRINTFUNCTIONENTRY
    Printf(stderr,"Entering constructorHandler\n");
#endif
    String *symname = Getattr(n, "sym:name");
    String *fullname = Swig_name_construct(NSPACE_TODO, symname);
    Printf(f_wrap_m,"function this = %s(varargin)\n",symname);
    Printf(f_wrap_m,"this.h = %s('%s',varargin{:})\n",mex_fcn,fullname);
    Printf(f_wrap_m,"end\n");
    return Language::constructorHandler(n);
}

int MATLAB::destructorHandler(Node *n) {
#ifdef MATLABPRINTFUNCTIONENTRY
    Printf(stderr,"Entering destructorHandler\n");
#endif
    Printf(f_wrap_m,"function delete(h)\n");
    String *symname = Getattr(n, "sym:name");
    String *fullname = Swig_name_destroy(NSPACE_TODO, symname);
    Printf(f_wrap_m,"%s('%s',h)\n",mex_fcn,fullname);
    Printf(f_wrap_m,"end\n");
    return Language::destructorHandler(n);
}

int MATLAB::staticmemberfunctionHandler(Node *n) {
#ifdef MATLABPRINTFUNCTIONENTRY
    Printf(stderr,"Entering staticmemberfunctionHandler\n");
#endif
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
