/* -----------------------------------------------------------------------------
 * This file is part of SWIG, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at http://www.swig.org/legal.html.
 *
 * php.cxx
 *
 * PHP language module for SWIG.
 * -----------------------------------------------------------------------------
 */

#include "swigmod.h"

#include <ctype.h>
#include <errno.h>

static const char *usage = "\
PHP Options (available with -php7)\n\
     -prefix <prefix> - Prepend <prefix> to all class names in PHP wrappers\n\
\n";

// How to wrap non-class functions, variables and constants:
// FIXME: Make this specifiable and also allow a real namespace.

// Wrap as global PHP names.
static bool wrap_nonclass_global = true;

// Wrap in a class to fake a namespace (for compatibility with SWIG's behaviour
// before PHP added namespaces.
static bool wrap_nonclass_fake_class = true;

static String *module = 0;
static String *cap_module = 0;
static String *prefix = 0;

static File *f_begin = 0;
static File *f_runtime = 0;
static File *f_runtime_h = 0;
static File *f_h = 0;
static File *f_directors = 0;
static File *f_directors_h = 0;

static String *s_header;
static String *s_wrappers;
static String *s_init;
static String *r_init;		// RINIT user code
static String *s_shutdown;	// MSHUTDOWN user code
static String *r_shutdown;	// RSHUTDOWN user code
static String *s_vdecl;
static String *s_cinit;		// consttab initialization code.
static String *s_oinit;
static String *s_arginfo;
static String *s_entry;
static String *cs_entry;
static String *all_cs_entry;
static String *fake_cs_entry;
static String *s_creation;
static String *pragma_incl;
static String *pragma_code;
static String *pragma_phpinfo;
static String *pragma_version;

static String *class_name = NULL;
static String *magic_set = NULL;
static String *magic_get = NULL;
static String *magic_isset = NULL;

// Class used as pseudo-namespace for compatibility.
static String *fake_class_name() {
  static String *result = NULL;
  if (!result) {
    result = Len(prefix) ? prefix : module;
    if (!s_creation) {
      s_creation = NewStringEmpty();
    }
    if (!fake_cs_entry) {
      fake_cs_entry = NewStringf("static zend_function_entry class_%s_functions[] = {\n", result);
    }
    Printf(s_creation, "/* class entry for %s */\n",result);
    Printf(s_creation, "zend_class_entry *SWIGTYPE_%s_ce;\n\n",result);
    Printf(s_oinit, "  INIT_CLASS_ENTRY(internal_ce, \"%s\", class_%s_functions);\n", result, result);
    Printf(s_oinit, "  SWIGTYPE_%s_ce = zend_register_internal_class(&internal_ce);\n", result);
    Printf(s_oinit, "\n");
  }
  return result;
}

/* To reduce code size (generated and compiled) we only want to emit each
 * different arginfo once, so we need to track which have been used.
 */
static Hash *arginfo_used;

/* Track non-class pointer types we need to to wrap */
static Hash *zend_types = 0;

static int shadow = 1;

static String *wrapping_member_constant = NULL;

// These static variables are used to pass some state from Handlers into functionWrapper
static enum {
  standard = 0,
  memberfn,
  staticmemberfn,
  membervar,
  staticmembervar,
  constructor,
  directorconstructor,
  directordisown
} wrapperType = standard;

extern "C" {
  static void (*r_prevtracefunc) (const SwigType *t, String *mangled, String *clientdata) = 0;
}

static void print_creation_free_wrapper(Node *n) {
  if (!s_creation) {
    s_creation = NewStringEmpty();
  }

  String *s = s_creation;

  Printf(s, "/* class entry for %s */\n",class_name);
  Printf(s, "zend_class_entry *SWIGTYPE_%s_ce;\n\n",class_name);
  Printf(s, "/* class object handlers for %s */\n",class_name);
  Printf(s, "zend_object_handlers %s_object_handlers;\n\n",class_name);

  if (Getattr(n, "has_destructor")) {
    Printf(s, "/* Garbage Collection Method for class %s */\n",class_name);
    Printf(s, "void %s_free_storage(zend_object *object) {\n",class_name);
    Printf(s, "  swig_object_wrapper *obj = 0;\n");
    Printf(s, "  if (!object)\n");
    Printf(s, "    return;\n");
    Printf(s, "  obj = php_fetch_object(object);\n");

    Printf(s, "  zend_object_std_dtor(&obj->std);\n");

    // expand %delete typemap instead of SWIG_remove?
    Printf(s, "  if (obj->newobject)\n");
    Printf(s, "    SWIG_remove((%s *)obj->ptr);\n", Getattr(n, "classtype"));
    Printf(s, "}\n\n");
  }

  Printf(s, "/* Object Creation Method for class %s */\n",class_name);
  Printf(s, "zend_object * %s_object_new(zend_class_entry *ce) {\n",class_name);
  Printf(s, "  swig_object_wrapper *obj = (swig_object_wrapper*)zend_object_alloc(sizeof(swig_object_wrapper), ce);\n");
  Printf(s, "  zend_object_std_init(&obj->std, ce);\n");
  Printf(s, "  object_properties_init(&obj->std, ce);\n");
  Printf(s, "  %s_object_handlers.offset = XtOffsetOf(swig_object_wrapper, std);\n", class_name);
  if (Getattr(n, "has_destructor")) {
    Printf(s, "  %s_object_handlers.free_obj = %s_free_storage;\n", class_name, class_name);
  }
  Printf(s, "  obj->std.handlers = &%s_object_handlers;\n  obj->newobject = 1;\n  return &obj->std;\n}\n\n\n",class_name);
}

static void SwigPHP_emit_pointer_type_registrations() {
  if (!zend_types)
    return;

  Iterator ki = First(zend_types);
  if (!ki.key)
    return;

  Printf(s_wrappers, "/* class object handlers for pointer wrappers */\n");
  Printf(s_wrappers, "static zend_object_handlers swig_ptr_object_handlers;\n\n");

  Printf(s_wrappers, "/* Object Creation Method for pointer wrapping class */\n");
  Printf(s_wrappers, "static zend_object * swig_ptr_object_new(zend_class_entry *ce) {\n");
  Printf(s_wrappers, "  swig_object_wrapper *obj = (swig_object_wrapper*)zend_object_alloc(sizeof(swig_object_wrapper), ce);\n");
  Printf(s_wrappers, "  zend_object_std_init(&obj->std, ce);\n");
  Printf(s_wrappers, "  object_properties_init(&obj->std, ce);\n");
  Printf(s_wrappers, "  obj->std.handlers = &swig_ptr_object_handlers;\n");
  Printf(s_wrappers, "  obj->newobject = 0;\n");
  Printf(s_wrappers, "  return &obj->std;\n");
  Printf(s_wrappers, "}\n\n");

  Printf(s_wrappers, "/* Implement __toString equivalent, since that worked for the old-style resource wrapped pointers. */\n");
  Append(s_wrappers, "#if PHP_MAJOR_VERSION < 8\n");
  Printf(s_wrappers, "static int swig_ptr_cast_object(zval *z, zval *retval, int type) {\n");
  Append(s_wrappers, "#else\n");
  Printf(s_wrappers, "static int swig_ptr_cast_object(zend_object *zobj, zval *retval, int type) {\n");
  Append(s_wrappers, "#endif\n");
  Printf(s_wrappers, "  if (type == IS_STRING) {\n");
  Printf(s_wrappers, "    char buf[80];\n");
  Append(s_wrappers, "#if PHP_MAJOR_VERSION < 8\n");
  Printf(s_wrappers, "    swig_object_wrapper *obj = SWIG_Z_FETCH_OBJ_P(z);\n");
  Append(s_wrappers, "#else\n");
  Printf(s_wrappers, "    swig_object_wrapper *obj = php_fetch_object(zobj);\n");
  Append(s_wrappers, "#endif\n");
  Printv(s_wrappers, "    sprintf(buf, \"SWIGPointer(%p,owned=%d)\", obj->ptr, obj->newobject);\n", NIL);
  Printf(s_wrappers, "    ZVAL_STRING(retval, buf);\n");
  Printf(s_wrappers, "    return SUCCESS;\n");
  Printf(s_wrappers, "  }\n");
  Printf(s_wrappers, "  return FAILURE;\n");
  Printf(s_wrappers, "}\n\n");

  Printf(s_oinit, "\n  /* Register classes to represent non-class pointer types */\n");
  Printf(s_oinit, "  memcpy(&swig_ptr_object_handlers, zend_get_std_object_handlers(), sizeof(zend_object_handlers));\n");
  Printf(s_oinit, "  swig_ptr_object_handlers.offset = XtOffsetOf(swig_object_wrapper, std);\n");
  Printf(s_oinit, "  swig_ptr_object_handlers.cast_object = swig_ptr_cast_object;\n");

  while (ki.key) {
    String *type = ki.key;

    if (!s_creation) {
      s_creation = NewStringEmpty();
    }

    Printf(s_creation, "/* class entry for pointer to %s */\n", type);
    Printf(s_creation, "zend_class_entry *SWIGTYPE_%s_ce;\n\n", type);

    Printf(s_oinit, "  INIT_CLASS_ENTRY(internal_ce, \"%s\\\\%s\", NULL);\n", "SWIG", type);
    Printf(s_oinit, "  SWIGTYPE_%s_ce = zend_register_internal_class(&internal_ce);\n", type);
    Printf(s_oinit, "  SWIGTYPE_%s_ce->create_object = swig_ptr_object_new;\n", type);
    Printf(s_oinit, "  SWIG_TypeClientData(SWIGTYPE%s,SWIGTYPE_%s_ce);\n", type, type);
    Printf(s_oinit, "\n");

    ki = Next(ki);
  }
}

class PHP : public Language {
public:
  PHP() {
    director_language = 1;
  }

  /* ------------------------------------------------------------
   * main()
   * ------------------------------------------------------------ */

  virtual void main(int argc, char *argv[]) {
    SWIG_library_directory("php");

    for (int i = 1; i < argc; i++) {
      if (strcmp(argv[i], "-prefix") == 0) {
	if (argv[i + 1]) {
	  prefix = NewString(argv[i + 1]);
	  Swig_mark_arg(i);
	  Swig_mark_arg(i + 1);
	  i++;
	} else {
	  Swig_arg_error();
	}
      } else if ((strcmp(argv[i], "-noshadow") == 0)) {
	shadow = 0;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-help") == 0) {
	fputs(usage, stdout);
      }
    }

    Preprocessor_define("SWIGPHP 1", 0);
    Preprocessor_define("SWIGPHP7 1", 0);
    SWIG_typemap_lang("php");
    SWIG_config_file("php.swg");
    allow_overloading();
  }

