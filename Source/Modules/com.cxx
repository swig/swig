/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * com.cxx
 *
 * COM module for SWIG.
 * ----------------------------------------------------------------------------- */

char cvsroot_com_cxx[] = "$Id$";

#include "swigmod.h"
#include "cparse.h"
#include <stdio.h>

typedef struct {
  unsigned long Data1;
  unsigned short Data2;
  unsigned short Data3;
  unsigned char Data4[8];
} GUID, UUID;

bool isNilGUID(GUID *arg) {
  if (arg->Data1 != 0 || arg->Data2 != 0 || arg->Data3 != 0)
    return false;

  for (int i = 0; i < 8; ++i)
    if (arg->Data4[i] != 0)
      return false;

  return true;
}

typedef struct {
  unsigned char octets[20];
} SHA1_hash;

/* Rotate left a 32-bit number */
unsigned int leftrot(unsigned int a, unsigned int pos) {
  return (a << pos) | ((a >> (32 - pos)) & ((1 << pos) - 1));
}

/* Implementation of SHA1. Needs unsigned int with at least 32 bits */
SHA1_hash SHA1(char *input_bytes, int input_len) {
  unsigned int h0 = 0x67452301;
  unsigned int h1 = 0xEFCDAB89;
  unsigned int h2 = 0x98BADCFE;
  unsigned int h3 = 0x10325476;
  unsigned int h4 = 0xC3D2E1F0;

  /*
   * Preprocessing: a '1'-bit is appended, followed by '0'-bits
   * until the number of bits % 512 == 448. Then the input's length
   * in bits is appended as a 64-bit number. The preprocessed input's
   * length is a multiple of 512 bits (64 bytes). Please note
   * that below the counting is in bytes instead of bits.
   */
  unsigned int padding = ((64 + 56) - (input_len + 1) % 64) % 64;
  unsigned int total_len = input_len + 1 + padding + 8;
  /* Preprocessed input */
  unsigned char *prep = new unsigned char[total_len];

  /* Copy the input to prep */
  for (unsigned int i = 0; i < input_len; ++i)
    prep[i] = input_bytes[i];

  /* Marker with single '1'-bit in most significant position */
  prep[input_len] = 0x80;

  /* Pad with 0's */
  for (unsigned int i = 0; i < padding; ++i)
    prep[input_len + 1 + i] = 0;

  /* Finally append 8 * input_len as a 64-bit number in big-endian format */
  unsigned int high_dword = (input_len >> 29) & 7;
  unsigned int low_dword = (input_len & ((1 << 29) - 1)) << 3;

  prep[total_len - 8] = high_dword >> 24;
  prep[total_len - 7] = (high_dword >> 16) & 0xff;
  prep[total_len - 6] = (high_dword >> 8) & 0xff;
  prep[total_len - 5] = high_dword & 0xff;
  prep[total_len - 4] = low_dword >> 24;
  prep[total_len - 3] = (low_dword >> 16) & 0xff;
  prep[total_len - 2] = (low_dword >> 8) & 0xff;
  prep[total_len - 1] = low_dword & 0xff;

  /* Divide preprocessed input into 512 bit chunks */
  for (unsigned int chunk = 0; chunk < total_len / 64; ++chunk) {
    unsigned int w[80];

    for (int i = 0; i < 16; ++i) {
      w[i] = ((unsigned int) prep[64 * chunk + 4 * i] << 24) |
          ((unsigned int) prep[64 * chunk + 4 * i + 1] << 16) |
          ((unsigned int) prep[64 * chunk + 4 * i + 2] << 8) |
          (unsigned int) prep[64 * chunk + 4 * i + 3];
    }

    for (int i = 16; i < 80; ++i) {
      w[i] = leftrot(w[i-3] ^ w[i-8] ^ w[i-14] ^ w[i-16], 1);
    }

    unsigned int a = h0;
    unsigned int b = h1;
    unsigned int c = h2;
    unsigned int d = h3;
    unsigned int e = h4;

    for (int i = 0; i < 80; ++i) {
      unsigned int f, k;

      if (i < 20) {
        f = (b & c) | (~b & d);
        k = 0x5A827999;
      } else if (i < 40) {
        f = b ^ c ^ d;
        k = 0x6ED9EBA1;
      } else if (i < 60) {
        f = (b & c) | (b & d) | (c & d);
        k = 0x8F1BBCDC;
      } else {
        f = b ^ c ^ d;
        k = 0xCA62C1D6;
      }

      int temp = leftrot(a, 5) + f + e + k + w[i];
      e = d;
      d = c;
      c = leftrot(b, 30);      
      b = a;
      a = temp;
    }

    h0 = h0 + a;
    h1 = h1 + b;
    h2 = h2 + c;
    h3 = h3 + d;
    h4 = h4 + e;
  }

  delete prep;

  SHA1_hash res = {
      (h0 >> 24) & 0xff, (h0 >> 16) & 0xff, (h0 >> 8) & 0xff, h0 & 0xff,
      (h1 >> 24) & 0xff, (h1 >> 16) & 0xff, (h1 >> 8) & 0xff, h1 & 0xff,
      (h2 >> 24) & 0xff, (h2 >> 16) & 0xff, (h2 >> 8) & 0xff, h2 & 0xff,
      (h3 >> 24) & 0xff, (h3 >> 16) & 0xff, (h3 >> 8) & 0xff, h3 & 0xff,
      (h4 >> 24) & 0xff, (h4 >> 16) & 0xff, (h4 >> 8) & 0xff, h4 & 0xff,
  };

  return res;
}

class COM:public Language {
  static const char *usage;
  const String *empty_string;

  Hash *swig_types_hash;
  List *filenames_list;

  File *f_runtime;
  File *f_header;
  File *f_module;
  File *f_deffile;
  File *f_rcfile;
  File *f_wrappers;
  File *f_proxy;
  File *f_proxy_forward_defs;
  File *f_vtables;
  File *f_vtable_defs;
  File *f_factory;
  File *f_directors;

  bool proxy_flag;		// Flag for generating proxy classes
  bool dllexports_flag;
  bool deffile_flag;
  bool rcfile_flag;
  bool hresult_flag;            // Flag specifying whether to use HRESULT as return type
  bool enum_constant_flag;	// Flag for when wrapping an enum or constant
  bool static_flag;		// Flag for when wrapping a static functions or member variables
  bool variable_wrapper_flag;	// Flag for when wrapping a nonstatic member variable
  bool wrapping_member_flag;	// Flag for when wrapping a member variable/enum/const
  bool global_variable_flag;	// Flag for when wrapping a global variable
  bool generate_property_declaration_flag;	// Flag for generating properties
  bool member_func_flag;
  bool constructor_flag;

  String *proxy_class_def;
  String *proxy_static_class_def;
  String *proxy_class_forward_def;
  String *proxy_class_code;
  String *proxy_static_class_code;
  String *proxy_class_name;
  String *proxy_class_constants_code;
  String *clsid_list;
  List *proxy_class_member_functions;
  String *variable_name;	//Name of a variable being wrapped
  GUID *proxy_iid;
  GUID *proxy_static_iid;
  GUID *proxy_clsid;
  GUID master_guid;
  GUID typelib_guid;
  GUID module_iid;
  GUID module_clsid;

  String *module_class_vtable_code;
  String *proxy_class_vtable_code;
  String *proxy_static_class_vtable_code;
  String *proxy_class_vtable_defs;

  String *module_class_name;	// module class name
  String *module_class_code;
  String *namespce;

  String *default_ctor_wname;

#if 0

  static Parm *NewParmFromNode(SwigType *type, const String_or_char *name, Node *n) {
    Parm *p = NewParm(type, name);
    Setfile(p, Getfile(n));
    Setline(p, Getline(n));
    return p;
  }

#endif

public:

  /* -----------------------------------------------------------------------------
   * COM()
   * ----------------------------------------------------------------------------- */

  COM():empty_string(NewString("")),
      hresult_flag(true),
      proxy_flag(true),
      deffile_flag(true),
      rcfile_flag(true),
      dllexports_flag(true),
      enum_constant_flag(false),
      proxy_class_vtable_code(NewString("")),
      proxy_static_class_vtable_code(NewString("")),
      proxy_class_vtable_defs(NewString("")),
      clsid_list(NewString("")),
      namespce(NULL) {
    /* Use NIL GUID by default */
    memset(&master_guid, 0, sizeof(GUID));
    memset(&typelib_guid, 0, sizeof(GUID));
    memset(&module_iid, 0, sizeof(GUID));
    memset(&module_clsid, 0, sizeof(GUID));
    director_language = 0;
  }

  /* -----------------------------------------------------------------------------
   * getProxyName()
   *
   * Test to see if a type corresponds to something wrapped with a proxy class
   * Return NULL if not otherwise the proxy class name
   * ----------------------------------------------------------------------------- */
  
   String *getProxyName(SwigType *t) {
    if (proxy_flag) {
      Node *n = classLookup(t);
      if (n) {
	return Getattr(n, "sym:name");
      }
    }
    return NULL;
  }

  /* ------------------------------------------------------------
   * main()
   * ------------------------------------------------------------ */

  virtual void main(int argc, char *argv[]) {

    SWIG_library_directory("com");

    // Look for certain command line options
    for (int i = 1; i < argc; i++) {
      if (argv[i]) {
	if (strcmp(argv[i], "-help") == 0) {
	  Printf(stdout, "%s\n", usage);
	} else if ((strcmp(argv[i], "-nodllexports") == 0)) {
	  Swig_mark_arg(i);
          dllexports_flag = false;
          deffile_flag = false;
          rcfile_flag = false;
	} else if (strcmp(argv[i], "-nodeffile") == 0) {
	  Swig_mark_arg(i);
          deffile_flag = false;
	} else if (strcmp(argv[i], "-norcfile") == 0) {
	  Swig_mark_arg(i);
          rcfile_flag = false;
	} else if (strcmp(argv[i], "-namespace") == 0) {
	  if (argv[i + 1]) {
	    namespce = NewString("");
	    Printf(namespce, argv[i + 1]);
	    Swig_mark_arg(i);
	    Swig_mark_arg(i + 1);
	    i++;
	  } else {
	    Swig_arg_error();
	  }
	}
      }
    }
    // Add a symbol to the parser for conditional compilation
    Preprocessor_define("SWIGCOM 1", 0);

    // Add typemap definitions
    SWIG_typemap_lang("com");
    SWIG_config_file("com.swg");

    allow_overloading(0);
  }