  /* ------------------------------------------------------------
   * top()
   * ------------------------------------------------------------ */

  virtual int top(Node *n) {

    String *filen;

    /* Check if directors are enabled for this module. */
    Node *mod = Getattr(n, "module");
    if (mod) {
      Node *options = Getattr(mod, "options");
      if (options && Getattr(options, "directors")) {
	allow_directors();
      }
    }

    /* Set comparison with null for ConstructorToFunction */
    setSubclassInstanceCheck(NewString("Z_TYPE_P($arg) != IS_NULL"));

    /* Initialize all of the output files */
    String *outfile = Getattr(n, "outfile");
    String *outfile_h = Getattr(n, "outfile_h");

    /* main output file */
    f_begin = NewFile(outfile, "w", SWIG_output_files());
    if (!f_begin) {
      FileErrorDisplay(outfile);
      SWIG_exit(EXIT_FAILURE);
    }
    f_runtime = NewStringEmpty();

    /* sections of the output file */
    s_init = NewStringEmpty();
    r_init = NewStringEmpty();
    s_shutdown = NewStringEmpty();
    r_shutdown = NewStringEmpty();
    s_header = NewString("/* header section */\n");
    s_wrappers = NewString("/* wrapper section */\n");
    /* subsections of the init section */
    s_vdecl = NewString("/* vdecl subsection */\n");
    s_cinit = NewString("  /* cinit subsection */\n");
    s_oinit = NewString("  /* oinit subsection */\n");
    pragma_phpinfo = NewStringEmpty();
    f_directors_h = NewStringEmpty();
    f_directors = NewStringEmpty();

    if (directorsEnabled()) {
      f_runtime_h = NewFile(outfile_h, "w", SWIG_output_files());
      if (!f_runtime_h) {
	FileErrorDisplay(outfile_h);
	SWIG_exit(EXIT_FAILURE);
      }
    }

    /* Register file targets with the SWIG file handler */
    Swig_register_filebyname("begin", f_begin);
    Swig_register_filebyname("runtime", f_runtime);
    Swig_register_filebyname("init", s_init);
    Swig_register_filebyname("rinit", r_init);
    Swig_register_filebyname("shutdown", s_shutdown);
    Swig_register_filebyname("rshutdown", r_shutdown);
    Swig_register_filebyname("header", s_header);
    Swig_register_filebyname("wrapper", s_wrappers);
    Swig_register_filebyname("director", f_directors);
    Swig_register_filebyname("director_h", f_directors_h);

    Swig_banner(f_begin);

    Printf(f_runtime, "\n\n#ifndef SWIGPHP\n#define SWIGPHP\n#endif\n\n");

    if (directorsEnabled()) {
      Printf(f_runtime, "#define SWIG_DIRECTORS\n");
    }

    /* Set the module name */
    module = Copy(Getattr(n, "name"));
    cap_module = NewStringf("%(upper)s", module);
    if (!prefix)
      prefix = NewStringEmpty();

    if (directorsEnabled()) {
      Swig_banner(f_directors_h);
      Printf(f_directors_h, "\n");
      Printf(f_directors_h, "#ifndef SWIG_%s_WRAP_H_\n", cap_module);
      Printf(f_directors_h, "#define SWIG_%s_WRAP_H_\n\n", cap_module);

      String *filename = Swig_file_filename(outfile_h);
      Printf(f_directors, "\n#include \"%s\"\n\n", filename);
      Delete(filename);
    }

    /* sub-sections of the php file */
    pragma_code = NewStringEmpty();
    pragma_incl = NewStringEmpty();
    pragma_version = NULL;

    /* Initialize the rest of the module */

    /* start the header section */
    Printf(s_header, "#define SWIG_name  \"%s\"\n", module);
    Printf(s_header, "#ifdef __cplusplus\n");
    Printf(s_header, "extern \"C\" {\n");
    Printf(s_header, "#endif\n");
    Printf(s_header, "#include \"php_ini.h\"\n");
    Printf(s_header, "#include \"ext/standard/info.h\"\n");
    Printf(s_header, "#include \"php_%s.h\"\n", module);
    Printf(s_header, "#ifdef __cplusplus\n");
    Printf(s_header, "}\n");
    Printf(s_header, "#endif\n\n");

    Printf(s_header, "#ifdef __cplusplus\n#define SWIG_remove(PTR) delete PTR\n");
    Printf(s_header, "#else\n#define SWIG_remove(PTR) free(PTR)\n#endif\n\n");

    if (directorsEnabled()) {
      // Insert director runtime
      Swig_insert_file("director_common.swg", s_header);
      Swig_insert_file("director.swg", s_header);
    }

    /* Create the .h file too */
    filen = NewStringEmpty();
    Printv(filen, SWIG_output_directory(), "php_", module, ".h", NIL);
    f_h = NewFile(filen, "w", SWIG_output_files());
    if (!f_h) {
      FileErrorDisplay(filen);
      SWIG_exit(EXIT_FAILURE);
    }

    Swig_banner(f_h);

    Printf(f_h, "\n");
    Printf(f_h, "#ifndef PHP_%s_H\n", cap_module);
    Printf(f_h, "#define PHP_%s_H\n\n", cap_module);
    Printf(f_h, "extern zend_module_entry %s_module_entry;\n", module);
    Printf(f_h, "#define phpext_%s_ptr &%s_module_entry\n\n", module, module);
    Printf(f_h, "#ifdef PHP_WIN32\n");
    Printf(f_h, "# define PHP_%s_API __declspec(dllexport)\n", cap_module);
    Printf(f_h, "#else\n");
    Printf(f_h, "# define PHP_%s_API\n", cap_module);
    Printf(f_h, "#endif\n\n");

    /* start the arginfo section */
    s_arginfo = NewString("/* arginfo subsection */\n");
    arginfo_used = NewHash();

    /* start the function entry section */
    s_entry = NewString("/* entry subsection */\n");

    /* holds all the per-class function entry sections */
    all_cs_entry = NewString("/* class entry subsection */\n");
    cs_entry = NULL;
    fake_cs_entry = NULL;

    Printf(s_entry, "/* Every non-class user visible function must have an entry here */\n");
    Printf(s_entry, "static zend_function_entry module_%s_functions[] = {\n", module);

    /* Emit all of the code */
    Language::top(n);

    SwigPHP_emit_pointer_type_registrations();
    if (s_creation) {
      Dump(s_creation, s_header);
      Delete(s_creation);
      s_creation = NULL;
    }

    /* start the init section */
    {
      String * s_init_old = s_init;
      s_init = NewString("/* init section */\n");
      Printv(s_init, "zend_module_entry ", module, "_module_entry = {\n", NIL);
      Printf(s_init, "    STANDARD_MODULE_HEADER,\n");
      Printf(s_init, "    \"%s\",\n", module);
      Printf(s_init, "    module_%s_functions,\n", module);
      Printf(s_init, "    PHP_MINIT(%s),\n", module);
      if (Len(s_shutdown) > 0) {
	Printf(s_init, "    PHP_MSHUTDOWN(%s),\n", module);
      } else {
	Printf(s_init, "    NULL, /* No MSHUTDOWN code */\n");
      }
      if (Len(r_init) > 0) {
	Printf(s_init, "    PHP_RINIT(%s),\n", module);
      } else {
	Printf(s_init, "    NULL, /* No RINIT code */\n");
      }
      if (Len(r_shutdown) > 0) {
	Printf(s_init, "    PHP_RSHUTDOWN(%s),\n", module);
      } else {
	Printf(s_init, "    NULL, /* No RSHUTDOWN code */\n");
      }
      if (Len(pragma_phpinfo) > 0) {
	Printf(s_init, "    PHP_MINFO(%s),\n", module);
      } else {
	Printf(s_init, "    NULL, /* No MINFO code */\n");
      }
      if (Len(pragma_version) > 0) {
	Printf(s_init, "    \"%s\",\n", pragma_version);
      } else {
	Printf(s_init, "    NO_VERSION_YET,\n");
      }
      Printf(s_init, "    STANDARD_MODULE_PROPERTIES\n");
      Printf(s_init, "};\n");
      Printf(s_init, "zend_module_entry* SWIG_module_entry = &%s_module_entry;\n\n", module);

      Printf(s_init, "#ifdef __cplusplus\n");
      Printf(s_init, "extern \"C\" {\n");
      Printf(s_init, "#endif\n");
      // We want to write "SWIGEXPORT ZEND_GET_MODULE(%s)" but ZEND_GET_MODULE
      // in PHP7 has "extern "C" { ... }" around it so we can't do that.
      Printf(s_init, "SWIGEXPORT zend_module_entry *get_module(void) { return &%s_module_entry; }\n", module);
      Printf(s_init, "#ifdef __cplusplus\n");
      Printf(s_init, "}\n");
      Printf(s_init, "#endif\n\n");

      Printf(s_init, "#define SWIG_php_minit PHP_MINIT_FUNCTION(%s)\n\n", module);

      Printv(s_init, s_init_old, NIL);
      Delete(s_init_old);
    }

    /* We have to register the constants before they are (possibly) used
     * by the pointer typemaps. This all needs re-arranging really as
     * things are being called in the wrong order
     */

    //    Printv(s_init,s_resourcetypes,NIL);
    Printf(s_oinit, "  /* end oinit subsection */\n");
    Printf(s_init, "%s\n", s_oinit);

    /* Constants generated during top call */
    Printf(s_cinit, "  /* end cinit subsection */\n");
    Printf(s_init, "%s\n", s_cinit);
    Clear(s_cinit);
    Delete(s_cinit);

    Printf(s_init, "  return SUCCESS;\n");
    Printf(s_init, "}\n\n");

    // Now do REQUEST init which holds any user specified %rinit, and also vinit
    if (Len(r_init) > 0) {
      Printf(f_h, "PHP_RINIT_FUNCTION(%s);\n", module);

      Printf(s_init, "PHP_RINIT_FUNCTION(%s)\n{\n", module);
      Printv(s_init,
	     "/* rinit section */\n",
	     r_init, "\n",
	     NIL);

      Printf(s_init, "  return SUCCESS;\n");
      Printf(s_init, "}\n\n");
    }

    Printf(f_h, "PHP_MINIT_FUNCTION(%s);\n", module);

    if (Len(s_shutdown) > 0) {
      Printf(f_h, "PHP_MSHUTDOWN_FUNCTION(%s);\n", module);

      Printv(s_init, "PHP_MSHUTDOWN_FUNCTION(", module, ")\n"
		     "/* shutdown section */\n"
		     "{\n",
		     s_shutdown,
		     "  return SUCCESS;\n"
		     "}\n\n", NIL);
    }

    if (Len(r_shutdown) > 0) {
      Printf(f_h, "PHP_RSHUTDOWN_FUNCTION(%s);\n", module);

      Printf(s_init, "PHP_RSHUTDOWN_FUNCTION(%s)\n{\n", module);
      Printf(s_init, "/* rshutdown section */\n");
      Printf(s_init, "%s\n", r_shutdown);
      Printf(s_init, "    return SUCCESS;\n");
      Printf(s_init, "}\n\n");
    }

    if (Len(pragma_phpinfo) > 0) {
      Printf(f_h, "PHP_MINFO_FUNCTION(%s);\n", module);

      Printf(s_init, "PHP_MINFO_FUNCTION(%s)\n{\n", module);
      Printf(s_init, "%s", pragma_phpinfo);
      Printf(s_init, "}\n");
    }

    Printf(s_init, "/* end init section */\n");

    Printf(f_h, "\n#endif /* PHP_%s_H */\n", cap_module);

    Delete(f_h);

    String *type_table = NewStringEmpty();
    SwigType_emit_type_table(f_runtime, type_table);
    Printf(s_header, "%s", type_table);
    Delete(type_table);

    /* Oh dear, more things being called in the wrong order. This whole
     * function really needs totally redoing.
     */

    if (directorsEnabled()) {
      Dump(f_directors_h, f_runtime_h);
      Printf(f_runtime_h, "\n");
      Printf(f_runtime_h, "#endif\n");
      Delete(f_runtime_h);
    }

    Printf(s_header, "/* end header section */\n");
    Printf(s_wrappers, "/* end wrapper section */\n");
    Printf(s_vdecl, "/* end vdecl subsection */\n");

    Dump(f_runtime, f_begin);
    Printv(f_begin, s_header, NIL);
    if (directorsEnabled()) {
      Dump(f_directors, f_begin);
    }
    Printv(f_begin, s_vdecl, s_wrappers, NIL);
    Printv(f_begin, s_arginfo, "\n\n", all_cs_entry, "\n\n", s_entry,
	" ZEND_FE_END\n};\n\n", NIL);
    if (fake_cs_entry) {
      Printv(f_begin, fake_cs_entry, " ZEND_FE_END\n};\n\n", NIL);
      Delete(fake_cs_entry);
      fake_cs_entry = NULL;
    }
    Printv(f_begin, s_init, NIL);
    Delete(s_header);
    Delete(s_wrappers);
    Delete(s_init);
    Delete(s_vdecl);
    Delete(all_cs_entry);
    Delete(s_entry);
    Delete(s_arginfo);
    Delete(f_runtime);
    Delete(f_begin);
    Delete(arginfo_used);

    if (Len(pragma_incl) > 0 || Len(pragma_code) > 0) {
      /* PHP module file */
      String *php_filename = NewStringEmpty();
      Printv(php_filename, SWIG_output_directory(), module, ".php", NIL);

      File *f_phpcode = NewFile(php_filename, "w", SWIG_output_files());
      if (!f_phpcode) {
	FileErrorDisplay(php_filename);
	SWIG_exit(EXIT_FAILURE);
      }

      Printf(f_phpcode, "<?php\n\n");

      if (Len(pragma_incl) > 0) {
	Printv(f_phpcode, pragma_incl, "\n", NIL);
      }

      if (Len(pragma_code) > 0) {
	Printv(f_phpcode, pragma_code, "\n", NIL);
      }

      Delete(f_phpcode);
      Delete(php_filename);
    }

    return SWIG_OK;
  }

  /* Just need to append function names to function table to register with PHP. */
  void create_command(String *cname, String *fname, Node *n, bool overload, String *modes = NULL) {
    // This is for the single main zend_function_entry record
    bool has_this = false;
    if (cname && Cmp(Getattr(n, "storage"), "friend") != 0) {
      Printf(f_h, "PHP_METHOD(%s%s,%s);\n", prefix, cname, fname);
      has_this = (wrapperType != staticmemberfn) &&
		 (wrapperType != staticmembervar) &&
		 (Cmp(fname, "__construct") != 0);
    } else {
      if (overload) {
        Printf(f_h, "ZEND_NAMED_FUNCTION(%s);\n", fname);
      } else {
        Printf(f_h, "PHP_FUNCTION(%s);\n", fname);
      }
    }
    // We want to only emit each different arginfo once, as that reduces the
    // size of both the generated source code and the compiled extension
    // module.  The parameters at this level are just named arg1, arg2, etc
    // so we generate an arginfo name with the number of parameters and a
    // bitmap value saying which (if any) are passed by reference.
    ParmList *l = Getattr(n, "parms");
    unsigned long bitmap = 0, bit = 1;
    bool overflowed = false;
    bool skip_this = has_this;
    for (Parm *p = l; p; p = Getattr(p, "tmap:in:next")) {
      if (skip_this) {
	skip_this = false;
        continue;
      }
      String* tmap_in_numinputs = Getattr(p, "tmap:in:numinputs");
      // tmap:in:numinputs is unset for varargs, which we don't count here.
      if (!tmap_in_numinputs || Equal(tmap_in_numinputs, "0")) {
	/* Ignored parameter */
	continue;
      }
      if (GetFlag(p, "tmap:in:byref")) {
	  bitmap |= bit;
	  if (bit == 0) overflowed = true;
      }
      bit <<= 1;
    }
    int num_arguments = emit_num_arguments(l);
    int num_required = emit_num_required(l);
    if (has_this) {
      --num_arguments;
      --num_required;
    }
    String * arginfo_code;
    if (overflowed) {
      // We overflowed the bitmap so just generate a unique name - this only
      // happens for a function with more parameters than bits in a long
      // where a high numbered parameter is passed by reference, so should be
      // rare in practice.
      static int overflowed_counter = 0;
      arginfo_code = NewStringf("z%d", ++overflowed_counter);
    } else if (bitmap == 0) {
      // No parameters passed by reference.
      if (num_required == num_arguments) {
	  arginfo_code = NewStringf("%d", num_arguments);
      } else {
	  arginfo_code = NewStringf("%d_%d", num_required, num_arguments);
      }
    } else {
      if (num_required == num_arguments) {
	  arginfo_code = NewStringf("%d_r%lx", num_arguments, bitmap);
      } else {
	  arginfo_code = NewStringf("%d_%d_r%lx", num_required, num_arguments, bitmap);
      }
    }

    if (!GetFlag(arginfo_used, arginfo_code)) {
      // Not had this one before so emit it.
      SetFlag(arginfo_used, arginfo_code);
      Printf(s_arginfo, "ZEND_BEGIN_ARG_INFO_EX(swig_arginfo_%s, 0, 0, %d)\n", arginfo_code, num_required);
      bool skip_this = has_this;
      int param_count = 0;
      for (Parm *p = l; p; p = Getattr(p, "tmap:in:next")) {
	if (skip_this) {
	  skip_this = false;
	  continue;
	}
	String* tmap_in_numinputs = Getattr(p, "tmap:in:numinputs");
	// tmap:in:numinputs is unset for varargs, which we don't count here.
	if (!tmap_in_numinputs || Equal(tmap_in_numinputs, "0")) {
	  /* Ignored parameter */
	  continue;
	}
	Printf(s_arginfo, " ZEND_ARG_INFO(%d,arg%d)\n", GetFlag(p, "tmap:in:byref"), ++param_count);
      }
      Printf(s_arginfo, "ZEND_END_ARG_INFO()\n");
    }

    String * s = cs_entry;
    if (!s) s = s_entry;
    if (cname && Cmp(Getattr(n, "storage"), "friend") != 0) {
      Printf(all_cs_entry, " PHP_ME(%s%s,%s,swig_arginfo_%s,%s)\n", prefix, cname, fname, arginfo_code, modes);
    } else {
      if (overload) {
	if (wrap_nonclass_global) {
	  Printf(s, " ZEND_NAMED_FE(%(lower)s,%s,swig_arginfo_%s)\n", Getattr(n, "sym:name"), fname, arginfo_code);
	}

	if (wrap_nonclass_fake_class) {
	  (void)fake_class_name();
	  Printf(fake_cs_entry, " ZEND_NAMED_ME(%(lower)s,%s,swig_arginfo_%s,ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)\n", Getattr(n, "sym:name"), fname, arginfo_code);
	}
      } else {
	if (wrap_nonclass_global) {
	  Printf(s, " PHP_FE(%s,swig_arginfo_%s)\n", fname, arginfo_code);
	}

	if (wrap_nonclass_fake_class) {
	  String *fake_class = fake_class_name();
	  Printf(fake_cs_entry, " PHP_ME(%s,%s,swig_arginfo_%s,ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)\n", fake_class, fname, arginfo_code);
	}
      }
    }
    Delete(arginfo_code);
  }

  /* ------------------------------------------------------------
   * dispatchFunction()
   * ------------------------------------------------------------ */
  void dispatchFunction(Node *n, int constructor) {
    /* Last node in overloaded chain */

    int maxargs;
    String *tmp = NewStringEmpty();
    String *dispatch = Swig_overload_dispatch(n, "%s(INTERNAL_FUNCTION_PARAM_PASSTHRU); return;", &maxargs);

    /* Generate a dispatch wrapper for all overloaded functions */

    Wrapper *f = NewWrapper();
    String *symname = Getattr(n, "sym:name");
    String *wname = NULL;
    String *modes = NULL;
    bool constructorRenameOverload = false;

    if (constructor) {
      // Renamed constructor - turn into static factory method
      if (Cmp(class_name, Getattr(n, "constructorHandler:sym:name")) != 0) {
        constructorRenameOverload = true;
        wname = Copy(Getattr(n, "constructorHandler:sym:name"));
      } else {
        wname = NewString("__construct");
      }
    } else if (class_name) {
      wname = Getattr(n, "wrapper:method:name");
    } else {
      wname = Swig_name_wrapper(symname);
    }

    if (constructor) {
      modes = NewString("ZEND_ACC_PUBLIC | ZEND_ACC_CTOR");
      if (constructorRenameOverload) {
        Append(modes, " | ZEND_ACC_STATIC");
      }
    } else if (wrapperType == staticmemberfn || Cmp(Getattr(n, "storage"), "static") == 0) {
      modes = NewString("ZEND_ACC_PUBLIC | ZEND_ACC_STATIC");
    } else {
      modes = NewString("ZEND_ACC_PUBLIC");
    }

    create_command(class_name, wname, n, true, modes);

    if (class_name && Cmp(Getattr(n, "storage"), "friend") != 0) {
      Printv(f->def, "PHP_METHOD(", prefix, class_name, ",", wname, ") {\n", NIL);
    } else {
      Printv(f->def, "ZEND_NAMED_FUNCTION(", wname, ") {\n", NIL);
    }

    Wrapper_add_local(f, "argc", "int argc");

    Printf(tmp, "zval argv[%d]", maxargs);
    Wrapper_add_local(f, "argv", tmp);

    Printf(f->code, "argc = ZEND_NUM_ARGS();\n");

    Printf(f->code, "zend_get_parameters_array_ex(argc, argv);\n");

    Replaceall(dispatch, "$args", "self,args");

    Printv(f->code, dispatch, "\n", NIL);

    Printf(f->code, "zend_throw_exception(zend_ce_type_error, \"No matching function for overloaded '%s'\", 0);\n", symname);
    Printv(f->code, "fail:\n", NIL);
    Printv(f->code, "return;\n", NIL);
    Printv(f->code, "}\n", NIL);
    Wrapper_print(f, s_wrappers);

    DelWrapper(f);
    Delete(dispatch);
    Delete(tmp);
  }