  /* ---------------------------------------------------------------------
   * top()
   * --------------------------------------------------------------------- */

  virtual int top(Node *n) {

    // Get any options set in the module directive
    Node *optionsnode = Getattr(Getattr(n, "module"), "options");

    if (optionsnode) {
      if (Getattr(optionsnode, "masterguid")) {
	if (!parseGUID(Getattr(optionsnode, "masterguid"), &master_guid)) {
          /* Bad GUID */
          /* FIXME: report an error */
        }
      }
      if (Getattr(optionsnode, "tlbid")) {
	if (!parseGUID(Getattr(optionsnode, "tlbid"), &typelib_guid)) {
          /* Bad GUID */
          /* FIXME: report an error */
        }
      }
      if (Getattr(optionsnode, "moduleiid")) {
	if (!parseGUID(Getattr(optionsnode, "moduleiid"), &module_iid)) {
          /* Bad GUID */
          /* FIXME: report an error */
        }
      }
      if (Getattr(optionsnode, "moduleclsid")) {
	if (!parseGUID(Getattr(optionsnode, "moduleclsid"), &module_clsid)) {
          /* Bad GUID */
          /* FIXME: report an error */
        }
      }
#if 0
      if (Getattr(optionsnode, "directors")) {
	allow_directors();
      }
#endif
    }

    /* Initialize all of the output files */
    String *outfile = Getattr(n, "outfile");
    String *outfile_h = Getattr(n, "outfile_h");

    if (!outfile) {
      Printf(stderr, "Unable to determine outfile\n");
      SWIG_exit(EXIT_FAILURE);
    }

    f_runtime = NewFile(outfile, "w");
    if (!f_runtime) {
      FileErrorDisplay(outfile);
      SWIG_exit(EXIT_FAILURE);
    }

    f_header = NewString("");
    f_wrappers = NewString("");
    f_proxy = NewString("");
    f_proxy_forward_defs = NewString("");
    f_vtables = NewString("");
    f_vtable_defs = NewString("");
    f_directors = NewString("");
    f_factory = NewString("");

    /* Register file targets with the SWIG file handler */
    Swig_register_filebyname("header", f_header);
    Swig_register_filebyname("wrapper", f_wrappers);
    Swig_register_filebyname("runtime", f_runtime);
    Swig_register_filebyname("factory", f_factory);

    swig_types_hash = NewHash();
    filenames_list = NewList();

    /* FIXME: do it as it is done in other targets */
    module_class_name = Copy(Getattr(n, "name"));

    if (!namespce)
      namespce = Copy(module_class_name);

    module_class_code = NewString("");
    proxy_class_def = NewString("");
    proxy_static_class_def = NewString("");
    proxy_class_forward_def = NewString("");
    proxy_class_code = NewString("");
    proxy_static_class_code = NewString("");

    if (isNilGUID(&typelib_guid)) {
      String *tlbid_ident = NewStringf("%s.%s.TLBID", namespce, module_class_name);
      generateGUID(&typelib_guid, tlbid_ident);
      Delete(tlbid_ident);
    }

    if (isNilGUID(&module_iid)) {
      String *module_iid_ident = NewStringf("%s.%s.IID", namespce, module_class_name);
      generateGUID(&module_iid, module_iid_ident);
      Delete(module_iid_ident);
    }

    if (isNilGUID(&module_clsid)) {
      String *module_clsid_ident = NewStringf("%s.%s.CLSID", namespce, module_class_name);
      generateGUID(&module_clsid, module_clsid_ident);
      Delete(module_clsid_ident);
    }

    module_class_vtable_code = NewString("");

    Printf(module_class_vtable_code, "GUID IID_I%s = ", module_class_name);
    formatGUID(module_class_vtable_code, &module_iid, true);
    Printf(module_class_vtable_code, ";\n\n");

    Printf(module_class_vtable_code, "GUID CLSID_%s = ", module_class_name);
    formatGUID(module_class_vtable_code, &module_clsid, true);
    Printf(module_class_vtable_code, ";\n\n");

    Printf(module_class_vtable_code, "extern SWIG_funcptr _wrap%s_vtable[];\n\n", module_class_name);

    Printf(module_class_vtable_code,
        "void * SWIGSTDCALL _wrap_new_%s() {\n"
        "  return _wrap_new_staticclass(_wrap%s_vtable, &IID_I%s);\n"
        "};\n\n",
        module_class_name, module_class_name, module_class_name);

    Printf(module_class_vtable_code, "SWIG_funcptr _wrap%s_vtable[] = "
        "{\n  (SWIG_funcptr) _wrap_staticclass_QueryInterface,"
        "\n  (SWIG_funcptr) SWIGAddRef1,"
        "\n  (SWIG_funcptr) SWIGRelease1,"
        "\n  (SWIG_funcptr) SWIGGetTypeInfoCount,"
        "\n  (SWIG_funcptr) SWIGGetTypeInfo,"
        "\n  (SWIG_funcptr) SWIGGetIDsOfNames,"
        "\n  (SWIG_funcptr) SWIGInvoke",
        module_class_name);

    Printf(clsid_list, "static TCHAR * SWIG_tlb_guid_string = _T(\"{");
    formatGUID(clsid_list, &typelib_guid, false);
    Printf(clsid_list, "}\");\n\n");

    Printf(clsid_list, "static SWIGClassDescription_t SWIGClassDescription[] = {\n");
    Printf(clsid_list, "  { (SWIG_funcptr) _wrap_new_%s, &CLSID_%s, _T(\"{", module_class_name, module_class_name);
    formatGUID(clsid_list, &module_clsid, false);
    Printf(clsid_list,  "}\"), _T(\"%s.%s\"), 0 },\n", namespce, module_class_name);

    /* Emit code */
    Language::top(n);

    /* Insert guard element */
    Printf(clsid_list, "  { NULL, NULL, NULL, NULL } /* guard element */\n");

    Printf(clsid_list, "};\n\n");

    Printv(module_class_vtable_code, "\n};\n\n", NIL);

    // Output a COM type wrapper class for each SWIG type
    for (Iterator swig_type = First(swig_types_hash); swig_type.key; swig_type = Next(swig_type)) {
      emitTypeWrapperClass(swig_type.key, swig_type.item);
    }

    /* Generate DEF file */
    if (deffile_flag) {
      String *filen = NewStringf("%s%s.def", SWIG_output_directory(), module_class_name);
      f_deffile = NewFile(filen, "w");
      if (!f_deffile) {
	FileErrorDisplay(filen);
	SWIG_exit(EXIT_FAILURE);
      }
      // Append(filenames_list, Copy(filen));
      Delete(filen);
      filen = NULL;

      Printf(f_deffile, "LIBRARY %s\n", module_class_name);

      Printf(f_deffile, "EXPORTS\n"
          "  DllGetClassObject PRIVATE\n"
          "  DllCanUnloadNow PRIVATE\n"
          "  DllRegisterServer PRIVATE\n"
          "  DllUnregisterServer PRIVATE\n"
          "  DllMain\n");
    }

    if (rcfile_flag) {
      String *filen = NewStringf("%s%s.rc", SWIG_output_directory(), module_class_name);
      f_rcfile = NewFile(filen, "w");
      if (!f_rcfile) {
	FileErrorDisplay(filen);
	SWIG_exit(EXIT_FAILURE);
      }
      // Append(filenames_list, Copy(filen));
      Delete(filen);
      filen = NULL;

      Printf(f_rcfile, "1 typelib \"%s.tlb\"\n", module_class_name);
    }

    /* Generate the IDL file containing the module class and proxy classes */
    {
      String *filen = NewStringf("%s%s.idl", SWIG_output_directory(), module_class_name);
      f_module = NewFile(filen, "w");
      if (!f_module) {
	FileErrorDisplay(filen);
	SWIG_exit(EXIT_FAILURE);
      }
      // Append(filenames_list, Copy(filen));
      Delete(filen);
      filen = NULL;

      // Banner for the IDL file
      emitBanner(f_module);

      // Header containing IDispatch declaration
      // NOTE: MIDL does not need this, but WIDL does (and is sensitive to the position
      //       in the file where it is imported)
      Printf(f_module, "import \"oaidl.idl\";\n\n");

      Printf(f_module, "[\n  uuid(");
      formatGUID(f_module, &typelib_guid, false);
      Printf(f_module, "),\n  version(1.0)\n]\nlibrary %sTLB {\n\n",
          module_class_name);

      // Import IDispatch declaration, part 2
      Printf(f_module, "  importlib(\"stdole2.tlb\");\n\n");

      Printv(f_module, f_proxy_forward_defs, "\n", NIL);

      // Interface for module class
      Printf(f_module, "  [\n    object,\n    local,\n    uuid(");
      formatGUID(f_module, &module_iid, false);
      Printf(f_module, "),\n    dual\n  ]\n  interface I%s : IDispatch {\n", module_class_name);

      // Add the wrapper methods
      Printv(f_module, module_class_code, NIL);

      Printf(f_module, "  };\n\n");

      Printv(f_module, "  [\n    uuid(", NIL);
      formatGUID(f_module, &module_clsid, false);
      Printv(f_module, ")\n  ]\n  coclass ", module_class_name, " {\n"
          "    interface I", module_class_name, ";\n  };\n\n", NIL);

      // Add the proxy code
      Printv(f_module, f_proxy, NIL);

      Printf(f_module, "};\n");
    }

    /* Close all of the files */
    Dump(f_header, f_runtime);
    Delete(f_header);
    Printv(f_runtime, f_vtable_defs, "\n", NIL);
    Delete(f_vtable_defs);
    Dump(f_wrappers, f_runtime);
    Delete(f_wrappers);
    Dump(f_directors, f_runtime);
    Delete(f_directors);
    // Vtable for the module class
    Printv(f_runtime, module_class_vtable_code, NIL);
    Dump(f_vtables, f_runtime);
    Delete(f_vtables);
    Dump(clsid_list, f_runtime);
    Delete(clsid_list);
    Replaceall(f_factory, "$module", module_class_name);
    if (dllexports_flag)
      Dump(f_factory, f_runtime);
    Delete(f_factory);
    Delete(f_runtime);
    Delete(f_module);
    if (deffile_flag) {
      Delete(f_deffile);
    }
    if (rcfile_flag) {
      Delete(f_rcfile);
    }
    Delete(namespce);
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------------
   * emitBanner()
   * ----------------------------------------------------------------------------- */

  void emitBanner(File *f) {
    Printf(f, "/* ----------------------------------------------------------------------------\n");
    Printf(f, " * This file was automatically generated by SWIG (http://www.swig.org).\n");
    Printf(f, " * Version %s\n", Swig_package_version());
    Printf(f, " *\n");
    Printf(f, " * Do not make changes to this file unless you know what you are doing--modify\n");
    Printf(f, " * the SWIG interface file instead.\n");
    Printf(f, " * ----------------------------------------------------------------------------- */\n\n");
  }

  /* -----------------------------------------------------------------------------
   * functionWrapper()
   * ----------------------------------------------------------------------------- */

  virtual int functionWrapper(Node *n) {
    String *symname = Getattr(n, "sym:name");
    SwigType *t = Getattr(n, "type");
    ParmList *l = Getattr(n, "parms");
    String *tm;
    Parm *p;
    int i;
    String *c_return_type = NewString("");
    String *cleanup = NewString("");
    String *outarg = NewString("");
    bool is_void_return;
    int num_arguments = 0;
    int num_required = 0;

    /* FIXME */
    String *overloaded_name = Copy(symname);

    // A new wrapper function object
    Wrapper *f = NewWrapper();

    // Make a wrapper name for this function
    String *wname = Swig_name_wrapper(overloaded_name);

    /* Attach the non-standard typemaps to the parameter list. */
    Swig_typemap_attach_parms("ctype", l, f);

    /* Get return types */
    if ((tm = Swig_typemap_lookup("ctype", n, "", 0))) {
      String *ctypeout = Getattr(n, "tmap:ctype:out");	// the type in the ctype typemap's out attribute overrides the type in the typemap
      if (ctypeout)
	tm = ctypeout;
      Printf(c_return_type, "%s", tm);
    } else {
      Swig_warning(WARN_COM_TYPEMAP_CTYPE_UNDEF, input_file, line_number, "No ctype typemap defined for %s\n", SwigType_str(t, 0));
    }

    is_void_return = (Cmp(c_return_type, "void") == 0);
    if (!is_void_return)
      Wrapper_add_localv(f, "jresult", c_return_type, "jresult", NIL);

    if (hresult_flag) {
      Wrapper_add_localv(f, "hres", "HRESULT", "hres", NIL);
      Printv(f->def, "HRESULT SWIGSTDCALL ", wname, "(", NIL);
    } else {
      Printv(f->def, c_return_type, " SWIGSTDCALL ", wname, "(", NIL);
    }

    // Emit all of the local variables for holding arguments.
    emit_parameter_variables(l, f);

    /* Attach the standard typemaps */
    emit_attach_parmmaps(l, f);

    // Parameter overloading
    Setattr(n, "wrap:parms", l);
    Setattr(n, "wrap:name", wname);

    /* Get number of required and total arguments */
    num_arguments = emit_num_arguments(l);
    num_required = emit_num_required(l);
    int gencomma = 0;

    /* There are no global or static member functions in COM - thus they need fake 'this' arguments */
    // FIXME: this should include static member functions too
    if ((!is_wrapping_class() || static_flag) && !enum_constant_flag) {
      Printv(f->def, "void *SWIG_ignored", NIL);
      gencomma = 1;
    }


    // Now walk the function parameter list and generate code to get arguments
    for (i = 0, p = l; i < num_arguments; i++) {

      while (checkAttribute(p, "tmap:in:numinputs", "0")) {
	p = Getattr(p, "tmap:in:next");
      }

      SwigType *pt = Getattr(p, "type");
      String *ln = Getattr(p, "lname");
      String *c_param_type = NewString("");
      String *arg = NewString("");

      Printf(arg, "j%s", ln);

      /* Get the ctype types of the parameter */
      if ((tm = Getattr(p, "tmap:ctype"))) {
	Printv(c_param_type, tm, NIL);
      } else {
	Swig_warning(WARN_COM_TYPEMAP_CTYPE_UNDEF, input_file, line_number, "No ctype typemap defined for %s\n", SwigType_str(pt, 0));
      }

      // Add parameter to C function
      Printv(f->def, gencomma ? ", " : "", c_param_type, " ", arg, NIL);

      gencomma = 1;

      // Get typemap for this argument
      if ((tm = Getattr(p, "tmap:in"))) {
	Replaceall(tm, "$source", arg);	/* deprecated */
	Replaceall(tm, "$target", ln);	/* deprecated */
	Replaceall(tm, "$arg", arg);	/* deprecated? */
	Replaceall(tm, "$input", arg);
	Setattr(p, "emit:input", arg);
	Printf(f->code, "%s\n", tm);
	p = Getattr(p, "tmap:in:next");
      } else {
	Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, "Unable to use type %s as a function argument.\n", SwigType_str(pt, 0));
	p = nextSibling(p);
      }
      Delete(c_param_type);
      Delete(arg);
    }

    if (!is_void_return && hresult_flag) {
      Printv(f->def, gencomma ? ", " : "", c_return_type, "*SWIG_result_ptr", NIL);
      gencomma = 1;
    }

    String *null_attribute = 0;
    // Now write code to make the function call
    if (Cmp(nodeType(n), "constant") == 0) {
      // Wrapping a constant hack
      Swig_save("functionWrapper", n, "wrap:action", NIL);

      // below based on Swig_VargetToFunction()
      SwigType *ty = Swig_wrapped_var_type(Getattr(n, "type"), use_naturalvar_mode(n));
      Setattr(n, "wrap:action", NewStringf("result = (%s) %s;", SwigType_lstr(ty, 0), Getattr(n, "value")));
    }

    String *actioncode = emit_action(n);

    if (Cmp(nodeType(n), "constant") == 0)
      Swig_restore(n);

    /* Return value if necessary  */
    if ((tm = Swig_typemap_lookup_out("out", n, "result", f, actioncode))) {
      Replaceall(tm, "$source", "result");	/* deprecated */
      if (!hresult_flag) {
        Replaceall(tm, "$target", "jresult");	/* deprecated */
        Replaceall(tm, "$result", "jresult");
      } else {
        Replaceall(tm, "$target", "*SWIG_result_ptr");	/* deprecated */
        Replaceall(tm, "$result", "*SWIG_result_ptr");
      }

      if (GetFlag(n, "feature:new"))
        Replaceall(tm, "$owner", "1");
      else
        Replaceall(tm, "$owner", "0");

      /* FIXME: see if this is needed and works as it should */
      substituteClassname(t, tm);

      Printf(f->code, "%s", tm);
      null_attribute = Getattr(n, "tmap:out:null");
      if (Len(tm))
        Printf(f->code, "\n");
    } else {
      Swig_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to use return type %s in function %s.\n", SwigType_str(t, 0), Getattr(n, "name"));
    }
    emit_return_variable(n, t, f);

    /* Insert cleanup code */
    for (p = l; p;) {
      if ((tm = Getattr(p, "tmap:freearg"))) {
	Replaceall(tm, "$source", Getattr(p, "emit:input"));	/* deprecated */
	Replaceall(tm, "$arg", Getattr(p, "emit:input"));	/* deprecated? */
	Replaceall(tm, "$input", Getattr(p, "emit:input"));
	Printv(cleanup, tm, "\n", NIL);
	p = Getattr(p, "tmap:freearg:next");
      } else {
	p = nextSibling(p);
      }
    }

    /* Insert argument output code */
    for (p = l; p;) {
      if ((tm = Getattr(p, "tmap:argout"))) {
	Replaceall(tm, "$source", Getattr(p, "emit:input"));	/* deprecated */
	Replaceall(tm, "$target", Getattr(p, "lname"));	/* deprecated */
	Replaceall(tm, "$arg", Getattr(p, "emit:input"));	/* deprecated? */
	Replaceall(tm, "$result", "jresult");
	Replaceall(tm, "$input", Getattr(p, "emit:input"));
	Printv(outarg, tm, "\n", NIL);
	p = Getattr(p, "tmap:argout:next");
      } else {
	p = nextSibling(p);
      }
    }

    /* Output argument output code */
    Printv(f->code, outarg, NIL);

    /* Output cleanup code */
    Printv(f->code, cleanup, NIL);

    Printf(f->def, ") {");

    if (!is_void_return && !hresult_flag)
      Printv(f->code, "    return jresult;\n", NIL);
    if (hresult_flag)
      Printv(f->code, "    return S_OK;\n", NIL);
    Printf(f->code, "}\n");

    /* Contract macro modification */
    Replaceall(f->code, "SWIG_contract_assert(", "SWIG_contract_assert($null, ");

    if (hresult_flag) {
      Replaceall(f->code, "$null", "E_ABORT");
      Replaceall(f->code, "$invalidarg", "E_INVALIDARG");
    }
    else if (!is_void_return) {
      Replaceall(f->code, "$null", "0");
      Replaceall(f->code, "$invalidarg", "0");
    }
    else {
      Replaceall(f->code, "$null", "");
      Replaceall(f->code, "$invalidarg", "");
    }

    Wrapper_print(f, f_wrappers);

    if (!(proxy_flag && is_wrapping_class()) && !enum_constant_flag && !constructor_flag) {
      moduleClassFunctionHandler(n);
      Printf(module_class_vtable_code, ",\n  (SWIG_funcptr) %s", wname);
    } else if (constructor_flag) {
      moduleClassFunctionHandler(n);
      Printf(proxy_static_class_vtable_code, ",\n  (SWIG_funcptr) %s", wname);
    }

    /* 
     * Generate the proxy class properties for public member variables.
     * Not for enums and constants.
     */
    if (proxy_flag && wrapping_member_flag && !enum_constant_flag) {
      // Capitalize the first letter in the variable in the getter/setter function name
      bool getter_flag = Cmp(symname, Swig_name_set(getNSpace(), Swig_name_member(0, proxy_class_name, variable_name))) != 0;

      String *getter_setter_name = NewString("");

      Printf(getter_setter_name, "%s", variable_name);

      Setattr(n, "proxyfuncname", getter_setter_name);

      proxyClassFunctionHandler(n);
      Delete(getter_setter_name);
    }

    Delete(cleanup);
    Delete(outarg);

    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------
   * globalvariableHandler()
   * ------------------------------------------------------------------------ */

  virtual int globalvariableHandler(Node *n) {

    generate_property_declaration_flag = true;
    variable_name = Getattr(n, "sym:name");
    global_variable_flag = true;
    int ret = Language::globalvariableHandler(n);
    global_variable_flag = false;
    generate_property_declaration_flag = false;

    return ret;
  }

  /* -----------------------------------------------------------------------
   * constantWrapper()
   * ------------------------------------------------------------------------ */

  virtual int constantWrapper(Node *n) {

    generate_property_declaration_flag = true;
    variable_wrapper_flag = true;

    if (!wrapping_member_flag) {
      global_variable_flag = true;
      variable_name = Getattr(n, "sym:name");
    } else {
      static_flag = true;
    }

    int ret = Language::variableWrapper(n);

    global_variable_flag = false;
    static_flag = false;
    variable_wrapper_flag = false;
    generate_property_declaration_flag = false;

    return ret;
  }

  /* ----------------------------------------------------------------------
   * memberfunctionHandler()
   * ---------------------------------------------------------------------- */

  virtual int memberfunctionHandler(Node *n) {
    Language::memberfunctionHandler(n);

    if (proxy_flag) {
      // FIXME: String *overloaded_name = getOverloadedName(n);
      String *overloaded_name = Getattr(n, "sym:name");
      String *intermediary_function_name = Swig_name_member(getNSpace(), proxy_class_name, overloaded_name);
      Setattr(n, "proxyfuncname", Getattr(n, "sym:name"));
      proxyClassFunctionHandler(n);
      Delete(overloaded_name);
    }
    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * membervariableHandler()
   * ---------------------------------------------------------------------- */

  virtual int membervariableHandler(Node *n) {

    generate_property_declaration_flag = true;
    variable_name = Getattr(n, "sym:name");
    wrapping_member_flag = true;
    variable_wrapper_flag = true;
    Language::membervariableHandler(n);
    wrapping_member_flag = false;
    variable_wrapper_flag = false;
    generate_property_declaration_flag = false;

    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * staticmembervariableHandler()
   * ---------------------------------------------------------------------- */

  virtual int staticmembervariableHandler(Node *n) {

    bool static_const_member_flag = (Getattr(n, "value") == 0);

    generate_property_declaration_flag = true;
    variable_name = Getattr(n, "sym:name");
    wrapping_member_flag = true;
    static_flag = true;
    Language::staticmembervariableHandler(n);
    wrapping_member_flag = false;
    static_flag = false;
    generate_property_declaration_flag = false;

    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * memberconstantHandler()
   * ---------------------------------------------------------------------- */

  virtual int memberconstantHandler(Node *n) {

    variable_name = Getattr(n, "sym:name");
    wrapping_member_flag = true;
    Language::memberconstantHandler(n);
    wrapping_member_flag = false;

    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------------
   * constructorHandler()
   * ----------------------------------------------------------------------------- */

  virtual int constructorHandler(Node *n) {

    static_flag = true;
    constructor_flag = true;
    Language::constructorHandler(n);
    constructor_flag = false;
    static_flag = false;

    if (Getattr(n, "default_constructor") ||
        checkAttribute(n, "access", "public") && !Getattr(n, "parms")) {
      default_ctor_wname = Copy(Getattr(n, "wrap:name"));
    }

    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------------
   * moduleClassFunctionHandler()
   * ----------------------------------------------------------------------------- */

  int moduleClassFunctionHandler(Node *n) {
    SwigType *t = Getattr(n, "type");
    ParmList *l = Getattr(n, "parms");
    String *tm;
    String *return_type = NewString("");
    String *function_code = NewString("");
    Parm *p;
    int i;
    String *func_name = NULL;
    bool setter_flag = false;
    bool is_void_return;

    if (l) {
      if (SwigType_type(Getattr(l, "type")) == T_VOID) {
	l = nextSibling(l);
      }
    }

    /* Attach the non-standard typemaps to the parameter list */
    Swig_typemap_attach_parms("comtype", l, NULL);
    Swig_typemap_attach_parms("comin", l, NULL);

    /* Get return types */
    if (!constructor_flag && (tm = Swig_typemap_lookup("comtype", n, "", 0))) {
      String *comtypeout = Getattr(n, "tmap:comtype:out");	// the type in the comtype typemap's out attribute overrides the type in the typemap
      if (comtypeout)
	tm = comtypeout;
      substituteClassname(t, tm);
      Printf(return_type, "%s", tm);
    } else if (constructor_flag) {
      Printf(return_type, "I%s *", proxy_class_name);
    } else {
      Swig_warning(WARN_COM_TYPEMAP_COMTYPE_UNDEF, input_file, line_number, "No comtype typemap defined for %s\n", SwigType_str(t, 0));
    }

    is_void_return = (Cmp(return_type, "void") == 0);

    if (proxy_flag && global_variable_flag) {
      func_name = NewString("");
      setter_flag = (Cmp(Getattr(n, "sym:name"), Swig_name_set(getNSpace(), variable_name)) == 0);
      Printf(func_name, "%s", variable_name);

      if (setter_flag) {
        Printf(function_code, "    [ propput ]\n");
      } else {
        Printf(function_code, "    [ propget ]\n");
      }
    } else {
      /* FIXME: ... */
      func_name = Getattr(n, "sym:name");
    }

    if (hresult_flag) {
      Printf(function_code, "    HRESULT %s(", func_name);
    } else {
      Printf(function_code, "    %s %s(", return_type, func_name);
    }

    /* Get number of required and total arguments */
    int num_arguments = emit_num_arguments(l);
    int num_required = emit_num_required(l);

    int gencomma = 0;

    /* Output each parameter */
    for (i = 0, p = l; i < num_arguments; i++) {

      /* Ignored parameters */
      while (checkAttribute(p, "tmap:in:numinputs", "0")) {
	p = Getattr(p, "tmap:in:next");
      }

      SwigType *pt = Getattr(p, "type");
      String *param_type = NewString("");

      /* Get the COM parameter type */
      if ((tm = Getattr(p, "tmap:comtype"))) {
        /* Check if we should set any special attributes */
        String *tm_attr;
        if (tm_attr = Getattr(p, "tmap:comptype:attribute")) {
          Printf(param_type, "[ %s ] ", tm_attr);
        }

	substituteClassname(pt, tm);
	Printf(param_type, "%s", tm);
      } else {
	Swig_warning(WARN_COM_TYPEMAP_COMTYPE_UNDEF, input_file, line_number, "No comtype typemap defined for %s\n", SwigType_str(pt, 0));
      }

      /* FIXME: get the real argument name, it is important in the IDL */
      String *arg = NewStringf("arg%d", i);

      /* Add parameter to module class function */
      if (gencomma >= 2)
	Printf(function_code, ", ");
      gencomma = 2;
      Printf(function_code, "%s %s", param_type, arg);

      p = Getattr(p, "tmap:in:next");
      Delete(arg);
      Delete(param_type);
    }

    if (hresult_flag && !is_void_return) {
      Printv(function_code, gencomma ? ", " : "", "[ retval, out ] ", return_type, "*SWIG_result_ptr", NIL);
      gencomma = 2;
    }

    Printf(function_code, ");\n");

    if (!constructor_flag)
      Printv(module_class_code, function_code, NIL);
    else
      Printv(proxy_static_class_code, function_code, NIL);
    Delete(function_code);
    Delete(return_type);

    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------------
   * emitProxyClassDefAndCPPCasts()
   * ----------------------------------------------------------------------------- */

  void emitProxyClassDefAndCPPCasts(Node *n) {
    String *c_classname = SwigType_namestr(Getattr(n, "name"));
    String *c_baseclass = NULL;
    String *baseclass = NULL;
    String *c_baseclassname = NULL;
    String *typemap_lookup_type = Getattr(n, "classtypeobj");
    bool feature_director = Swig_directorclass(n) ? true : false;

    Node *attributes = NewHash();

    const String *pure_baseclass = NewString("");

    List *baselist = Getattr(n, "bases");
    if (baselist) {
      Iterator base = First(baselist);
      while (base.item && GetFlag(base.item, "feature:ignore")) {
        base = Next(base);
      }
      if (base.item) {
        c_baseclassname = Getattr(base.item, "name");
        baseclass = Copy(getProxyName(c_baseclassname));
        if (baseclass)
          c_baseclass = SwigType_namestr(Getattr(base.item, "name"));
        base = Next(base);
        /* Warn about multiple inheritance for additional base class(es) */
        while (base.item) {
          if (GetFlag(base.item, "feature:ignore")) {
            base = Next(base);
            continue;
          }
          String *proxyclassname = SwigType_str(Getattr(n, "classtypeobj"), 0);
          String *baseclassname = SwigType_str(Getattr(base.item, "name"), 0);
          Swig_warning(WARN_COM_MULTIPLE_INHERITANCE, input_file, line_number,
                       "Warning for %s proxy: Base %s ignored. Multiple inheritance is not supported in COM.\n", proxyclassname, baseclassname);
          base = Next(base);
        }
      }
    }

    const String *wanted_base = baseclass ? baseclass : pure_baseclass;
    bool derived = baseclass && getProxyName(c_baseclassname);

    if (!Getattr(n, "abstract") && default_ctor_wname != NULL) {
      Printv(proxy_class_def, "  [\n    aggregatable,\n    uuid(", NIL);
      formatGUID(proxy_class_def, proxy_clsid, false);
      Printv(proxy_class_def, ")\n  ]\n  coclass $comclassname {\n"
          "    interface I$comclassname;\n  };\n\n", NIL);
    }

    Printv(proxy_class_forward_def, "  interface I$comclassname;\n", NIL);
    Printv(proxy_class_forward_def, "  interface I$comclassnameStatic;\n", NIL);
    Printv(proxy_class_def, "  [\n    object,\n    local,\n    uuid(", NIL);
    formatGUID(proxy_class_def, proxy_iid, false);

    Printv(proxy_class_def, "),\n    dual\n  ]\n  interface I$comclassname : ",
        "I", *Char(wanted_base) ? wanted_base : "Dispatch", " {\n", NIL);

    Delete(attributes);

    Printv(proxy_static_class_def, "  [\n    object,\n    local,\n    uuid(", NIL);
    formatGUID(proxy_static_class_def, proxy_static_iid, false);

    Printv(proxy_static_class_def, "),\n    dual\n  ]\n  interface I$comclassnameStatic : "
        "IDispatch {\n", NIL);

    // Add static class property to module class
    Printf(module_class_code, "    [ propget]\n"
        "    HRESULT %s([ retval, out ] I%sStatic **SWIG_result);\n",
        proxy_class_name, proxy_class_name);

    Printf(module_class_vtable_code, ",\n  (SWIG_funcptr) _wrap_%sStatic");

    Printf(f_wrappers, "extern GUID IID_I%sStatic;\n\n", proxy_class_name);
    Printf(f_wrappers, "extern SWIG_funcptr _wrap%sStatic_vtable[];\n\n", proxy_class_name);

    Printf(f_wrappers, "HRESULT SWIGSTDCALL _wrap_%sStatic(void *SWIG_ignored, SWIGIUnknown **SWIG_result) {\n"
        "  *SWIG_result = (SWIGIUnknown *) _wrap_new_staticclass(_wrap%sStatic_vtable, &IID_I%sStatic);\n"
        "\n"
        "  return S_OK;\n"
        "}\n\n", proxy_class_name, proxy_class_name, proxy_class_name);

    // Substitute various strings into the above template
    Replaceall(proxy_class_code, "$comclassname", proxy_class_name);
    Replaceall(proxy_static_class_code, "$comclassname", proxy_class_name);
    Replaceall(proxy_class_def, "$comclassname", proxy_class_name);
    Replaceall(proxy_static_class_def, "$comclassname", proxy_class_name);
    Replaceall(proxy_class_forward_def, "$comclassname", proxy_class_name);

    Replaceall(proxy_class_def, "$module", module_class_name);
    Replaceall(proxy_static_class_def, "$module", module_class_name);
    Replaceall(proxy_class_code, "$module", module_class_name);
    Replaceall(proxy_static_class_code, "$module", module_class_name);

    Delete(baseclass);
  }

  /* ----------------------------------------------------------------------
   * generateGUID()
   * ---------------------------------------------------------------------- */

  void generateGUID(GUID *result, String *name) {
    int name_len = Len(name);
    char *name_chars = Char(name);

    char *prep_input = new char[16 + name_len];

    /* master_guid serves as a "name space ID" as used in RFC 4122. */
    prep_input[0] = (master_guid.Data1 >> 24) & 0xff;
    prep_input[1] = (master_guid.Data1 >> 16) & 0xff;
    prep_input[2] = (master_guid.Data1 >> 8) & 0xff;
    prep_input[3] = master_guid.Data1 & 0xff;
    prep_input[4] = (master_guid.Data2 >> 8) & 0xff;
    prep_input[5] = master_guid.Data2 & 0xff;
    prep_input[6] = (master_guid.Data3 >> 8) & 0xff;
    prep_input[7] = master_guid.Data3 & 0xff;

    for (int i = 0; i < 8; ++i) {
      prep_input[8 + i] = master_guid.Data4[i];
    }

    for (int i = 0; i < name_len; ++i) {
      prep_input[16 + i] = name_chars[i];
    }

    SHA1_hash hash = SHA1(prep_input, 16 + name_len);

    GUID res = {
      /* time_low */ ((unsigned int) hash.octets[0] << 24) |
          ((unsigned int) hash.octets[1] << 16) |
          ((unsigned int) hash.octets[2] << 8) |
          (unsigned int) hash.octets[3],
      /* time_mid */ ((unsigned int) hash.octets[4] << 8) |
          (unsigned int) hash.octets[5],
      /* time_hi_and_version */ ((unsigned int) hash.octets[6] << 8) |
          (unsigned int) hash.octets[7],
      hash.octets[8],
      hash.octets[9],
      hash.octets[10],
      hash.octets[11],
      hash.octets[12],
      hash.octets[13],
      hash.octets[14],
      hash.octets[15],
    };

    /* Set version to 5 */
    res.Data3 &= 0x0fff;
    res.Data3 |= 0x5000;

    /* Clear top 2 bits of Data4[0] */
    res.Data4[0] &= 0x3f;
    res.Data4[0] |= 0x80;

    *result = res;

    delete prep_input;
  }

  /* ----------------------------------------------------------------------
   * formatGUID()
   * ---------------------------------------------------------------------- */

  void formatGUID(File *output, GUID *input, bool cFormat) {
    if (cFormat) {
      Printf(output,
          "{ 0x%08x, 0x%04x, 0x%04x, { 0x%02x, 0x%02x, 0x%02x, 0x%02x, 0x%02x, 0x%02x, 0x%02x, 0x%02x}}",
          input->Data1, input->Data2, input->Data3, input->Data4[0], input->Data4[1],
          input->Data4[2], input->Data4[3], input->Data4[4], input->Data4[5], input->Data4[6], input->Data4[7]);
    } else {
      Printf(output,
          "%08x-%04x-%04x-%04x-%02x%02x%02x%02x%02x%02x",
          input->Data1, input->Data2, input->Data3, (((int) input->Data4[0]) << 8) | input->Data4[1],
          input->Data4[2], input->Data4[3], input->Data4[4], input->Data4[5], input->Data4[6], input->Data4[7]);
    }
  }

  /* ----------------------------------------------------------------------
   * parseHex()
   * ---------------------------------------------------------------------- */

  unsigned int parseHex(char *text, int start, int end) {
    unsigned int result = 0;

    for (int i = start; i < end; ++i) {
      int digit = 0;

      if (text[i] >= '0' && text[i] <= '9')
        digit = text[i] - '0';
      else if (text[i] >= 'a' && text[i] <= 'f')
        digit = text[i] - 'a' + 10;
      else
        digit = text[i] - 'A' + 10;

      result = 16 * result + digit;
    }

    return result;
  }

  /* ----------------------------------------------------------------------
   * parseGUID()
   * ---------------------------------------------------------------------- */

  bool parseGUID(String *input, GUID *output) {
    if (!input || Len(input) != 36)
      return false;

    char *input_chars = Char(input);

    /* Check GUID format */
    for (int i = 0; i < 36; ++i) {
      if (i == 8 || i == 13 || i == 18 || i == 23) {
        if (input_chars[i] != '-')
          return false;
      } else {
        if (input_chars[i] >= '0' && input_chars[i] <= '9')
          continue;
        if (input_chars[i] >= 'a' && input_chars[i] <= 'f')
          continue;
        if (input_chars[i] >= 'A' && input_chars[i] <= 'F')
          continue;

        return false;
      }
    }

    output->Data1 = parseHex(input_chars, 0, 8);
    output->Data2 = parseHex(input_chars, 9, 13);
    output->Data3 = parseHex(input_chars, 14, 18);
    output->Data4[0] = parseHex(input_chars, 19, 21);
    output->Data4[1] = parseHex(input_chars, 21, 23);

    for (int i = 0; i < 6; ++i) {
      output->Data4[2 + i] = parseHex(input_chars, 24 + 2 * i, 26 + 2 * i);
    }

    return true;
  }

  /* ----------------------------------------------------------------------
   * classHandler()
   * ---------------------------------------------------------------------- */

  virtual int classHandler(Node *n) {
    if (proxy_flag) {
      proxy_class_name = NewString(Getattr(n, "sym:name"));
      List *bases = NULL;

      if (!addSymbol(proxy_class_name, n))
	return SWIG_ERROR;

      if (Cmp(proxy_class_name, module_class_name) == 0) {
	Printf(stderr, "Class name cannot be equal to module class name: %s\n", proxy_class_name);
	SWIG_exit(EXIT_FAILURE);
      }

      Clear(proxy_class_def);
      Clear(proxy_static_class_def);
      Clear(proxy_class_code);
      Clear(proxy_static_class_code);
      Clear(proxy_class_forward_def);
      Clear(proxy_class_vtable_code);
      Clear(proxy_static_class_vtable_code);
      Clear(proxy_class_vtable_defs);

      default_ctor_wname = NULL;

      proxy_iid = new GUID;
      if (Getattr(n, "feature:iid")) {
        parseGUID(Getattr(n, "feature:iid"), proxy_iid);
      } else {
        String *proxy_iid_ident = NewStringf("%s.%s.IID", namespce, proxy_class_name);
        generateGUID(proxy_iid, proxy_iid_ident);
        Delete(proxy_iid_ident);
      }

      Printf(proxy_class_vtable_code, "GUID IID_I%s = ", proxy_class_name);
      formatGUID(proxy_class_vtable_code, proxy_iid, true);
      Printf(proxy_class_vtable_code, ";\n\n");

      proxy_static_iid = new GUID;
      {
        String *proxy_static_iid_ident = NewStringf("%s.%s.StaticIID", namespce, proxy_class_name);
        generateGUID(proxy_static_iid, proxy_static_iid_ident);
        Delete(proxy_static_iid_ident);
      }

      Printf(proxy_static_class_vtable_code, "GUID IID_I%sStatic = ", proxy_class_name);
      formatGUID(proxy_static_class_vtable_code, proxy_static_iid, true);
      Printf(proxy_static_class_vtable_code, ";\n\n");

      Printf(proxy_class_vtable_code, "HRESULT SWIGSTDCALL _wrap%sQueryInterface1(void *that, GUID *iid, "
          "void ** ppvObject) {\n", proxy_class_name);

      Printf(proxy_class_vtable_code,
          "  SWIGWrappedObject *obj = (SWIGWrappedObject *) that;\n\n");

      /* Look if we are an aggregated object */
      Printf(proxy_class_vtable_code,
          "  if (obj->outer != NULL) {\n"
          "    return ((HRESULT (SWIGSTDCALL *)(SWIGIUnknown *, GUID *, void **))\n"
          "        obj->outer->vtable[0])(obj->outer, iid, ppvObject);\n"
          "  } else {\n");

      /* Look if the requested interface is ISWIGWrappedObject */
      Printf(proxy_class_vtable_code,
          "    if (SWIGIsEqual(iid, &IID_ISWIGWrappedObject)) {\n"
          "      /* FIXME: This could be more elegant */\n"
          "      SWIGAddRef1(that);\n"
          "      *ppvObject = &obj->SWIGWrappedObject_vtable;\n"
          "      return S_OK;\n"
          "    } else if (SWIGIsEqual(iid, &IID_ISupportErrorInfo)) {\n"
          "      SWIGAddRef1(that);\n"
          "      *ppvObject = &obj->ISupportErrorInfo_vtable;\n"
          "      return S_OK;\n"
          "    }\n\n");

      Printf(proxy_class_vtable_code, "    if (SWIGIsEqual(iid, &IID_IUnknown) ||\n"
        "        SWIGIsEqual(iid, &IID_IDispatch) ||\n"
        "        SWIGIsEqual(iid, &IID_I%s)", proxy_class_name);

      bases = Getattr(n, "bases");

      /* Iterate through the ancestors */
      while (bases) {
        Iterator base = First(bases);

        while (base.item && Getattr(base.item, "feature:ignore"))
          base = Next(base);

        if (base.item) {
          Printf(proxy_class_vtable_code, " ||\n        SWIGIsEqual(iid, &IID_I%s)", Getattr(base.item, "sym:name"));
          /* Get next base */
          bases = Getattr(base.item, "bases");
        } else {
          bases = NULL;
        }
      }

      Printf(proxy_class_vtable_code, ") {\n"
          "      SWIGAddRef1(that);\n"
          "      *ppvObject = obj;\n"
          "      return S_OK;\n"
          "    }\n\n");

      Printf(proxy_class_vtable_code, "    return E_NOINTERFACE;\n  }\n");

      Printf(proxy_class_vtable_code, "}\n\n");

      bases = NULL;

      Printf(proxy_class_vtable_code, "HRESULT SWIGSTDCALL _wrap%sQueryInterface2(void *that, GUID *iid, "
          "void ** ppvObject) {\n", proxy_class_name);

      Printf(proxy_class_vtable_code,
          "  return _wrap%sQueryInterface1((void *) ((void **) that - 1), iid, ppvObject);\n", proxy_class_name);

      Printf(proxy_class_vtable_code, "}\n\n");

      /*
       * This code is only slightly different from *QueryInterface1 but there are
       * subtle differences because of COM aggregation rules.
       */
      Printf(proxy_class_vtable_code, "HRESULT SWIGSTDCALL _wrap%sQueryInterface3(void *that, GUID *iid, "
          "void ** ppvObject) {\n", proxy_class_name);

      Printf(proxy_class_vtable_code,
          "  SWIGWrappedObject *obj = (SWIGWrappedObject *) ((void **)that - 2);\n\n");

      /* Look if the requested interface is ISWIGWrappedObject */
      Printf(proxy_class_vtable_code,
          "  if (SWIGIsEqual(iid, &IID_ISWIGWrappedObject)) {\n"
          "    /* FIXME: This could be more elegant */\n"
          "    SWIGAddRef3(that);\n"
          "    *ppvObject = &obj->SWIGWrappedObject_vtable;\n"
          "    return S_OK;\n"
          "  } else if (SWIGIsEqual(iid, &IID_ISupportErrorInfo)) {\n"
          "    SWIGAddRef1(that);\n"
          "    *ppvObject = &obj->ISupportErrorInfo_vtable;\n"
          "    return S_OK;\n"
          "  }\n\n");

      /* Special case for aggregation - IUnknown has to be different */
      Printf(proxy_class_vtable_code,
          "  if (SWIGIsEqual(iid, &IID_IUnknown)) {\n"
          "    /* FIXME: This could be more elegant */\n"
          "    SWIGAddRef3(that);\n"
          "    *ppvObject = &obj->aggregated_vtable;\n"
          "    return S_OK;\n"
          "  }\n\n");

      Printf(proxy_class_vtable_code, "  if (SWIGIsEqual(iid, &IID_IDispatch) ||\n"
        "      SWIGIsEqual(iid, &IID_I%s)", proxy_class_name);

      bases = Getattr(n, "bases");

      /* Iterate through the ancestors */
      while (bases) {
        Iterator base = First(bases);

        while (base.item && Getattr(base.item, "feature:ignore"))
          base = Next(base);

        if (base.item) {
          Printf(proxy_class_vtable_code, " ||\n        SWIGIsEqual(iid, &IID_I%s)", Getattr(base.item, "sym:name"));
          /* Get next base */
          bases = Getattr(base.item, "bases");
        } else {
          bases = NULL;
        }
      }

      Printf(proxy_class_vtable_code, ") {\n"
          "    /* FIXME: This could be more elegant */\n"
          "    SWIGAddRef3(that);\n"
          "    *ppvObject = obj;\n"
          "    return S_OK;\n"
          "  }\n\n");

      Printf(proxy_class_vtable_code, "  return E_NOINTERFACE;\n");

      Printf(proxy_class_vtable_code, "}\n\n");

      bases = NULL;

      Printf(proxy_class_vtable_code, "SWIG_funcptr _wrap%sSWIGWrappedObject_vtable[] = "
          "{\n  (SWIG_funcptr) _wrap%sQueryInterface2,"
          "\n  (SWIG_funcptr) SWIGAddRef2,"
          "\n  (SWIG_funcptr) SWIGRelease2,"
          "\n  (SWIG_funcptr) SWIGGetCPtr"
          "\n};\n\n",
          proxy_class_name, proxy_class_name);

      Printf(proxy_class_vtable_code, "SWIG_funcptr _wrap%saggregated_vtable[] = "
          "{\n  (SWIG_funcptr) _wrap%sQueryInterface3,"
          "\n  (SWIG_funcptr) SWIGAddRef3,"
          "\n  (SWIG_funcptr) SWIGRelease3"
          "\n};\n\n",
          proxy_class_name, proxy_class_name);

      Printf(proxy_class_vtable_code, "SWIG_funcptr _wrap%svtable[] = "
          "{\n  (SWIG_funcptr) _wrap%sQueryInterface1,"
          "\n  (SWIG_funcptr) SWIGAddRef1,"
          "\n  (SWIG_funcptr) SWIGRelease1,"
          "\n  (SWIG_funcptr) SWIGGetTypeInfoCount,"
          "\n  (SWIG_funcptr) SWIGGetTypeInfo,"
          "\n  (SWIG_funcptr) SWIGGetIDsOfNames,"
          "\n  (SWIG_funcptr) SWIGInvoke",
          proxy_class_name, proxy_class_name);

      bases = Getattr(n, "bases");

      if (!bases) {
        proxy_class_member_functions = NewList();
      } else {
        Iterator base = First(bases);

        List *base_member_functions = Getattr(base.item, "com:member_functions");
        proxy_class_member_functions = NewList();

        for (Iterator func = First(base_member_functions); func.item; func = Next(func)) {
          Append(proxy_class_member_functions, func.item);
        }
      }

      Setattr(n, "com:member_functions", proxy_class_member_functions);

      Printf(proxy_static_class_vtable_code, "extern SWIG_funcptr _wrap%sStatic_vtable[];\n\n", proxy_class_name);

      Printf(proxy_static_class_vtable_code, "SWIG_funcptr _wrap%sStatic_vtable[] = "
          "{\n  (SWIG_funcptr) _wrap_staticclass_QueryInterface,"
          "\n  (SWIG_funcptr) SWIGAddRef1,"
          "\n  (SWIG_funcptr) SWIGRelease1,"
          "\n  (SWIG_funcptr) SWIGGetTypeInfoCount,"
          "\n  (SWIG_funcptr) SWIGGetTypeInfo,"
          "\n  (SWIG_funcptr) SWIGGetIDsOfNames,"
          "\n  (SWIG_funcptr) SWIGInvoke",
          proxy_class_name);

      proxy_class_constants_code = NewString("");
    }

    Language::classHandler(n);

    if (proxy_flag) {
      for (Iterator func = First(proxy_class_member_functions); func.item; func = Next(func)) {
        Printf(proxy_class_vtable_code, ",\n  (SWIG_funcptr) %s", func.item);
      }

      if (!Getattr(n, "abstract") && default_ctor_wname != NULL) {
        /* Generate class object */
        proxy_clsid = new GUID;
        if (Getattr(n, "feature:clsid")) {
          parseGUID(Getattr(n, "feature:clsid"), proxy_clsid);
        } else {
          String *proxy_clsid_ident = NewStringf("%s.%s.CLSID", namespce, proxy_class_name);
          generateGUID(proxy_clsid, proxy_clsid_ident);
          Delete(proxy_clsid_ident);
        }
      }

      emitProxyClassDefAndCPPCasts(n);

      Replaceall(proxy_class_def, "$module", module_class_name);
      Replaceall(proxy_static_class_def, "$module", module_class_name);
      Replaceall(proxy_class_code, "$module", module_class_name);
      Replaceall(proxy_static_class_code, "$module", module_class_name);
      Replaceall(proxy_class_constants_code, "$module", module_class_name);

      Printv(f_proxy_forward_defs, proxy_class_forward_def, NIL);
      Printv(f_proxy, proxy_class_def, proxy_class_code, NIL);

      // Write out all the constants
      if (Len(proxy_class_constants_code) != 0)
	Printv(f_proxy, proxy_class_constants_code, NIL);

      Printf(f_proxy, "  };\n\n");

      Printv(f_proxy, proxy_static_class_def, proxy_static_class_code, NIL);

      Printf(f_proxy, "  };\n\n");

      Printv(proxy_class_vtable_code, "\n};\n\n", NIL);

      String *classtype = Getattr(n, "classtype");

      if (!Getattr(n, "abstract") && default_ctor_wname != NULL) {
        Printf(proxy_class_vtable_code, "%s* SWIGSTDCALL SWIG_new_%s() {\n"
            "#ifdef __cplusplus\n"
            "  return (%s *) SWIG_wrap%s((void *) new %s(), 1);\n"
            "#else\n"
            "  return (%s *) SWIG_wrap%s((void *) malloc(sizeof(%s)), 1);\n"
            "#endif\n"
            "}\n\n", classtype, proxy_class_name, classtype, proxy_class_name,
	    classtype, classtype, proxy_class_name, classtype, classtype);

        Printf(proxy_class_vtable_code, "GUID CLSID_%s = ", proxy_class_name);
        formatGUID(proxy_class_vtable_code, proxy_clsid, true);
        Printf(proxy_class_vtable_code, ";\n\n");

        Printf(clsid_list, "  { (SWIG_funcptr) SWIG_new_%s, &CLSID_%s, _T(\"{", proxy_class_name, proxy_class_name);
        formatGUID(clsid_list, proxy_clsid, false);
        Printf(clsid_list,  "}\"), _T(\"%s.%s\"), 1 },\n", namespce, proxy_class_name);
      }

      if (Getattr(n, "has_destructor")) {
        Printf(proxy_class_vtable_code, "void SWIG_delete_%s(%s *arg) {\n"
            "#ifdef __cplusplus\n"
            "  delete arg;\n"
            "#else\n"
            "  free(arg);\n"
            "#endif\n"
            "}\n\n", proxy_class_name, Getattr(n, "classtype"));
      }

      Printf(proxy_class_vtable_code, "void * SWIGSTDCALL SWIG_wrap%s(void *arg, int cMemOwn) {\n"
          "#ifdef __cplusplus\n"
          "  SWIGWrappedObject *res = new SWIGWrappedObject;\n"
          "#else\n"
          "  SWIGWrappedObject *res = (SWIGWrappedObject *) malloc(sizeof(SWIGWrappedObject));\n"
          "#endif\n"
          "  res->vtable = _wrap%svtable;\n"
          "  res->SWIGWrappedObject_vtable = _wrap%sSWIGWrappedObject_vtable;\n"
          "  res->aggregated_vtable = _wrap%saggregated_vtable;\n"
          "  res->ISupportErrorInfo_vtable = ISupportErrorInfo_vtable;\n"
          "  res->cPtr = arg;\n"
          "  res->cMemOwn = cMemOwn;\n"
          "  res->outer = NULL;\n"
          "  InterlockedIncrement(&globalRefCount);\n"
          "  res->refCount = 1;\n",
          proxy_class_name, proxy_class_name, proxy_class_name, proxy_class_name);

      if (Getattr(n, "has_destructor")) {
        Printf(proxy_class_vtable_code,
            "  res->deleteInstance = (void (*)(void *)) SWIG_delete_%s;\n",
            proxy_class_name);
      } else {
        Printf(proxy_class_vtable_code,
            "  res->deleteInstance = (void (*)(void *)) 0;\n");
      }

      Printf(proxy_class_vtable_code,
          "  /* GetTypeInfoOfGuid */\n"
          "  ((HRESULT (SWIGSTDCALL *)(ITypeLib *, GUID *, ITypeInfo **)) (((SWIGIUnknown *) SWIG_typelib)->vtable[6]))(SWIG_typelib, &IID_I%s, &res->typeInfo);\n"
          "  return (void *) res;\n"
          "}\n\n",
          proxy_class_name);

      Printf(proxy_class_vtable_defs,
          "void * SWIGSTDCALL SWIG_wrap%s(void *arg, int cMemOwn);\n", proxy_class_name);

      Printf(proxy_static_class_vtable_code, "\n};\n\n");

      Printv(f_vtables, proxy_class_vtable_code, NIL);
      Printv(f_vtables, proxy_static_class_vtable_code, NIL);
      Printv(f_vtable_defs, proxy_class_vtable_defs, NIL);

      Delete(proxy_class_name);
      proxy_class_name = NULL;
      Delete(proxy_class_constants_code);
      proxy_class_constants_code = NULL;
      delete proxy_iid;
      delete proxy_static_iid;
      if (default_ctor_wname != NULL)
        Delete(default_ctor_wname);
    }

    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * staticmemberfunctionHandler()
   * ---------------------------------------------------------------------- */

  virtual int staticmemberfunctionHandler(Node *n) {

    static_flag = true;
    member_func_flag = true;
    Language::staticmemberfunctionHandler(n);

    if (proxy_flag) {
      // FIXME: String *overloaded_name = getOverloadedName(n);
      String *overloaded_name = Getattr(n, "sym:name");
      String *intermediary_function_name = Swig_name_member(getNSpace(), proxy_class_name, overloaded_name);
      Setattr(n, "proxyfuncname", Getattr(n, "sym:name"));
      proxyClassFunctionHandler(n);
      Delete(overloaded_name);
    }
    static_flag = false;
    member_func_flag = false;

    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------------
   * proxyClassFunctionHandler()
   *
   * Function called for creating a COM wrapper function around a c++ function in the 
   * proxy class. Used for both static and non-static C++ class functions.
   * C++ class static functions map to member functions of the objects and/or to
   * member functions of the module class (TODO).
   * ----------------------------------------------------------------------------- */

  void proxyClassFunctionHandler(Node *n) {
    SwigType *t = Getattr(n, "type");
    ParmList *l = Getattr(n, "parms");
    String *proxy_function_name = Getattr(n, "proxyfuncname");
    String *tm;
    Parm *p;
    int i;
    String *return_type = NewString("");
    String *function_code = NewString("");
    bool setter_flag = false;
    String *pre_code = NewString("");
    String *post_code = NewString("");
    bool is_void_return;

    if (!proxy_flag)
      return;

    // Wrappers not wanted for some methods where the parameters cannot be overloaded in COM
    if (Getattr(n, "overload:ignore"))
      return;

    // Don't generate proxy method for additional explicitcall method used in directors
    if (GetFlag(n, "explicitcall"))
      return;

    // Check if the name has not already been used in a base class
    if (Getattr(n, "overloads_base")) {
      Node *over = Getattr(n, "overloads_base");
      SwigType *tc = Copy(Getattr(n, "decl"));
      String *oname;
      String *cname;

      oname = NewStringf("%s::%s", Getattr(Getattr(n, "sym:symtab"), "name"), Getattr(n, "name"));
      cname = NewStringf("%s::%s", Getattr(Getattr(over, "sym:symtab"), "name"), Getattr(over, "name"));

      SwigType *tc2 = Copy(Getattr(over, "decl"));

      Swig_warning(WARN_LANG_OVERLOAD_DECL, input_file, line_number, "Overloaded declaration ignored.  %s\n", SwigType_str(tc, SwigType_namestr(oname)));
      Swig_warning(WARN_LANG_OVERLOAD_DECL, Getfile(over), Getline(over), "Previous declaration is %s\n", SwigType_str(tc2, SwigType_namestr(cname)));

      Delete(tc2);
      Delete(tc);
      Delete(oname);
      Delete(cname);
      return;
    }

    if (!Getattr(n, "override")) {
      String *wname = Getattr(n, "wrap:name");
      // FIXME: do we have to use strings?
      Setattr(n, "com:vtable_index", NewStringf("%d", Len(proxy_class_member_functions)));
      Append(proxy_class_member_functions, wname);
    } else {
      String *wname = Getattr(n, "wrap:name");
      Node *prev = Getattr(n, "override");
      int index;

      // HACK: maybe there is a simpler way to store an integer in a node? :)
      sscanf(Char(Getattr(prev, "com:vtable_index")), "%d", &index);
      Setattr(n, "com:vtable_index", NewStringf("%d", index));
      Setitem(proxy_class_member_functions, index, wname);
    }

    if (checkAttribute(n, "storage", "static")) {
      // Add function to the static class
      String *wname = Getattr(n, "wrap:name");
      Printf(proxy_static_class_vtable_code, ",\n  (SWIG_funcptr) %s", wname);
    }

    if (l) {
      if (SwigType_type(Getattr(l, "type")) == T_VOID) {
	l = nextSibling(l);
      }
    }

    /* Attach the non-standard typemaps to the parameter list */
    Swig_typemap_attach_parms("in", l, NULL);
    Swig_typemap_attach_parms("comtype", l, NULL);

    /* Get return types */
    if ((tm = Swig_typemap_lookup("comtype", n, "", 0))) {
      // Note that in the case of polymorphic (covariant) return types, the method's return type is changed to be the base of the C++ return type
      SwigType *covariant = Getattr(n, "covariant");
      substituteClassname(covariant ? covariant : t, tm);
      Printf(return_type, "%s", tm);
      if (covariant)
	Swig_warning(WARN_COM_COVARIANT_RET, input_file, line_number,
		     "Covariant return types not supported in COM. Proxy method will return %s.\n", SwigType_str(covariant, 0));
    } else {
      Swig_warning(WARN_COM_TYPEMAP_COMTYPE_UNDEF, input_file, line_number, "No comtype typemap defined for %s\n", SwigType_str(t, 0));
    }

    is_void_return = (Cmp(return_type, "void") == 0);

    if (wrapping_member_flag && !enum_constant_flag) {
      // Properties
      setter_flag = (Cmp(Getattr(n, "sym:name"), Swig_name_set(getNSpace(), Swig_name_member(0, proxy_class_name, variable_name))) == 0);
      
      if (setter_flag) {
        Printf(function_code, "    [ propput ]\n");
      } else {
        Printf(function_code, "    [ propget ]\n");
      }
    }


    /* Start generating the proxy function */
    if (hresult_flag) {
      Printf(function_code, "    HRESULT %s(", proxy_function_name);
    } else {
      Printf(function_code, "    %s %s(", return_type, proxy_function_name);
    }

    emit_mark_varargs(l);

    int gencomma = 1;

    /* Output each parameter */
    for (i = 0, p = l; p; i++) {

      /* Ignored varargs */
      if (checkAttribute(p, "varargs:ignore", "1")) {
	p = nextSibling(p);
	continue;
      }

      /* Ignored parameters */
      if (checkAttribute(p, "tmap:in:numinputs", "0")) {
	p = Getattr(p, "tmap:in:next");
	continue;
      }

      /* Ignore the 'this' argument for variable wrappers */
      if (!(variable_wrapper_flag && i == 0) || static_flag) {
	SwigType *pt = Getattr(p, "type");
	String *param_type = NewString("");

	/* Get the COM parameter type */
	if ((tm = Getattr(p, "tmap:comtype"))) {
          /* Check if we should set any special attributes */
          String *tm_attr;
          if (tm_attr = Getattr(p, "tmap:comtype:attribute")) {
            Printf(param_type, "[ %s ] ", tm_attr);
          }

	  substituteClassname(pt, tm);
	  Printf(param_type, "%s", tm);
	} else {
	  Swig_warning(WARN_COM_TYPEMAP_COMTYPE_UNDEF, input_file, line_number, "No comtype typemap defined for %s\n", SwigType_str(pt, 0));
	}

	// FIXME: String *arg = makeParameterName(n, p, i, setter_flag);
        String *arg = NewStringf("arg%d", i);

	/* Add parameter to proxy function */
	if (gencomma >= 2)
	  Printf(function_code, ", ");
	gencomma = 2;
	Printf(function_code, "%s %s", param_type, arg);

	Delete(arg);
	Delete(param_type);
      }
      p = Getattr(p, "tmap:in:next");
    }

    if (hresult_flag && !is_void_return) {
      Printv(function_code, (gencomma >= 2) ? ", " : "", "[ retval, out ] ", return_type, "*SWIG_result_ptr", NIL);
      gencomma = 2;
    }

    Printf(function_code, ")");

    Printv(function_code, ";\n", NIL);

    if (!Getattr(n, "override")) {
      Printv(proxy_class_code, function_code, NIL);
    }

    if (checkAttribute(n, "storage", "static")) {
      Printv(proxy_static_class_code, function_code, NIL);
    }

    Delete(pre_code);
    Delete(post_code);
    Delete(function_code);
    Delete(return_type);
  }

  /* -----------------------------------------------------------------------------
   * emitTypeWrapperClass()
   * ----------------------------------------------------------------------------- */

  void emitTypeWrapperClass(String *classname, SwigType *type) {
    Clear(proxy_class_def);
    Clear(proxy_static_class_def);
    Clear(proxy_class_forward_def);

    proxy_iid = new GUID;

    // FIXME: Maybe we should allow specifying IIDs for opaque classes?
    {
      String *proxy_iid_ident = NewStringf("%s.%s.IID", namespce, classname);
      generateGUID(proxy_iid, proxy_iid_ident);
      Delete(proxy_iid_ident);
    }

    Printv(proxy_class_forward_def, "  interface I$comclassname;\n", NIL);

    Printv(proxy_class_def, "  [\n    object,\n    local,\n    uuid(", NIL);
    formatGUID(proxy_class_def, proxy_iid, false);
    Printv(proxy_class_def, ")\n  ]\n  interface I$comclassname : IUnknown {\n  };\n\n", NIL);

    Replaceall(proxy_class_forward_def, "$comclassname", classname);
    Replaceall(proxy_class_def, "$comclassname", classname);
    Replaceall(proxy_class_forward_def, "$module", module_class_name);
    Replaceall(proxy_class_def, "$module", module_class_name);

    Printf(f_vtable_defs, "void * (SWIGSTDCALL * SWIG_wrap%s)(void *, int) = SWIG_wrap_opaque;\n", classname);

    Printv(f_proxy_forward_defs, proxy_class_forward_def, NIL);
    Printv(f_proxy, proxy_class_def, NIL);

    delete proxy_iid;
  }

  /* -----------------------------------------------------------------------------
   * typemapLookup()
   * ----------------------------------------------------------------------------- */

  const String *typemapLookup(const String *op, String *type, int warning, Node *typemap_attributes = NULL) {
    String *tm = NULL;
    const String *code = NULL;

/*
    This code doesn't compile with the latest SWIG any more as Swig_typemap_search() doesn't exist now,
    but it doesn't matter anyhow as it is removed by the later commits, so just comment it out in this one.

    if ((tm = Swig_typemap_search(op, type, NULL, NULL))) {
      code = Getattr(tm, "code");
      if (typemap_attributes)
	Swig_typemap_attach_kwargs(tm, op, typemap_attributes);
    }

    if (!code) {
      code = empty_string;
      if (warning != WARN_NONE)
	Swig_warning(warning, input_file, line_number, "No %s typemap defined for %s\n", op, type);
    }
*/
    return code ? code : empty_string;
  }

  /* -----------------------------------------------------------------------------
   * substituteClassname()
   *
   * Substitute $comclassname with the proxy class name for classes/structs/unions that SWIG knows about.
   * Also substitutes enums with enum name.
   * Otherwise use the $descriptor name for the COM class name. Note that the $&comclassname substitution
   * is the same as a $&descriptor substitution, ie one pointer added to descriptor name.
   * Inputs:
   *   pt - parameter type
   *   tm - comtype typemap
   * Outputs:
   *   tm - comtype typemap with $comclassname substitution
   * Return:
   *   substitution_performed - flag indicating if a substitution was performed
   * ----------------------------------------------------------------------------- */

  bool substituteClassname(SwigType *pt, String *tm) {
    bool substitution_performed = false;
    SwigType *type = Copy(SwigType_typedef_resolve_all(pt));
    SwigType *strippedtype = SwigType_strip_qualifiers(type);

    if (Strstr(tm, "$comclassname")) {
      SwigType *classnametype = Copy(strippedtype);
      substituteClassnameSpecialVariable(classnametype, tm, "$comclassname");
      substitution_performed = true;
      Delete(classnametype);
    }
    if (Strstr(tm, "$*comclassname")) {
      SwigType *classnametype = Copy(strippedtype);
      Delete(SwigType_pop(classnametype));
      substituteClassnameSpecialVariable(classnametype, tm, "$*comclassname");
      substitution_performed = true;
      Delete(classnametype);
    }
    if (Strstr(tm, "$&comclassname")) {
      SwigType *classnametype = Copy(strippedtype);
      SwigType_add_pointer(classnametype);
      substituteClassnameSpecialVariable(classnametype, tm, "$&comclassname");
      substitution_performed = true;
      Delete(classnametype);
    }

    Delete(strippedtype);
    Delete(type);

    return substitution_performed;
  }

  /* -----------------------------------------------------------------------------
   * substituteClassnameSpecialVariable()
   * ----------------------------------------------------------------------------- */

  void substituteClassnameSpecialVariable(SwigType *classnametype, String *tm, const char *classnamespecialvariable) {
    if (SwigType_isenum(classnametype)) {
      // FIXME: String *enumname = getEnumName(classnametype);
      String *enumname = classnametype;
      if (enumname)
	Replaceall(tm, classnamespecialvariable, enumname);
      else
	Replaceall(tm, classnamespecialvariable, NewStringf("int"));
    } else {
      String *classname = getProxyName(classnametype);
      if (classname) {
	Replaceall(tm, classnamespecialvariable, classname);	// getProxyName() works for pointers to classes too
      } else {			// use $descriptor if SWIG does not know anything about this type. Note that any typedefs are resolved.
	String *descriptor = NewStringf("SWIGTYPE%s", SwigType_manglestr(classnametype));
	Replaceall(tm, classnamespecialvariable, descriptor);

	// Add to hash table so that the type wrapper classes can be created later
	Setattr(swig_types_hash, descriptor, classnametype);
	Delete(descriptor);
      }
    }
  }


};				/* class COM */

/* -----------------------------------------------------------------------------
 * swig_com()    - Instantiate module
 * ----------------------------------------------------------------------------- */

static Language *new_swig_com() {
  return new COM();
}
extern "C" Language *swig_com(void) {
  return new_swig_com();
}

/* -----------------------------------------------------------------------------
 * Static member variables
 * ----------------------------------------------------------------------------- */

const char *COM::usage = (char *)
"COM Options (available with -com)\n"
"     -namespace <nm> - Use <nm> as prefix for Automation names\n"
"                       (defaults to module name)\n"
// "     -norcfile       - Do not generate RC (resource definition) file\n"
// "     -nodeffile      - Do not generate DEF file\n"
// "     -nodllexports   - Do not generate DllGetClassObject and DllCanUnloadNow\n"
// "                       (implies -nodeffile)\n"
"\n";