  /* ------------------------------------------------------------
   * functionWrapper()
   * ------------------------------------------------------------ */

  /* Helper method for PHP::functionWrapper */
  bool is_class(SwigType *t) {
    Node *n = classLookup(t);
    if (n) {
      String *r = Getattr(n, "php:proxy");	// Set by classDeclaration()
      if (!r)
	r = Getattr(n, "sym:name");	// Not seen by classDeclaration yet, but this is the name
      if (r)
	return true;
    }
    return false;
  }

  /* Helper method for PHP::functionWrapper to get class name for parameter*/
  String *get_class_name(SwigType *t) {
    Node *n = classLookup(t);
    String *r = NULL;
    if (n) {
      r = Getattr(n, "php:proxy");      // Set by classDeclaration()
      if (!r)
        r = Getattr(n, "sym:name");     // Not seen by classDeclaration yet, but this is the name
    }
    return r;
  }

  /* Helper function to check if class is wrapped */
  bool is_class_wrapped(String *className) {
    if (!className)
      return false;
    Node * n = symbolLookup(className);
    return n && Getattr(n, "classtype") != NULL;
  }

  /* Is special return type */
  bool is_param_type_pointer(SwigType *t) {
    
    if (SwigType_ispointer(t) ||
          SwigType_ismemberpointer(t) ||
            SwigType_isreference(t) ||
              SwigType_isarray(t))
      return true;

    return false;
  }

  void generate_magic_property_methods(Node *class_node, String *base_class) {
    if (Equal(base_class, "Exception") || !is_class_wrapped(base_class)) {
      base_class = NULL;
    }

    // Ensure arginfo_1 and arginfo_2 exist.
    if (!GetFlag(arginfo_used, "1")) {
      SetFlag(arginfo_used, "1");
      Append(s_arginfo,
	     "ZEND_BEGIN_ARG_INFO_EX(swig_arginfo_1, 0, 0, 1)\n"
	     " ZEND_ARG_INFO(0,arg1)\n"
	     "ZEND_END_ARG_INFO()\n");
    }
    if (!GetFlag(arginfo_used, "2")) {
      SetFlag(arginfo_used, "2");
      Append(s_arginfo,
	     "ZEND_BEGIN_ARG_INFO_EX(swig_arginfo_2, 0, 0, 2)\n"
	     " ZEND_ARG_INFO(0,arg1)\n"
	     " ZEND_ARG_INFO(0,arg2)\n"
	     "ZEND_END_ARG_INFO()\n");
    }

    Wrapper *f = NewWrapper();

    Printf(f_h, "PHP_METHOD(%s%s,__set);\n", prefix, class_name);
    Printf(all_cs_entry, " PHP_ME(%s%s,__set,swig_arginfo_2,ZEND_ACC_PUBLIC)\n", prefix, class_name);
    Printf(f->code, "PHP_METHOD(%s%s,__set) {\n", prefix, class_name);

    Printf(f->code, "  swig_object_wrapper *arg = SWIG_Z_FETCH_OBJ_P(ZEND_THIS);\n");
    Printf(f->code, "  zval args[2];\n zval tempZval;\n  zend_string *arg2 = 0;\n\n");
    Printf(f->code, "  if(ZEND_NUM_ARGS() != 2 || zend_get_parameters_array_ex(2, args) != SUCCESS) {\n");
    Printf(f->code, "\tWRONG_PARAM_COUNT;\n}\n\n");
    Printf(f->code, "  if (!arg) {\n");
    Printf(f->code, "    zend_throw_exception(zend_ce_type_error, \"this pointer is NULL\", 0);\n");
    Printf(f->code, "    return;\n");
    Printf(f->code, "  }\n");
    Printf(f->code, "  arg2 = Z_STR(args[0]);\n\n");

    Printf(f->code, "if (!arg2) {\n  RETVAL_NULL();\n}\n");
    if (magic_set) {
      Append(f->code, magic_set);
    }
    Printf(f->code, "\nelse if (strcmp(ZSTR_VAL(arg2),\"thisown\") == 0) {\n");
    Printf(f->code, "arg->newobject = zval_get_long(&args[1]);\n");
    if (Swig_directorclass(class_node)) {
      Printv(f->code, "if (arg->newobject == 0) {\n",
		      "  Swig::Director *director = SWIG_DIRECTOR_CAST((", Getattr(class_node, "classtype"), "*)(arg->ptr));\n",
		      "  if (director) director->swig_disown();\n",
		      "}\n", NIL);
    }
    Printf(f->code, "} else {\n");
    if (base_class) {
      Printf(f->code, "PHP_MN(%s%s___set)(INTERNAL_FUNCTION_PARAM_PASSTHRU);\n}\n", prefix, base_class);
    } else {
      Printf(f->code, "add_property_zval_ex(ZEND_THIS, ZSTR_VAL(arg2), ZSTR_LEN(arg2), &args[1]);\n}\n");
    }

    Printf(f->code, "fail:\n");
    Printf(f->code, "return;\n");
    Printf(f->code, "}\n\n\n");


    Printf(f_h, "PHP_METHOD(%s%s,__get);\n", prefix, class_name);
    Printf(all_cs_entry, " PHP_ME(%s%s,__get,swig_arginfo_1,ZEND_ACC_PUBLIC)\n", prefix, class_name);
    Printf(f->code, "PHP_METHOD(%s%s,__get) {\n",prefix, class_name);

    Printf(f->code, "  swig_object_wrapper *arg = SWIG_Z_FETCH_OBJ_P(ZEND_THIS);\n", class_name);
    Printf(f->code, "  zval args[1];\n zval tempZval;\n  zend_string *arg2 = 0;\n\n");
    Printf(f->code, "  if(ZEND_NUM_ARGS() != 1 || zend_get_parameters_array_ex(1, args) != SUCCESS) {\n");
    Printf(f->code, "\tWRONG_PARAM_COUNT;\n}\n\n");
    Printf(f->code, "  if (!arg) {\n");
    Printf(f->code, "    zend_throw_exception(zend_ce_type_error, \"this pointer is NULL\", 0);\n");
    Printf(f->code, "    return;\n");
    Printf(f->code, "  }\n");
    Printf(f->code, "  arg2 = Z_STR(args[0]);\n\n");

    Printf(f->code, "if (!arg2) {\n  RETVAL_NULL();\n}\n");
    if (magic_get) {
      Append(f->code, magic_get);
    }
    Printf(f->code, "\nelse if (strcmp(ZSTR_VAL(arg2),\"thisown\") == 0) {\n");
    Printf(f->code, "if(arg->newobject) {\nRETVAL_LONG(1);\n}\nelse {\nRETVAL_LONG(0);\n}\n}\n\n");
    Printf(f->code, "else {\n");
    if (base_class) {
      Printf(f->code, "PHP_MN(%s%s___get)(INTERNAL_FUNCTION_PARAM_PASSTHRU);\n}\n", prefix, base_class);
    } else {
      // __get is only called if the property isn't set on the zend_object.
      Printf(f->code, "RETVAL_NULL();\n}\n");
    }

    Printf(f->code, "fail:\n");
    Printf(f->code, "return;\n");
    Printf(f->code, "}\n\n\n");


    Printf(f_h, "PHP_METHOD(%s%s,__isset);\n", prefix, class_name);
    Printf(all_cs_entry, " PHP_ME(%s%s,__isset,swig_arginfo_1,ZEND_ACC_PUBLIC)\n", prefix, class_name);
    Printf(f->code, "PHP_METHOD(%s%s,__isset) {\n",prefix, class_name);

    Printf(f->code, "  swig_object_wrapper *arg = SWIG_Z_FETCH_OBJ_P(ZEND_THIS);\n", class_name);
    Printf(f->code, "  zval args[1];\n  zend_string *arg2 = 0;\n\n");
    Printf(f->code, "  if(ZEND_NUM_ARGS() != 1 || zend_get_parameters_array_ex(1, args) != SUCCESS) {\n");
    Printf(f->code, "\tWRONG_PARAM_COUNT;\n}\n\n");
    Printf(f->code, "  if(!arg) {\n");
    Printf(f->code, "    zend_throw_exception(zend_ce_type_error, \"this pointer is NULL\", 0);\n");
    Printf(f->code, "  }\n");
    Printf(f->code, "  arg2 = Z_STR(args[0]);\n\n");

    Printf(f->code, "if (!arg2) {\n  RETVAL_FALSE;\n}\n");
    Printf(f->code, "\nelse if (strcmp(ZSTR_VAL(arg2),\"thisown\") == 0) {\n");
    Printf(f->code, "RETVAL_TRUE;\n}\n\n");
    if (magic_isset) {
      Append(f->code, magic_isset);
    }
    Printf(f->code, "else {\n");
    if (base_class) {
      Printf(f->code, "PHP_MN(%s%s___isset)(INTERNAL_FUNCTION_PARAM_PASSTHRU);\n}\n", prefix, base_class);
    } else {
      // __isset is only called if the property isn't set on the zend_object.
      Printf(f->code, "RETVAL_FALSE;\n}\n");
    }

    Printf(f->code, "fail:\n");
    Printf(f->code, "return;\n");
    Printf(f->code, "}\n\n\n");

    Wrapper_print(f, s_wrappers);
    DelWrapper(f);
    f = NULL;

    Delete(magic_set);
    Delete(magic_get);
    Delete(magic_isset);
    magic_set = NULL;
    magic_get = NULL;
    magic_isset = NULL;
  }

  String *getAccessMode(String *access) {
    if (Cmp(access, "protected") == 0) {
      return NewString("ZEND_ACC_PROTECTED");
    } else if (Cmp(access, "private") == 0) {
      return NewString("ZEND_ACC_PRIVATE");
    }
    return NewString("ZEND_ACC_PUBLIC");
  }

  bool is_setter_method(Node *n) {

    const char *p = GetChar(n, "sym:name");
      if (strlen(p) > 4) {
        p += strlen(p) - 4;
        if (strcmp(p, "_set") == 0) {
          return true;
        }
      }
      return false;
  }

  bool is_getter_method(Node *n) {

    const char *p = GetChar(n, "sym:name");
      if (strlen(p) > 4) {
        p += strlen(p) - 4;
        if (strcmp(p, "_get") == 0) {
          return true;
        }
      }
      return false;
  }

  virtual int functionWrapper(Node *n) {
    if (wrapperType == directordisown) {
      // Handled via __set magic method - no explicit wrapper method wanted.
      return SWIG_OK;
    }
    String *name = GetChar(n, "name");
    String *iname = GetChar(n, "sym:name");
    SwigType *d = Getattr(n, "type");
    ParmList *l = Getattr(n, "parms");
    String *nodeType = Getattr(n, "nodeType");
    int newobject = GetFlag(n, "feature:new");
    int constructor = (Cmp(nodeType, "constructor") == 0);

    Parm *p;
    int i;
    int numopt;
    String *tm;
    Wrapper *f;

    String *wname = NewStringEmpty();
    String *overloadwname = NULL;
    int overloaded = 0;
    String *overname = 0;
    String *modes = NULL;
    bool static_setter = false;
    bool static_getter = false;

    modes = getAccessMode(Getattr(n, "access"));

    if (constructor) {
      Append(modes, " | ZEND_ACC_CTOR");
    } 
    if (wrapperType == staticmemberfn || Cmp(Getattr(n, "storage"), "static") == 0) {
      Append(modes, " | ZEND_ACC_STATIC");
    }
    if (GetFlag(n, "abstract") && Swig_directorclass(Swig_methodclass(n)) && !is_member_director(n))
      Append(modes, " | ZEND_ACC_ABSTRACT");

    if (Getattr(n, "sym:overloaded")) {
      overloaded = 1;
      overname = Getattr(n, "sym:overname");
    } else {
      if (!addSymbol(iname, n))
	return SWIG_ERROR;
    }

    if (overname) {
      // Test for overloading
      overloadwname = NewString(Swig_name_wrapper(iname));
      Printf(overloadwname, "%s", overname);
    }

    if (constructor) {
      wname = NewString("__construct");
    } else if (wrapperType == membervar) {
      wname = Copy(Getattr(n, "membervariableHandler:sym:name"));
      if (is_setter_method(n)) {
        Append(wname, "_set");
      } else if (is_getter_method(n)) {
        Append(wname, "_get");
      }
    } else if (wrapperType == memberfn) {
      wname = Getattr(n, "memberfunctionHandler:sym:name");
    } else if (wrapperType == staticmembervar) {
      // Shape::nshapes -> nshapes
      wname = Getattr(n, "staticmembervariableHandler:sym:name");

      /* We get called twice for getter and setter methods. But to maintain
         compatibility, Shape::nshapes() is being used for both setter and 
         getter methods. So using static_setter and static_getter variables
         to generate half of the code each time.
       */
      static_setter = is_setter_method(n);

      if (is_getter_method(n)) {
        // This is to overcome types that can't be set and hence no setter.
        if (Cmp(Getattr(n, "feature:immutable"), "1") != 0)
          static_getter = true;
      }
    } else if (wrapperType == staticmemberfn) {
      wname = Getattr(n, "staticmemberfunctionHandler:sym:name");
    } else {
      if (class_name) {
        if (Cmp(Getattr(n, "storage"), "friend") == 0 && Cmp(Getattr(n, "view"), "globalfunctionHandler") == 0) {
          wname = iname;
        } else {
          wname = Getattr(n, "destructorHandler:sym:name");
        }
      } else {
        wname = iname;
      }
    }

    if (Cmp(nodeType, "destructor") == 0) {
      // We don't explicitly wrap the destructor for PHP - Zend manages the
      // reference counting, and the user can just do `$obj = null;' or similar
      // to remove a reference to an object.
      return SWIG_OK;
    }

    f = NewWrapper();

    if (static_getter) {
      Printf(f->def, "{\n");
    }

    String *outarg = NewStringEmpty();
    String *cleanup = NewStringEmpty();

    if (!overloaded) {
      if (!static_getter) {
        if (class_name && Cmp(Getattr(n, "storage"), "friend") != 0) {
          Printv(f->def, "PHP_METHOD(", prefix, class_name, ",", wname, ") {\n", NIL);
        } else {
	  if (wrap_nonclass_global) {
	    Printv(f->def, "PHP_METHOD(", fake_class_name(), ",", wname, ") {\n",
			   "  PHP_FN(", wname, ")(INTERNAL_FUNCTION_PARAM_PASSTHRU);\n",
			   "}\n\n", NIL);
	  }

	  if (wrap_nonclass_fake_class) {
	    Printv(f->def, "PHP_FUNCTION(", wname, ") {\n", NIL);
	  }
        }
      }
    } else {
      Printv(f->def, "ZEND_NAMED_FUNCTION(", overloadwname, ") {\n", NIL);
    }

    emit_parameter_variables(l, f);
    /* Attach standard typemaps */

    emit_attach_parmmaps(l, f);
    // Not issued for overloaded functions.
    if (!overloaded && !static_getter) {
      create_command(class_name, wname, n, false, modes);
    }

    if (wrapperType == memberfn || wrapperType == membervar) {
      // Assign "this" to arg1 and remove first entry from ParmList l.
      Printf(f->code, "arg1 = (%s)SWIG_Z_FETCH_OBJ_P(ZEND_THIS)->ptr;\n", SwigType_lstr(Getattr(l, "type"), ""));
      l = nextSibling(l);
    }

    // wrap:parms is used by overload resolution.
    Setattr(n, "wrap:parms", l);

    int num_arguments = emit_num_arguments(l);
    int num_required = emit_num_required(l);
    numopt = num_arguments - num_required;

    if (num_arguments > 0) {
      String *args = NewStringEmpty();
      Printf(args, "zval args[%d]", num_arguments);
      Wrapper_add_local(f, "args", args);
      Delete(args);
      args = NULL;
    }
    if (wrapperType == directorconstructor) {
      Wrapper_add_local(f, "arg0", "zval *arg0 = ZEND_THIS");
    }

    // This generated code may be called:
    // 1) as an object method, or
    // 2) as a class-method/function (without a "this_ptr")
    // Option (1) has "this_ptr" for "this", option (2) needs it as
    // first parameter

    // NOTE: possible we ignore this_ptr as a param for native constructor

    if (numopt > 0) {		// membervariable wrappers do not have optional args
      Wrapper_add_local(f, "arg_count", "int arg_count");
      Printf(f->code, "arg_count = ZEND_NUM_ARGS();\n");
      Printf(f->code, "if(arg_count<%d || arg_count>%d ||\n", num_required, num_arguments);
      Printf(f->code, "   zend_get_parameters_array_ex(arg_count,args)!=SUCCESS)\n");
      Printf(f->code, "\tWRONG_PARAM_COUNT;\n\n");
    } else if (static_setter || static_getter) {
      if (num_arguments == 0) {
        Printf(f->code, "if(ZEND_NUM_ARGS() == 0) {\n");
      } else {
        Printf(f->code, "if(ZEND_NUM_ARGS() == %d && zend_get_parameters_array_ex(%d, args) == SUCCESS) {\n", num_arguments, num_arguments);
      }
    } else {
      if (num_arguments == 0) {
	Printf(f->code, "if(ZEND_NUM_ARGS() != 0) {\n");
      } else {
	Printf(f->code, "if(ZEND_NUM_ARGS() != %d || zend_get_parameters_array_ex(%d, args) != SUCCESS) {\n", num_arguments, num_arguments);
      }
      Printf(f->code, "WRONG_PARAM_COUNT;\n}\n\n");
    }

    /* Now convert from PHP to C variables */
    // At this point, argcount if used is the number of deliberately passed args
    // not including this_ptr even if it is used.
    // It means error messages may be out by argbase with error
    // reports.  We can either take argbase into account when raising
    // errors, or find a better way of dealing with _thisptr.
    // I would like, if objects are wrapped, to assume _thisptr is always
    // _this and not the first argument.
    // This may mean looking at Language::memberfunctionHandler

    for (i = 0, p = l; i < num_arguments; i++) {
      String *source;

      /* Skip ignored arguments */
      //while (Getattr(p,"tmap:ignore")) { p = Getattr(p,"tmap:ignore:next");}
      while (checkAttribute(p, "tmap:in:numinputs", "0")) {
	p = Getattr(p, "tmap:in:next");
      }

      SwigType *pt = Getattr(p, "type");

      source = NewStringf("args[%d]", i);

      /* Check if optional */
      if (i >= num_required) {
	Printf(f->code, "\tif(arg_count > %d) {\n", i);
      }

      String *paramType_class = NULL;
      bool paramType_valid = is_class(pt);

      if (paramType_valid) {
        paramType_class = get_class_name(pt);
        Chop(paramType_class);
      }

      if ((tm = Getattr(p, "tmap:in"))) {
	Replaceall(tm, "$input", source);
	Setattr(p, "emit:input", source);
	Printf(f->code, "%s\n", tm);
	if (i == 0 && Getattr(p, "self")) {
	  Printf(f->code, "\tif(!arg1) {\n");
	  Printf(f->code, "\t  zend_throw_exception(zend_ce_type_error, \"this pointer is NULL\", 0);\n");
	  Printf(f->code, "\t  return;\n");
	  Printf(f->code, "\t}\n");
	}
	p = Getattr(p, "tmap:in:next");
	if (i >= num_required) {
	  Printf(f->code, "}\n");
	}
	continue;
      } else {
	Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, "Unable to use type %s as a function argument.\n", SwigType_str(pt, 0));
      }
      if (i >= num_required) {
	Printf(f->code, "\t}\n");
      }
      Delete(source);
    }

    if (is_member_director(n)) {
      Wrapper_add_local(f, "upcall", "bool upcall = false");
      Printf(f->code, "upcall = !Swig::Director::swig_is_overridden_method(\"%s%s\", ZEND_THIS);\n",
	  prefix, Swig_class_name(Swig_methodclass(n)));
    }

    Swig_director_emit_dynamic_cast(n, f);

    /* Insert constraint checking code */
    for (p = l; p;) {
      if ((tm = Getattr(p, "tmap:check"))) {
	Printv(f->code, tm, "\n", NIL);
	p = Getattr(p, "tmap:check:next");
      } else {
	p = nextSibling(p);
      }
    }

    /* Insert cleanup code */
    for (i = 0, p = l; p; i++) {
      if ((tm = Getattr(p, "tmap:freearg"))) {
	Printv(cleanup, tm, "\n", NIL);
	p = Getattr(p, "tmap:freearg:next");
      } else {
	p = nextSibling(p);
      }
    }

    /* Insert argument output code */
    for (i = 0, p = l; p; i++) {
      if ((tm = Getattr(p, "tmap:argout")) && Len(tm)) {
	Replaceall(tm, "$result", "return_value");
	Replaceall(tm, "$arg", Getattr(p, "emit:input"));
	Replaceall(tm, "$input", Getattr(p, "emit:input"));
	Printv(outarg, tm, "\n", NIL);
	p = Getattr(p, "tmap:argout:next");
      } else {
	p = nextSibling(p);
      }
    }

    if (!overloaded) {
      Setattr(n, "wrap:name", wname);
    } else {
      Setattr(n, "wrap:name", overloadwname);
    }
    Setattr(n, "wrapper:method:name", wname);

    bool php_constructor = (constructor && Cmp(class_name, Getattr(n, "constructorHandler:sym:name")) == 0);

    /* emit function call */
    String *actioncode = emit_action(n);

    if ((tm = Swig_typemap_lookup_out("out", n, Swig_cresult_name(), f, actioncode))) {
      Replaceall(tm, "$input", Swig_cresult_name());
      Replaceall(tm, "$result", php_constructor ? "ZEND_THIS" : "return_value");
      Replaceall(tm, "$owner", newobject ? "1" : "0");
      Printf(f->code, "%s\n", tm);
    } else {
      Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to use return type %s in function %s.\n", SwigType_str(d, 0), name);
    }
    emit_return_variable(n, d, f);

    if (outarg) {
      Printv(f->code, outarg, NIL);
    }

    if (cleanup) {
      Printv(f->code, cleanup, NIL);
    }

    /* Look to see if there is any newfree cleanup code */
    if (GetFlag(n, "feature:new")) {
      if ((tm = Swig_typemap_lookup("newfree", n, Swig_cresult_name(), 0))) {
	Printf(f->code, "%s\n", tm);
	Delete(tm);
      }
    }

    /* See if there is any return cleanup code */
    if ((tm = Swig_typemap_lookup("ret", n, Swig_cresult_name(), 0))) {
      Printf(f->code, "%s\n", tm);
      Delete(tm);
    }

    if (static_getter) {
      Printf(f->code, "}\n");
    }

    if (static_setter || static_getter) {
      Printf(f->code, "}\n");
    }

    if (!static_setter) {
      Printf(f->code, "fail:\n");
      Printv(f->code, cleanup, NIL);
      Printf(f->code, "return;\n");
      Printf(f->code, "}\n");
    }

    Replaceall(f->code, "$cleanup", cleanup);
    Replaceall(f->code, "$symname", iname);

    Wrapper_print(f, s_wrappers);
    DelWrapper(f);
    f = NULL;
    wname = NULL;

    if (overloaded && !Getattr(n, "sym:nextSibling")) {
      dispatchFunction(n, constructor);
    }

    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * globalvariableHandler()
   * ------------------------------------------------------------ */

  /* PHP doesn't support intercepting reads and writes to global variables
   * (nor static property reads and writes so we can't wrap them as static
   * properties on a dummy class) so just let SWIG do its default thing and
   * wrap them as name_get() and name_set().
   */
  //virtual int globalvariableHandler(Node *n) {
  //}

  /* ------------------------------------------------------------
   * constantWrapper()
   * ------------------------------------------------------------ */

  virtual int constantWrapper(Node *n) {
    String *name = GetChar(n, "name");
    String *iname = GetChar(n, "sym:name");
    SwigType *type = Getattr(n, "type");
    String *rawval = Getattr(n, "rawval");
    String *value = rawval ? rawval : Getattr(n, "value");
    String *tm;

    if (!addSymbol(iname, n))
      return SWIG_ERROR;

    SwigType_remember(type);

    if (!wrapping_member_constant) {
      {
	tm = Swig_typemap_lookup("consttab", n, name, 0);
	Replaceall(tm, "$value", value);
        if (Getattr(n, "tmap:consttab:rinit")) {
          Printf(r_init, "%s\n", tm);
        } else {
          Printf(s_cinit, "%s\n", tm);
        }
      }

      {
        tm = Swig_typemap_lookup("classconsttab", n, name, 0);

        Replaceall(tm, "$class", fake_class_name());
        Replaceall(tm, "$const_name", iname);
	Replaceall(tm, "$value", value);
        if (Getattr(n, "tmap:classconsttab:rinit")) {
          Printf(r_init, "%s\n", tm);
        } else {
          Printf(s_cinit, "%s\n", tm);
        }
      }
    } else {
      tm = Swig_typemap_lookup("classconsttab", n, name, 0);
      Replaceall(tm, "$class", class_name);
      Replaceall(tm, "$const_name", wrapping_member_constant);
      Replaceall(tm, "$value", value);
      if (Getattr(n, "tmap:classconsttab:rinit")) {
        Printf(r_init, "%s\n", tm);
      } else {
        Printf(s_cinit, "%s\n", tm);
      }
    }

    wrapperType = standard;
    return SWIG_OK;
  }

  /*
   * PHP::pragma()
   *
   * Pragma directive.
   *
   * %pragma(php) code="String"         # Includes a string in the .php file
   * %pragma(php) include="file.php"    # Includes a file in the .php file
   */

  virtual int pragmaDirective(Node *n) {
    if (!ImportMode) {
      String *lang = Getattr(n, "lang");
      String *type = Getattr(n, "name");
      String *value = Getattr(n, "value");

      if (Strcmp(lang, "php") == 0) {
	if (Strcmp(type, "code") == 0) {
	  if (value) {
	    Printf(pragma_code, "%s\n", value);
	  }
	} else if (Strcmp(type, "include") == 0) {
	  if (value) {
	    Printf(pragma_incl, "include '%s';\n", value);
	  }
	} else if (Strcmp(type, "phpinfo") == 0) {
	  if (value) {
	    Printf(pragma_phpinfo, "%s\n", value);
	  }
	} else if (Strcmp(type, "version") == 0) {
	  if (value) {
	    pragma_version = value;
	  }
	} else {
	  Swig_warning(WARN_PHP_UNKNOWN_PRAGMA, input_file, line_number, "Unrecognized pragma <%s>.\n", type);
	}
      }
    }
    return Language::pragmaDirective(n);
  }

  /* ------------------------------------------------------------
   * classDeclaration()
   * ------------------------------------------------------------ */

  virtual int classDeclaration(Node *n) {
    if (!Getattr(n, "feature:onlychildren")) {
      String *symname = Getattr(n, "sym:name");
      Setattr(n, "php:proxy", symname);
    }

    return Language::classDeclaration(n);
  }

  /* ------------------------------------------------------------
   * classHandler()
   * ------------------------------------------------------------ */

  virtual int classHandler(Node *n) {
    String *symname = Getattr(n, "sym:name");
    String *base_class = NULL;

    class_name = symname;

    Printf(all_cs_entry, "static zend_function_entry class_%s_functions[] = {\n", class_name);

    // namespace code to introduce namespaces into wrapper classes.
    //if (nameSpace != NULL)
      //Printf(s_oinit, "INIT_CLASS_ENTRY(internal_ce, \"%s\\\\%s\", class_%s_functions);\n", nameSpace, class_name, class_name);
    //else
    Printf(s_oinit, "  INIT_CLASS_ENTRY(internal_ce, \"%s%s\", class_%s_functions);\n", prefix, class_name, class_name);

    if (shadow) {
      char *rename = GetChar(n, "sym:name");

      if (!addSymbol(rename, n))
	return SWIG_ERROR;

      /* Deal with inheritance */
      List *baselist = Getattr(n, "bases");
      if (baselist) {
	Iterator base = First(baselist);
	while (base.item) {
	  if (!GetFlag(base.item, "feature:ignore")) {
	    if (!base_class) {
	      base_class = Getattr(base.item, "sym:name");
	    } else {
	      /* Warn about multiple inheritance for additional base class(es) */
	      String *proxyclassname = SwigType_str(Getattr(n, "classtypeobj"), 0);
	      String *baseclassname = SwigType_str(Getattr(base.item, "name"), 0);
	      Swig_warning(WARN_PHP_MULTIPLE_INHERITANCE, input_file, line_number,
			   "Warning for %s, base %s ignored. Multiple inheritance is not supported in PHP.\n", proxyclassname, baseclassname);
	    }
	  }
	  base = Next(base);
	}
      }
    }

    if (GetFlag(n, "feature:exceptionclass") && Getattr(n, "feature:except")) {
      /* PHP requires thrown objects to be instances of or derived from
       * Exception, so that really needs to take priority over any
       * explicit base class.
       */
      if (base_class) {
	String *proxyclassname = SwigType_str(Getattr(n, "classtypeobj"), 0);
	Swig_warning(WARN_PHP_MULTIPLE_INHERITANCE, input_file, line_number,
		     "Warning for %s, base %s ignored. Multiple inheritance is not supported in PHP.\n", proxyclassname, base_class);
      }
      base_class = NewString("Exception");
    }

    if (Equal(base_class, "Exception")) {
      Printf(s_oinit, "  SWIGTYPE_%s_ce = zend_register_internal_class_ex(&internal_ce, zend_ce_exception);\n", class_name);
    } else if (is_class_wrapped(base_class)) {
      Printf(s_oinit, "  SWIGTYPE_%s_ce = zend_register_internal_class_ex(&internal_ce, SWIGTYPE_%s_ce);\n", class_name, base_class);
    } else {
      Printf(s_oinit, "  SWIGTYPE_%s_ce = zend_register_internal_class(&internal_ce);\n", class_name);
    }

    if (Getattr(n, "abstracts") && !GetFlag(n, "feature:notabstract")) {
      Printf(s_oinit, "  SWIGTYPE_%s_ce->ce_flags |= ZEND_ACC_EXPLICIT_ABSTRACT_CLASS;\n", class_name);
    }

    {
      Node *node = NewHash();
      Setattr(node, "type", Getattr(n, "name"));
      Setfile(node, Getfile(n));
      Setline(node, Getline(n));
      String *interfaces = Swig_typemap_lookup("phpinterfaces", node, "", 0);
      Replaceall(interfaces, " ", "");
      if (interfaces && Len(interfaces) > 0) {
	// It seems we need to wait until RINIT time to look up class entries
	// for interfaces by name.  The downside is that this then happens for
	// every request.
	//
	// Most pre-defined interfaces are accessible via zend_class_entry*
	// variables declared in the PHP C API - these we can use at MINIT
	// time, so we special case them.  This will also be a little faster
	// than looking up by name.
	Printv(s_header,
	       "#ifdef __cplusplus\n",
	       "extern \"C\" {\n",
	       "#endif\n",
	       NIL);

	String *r_init_prefix = NewStringEmpty();

	List *interface_list = Split(interfaces, ',', -1);
	int num_interfaces = Len(interface_list);
	for (int i = 0; i < num_interfaces; ++i) {
	  String *interface = Getitem(interface_list, i);
	  // We generate conditional code in both minit and rinit - then we or the user
	  // just need to define SWIG_PHP_INTERFACE_xxx_CE (and optionally
	  // SWIG_PHP_INTERFACE_xxx_CE) to handle interface `xxx` at minit-time.
	  Printv(s_header,
		 "#ifdef SWIG_PHP_INTERFACE_", interface, "_HEADER\n",
		 "# include SWIG_PHP_INTERFACE_", interface, "_HEADER\n",
		 "#endif\n",
		 NIL);
	  Printv(s_oinit,
		 "#ifdef SWIG_PHP_INTERFACE_", interface, "_CE\n",
		 "  zend_do_implement_interface(SWIGTYPE_", class_name, "_ce, SWIG_PHP_INTERFACE_", interface, "_CE);\n",
		 "#endif\n",
		 NIL);
	  Printv(r_init_prefix,
		 "#ifndef SWIG_PHP_INTERFACE_", interface, "_CE\n",
		 "  {\n",
		 "    zend_class_entry *swig_interface_ce = zend_lookup_class(zend_string_init(\"", interface, "\", sizeof(\"", interface, "\") - 1, 0));\n",
		 "    if (!swig_interface_ce) zend_throw_exception(zend_ce_error, \"Interface \\\"", interface, "\\\" not found\", 0);\n",
		 "    zend_do_implement_interface(SWIGTYPE_", class_name, "_ce, swig_interface_ce);\n",
		 "  }\n",
		 "#endif\n",
		 NIL);
	}

	// Handle interfaces at the start of rinit so that they're added
	// before any potential constant objects, etc which might be created
	// later in rinit.
	Insert(r_init, 0, r_init_prefix);
	Delete(r_init_prefix);

	Printv(s_header,
	       "#ifdef __cplusplus\n",
	       "}\n",
	       "#endif\n",
	       NIL);
      }
      Delete(interfaces);
    }

    Printf(s_oinit, "  SWIGTYPE_%s_ce->create_object = %s_object_new;\n", class_name, class_name);
    Printf(s_oinit, "  memcpy(&%s_object_handlers,zend_get_std_object_handlers(), sizeof(zend_object_handlers));\n", class_name);
    Printf(s_oinit, "  %s_object_handlers.clone_obj = NULL;\n", class_name);
    // If not defined we aren't wrapping any functions which use this type as a
    // parameter or return value, in which case we don't need the clientdata
    // set.
    Printf(s_oinit, "#ifdef SWIGTYPE_p%s\n", SwigType_manglestr(Getattr(n, "classtypeobj")));
    Printf(s_oinit, "  SWIG_TypeClientData(SWIGTYPE_p%s,SWIGTYPE_%s_ce);\n", SwigType_manglestr(Getattr(n, "classtypeobj")), class_name);
    Printf(s_oinit, "#endif\n");
    Printf(s_oinit, "\n");

    Language::classHandler(n);

    print_creation_free_wrapper(n);
    generate_magic_property_methods(n, base_class);
    Printf(all_cs_entry, " ZEND_FE_END\n};\n\n");

    class_name = NULL;
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * memberfunctionHandler()
   * ------------------------------------------------------------ */

  virtual int memberfunctionHandler(Node *n) {
    wrapperType = memberfn;
    Language::memberfunctionHandler(n);
    wrapperType = standard;

    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * membervariableHandler()
   * ------------------------------------------------------------ */

  virtual int membervariableHandler(Node *n) {
    if (magic_set == NULL) {
      magic_set = NewStringEmpty();
      magic_get = NewStringEmpty();
      magic_isset = NewStringEmpty();
    }

    String *v_name = GetChar(n, "name");

    Printf(magic_set, "\nelse if (strcmp(ZSTR_VAL(arg2),\"%s\") == 0) {\n", v_name);
    Printf(magic_set, "ZVAL_STRING(&tempZval, \"%s_set\");\n", v_name);
    Printf(magic_set, "call_user_function(EG(function_table),ZEND_THIS,&tempZval,return_value,1,&args[1]);\n}\n");

    Printf(magic_get, "\nelse if (strcmp(ZSTR_VAL(arg2),\"%s\") == 0) {\n", v_name);
    Printf(magic_get, "ZVAL_STRING(&tempZval, \"%s_get\");\n", v_name);
    Printf(magic_get, "call_user_function(EG(function_table),ZEND_THIS,&tempZval,return_value,0,NULL);\n}\n");

    Printf(magic_isset, "\nelse if (strcmp(ZSTR_VAL(arg2),\"%s\") == 0) {\n", v_name);
    Printf(magic_isset, "RETVAL_TRUE;\n}\n");

    wrapperType = membervar;
    Language::membervariableHandler(n);
    wrapperType = standard;

    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * staticmembervariableHandler()
   * ------------------------------------------------------------ */

  virtual int staticmembervariableHandler(Node *n) {
    wrapperType = staticmembervar;
    Language::staticmembervariableHandler(n);
    wrapperType = standard;

    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * staticmemberfunctionHandler()
   * ------------------------------------------------------------ */

  virtual int staticmemberfunctionHandler(Node *n) {
    wrapperType = staticmemberfn;
    Language::staticmemberfunctionHandler(n);
    wrapperType = standard;

    return SWIG_OK;
  }

  int abstractConstructorHandler(Node *) {
    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * constructorHandler()
   * ------------------------------------------------------------ */

  virtual int constructorHandler(Node *n) {
    if (Swig_directorclass(n)) {
      String *ctype = GetChar(Swig_methodclass(n), "classtype");
      String *sname = GetChar(Swig_methodclass(n), "sym:name");
      String *args = NewStringEmpty();
      ParmList *p = Getattr(n, "parms");
      int i;

      for (i = 0; p; p = nextSibling(p), i++) {
	if (i) {
	  Printf(args, ", ");
	}
	if (Strcmp(GetChar(p, "type"), SwigType_str(GetChar(p, "type"), 0))) {
	  SwigType *t = Getattr(p, "type");
	  Printf(args, "%s", SwigType_rcaststr(t, 0));
	  if (SwigType_isreference(t)) {
	    Append(args, "*");
	  }
	}
	Printf(args, "arg%d", i+1);
      }

      /* director ctor code is specific for each class */
      Delete(director_ctor_code);
      director_ctor_code = NewStringEmpty();
      director_prot_ctor_code = NewStringEmpty();
      Printf(director_ctor_code, "if (Swig::Director::swig_is_overridden_method(\"%s\", arg0)) { /* not subclassed */\n", class_name);
      Printf(director_prot_ctor_code, "if (Swig::Director::swig_is_overridden_method(\"%s\", arg0)) { /* not subclassed */\n", class_name);
      Printf(director_ctor_code, "  %s = new %s(%s);\n", Swig_cresult_name(), ctype, args);
      Printf(director_prot_ctor_code,
	     "  zend_throw_exception(zend_ce_type_error, \"accessing abstract class or protected constructor\", 0);\n"
	     "  return;\n");
      if (i) {
	Insert(args, 0, ", ");
      }
      Printf(director_ctor_code, "} else {\n  %s = (%s *)new SwigDirector_%s(arg0%s);\n}\n", Swig_cresult_name(), ctype, sname, args);
      Printf(director_prot_ctor_code, "} else {\n  %s = (%s *)new SwigDirector_%s(arg0%s);\n}\n", Swig_cresult_name(), ctype, sname, args);
      Delete(args);

      wrapperType = directorconstructor;
    } else {
      wrapperType = constructor;
    }
    Language::constructorHandler(n);
    wrapperType = standard;

    return SWIG_OK;
  }

  /* ------------------------------------------------------------
   * destructorHandler()
   * ------------------------------------------------------------ */
  //virtual int destructorHandler(Node *n) {
  //}

  /* ------------------------------------------------------------
   * memberconstantHandler()
   * ------------------------------------------------------------ */

  virtual int memberconstantHandler(Node *n) {
    wrapping_member_constant = Getattr(n, "sym:name");
    Language::memberconstantHandler(n);
    wrapping_member_constant = NULL;
    return SWIG_OK;
  }

  int classDirectorInit(Node *n) {
    String *declaration = Swig_director_declaration(n);
    Printf(f_directors_h, "%s\n", declaration);
    Printf(f_directors_h, "public:\n");
    Delete(declaration);
    return Language::classDirectorInit(n);
  }

  int classDirectorEnd(Node *n) {
    Printf(f_directors_h, "};\n");
    return Language::classDirectorEnd(n);
  }

  int classDirectorConstructor(Node *n) {
    Node *parent = Getattr(n, "parentNode");
    String *decl = Getattr(n, "decl");
    String *supername = Swig_class_name(parent);
    String *classname = NewStringEmpty();
    Printf(classname, "SwigDirector_%s", supername);

    /* insert self parameter */
    Parm *p;
    ParmList *superparms = Getattr(n, "parms");
    ParmList *parms = CopyParmList(superparms);
    String *type = NewString("zval");
    SwigType_add_pointer(type);
    p = NewParm(type, NewString("self"), n);
    set_nextSibling(p, parms);
    parms = p;

    if (!Getattr(n, "defaultargs")) {
      // There should always be a "self" parameter first.
      assert(ParmList_len(parms) > 0);

      /* constructor */
      {
	Wrapper *w = NewWrapper();
	String *call;
	String *basetype = Getattr(parent, "classtype");

	String *target = Swig_method_decl(0, decl, classname, parms, 0);
	call = Swig_csuperclass_call(0, basetype, superparms);
	Printf(w->def, "%s::%s: %s, Swig::Director(self) {", classname, target, call);
	Append(w->def, "}");
	Delete(target);
	Wrapper_print(w, f_directors);
	Delete(call);
	DelWrapper(w);
      }

      /* constructor header */
      {
	String *target = Swig_method_decl(0, decl, classname, parms, 1);
	Printf(f_directors_h, "    %s;\n", target);
	Delete(target);
      }
    }
    return Language::classDirectorConstructor(n);
  }

  int classDirectorMethod(Node *n, Node *parent, String *super) {
    int is_void = 0;
    int is_pointer = 0;
    String *decl = Getattr(n, "decl");
    String *returntype = Getattr(n, "type");
    String *name = Getattr(n, "name");
    String *classname = Getattr(parent, "sym:name");
    String *c_classname = Getattr(parent, "name");
    String *symname = Getattr(n, "sym:name");
    String *declaration = NewStringEmpty();
    ParmList *l = Getattr(n, "parms");
    Wrapper *w = NewWrapper();
    String *tm;
    String *wrap_args = NewStringEmpty();
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

    /* determine if the method returns a pointer */
    is_pointer = SwigType_ispointer_return(decl);
    is_void = (Cmp(returntype, "void") == 0 && !is_pointer);

    /* virtual method definition */
    String *target;
    String *pclassname = NewStringf("SwigDirector_%s", classname);
    String *qualified_name = NewStringf("%s::%s", pclassname, name);
    SwigType *rtype = Getattr(n, "conversion_operator") ? 0 : Getattr(n, "classDirectorMethods:type");
    target = Swig_method_decl(rtype, decl, qualified_name, l, 0);
    Printf(w->def, "%s", target);
    Delete(qualified_name);
    Delete(target);
    /* header declaration */
    target = Swig_method_decl(rtype, decl, name, l, 1);
    Printf(declaration, "    virtual %s", target);
    Delete(target);

    // Get any exception classes in the throws typemap
    if (Getattr(n, "noexcept")) {
      Append(w->def, " noexcept");
      Append(declaration, " noexcept");
    }
    ParmList *throw_parm_list = 0;

    if ((throw_parm_list = Getattr(n, "throws")) || Getattr(n, "throw")) {
      Parm *p;
      int gencomma = 0;

      Append(w->def, " throw(");
      Append(declaration, " throw(");

      if (throw_parm_list)
	Swig_typemap_attach_parms("throws", throw_parm_list, 0);
      for (p = throw_parm_list; p; p = nextSibling(p)) {
	if (Getattr(p, "tmap:throws")) {
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

    /* declare method return value 
     * if the return value is a reference or const reference, a specialized typemap must
     * handle it, including declaration of c_result ($result).
     */
    if (!is_void && (!ignored_method || pure_virtual)) {
      if (!SwigType_isclass(returntype)) {
	if (!(SwigType_ispointer(returntype) || SwigType_isreference(returntype))) {
	  String *construct_result = NewStringf("= SwigValueInit< %s >()", SwigType_lstr(returntype, 0));
	  Wrapper_add_localv(w, "c_result", SwigType_lstr(returntype, "c_result"), construct_result, NIL);
	  Delete(construct_result);
	} else {
	  Wrapper_add_localv(w, "c_result", SwigType_lstr(returntype, "c_result"), "= 0", NIL);
	}
      } else {
	String *cres = SwigType_lstr(returntype, "c_result");
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
      /* attach typemaps to arguments (C/C++ -> PHP) */
      Swig_director_parms_fixup(l);

      /* remove the wrapper 'w' since it was producing spurious temps */
      Swig_typemap_attach_parms("in", l, 0);
      Swig_typemap_attach_parms("directorin", l, w);
      Swig_typemap_attach_parms("directorargout", l, w);

      Parm *p;

      int outputs = 0;
      if (!is_void)
	outputs++;

      /* build argument list and type conversion string */
      idx = 0;
      p = l;
      while (p) {
	if (checkAttribute(p, "tmap:in:numinputs", "0")) {
	  p = Getattr(p, "tmap:in:next");
	  continue;
	}

	if (Getattr(p, "tmap:directorargout") != 0)
	  outputs++;

	String *pname = Getattr(p, "name");
	String *ptype = Getattr(p, "type");

	if ((tm = Getattr(p, "tmap:directorin")) != 0) {
	  String *parse = Getattr(p, "tmap:directorin:parse");
	  if (!parse) {
	    String *input = NewStringf("&args[%d]", idx++);
	    Setattr(p, "emit:directorinput", input);
	    Replaceall(tm, "$input", input);
	    Delete(input);
	    Replaceall(tm, "$owner", "0");
	    Printv(wrap_args, tm, "\n", NIL);
	  } else {
	    Setattr(p, "emit:directorinput", pname);
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

      if (!idx) {
	Printf(w->code, "zval *args = NULL;\n");
      } else {
	Printf(w->code, "zval args[%d];\n", idx);
      }
      // typemap_directorout testcase requires that 0 can be assigned to the
      // variable named after the result of Swig_cresult_name(), so that can't
      // be a zval - make it a pointer to one instead.
      Printf(w->code, "zval swig_zval_result;\n");
      Printf(w->code, "zval * SWIGUNUSED %s = &swig_zval_result;\n", Swig_cresult_name());

      /* wrap complex arguments to zvals */
      Append(w->code, wrap_args);

      const char * funcname = GetChar(n, "sym:name");
      Append(w->code, "{\n");
      Append(w->code, "#if PHP_MAJOR_VERSION < 8\n");
      Printf(w->code, "zval swig_funcname;\n");
      Printf(w->code, "ZVAL_STRINGL(&swig_funcname, \"%s\", %d);\n", funcname, strlen(funcname));
      Printf(w->code, "call_user_function(EG(function_table), &swig_self, &swig_funcname, &swig_zval_result, %d, args);\n", idx);
      Append(w->code, "#else\n");
      Printf(w->code, "zend_string *swig_funcname = zend_string_init(\"%s\", %d, 0);\n", funcname, strlen(funcname));
      Append(w->code, "zend_function *swig_zend_func = zend_std_get_method(&Z_OBJ(swig_self), swig_funcname, NULL);\n");
      Append(w->code, "zend_string_release(swig_funcname);\n");
      Printf(w->code, "if (swig_zend_func) zend_call_known_instance_method(swig_zend_func, Z_OBJ(swig_self), &swig_zval_result, %d, args);\n", idx);
      Append(w->code, "#endif\n");

      /* exception handling */
      tm = Swig_typemap_lookup("director:except", n, Swig_cresult_name(), 0);
      if (!tm) {
	tm = Getattr(n, "feature:director:except");
	if (tm)
	  tm = Copy(tm);
      }
      if ((tm) && Len(tm) && (Strcmp(tm, "1") != 0)) {
	Replaceall(tm, "$error", "EG(exception)");
	Printv(w->code, Str(tm), "\n", NIL);
      }
      Append(w->code, "}\n");
      Delete(tm);

      /* marshal return value from PHP to C/C++ type */

      String *cleanup = NewStringEmpty();
      String *outarg = NewStringEmpty();

      idx = 0;

      /* marshal return value */
      if (!is_void) {
	tm = Swig_typemap_lookup("directorout", n, Swig_cresult_name(), w);
	if (tm != 0) {
	  Replaceall(tm, "$input", Swig_cresult_name());
	  char temp[24];
	  sprintf(temp, "%d", idx);
	  Replaceall(tm, "$argnum", temp);

	  /* TODO check this */
	  if (Getattr(n, "wrap:disown")) {
	    Replaceall(tm, "$disown", "SWIG_POINTER_DISOWN");
	  } else {
	    Replaceall(tm, "$disown", "0");
	  }
	  Replaceall(tm, "$result", "c_result");
	  Printv(w->code, tm, "\n", NIL);
	  Delete(tm);
	} else {
	  Swig_warning(WARN_TYPEMAP_DIRECTOROUT_UNDEF, input_file, line_number,
		       "Unable to use return type %s in director method %s::%s (skipping method).\n", SwigType_str(returntype, 0),
		       SwigType_namestr(c_classname), SwigType_namestr(name));
	  status = SWIG_ERROR;
	}
      }

      /* marshal outputs */
      for (p = l; p;) {
	if ((tm = Getattr(p, "tmap:directorargout")) != 0) {
	  Replaceall(tm, "$result", Swig_cresult_name());
	  Replaceall(tm, "$input", Getattr(p, "emit:directorinput"));
	  Printv(w->code, tm, "\n", NIL);
	  p = Getattr(p, "tmap:directorargout:next");
	} else {
	  p = nextSibling(p);
	}
      }

      Delete(cleanup);
      Delete(outarg);
    }

    Append(w->code, "fail: ;\n");
    if (!is_void) {
      if (!(ignored_method && !pure_virtual)) {
	String *rettype = SwigType_str(returntype, 0);
	if (!SwigType_isreference(returntype)) {
	  Printf(w->code, "return (%s) c_result;\n", rettype);
	} else {
	  Printf(w->code, "return (%s) *c_result;\n", rettype);
	}
	Delete(rettype);
      }
    }
    Append(w->code, "}\n");

    // We expose protected methods via an extra public inline method which makes a straight call to the wrapped class' method
    String *inline_extra_method = NewStringEmpty();
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

    /* emit the director method */
    if (status == SWIG_OK) {
      if (!Getattr(n, "defaultargs")) {
	Replaceall(w->code, "$symname", symname);
	Wrapper_print(w, f_directors);
	Printv(f_directors_h, declaration, NIL);
	Printv(f_directors_h, inline_extra_method, NIL);
      }
    }

    /* clean up */
    Delete(wrap_args);
    Delete(pclassname);
    DelWrapper(w);
    return status;
  }

  int classDirectorDisown(Node *n) {
    wrapperType = directordisown;
    int result = Language::classDirectorDisown(n);
    wrapperType = standard;
    return result;
  }
};				/* class PHP */

static PHP *maininstance = 0;

// Collect non-class pointer types from the type table so we can set up PHP
// resource types for them later.
//
// NOTE: it's a function NOT A PHP::METHOD
extern "C" {
static void typetrace(const SwigType *ty, String *mangled, String *clientdata) {
  if (maininstance->classLookup(ty) == NULL) {
    // a non-class pointer
    if (!zend_types) {
      zend_types = NewHash();
    }
    Setattr(zend_types, mangled, mangled);
  }
  if (r_prevtracefunc)
    (*r_prevtracefunc) (ty, mangled, clientdata);
}
}

/* -----------------------------------------------------------------------------
 * new_swig_php()    - Instantiate module
 * ----------------------------------------------------------------------------- */

static Language *new_swig_php() {
  maininstance = new PHP;
  if (!r_prevtracefunc) {
    r_prevtracefunc = SwigType_remember_trace(typetrace);
  } else {
    Printf(stderr, "php Typetrace vector already saved!\n");
    assert(0);
  }
  return maininstance;
}

extern "C" Language *swig_php(void) {
  return new_swig_php();
}
