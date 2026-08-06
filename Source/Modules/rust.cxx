/* -----------------------------------------------------------------------------
 * This file is part of SWIG, which is licensed as a whole under version 3
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at https://www.swig.org/legal.html.
 *
 * rust.cxx
 *
 * Rust language module for SWIG.
 * ----------------------------------------------------------------------------- */

#include "swigmod.h"

typedef DOH UpcallData;

static const char *usage = "\
Rust Options (available with -rust)\n\
     -crate <name>  - Set the Rust module/crate name used in generated comments\n\
\n";

class RUST : public Language {
  File *f_begin;
  File *f_runtime;
  File *f_runtime_h;
  File *f_header;
  File *f_wrappers;
  File *f_init;
  File *f_directors;
  File *f_directors_h;
  File *f_rust;
  File *f_rust_ffi;
  File *f_rust_module;
  File *f_rust_runtime;
  File *f_rust_proxy;
  String *module_name;
  String *rust_module_name;
  String *crate_name;
  String *rust_ffi_code;
  String *rust_item_modules;
  String *rust_item_reexports;
  Hash *rust_namespace_modules;
  Hash *rust_namespace_reexports;
  Hash *rust_namespace_declared;
  List *rust_namespace_list;
  String *rust_extern_code;
  String *rust_proxy_code;
  String *rust_module_imports;
  String *rust_module_code;
  String *rust_extern_attributes;
  String *rust_extern_pragmas;
  String *rust_class_attributes;
  String *rust_class_derives;
  String *rust_class_code;
  String *rust_visibility;
  String *rust_class_file_code;
  String *rust_class_extra_code;
  String *proxy_class_name;
  String *proxy_class_code;
  String *destructor_call;
  String *variable_name;
  String *rust_enum_from_i32_code;
  String *rust_exception_kind_mappings;
  String *rust_exception_code_mappings;
  String *rust_exception_code_constants;
  String *director_callback_typedefs;
  String *director_callbacks;
  String *director_connect_parms;
  String *director_trait_code;
  String *director_callback_shims;
  String *director_method_metadata;
  String *director_rust_code;
  List *dmethods_seq;
  Hash *dmethods_table;
  int n_dmethods;
  int first_class_dmethod;
  int curr_class_dmethod;
  bool global_variable_flag;
  bool member_variable_flag;
  bool static_member_variable_flag;
  bool rust_exception_policy_result;
  bool rust_method_case_snake;

  void rustFileAttributes(File *f) {
    Printf(f, "#![allow(dead_code)]\n");
    Printf(f, "#![allow(non_camel_case_types)]\n");
    Printf(f, "#![allow(non_snake_case)]\n");
    Printf(f, "#![allow(non_upper_case_globals)]\n");
    Printf(f, "#![allow(path_statements)]\n");
    Printf(f, "#![allow(unused_imports)]\n\n");
  }

  void emitRustExceptionRuntime(File *f) {
    Printf(f, "#[derive(Clone, Debug, Eq, PartialEq)]\n");
    Printf(f, "pub enum RustExceptionKind {\n");
    Printf(f, "  BadCast,\n");
    Printf(f, "  InvalidArgument,\n");
    Printf(f, "  OutOfRange,\n");
    Printf(f, "  Overflow,\n");
    Printf(f, "  Runtime,\n");
    Printf(f, "  Logic,\n");
    Printf(f, "  Unknown,\n");
    Printf(f, "}\n\n");
    Printf(f, "impl RustExceptionKind {\n");
    Printf(f, "  pub fn from_type_name(kind: &str) -> Self {\n");
    Printf(f, "    match kind {\n");
    if (rust_exception_kind_mappings)
      Dump(rust_exception_kind_mappings, f);
    Printf(f, "      \"std::bad_cast\" => Self::BadCast,\n");
    Printf(f, "      \"std::invalid_argument\" => Self::InvalidArgument,\n");
    Printf(f, "      \"std::length_error\" | \"std::out_of_range\" | \"std::range_error\" => Self::OutOfRange,\n");
    Printf(f, "      \"std::overflow_error\" | \"std::underflow_error\" => Self::Overflow,\n");
    Printf(f, "      \"std::bad_exception\" | \"std::exception\" | \"std::runtime_error\" => Self::Runtime,\n");
    Printf(f, "      \"std::domain_error\" | \"std::logic_error\" => Self::Logic,\n");
    Printf(f, "      _ => Self::Unknown,\n");
    Printf(f, "    }\n");
    Printf(f, "  }\n");
    Printf(f, "}\n\n");
    Printf(f, "pub fn rust_exception_code_from_type_name(kind: &str) -> Option<&'static str> {\n");
    Printf(f, "  match kind {\n");
    if (rust_exception_code_mappings)
      Dump(rust_exception_code_mappings, f);
    Printf(f, "    _ => None,\n");
    Printf(f, "  }\n");
    Printf(f, "}\n\n");
    if (rust_exception_code_constants)
      Dump(rust_exception_code_constants, f);
    Printf(f, "impl std::fmt::Display for RustExceptionKind {\n");
    Printf(f, "  fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {\n");
    Printf(f, "    match self {\n");
    Printf(f, "      Self::BadCast => write!(f, \"bad cast\"),\n");
    Printf(f, "      Self::InvalidArgument => write!(f, \"invalid argument\"),\n");
    Printf(f, "      Self::OutOfRange => write!(f, \"out of range\"),\n");
    Printf(f, "      Self::Overflow => write!(f, \"overflow\"),\n");
    Printf(f, "      Self::Runtime => write!(f, \"runtime\"),\n");
    Printf(f, "      Self::Logic => write!(f, \"logic\"),\n");
    Printf(f, "      Self::Unknown => write!(f, \"unknown\"),\n");
    Printf(f, "    }\n");
    Printf(f, "  }\n");
    Printf(f, "}\n\n");
    Printf(f, "#[derive(Clone, Debug, Eq, PartialEq)]\n");
    Printf(f, "pub struct RustException {\n");
    Printf(f, "  pub kind: RustExceptionKind,\n");
    Printf(f, "  pub code: Option<&'static str>,\n");
    Printf(f, "  pub type_name: String,\n");
    Printf(f, "  pub message: String,\n");
    Printf(f, "}\n\n");
    Printf(f, "impl RustException {\n");
    Printf(f, "  pub fn new(kind: RustExceptionKind, type_name: impl Into<String>, message: impl Into<String>) -> Self {\n");
    Printf(f, "    let type_name = type_name.into();\n");
    Printf(f, "    let code = rust_exception_code_from_type_name(&type_name);\n");
    Printf(f, "    Self { kind, code, type_name, message: message.into() }\n");
    Printf(f, "  }\n");
    Printf(f, "  pub fn new_unknown(message: impl Into<String>) -> Self {\n");
    Printf(f, "    Self::new(RustExceptionKind::Unknown, \"unknown\", message)\n");
    Printf(f, "  }\n");
    Printf(f, "  pub fn is_type(&self, type_name: &str) -> bool {\n");
    Printf(f, "    self.type_name == type_name\n");
    Printf(f, "  }\n");
    Printf(f, "}\n\n");
    Printf(f, "impl std::fmt::Display for RustException {\n");
    Printf(f, "  fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {\n");
    Printf(f, "    write!(f, \"{}: {}\", self.type_name, self.message)\n");
    Printf(f, "  }\n");
    Printf(f, "}\n\n");
    Printf(f, "impl std::error::Error for RustException {}\n\n");
    Printf(f, "pub(super) fn rust_take_exception() -> Option<RustException> {\n");
    Printf(f, "  unsafe {\n");
    Printf(f, "    let kind = Rust_take_exception_type_raw();\n");
    Printf(f, "    let message = Rust_take_exception_raw();\n");
    Printf(f, "    if kind.is_null() && message.is_null() {\n");
    Printf(f, "      return None;\n");
    Printf(f, "    }\n");
    Printf(f, "    let kind_text = if kind.is_null() {\n");
    Printf(f, "      \"std::exception\".to_string()\n");
    Printf(f, "    } else {\n");
    Printf(f, "      let text = std::ffi::CStr::from_ptr(kind).to_string_lossy().into_owned();\n");
    Printf(f, "      Rust_string_free_raw(kind);\n");
    Printf(f, "      text\n");
    Printf(f, "    };\n");
    Printf(f, "    let message_text = if message.is_null() {\n");
    Printf(f, "      \"C++ exception\".to_string()\n");
    Printf(f, "    } else {\n");
    Printf(f, "      let text = std::ffi::CStr::from_ptr(message).to_string_lossy().into_owned();\n");
    Printf(f, "      Rust_string_free_raw(message);\n");
    Printf(f, "      text\n");
    Printf(f, "    };\n");
    Printf(f,
           "    Some(RustException { kind: RustExceptionKind::from_type_name(&kind_text), code: rust_exception_code_from_type_name(&kind_text), type_name: "
           "kind_text, message: message_text })\n");
    Printf(f, "  }\n");
    Printf(f, "}\n\n");
    Printf(f, "pub(super) fn rust_check_exception() {\n");
    Printf(f, "  if let Some(error) = rust_take_exception() {\n");
    Printf(f, "    panic!(\"{}\", error);\n");
    Printf(f, "  }\n");
    Printf(f, "}\n\n");
  }

  void emitRustDirectorRuntime(File *f) {
    Printf(f, "#[derive(Clone, Debug)]\n");
    Printf(f, "pub struct RustDirectorError {\n");
    Printf(f, "  pub kind: String,\n");
    Printf(f, "  pub message: String,\n");
    Printf(f, "}\n\n");
    Printf(f, "impl RustDirectorError {\n");
    Printf(f, "  pub fn new(kind: impl Into<String>, message: impl Into<String>) -> Self {\n");
    Printf(f, "    Self { kind: kind.into(), message: message.into() }\n");
    Printf(f, "  }\n");
    Printf(f, "  pub fn raise(kind: impl Into<String>, message: impl Into<String>) -> ! {\n");
    Printf(f, "    std::panic::panic_any(Self::new(kind, message))\n");
    Printf(f, "  }\n");
    Printf(f, "}\n\n");
    Printf(f, "impl std::fmt::Display for RustDirectorError {\n");
    Printf(f, "  fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {\n");
    Printf(f, "    write!(f, \"{}: {}\", self.kind, self.message)\n");
    Printf(f, "  }\n");
    Printf(f, "}\n\n");
    Printf(f, "impl std::error::Error for RustDirectorError {}\n\n");
    Printf(f, "pub fn rust_director_error(kind: impl Into<String>, message: impl Into<String>) -> ! {\n");
    Printf(f, "  RustDirectorError::raise(kind, message)\n");
    Printf(f, "}\n\n");
    Printf(f, "fn rust_director_panic_message(payload: &(dyn std::any::Any + Send)) -> String {\n");
    Printf(f, "  if let Some(error) = payload.downcast_ref::<RustDirectorError>() {\n");
    Printf(f, "    error.to_string()\n");
    Printf(f, "  } else if let Some(message) = payload.downcast_ref::<&str>() {\n");
    Printf(f, "    (*message).to_string()\n");
    Printf(f, "  } else if let Some(message) = payload.downcast_ref::<String>() {\n");
    Printf(f, "    message.clone()\n");
    Printf(f, "  } else {\n");
    Printf(f, "    \"non-string panic payload\".to_string()\n");
    Printf(f, "  }\n");
    Printf(f, "}\n\n");
    Printf(f,
           "pub(super) unsafe fn rust_set_director_panic(error: *mut c_int, message: *mut c_char, message_len: usize, payload: Box<dyn "
           "std::any::Any + Send>) {\n");
    Printf(f, "  if !error.is_null() {\n");
    Printf(f, "    *error = 1;\n");
    Printf(f, "  }\n");
    Printf(f, "  if !message.is_null() && message_len > 0 {\n");
    Printf(f,
           "    let prefix = if payload.is::<RustDirectorError>() { \"Rust director callback error\" } else { \"Rust director callback "
           "panicked\" };\n");
    Printf(f, "    let text = format!(\"{}: {}\", prefix, rust_director_panic_message(&*payload));\n");
    Printf(f, "    let bytes = text.as_bytes();\n");
    Printf(f, "    let copy_len = std::cmp::min(bytes.len(), message_len - 1);\n");
    Printf(f, "    std::ptr::copy_nonoverlapping(bytes.as_ptr(), message as *mut u8, copy_len);\n");
    Printf(f, "    *(message as *mut u8).add(copy_len) = 0;\n");
    Printf(f, "  }\n");
    Printf(f, "}\n\n");
  }

public:
  RUST() :
    f_begin(NULL),
    f_runtime(NULL),
    f_runtime_h(NULL),
    f_header(NULL),
    f_wrappers(NULL),
    f_init(NULL),
    f_directors(NULL),
    f_directors_h(NULL),
    f_rust(NULL),
    f_rust_ffi(NULL),
    f_rust_module(NULL),
    f_rust_runtime(NULL),
    f_rust_proxy(NULL),
    module_name(NULL),
    rust_module_name(NULL),
    crate_name(NULL),
    rust_ffi_code(NULL),
    rust_item_modules(NULL),
    rust_item_reexports(NULL),
    rust_namespace_modules(NULL),
    rust_namespace_reexports(NULL),
    rust_namespace_declared(NULL),
    rust_namespace_list(NULL),
    rust_extern_code(NULL),
    rust_proxy_code(NULL),
    rust_module_imports(NULL),
    rust_module_code(NULL),
    rust_extern_attributes(NULL),
    rust_extern_pragmas(NULL),
    rust_class_attributes(NULL),
    rust_class_derives(NULL),
    rust_class_code(NULL),
    rust_visibility(NULL),
    rust_class_file_code(NULL),
    rust_class_extra_code(NULL),
    proxy_class_name(NULL),
    proxy_class_code(NULL),
    destructor_call(NULL),
    variable_name(NULL),
    rust_enum_from_i32_code(NULL),
    rust_exception_kind_mappings(NULL),
    rust_exception_code_mappings(NULL),
    rust_exception_code_constants(NULL),
    director_callback_typedefs(NULL),
    director_callbacks(NULL),
    director_connect_parms(NULL),
    director_trait_code(NULL),
    director_callback_shims(NULL),
    director_method_metadata(NULL),
    director_rust_code(NULL),
    dmethods_seq(NULL),
    dmethods_table(NULL),
    n_dmethods(0),
    first_class_dmethod(0),
    curr_class_dmethod(0),
    global_variable_flag(false),
    member_variable_flag(false),
    static_member_variable_flag(false),
    rust_exception_policy_result(false),
    rust_method_case_snake(false) {
    director_multiple_inheritance = 0;
    directorLanguage();
    allow_overloading();
    Swig_interface_feature_enable();
  }

  virtual void main(int argc, char *argv[]) {
    SWIG_library_directory("rust");

    for (int i = 1; i < argc; i++) {
      if (argv[i]) {
        if (strcmp(argv[i], "-help") == 0) {
          fputs(usage, stdout);
        } else if (strcmp(argv[i], "-crate") == 0) {
          if (argv[i + 1]) {
            crate_name = NewString(argv[i + 1]);
            Swig_mark_arg(i);
            Swig_mark_arg(i + 1);
            i++;
          } else {
            Swig_arg_error();
          }
        }
      }
    }

    Preprocessor_define("SWIGRUST 1", 0);
    SWIG_config_file("rust.swg");
  }

  virtual int top(Node *n) {
    module_name = Getattr(n, "name");

    Node *module = Getattr(n, "module");
    Node *optionsnode = Getattr(module, "options");
    if (optionsnode) {
      if (Getattr(optionsnode, "rustname"))
        rust_module_name = Copy(Getattr(optionsnode, "rustname"));
      if (Getattr(optionsnode, "crate")) {
        Delete(crate_name);
        crate_name = Copy(Getattr(optionsnode, "crate"));
      }
      if (Getattr(optionsnode, "directors"))
        allow_directors();
      if (Getattr(optionsnode, "dirprot"))
        allow_dirprot();
      allow_allprotected(GetFlag(optionsnode, "allprotected"));
    }
    if (!rust_module_name)
      rust_module_name = Copy(module_name);
    if (!crate_name)
      crate_name = Copy(rust_module_name);

    String *outfile = Getattr(n, "outfile");
    String *outfile_h = Getattr(n, "outfile_h");
    f_begin = NewFile(outfile, "w", SWIG_output_files());
    if (!f_begin) {
      FileErrorDisplay(outfile);
      Exit(EXIT_FAILURE);
    }

    if (Swig_directors_enabled()) {
      if (!outfile_h) {
        Printf(stderr, "Unable to determine outfile_h\n");
        Exit(EXIT_FAILURE);
      }
      f_runtime_h = NewFile(outfile_h, "w", SWIG_output_files());
      if (!f_runtime_h) {
        FileErrorDisplay(outfile_h);
        Exit(EXIT_FAILURE);
      }
    }

    String *output_directory = Copy(SWIG_output_directory());
    String *rustdir = NewStringf("%s", rust_module_name);
    String *newdir_error = Swig_new_subdirectory(output_directory, rustdir);
    if (newdir_error) {
      Printf(stderr, "%s\n", newdir_error);
      Delete(newdir_error);
      Exit(EXIT_FAILURE);
    }

    String *rustfile = NewStringf("%s%smod.rs", rustdir, SWIG_FILE_DELIMITER);
    String *rustffifile = NewStringf("%s%sffi.rs", rustdir, SWIG_FILE_DELIMITER);
    String *rustmodulefile = NewStringf("%s%smodule.rs", rustdir, SWIG_FILE_DELIMITER);
    String *rustruntimefile = NewStringf("%s%sruntime.rs", rustdir, SWIG_FILE_DELIMITER);
    String *rustproxyfile = NewStringf("%s%sproxy.rs", rustdir, SWIG_FILE_DELIMITER);

    f_rust = NewFile(rustfile, "w", SWIG_output_files());
    if (!f_rust) {
      FileErrorDisplay(rustfile);
      Exit(EXIT_FAILURE);
    }
    f_rust_ffi = NewFile(rustffifile, "w", SWIG_output_files());
    if (!f_rust_ffi) {
      FileErrorDisplay(rustffifile);
      Exit(EXIT_FAILURE);
    }
    f_rust_module = NewFile(rustmodulefile, "w", SWIG_output_files());
    if (!f_rust_module) {
      FileErrorDisplay(rustmodulefile);
      Exit(EXIT_FAILURE);
    }
    f_rust_runtime = NewFile(rustruntimefile, "w", SWIG_output_files());
    if (!f_rust_runtime) {
      FileErrorDisplay(rustruntimefile);
      Exit(EXIT_FAILURE);
    }
    f_rust_proxy = NewFile(rustproxyfile, "w", SWIG_output_files());
    if (!f_rust_proxy) {
      FileErrorDisplay(rustproxyfile);
      Exit(EXIT_FAILURE);
    }
    Delete(rustfile);
    Delete(rustffifile);
    Delete(rustmodulefile);
    Delete(rustruntimefile);
    Delete(rustproxyfile);
    Delete(rustdir);
    Delete(output_directory);

    f_runtime = NewString("");
    f_header = NewString("");
    f_wrappers = NewString("");
    f_init = NewString("");
    f_directors = NewString("");
    f_directors_h = NewString("");
    rust_ffi_code = NewString("");
    rust_item_modules = NewString("");
    rust_item_reexports = NewString("");
    rust_namespace_modules = NewHash();
    rust_namespace_reexports = NewHash();
    rust_namespace_declared = NewHash();
    rust_namespace_list = NewList();
    rust_extern_code = NewString("");
    rust_proxy_code = NewString("");
    rust_module_imports = NewString("");
    rust_module_code = NewString("");
    rust_extern_attributes = NewString("");
    rust_extern_pragmas = NewString("");
    rust_class_attributes = NewString("");
    rust_class_derives = NewString("");
    rust_class_code = NewString("");
    rust_visibility = NewString("pub");
    rust_exception_kind_mappings = NewString("");
    rust_exception_code_mappings = NewString("");
    rust_exception_code_constants = NewString("");
    dmethods_seq = NewList();
    dmethods_table = NewHash();
    n_dmethods = 0;

    Swig_register_filebyname("begin", f_begin);
    Swig_register_filebyname("runtime", f_runtime);
    Swig_register_filebyname("header", f_header);
    Swig_register_filebyname("wrapper", f_wrappers);
    Swig_register_filebyname("init", f_init);
    Swig_register_filebyname("director", f_directors);
    Swig_register_filebyname("director_h", f_directors_h);

    Swig_banner(f_begin);
    Swig_obligatory_macros(f_runtime, "RUST");
    Printf(f_runtime, "#include <stdlib.h>\n");
    Printf(f_runtime, "#include <string.h>\n\n");
    Printf(f_runtime, "#if defined(__cplusplus) && __cplusplus >= 201103L\n");
    Printf(f_runtime, "# define SWIGRUST_THREAD_LOCAL thread_local\n");
    Printf(f_runtime, "#elif defined(_MSC_VER)\n");
    Printf(f_runtime, "# define SWIGRUST_THREAD_LOCAL __declspec(thread)\n");
    Printf(f_runtime, "#elif defined(__GNUC__)\n");
    Printf(f_runtime, "# define SWIGRUST_THREAD_LOCAL __thread\n");
    Printf(f_runtime, "#else\n");
    Printf(f_runtime, "# define SWIGRUST_THREAD_LOCAL\n");
    Printf(f_runtime, "#endif\n\n");
    Printf(f_runtime, "static char *SWIG_RustStringCopy(const char *s) {\n");
    Printf(f_runtime, "  size_t len;\n");
    Printf(f_runtime, "  char *copy;\n");
    Printf(f_runtime, "  if (!s)\n");
    Printf(f_runtime, "    return 0;\n");
    Printf(f_runtime, "  len = strlen(s) + 1;\n");
    Printf(f_runtime, "  copy = (char *)malloc(len);\n");
    Printf(f_runtime, "  if (copy)\n");
    Printf(f_runtime, "    memcpy(copy, s, len);\n");
    Printf(f_runtime, "  return copy;\n");
    Printf(f_runtime, "}\n\n");
    Printf(f_runtime, "static SWIGRUST_THREAD_LOCAL char *SWIG_RustPendingExceptionType = 0;\n");
    Printf(f_runtime, "static SWIGRUST_THREAD_LOCAL char *SWIG_RustPendingException = 0;\n\n");
    Printf(f_runtime, "static void SWIG_RustSetPendingException(const char *kind, const char *message) {\n");
    Printf(f_runtime, "  if (SWIG_RustPendingExceptionType)\n");
    Printf(f_runtime, "    free(SWIG_RustPendingExceptionType);\n");
    Printf(f_runtime, "  if (SWIG_RustPendingException)\n");
    Printf(f_runtime, "    free(SWIG_RustPendingException);\n");
    Printf(f_runtime, "  SWIG_RustPendingExceptionType = SWIG_RustStringCopy(kind ? kind : \"std::exception\");\n");
    Printf(f_runtime, "  SWIG_RustPendingException = SWIG_RustStringCopy(message ? message : \"C++ exception\");\n");
    Printf(f_runtime, "}\n\n");

    if (Swig_directors_enabled()) {
      Printf(f_runtime, "#define SWIG_DIRECTORS\n");
      Swig_banner(f_directors_h);
      Printf(f_directors_h, "\n");
      Printf(f_directors_h, "#ifndef SWIG_%s_WRAP_H_\n", module_name);
      Printf(f_directors_h, "#define SWIG_%s_WRAP_H_\n\n", module_name);
      Printf(f_directors, "\n\n");
      Printf(f_directors, "/* ---------------------------------------------------\n");
      Printf(f_directors, " * C++ director class methods\n");
      Printf(f_directors, " * --------------------------------------------------- */\n\n");
      String *filename = Swig_file_filename(outfile_h);
      Printf(f_directors, "#include \"%s\"\n\n", filename);
      Delete(filename);
    }

    Swig_name_register("wrapper", "Rust_%f");
    Swig_name_register("construct", "new_%c");
    Swig_name_register("destroy", "delete_%c");

    Printf(f_wrappers, "\n#ifdef __cplusplus\n");
    Printf(f_wrappers, "extern \"C\" {\n");
    Printf(f_wrappers, "#endif\n\n");
    Printf(f_wrappers, "SWIGEXPORT void Rust_string_free(char *s) {\n");
    Printf(f_wrappers, "  free(s);\n");
    Printf(f_wrappers, "}\n\n");
    Printf(f_wrappers, "SWIGEXPORT char *Rust_take_exception(void) {\n");
    Printf(f_wrappers, "  char *message = SWIG_RustPendingException;\n");
    Printf(f_wrappers, "  SWIG_RustPendingException = 0;\n");
    Printf(f_wrappers, "  return message;\n");
    Printf(f_wrappers, "}\n\n");
    Printf(f_wrappers, "SWIGEXPORT char *Rust_take_exception_type(void) {\n");
    Printf(f_wrappers, "  char *kind = SWIG_RustPendingExceptionType;\n");
    Printf(f_wrappers, "  SWIG_RustPendingExceptionType = 0;\n");
    Printf(f_wrappers, "  return kind;\n");
    Printf(f_wrappers, "}\n\n");

    Printf(rust_extern_code, "  #[link_name = \"Rust_string_free\"]\n");
    Printf(rust_extern_code, "  pub fn Rust_string_free_raw(s: *mut c_char);\n");
    Printf(rust_extern_code, "  #[link_name = \"Rust_take_exception\"]\n");
    Printf(rust_extern_code, "  pub fn Rust_take_exception_raw() -> *mut c_char;\n");
    Printf(rust_extern_code, "  #[link_name = \"Rust_take_exception_type\"]\n");
    Printf(rust_extern_code, "  pub fn Rust_take_exception_type_raw() -> *mut c_char;\n");

    Language::top(n);

    if (Swig_directors_enabled()) {
      Swig_insert_file("director_common.swg", f_runtime);
      Swig_insert_file("director.swg", f_runtime);
    }

    Printf(f_wrappers, "\n#ifdef __cplusplus\n");
    Printf(f_wrappers, "}\n");
    Printf(f_wrappers, "#endif\n");

    if (Swig_directors_enabled()) {
      Printf(f_runtime_h, "\n");
      Dump(f_directors_h, f_runtime_h);
      Printf(f_runtime_h, "\n#endif\n");
    }

    writeRustNamespaceFiles();

    Swig_banner_target_lang(f_rust, "//");
    Printf(f_rust, "\n");
    rustFileAttributes(f_rust);
    Printf(f_rust, "mod ffi;\n");
    Printf(f_rust, "mod module;\n");
    Printf(f_rust, "mod runtime;\n\n");
    Dump(rust_item_modules, f_rust);
    if (Len(rust_item_modules))
      Printf(f_rust, "\n");
    Printf(f_rust, "mod proxy;\n\n");
    Printf(f_rust, "pub use self::module::*;\n");
    Dump(rust_item_reexports, f_rust);
    Printf(f_rust, "pub use self::proxy::*;\n");
    Printf(f_rust, "pub use self::runtime::{RustException, RustExceptionKind, RustOwnership};\n");
    if (Swig_directors_enabled())
      Printf(f_rust, "pub use self::runtime::{rust_director_error, RustDirectorError};\n");

    Swig_banner_target_lang(f_rust_module, "//");
    Printf(f_rust_module, "\n");
    rustFileAttributes(f_rust_module);
    Printf(f_rust_module,
           "use std::os::raw::{c_char, c_double, c_float, c_int, c_long, c_longlong, c_schar, c_short, c_uchar, c_uint, c_ulong, "
           "c_ulonglong, c_ushort, c_void};\n");
    Dump(rust_module_imports, f_rust_module);
    Printf(f_rust_module, "\n// Rust module code for the '%s' SWIG module.\n\n", crate_name);
    Dump(rust_module_code, f_rust_module);

    Swig_banner_target_lang(f_rust_ffi, "//");
    Printf(f_rust_ffi, "\n");
    rustFileAttributes(f_rust_ffi);
    Printf(f_rust_ffi, "use super::module::*;\n");
    Printf(f_rust_ffi,
           "use std::os::raw::{c_char, c_double, c_float, c_int, c_long, c_longlong, c_schar, c_short, c_uchar, c_uint, c_ulong, "
           "c_ulonglong, c_ushort, c_void};\n");
    Dump(rust_module_imports, f_rust_ffi);
    Dump(rust_ffi_code, f_rust_ffi);
    if (Len(rust_ffi_code))
      Printf(f_rust_ffi, "\n");
    Dump(rust_extern_attributes, f_rust_ffi);
    Printf(f_rust_ffi, "extern \"C\" {\n");
    Dump(rust_extern_pragmas, f_rust_ffi);
    Dump(rust_extern_code, f_rust_ffi);
    Printf(f_rust_ffi, "}\n");

    Swig_banner_target_lang(f_rust_runtime, "//");
    Printf(f_rust_runtime, "\n");
    rustFileAttributes(f_rust_runtime);
    Printf(f_rust_runtime, "use super::ffi::*;\n");
    Printf(f_rust_runtime,
           "use std::os::raw::{c_char, c_double, c_float, c_int, c_long, c_longlong, c_schar, c_short, c_uchar, c_uint, c_ulong, "
           "c_ulonglong, c_ushort, c_void};\n\n");
    Printf(f_rust_runtime, "#[derive(Clone, Copy, Debug, Eq, PartialEq)]\n");
    Printf(f_rust_runtime, "pub enum RustOwnership {\n");
    Printf(f_rust_runtime, "  Owned,\n");
    Printf(f_rust_runtime, "  Borrowed,\n");
    Printf(f_rust_runtime, "}\n\n");
    emitRustExceptionRuntime(f_rust_runtime);
    if (Swig_directors_enabled()) {
      emitRustDirectorRuntime(f_rust_runtime);
    }

    Swig_banner_target_lang(f_rust_proxy, "//");
    Printf(f_rust_proxy, "\n");
    rustFileAttributes(f_rust_proxy);
    Printf(f_rust_proxy, "use super::*;\n");
    Printf(f_rust_proxy, "use super::ffi::*;\n");
    Printf(f_rust_proxy, "use super::module::*;\n");
    Printf(f_rust_proxy, "use super::runtime::*;\n");
    Printf(f_rust_proxy,
           "use std::os::raw::{c_char, c_double, c_float, c_int, c_long, c_longlong, c_schar, c_short, c_uchar, c_uint, c_ulong, "
           "c_ulonglong, c_ushort, c_void};\n");
    Dump(rust_module_imports, f_rust_proxy);
    Printf(f_rust_proxy, "\n// Rust bindings for the '%s' SWIG module.\n", crate_name);
    Printf(f_rust_proxy, "// Link the generated wrapper library from your Rust build, for example with\n");
    Printf(f_rust_proxy, "// 'cargo:rustc-link-lib=dylib=%s'.\n\n", module_name);
    Dump(rust_proxy_code, f_rust_proxy);

    Dump(f_runtime, f_begin);
    Dump(f_header, f_begin);
    if (Swig_directors_enabled())
      Dump(f_directors, f_begin);
    Dump(f_wrappers, f_begin);
    Wrapper_pretty_print(f_init, f_begin);

    Delete(f_init);
    Delete(f_wrappers);
    Delete(f_header);
    Delete(f_runtime);
    Delete(f_directors);
    Delete(f_directors_h);
    if (f_runtime_h)
      Delete(f_runtime_h);
    Delete(f_rust);
    Delete(f_rust_ffi);
    Delete(f_rust_module);
    Delete(f_rust_runtime);
    Delete(f_rust_proxy);
    Delete(f_begin);
    Delete(rust_module_name);
    Delete(crate_name);
    Delete(rust_ffi_code);
    Delete(rust_item_modules);
    Delete(rust_item_reexports);
    Delete(rust_namespace_modules);
    Delete(rust_namespace_reexports);
    Delete(rust_namespace_declared);
    Delete(rust_namespace_list);
    Delete(rust_extern_code);
    Delete(rust_proxy_code);
    Delete(rust_module_imports);
    Delete(rust_module_code);
    Delete(rust_extern_attributes);
    Delete(rust_extern_pragmas);
    Delete(rust_class_attributes);
    Delete(rust_class_derives);
    Delete(rust_class_code);
    Delete(rust_visibility);
    Delete(rust_class_file_code);
    Delete(proxy_class_name);
    Delete(proxy_class_code);
    Delete(destructor_call);
    Delete(variable_name);
    Delete(rust_enum_from_i32_code);
    Delete(rust_exception_kind_mappings);
    Delete(rust_exception_code_mappings);
    Delete(rust_exception_code_constants);
    Delete(dmethods_seq);
    Delete(dmethods_table);
    Delete(director_rust_code);
    f_init = NULL;
    f_wrappers = NULL;
    f_header = NULL;
    f_runtime = NULL;
    f_directors = NULL;
    f_directors_h = NULL;
    f_runtime_h = NULL;
    f_rust = NULL;
    f_rust_ffi = NULL;
    f_rust_module = NULL;
    f_rust_runtime = NULL;
    f_rust_proxy = NULL;
    f_begin = NULL;
    rust_module_name = NULL;
    crate_name = NULL;
    rust_ffi_code = NULL;
    rust_item_modules = NULL;
    rust_item_reexports = NULL;
    rust_namespace_modules = NULL;
    rust_namespace_reexports = NULL;
    rust_namespace_declared = NULL;
    rust_namespace_list = NULL;
    rust_extern_code = NULL;
    rust_proxy_code = NULL;
    rust_module_imports = NULL;
    rust_module_code = NULL;
    rust_extern_attributes = NULL;
    rust_extern_pragmas = NULL;
    rust_class_attributes = NULL;
    rust_class_derives = NULL;
    rust_class_code = NULL;
    rust_visibility = NULL;
    rust_class_file_code = NULL;
    rust_class_extra_code = NULL;
    proxy_class_name = NULL;
    proxy_class_code = NULL;
    destructor_call = NULL;
    variable_name = NULL;
    rust_enum_from_i32_code = NULL;
    rust_exception_kind_mappings = NULL;
    rust_exception_code_mappings = NULL;
    rust_exception_code_constants = NULL;
    dmethods_seq = NULL;
    dmethods_table = NULL;
    director_rust_code = NULL;
    return SWIG_OK;
  }

  virtual int functionWrapper(Node *n) {
    String *symname = Getattr(n, "sym:name");
    SwigType *returntype = Getattr(n, "type");
    ParmList *parms = Getattr(n, "parms");
    String *tm = NULL;

    if (!Getattr(n, "sym:overloaded")) {
      if (!addSymbol(symname, n))
        return SWIG_ERROR;
    }

    String *overloaded_name = Copy(symname);
    if (Getattr(n, "sym:overloaded"))
      Append(overloaded_name, Getattr(n, "sym:overname"));

    String *wname = Swig_name_wrapper(overloaded_name);
    Setattr(n, "wrap:name", wname);

    Wrapper *f = NewWrapper();
    String *return_ctype = NewString("");
    String *return_imtype = NewString("");
    String *cleanup = NewString("");
    String *outarg = NewString("");

    Swig_typemap_attach_parms("ctype", parms, f);
    Swig_typemap_attach_parms("imtype", parms, f);
    Swig_typemap_attach_parms("rusttype", parms, f);
    Swig_typemap_attach_parms("rustin", parms, f);

    if ((tm = Swig_typemap_lookup("ctype", n, "", 0))) {
      String *ctypeout = Getattr(n, "tmap:ctype:out");
      Printv(return_ctype, ctypeout ? ctypeout : tm, NIL);
    } else {
      Swig_warning(WARN_TYPEMAP_UNDEF, input_file, line_number, "No ctype typemap defined for %s\n", SwigType_str(returntype, 0));
      Printv(return_ctype, SwigType_str(returntype, 0), NIL);
    }

    if ((tm = Swig_typemap_lookup("imtype", n, "", 0))) {
      String *imtypeout = Getattr(n, "tmap:imtype:out");
      Printv(return_imtype, imtypeout ? imtypeout : tm, NIL);
    } else {
      String *fallback = rustType(returntype);
      Printv(return_imtype, fallback, NIL);
      Delete(fallback);
    }
    String *return_enum_name = rustEnumNameForType(returntype);
    if (return_enum_name && rustTypeIsVoidPointer(return_imtype)) {
      Clear(return_imtype);
      Printf(return_imtype, "c_int");
    }
    Delete(return_enum_name);

    const bool is_void_return = Cmp(return_ctype, "void") == 0;

    if (!is_void_return)
      Wrapper_add_localv(f, "jresult", return_ctype, "jresult = 0", NIL);

    Printv(f->def, "SWIGEXPORT ", return_ctype, " ", wname, "(", NIL);
    emit_parameter_variables(parms, f);
    emit_attach_parmmaps(parms, f);
    Setattr(n, "wrap:parms", parms);

    String *rust_im_params = NewString("");
    String *rust_params = NewString("");
    String *rust_pre_code = NewString("");
    String *rust_post_code = NewString("");
    String *rust_terminator_code = NewString("");
    String *rust_args = NewString("");
    int gencomma = 0;
    int num_arguments = emit_num_arguments(parms);
    Parm *p = parms;
    for (int index = 0; index < num_arguments; index++) {
      while (p && checkAttribute(p, "tmap:in:numinputs", "0"))
        p = Getattr(p, "tmap:in:next");
      if (!p)
        break;

      SwigType *pt = Getattr(p, "type");
      String *lname = Getattr(p, "lname");
      String *arg = NewStringf("arg%d", index);
      String *c_arg_name = NewStringf("j%s", lname);
      String *c_param_type = Getattr(p, "tmap:ctype");
      String *im_param_type = Getattr(p, "tmap:imtype");
      String *rust_param_type = Getattr(p, "tmap:rusttype");
      String *rust_arg = Getattr(p, "tmap:rustin") ? Copy(Getattr(p, "tmap:rustin")) : Copy(arg);
      String *pre = Getattr(p, "tmap:rustin:pre");
      String *post = Getattr(p, "tmap:rustin:post");
      String *terminator = Getattr(p, "tmap:rustin:terminator");
      bool rust_param_type_owned = false;

      if (!c_param_type) {
        Swig_warning(WARN_TYPEMAP_UNDEF, input_file, line_number, "No ctype typemap defined for %s\n", SwigType_str(pt, 0));
        c_param_type = SwigType_str(pt, 0);
      }
      if (!im_param_type) {
        im_param_type = rustType(pt);
      } else {
        String *imtypeout = Getattr(p, "tmap:imtype:out");
        if (imtypeout)
          im_param_type = imtypeout;
      }
      String *param_enum_name = rustEnumNameForType(pt);
      if (param_enum_name && rustTypeIsVoidPointer(im_param_type))
        im_param_type = NewString("c_int");
      if (!rust_param_type) {
        rust_param_type = rustType(pt);
        rust_param_type_owned = true;
      } else {
        String *rusttypeout = Getattr(p, "tmap:rusttype:out");
        if (rusttypeout)
          rust_param_type = rusttypeout;
      }
      applyRustProxyInput(pt, arg, &rust_param_type, &rust_arg, &rust_param_type_owned);
      applyRustEnumInput(pt, arg, &rust_param_type, &rust_arg, &rust_param_type_owned);

      Replaceall(rust_arg, "$rustinput", arg);
      Replaceall(rust_arg, "$iminput", arg);
      if (pre) {
        String *pre_code = Copy(pre);
        Replaceall(pre_code, "$rustinput", arg);
        Replaceall(pre_code, "$iminput", arg);
        Printf(rust_pre_code, "  %s\n", pre_code);
        Delete(pre_code);
      }
      if (post) {
        String *post_code = Copy(post);
        Replaceall(post_code, "$rustinput", arg);
        Replaceall(post_code, "$iminput", arg);
        Printf(rust_post_code, "  %s\n", post_code);
        Delete(post_code);
      }
      if (terminator) {
        String *terminator_code = Copy(terminator);
        Replaceall(terminator_code, "$rustinput", arg);
        Replaceall(terminator_code, "$iminput", arg);
        String *indented_terminator_code = NewStringf("  %s\n", terminator_code);
        Insert(rust_terminator_code, 0, indented_terminator_code);
        Delete(indented_terminator_code);
        Delete(terminator_code);
      }

      Printv(f->def, gencomma ? ", " : "", c_param_type, " ", c_arg_name, NIL);
      Printv(rust_im_params, gencomma ? ", " : "", arg, ": ", im_param_type, NIL);
      Printv(rust_params, gencomma ? ", " : "", arg, ": ", rust_param_type, NIL);
      Printv(rust_args, gencomma ? ", " : "", rust_arg, NIL);
      gencomma = 1;

      if ((tm = Getattr(p, "tmap:in"))) {
        Replaceall(tm, "$arg", c_arg_name);
        Replaceall(tm, "$input", c_arg_name);
        Setattr(p, "emit:input", c_arg_name);
        Printf(f->code, "%s\n", tm);
        p = Getattr(p, "tmap:in:next");
      } else {
        Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, "Unable to use type %s as a function argument.\n", SwigType_str(pt, 0));
        p = nextSibling(p);
      }

      if (rust_param_type_owned)
        Delete(rust_param_type);
      Delete(param_enum_name);
      Delete(rust_arg);
      Delete(c_arg_name);
      Delete(arg);
    }

    Printf(f->def, ") {");

    for (p = parms; p;) {
      if ((tm = Getattr(p, "tmap:freearg"))) {
        Replaceall(tm, "$arg", Getattr(p, "emit:input"));
        Replaceall(tm, "$input", Getattr(p, "emit:input"));
        Printv(cleanup, tm, "\n", NIL);
        p = Getattr(p, "tmap:freearg:next");
      } else {
        p = nextSibling(p);
      }
    }

    for (p = parms; p;) {
      if ((tm = Getattr(p, "tmap:argout"))) {
        Replaceall(tm, "$arg", Getattr(p, "emit:input"));
        Replaceall(tm, "$result", "jresult");
        Replaceall(tm, "$input", Getattr(p, "emit:input"));
        Printv(outarg, tm, "\n", NIL);
        p = Getattr(p, "tmap:argout:next");
      } else {
        p = nextSibling(p);
      }
    }

    String *actioncode = emit_action(n);
    Replaceall(actioncode, "$null", is_void_return ? "" : "0");
    if (Strstr(actioncode, "darg")) {
      Node *current_class = getCurrentClass();
      if (current_class) {
        String *dirclassname = directorClassName(current_class);
        String *darg_decl = NewStringf("%s *darg", dirclassname);
        Wrapper_add_localv(f, "darg", darg_decl, "= 0", NIL);
        Printf(f->code, "darg = (%s *)arg1;\n", dirclassname);
        Delete(darg_decl);
        Delete(dirclassname);
      }
    }
    if ((tm = Swig_typemap_lookup_out("out", n, Swig_cresult_name(), f, actioncode))) {
      Replaceall(tm, "$result", "jresult");
      Replaceall(tm, "$owner", GetFlag(n, "feature:new") ? "1" : "0");
      Printf(f->code, "%s\n", tm);
      emit_return_variable(n, returntype, f);
    } else {
      Swig_warning(
        WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to use return type %s in function %s.\n", SwigType_str(returntype, 0), Getattr(n, "name"));
    }
    Printv(f->code, outarg, NIL);
    Printv(f->code, cleanup, NIL);
    if (!is_void_return)
      Printf(f->code, "return jresult;\n");
    Printf(f->code, "}\n");

    Wrapper_print(f, f_wrappers);
    writeRustFunction(n, overloaded_name, wname, return_imtype, rust_im_params, rust_params, rust_pre_code, rust_post_code, rust_terminator_code, rust_args);
    emitRustVariableAccessor(n, overloaded_name);

    Delete(outarg);
    Delete(cleanup);
    Delete(rust_terminator_code);
    Delete(rust_post_code);
    Delete(rust_pre_code);
    Delete(rust_params);
    Delete(rust_im_params);
    Delete(rust_args);
    Delete(return_imtype);
    Delete(return_ctype);
    Delete(wname);
    Delete(overloaded_name);
    DelWrapper(f);

    return SWIG_OK;
  }

  virtual int constantWrapper(Node *n) {
    String *symname = Getattr(n, "sym:name");
    String *value = Getattr(n, "value");
    SwigType *type = Getattr(n, "type");
    String *rust_type = rustType(type);

    if (!addSymbol(symname, n)) {
      Delete(rust_type);
      return SWIG_ERROR;
    }

    if (Getattr(n, "wrappedasconstant") && Getattr(n, "staticmembervariableHandler:value"))
      value = Getattr(n, "staticmembervariableHandler:value");

    if (value && rustTypeIsPrimitive(type)) {
      if (Getattr(n, "wrappedasconstant") && Getattr(n, "staticmembervariableHandler:value") && proxy_class_code && proxy_class_name) {
        String *prefix = NewStringf("%s_", proxy_class_name);
        String *member_name = Copy(symname);
        if (Strncmp(member_name, prefix, Len(prefix)) == 0) {
          String *stripped = NewString(Char(member_name) + Len(prefix));
          Delete(member_name);
          member_name = stripped;
        }
        String *rust_name = rustAssociatedConstantName(member_name);
        Printf(proxy_class_code, "  pub const %s: %s = %s;\n", rust_name, rust_type, value);
        Delete(rust_name);
        Delete(member_name);
        Delete(prefix);
      } else {
        String *rust_name = rustIdentifier(symname);
        Printf(rust_proxy_code, "%s const %s: %s = %s;\n", rust_visibility, rust_name, rust_type, value);
        Delete(rust_name);
      }
    } else {
      Swig_warning(WARN_LANG_NATIVE_UNIMPL, input_file, line_number, "Rust constant '%s' has unsupported type %s\n", symname, SwigType_str(type, 0));
    }

    Delete(rust_type);
    return SWIG_OK;
  }

  virtual int pragmaDirective(Node *n) {
    if (!ImportMode) {
      String *lang = Getattr(n, "lang");
      String *code = Getattr(n, "name");
      String *value = Getattr(n, "value");

      if (Strcmp(lang, "rust") == 0) {
        String *strvalue = NewString(value);
        Replaceall(strvalue, "\\\"", "\"");

        if (Strcmp(code, "moduleimports") == 0) {
          Printf(rust_module_imports, "%s\n", strvalue);
        } else if (Strcmp(code, "modulecode") == 0) {
          Printf(rust_module_code, "%s\n", strvalue);
        } else if (Strcmp(code, "externattributes") == 0) {
          Printf(rust_extern_attributes, "%s\n", strvalue);
        } else if (Strcmp(code, "externcode") == 0) {
          Printf(rust_extern_pragmas, "%s\n", strvalue);
        } else if (Strcmp(code, "classattributes") == 0) {
          Printf(rust_class_attributes, "%s\n", strvalue);
        } else if (Strcmp(code, "classderive") == 0) {
          Delete(rust_class_derives);
          rust_class_derives = Copy(strvalue);
        } else if (Strcmp(code, "classcode") == 0) {
          Printf(rust_class_code, "%s\n", strvalue);
        } else if (Strcmp(code, "visibility") == 0) {
          Delete(rust_visibility);
          rust_visibility = Copy(strvalue);
        } else if (Strcmp(code, "exceptionpolicy") == 0) {
          if (Strcmp(strvalue, "panic") == 0) {
            rust_exception_policy_result = false;
          } else if (Strcmp(strvalue, "result") == 0) {
            rust_exception_policy_result = true;
          } else {
            Swig_error(input_file, line_number, "Unsupported Rust exception policy '%s'. Expected 'panic' or 'result'.\n", strvalue);
          }
        } else if (Strcmp(code, "exceptionkind") == 0) {
          String *type_name = NULL;
          String *kind_name = NULL;
          if (!splitRustPragmaMapping(strvalue, &type_name, &kind_name)) {
            Swig_error(input_file, line_number, "Unsupported Rust exception kind mapping '%s'. Expected 'C++ type=RustExceptionKind'.\n", strvalue);
          } else {
            if (Strcmp(kind_name, "BadCast") != 0 && Strcmp(kind_name, "InvalidArgument") != 0 && Strcmp(kind_name, "OutOfRange") != 0 &&
                Strcmp(kind_name, "Overflow") != 0 && Strcmp(kind_name, "Runtime") != 0 && Strcmp(kind_name, "Logic") != 0 &&
                Strcmp(kind_name, "Unknown") != 0) {
              Swig_error(input_file, line_number, "Unsupported Rust exception kind '%s'.\n", kind_name);
            } else {
              Printf(rust_exception_kind_mappings, "      \"%s\" => Self::%s,\n", type_name, kind_name);
            }
          }
          Delete(kind_name);
          Delete(type_name);
        } else if (Strcmp(code, "exceptioncode") == 0) {
          String *type_name = NULL;
          String *code_name = NULL;
          if (!splitRustPragmaMapping(strvalue, &type_name, &code_name)) {
            Swig_error(input_file, line_number, "Unsupported Rust exception code mapping '%s'. Expected 'C++ type=CODE'.\n", strvalue);
          } else if (!rustIsPlainIdentifier(code_name)) {
            Swig_error(input_file, line_number, "Unsupported Rust exception code '%s'. Expected a plain Rust identifier.\n", code_name);
          } else {
            Printf(rust_exception_code_mappings, "    \"%s\" => Some(\"%s\"),\n", type_name, code_name);
            Printf(rust_exception_code_constants, "pub const %s: &str = \"%s\";\n", code_name, code_name);
            Printf(rust_module_code, "%s const %s: &str = \"%s\";\n", rust_visibility, code_name, code_name);
          }
          Delete(code_name);
          Delete(type_name);
        } else if (Strcmp(code, "methodcase") == 0) {
          if (Strcmp(strvalue, "preserve") == 0) {
            rust_method_case_snake = false;
          } else if (Strcmp(strvalue, "snake") == 0) {
            rust_method_case_snake = true;
          } else {
            Swig_error(input_file, line_number, "Unsupported Rust method case '%s'. Expected 'preserve' or 'snake'.\n", strvalue);
          }
        } else {
          Swig_error(input_file, line_number, "Unrecognized pragma.\n");
        }
        Delete(strvalue);
      }
    }
    return Language::pragmaDirective(n);
  }

  virtual int variableWrapper(Node *n) {
    return Language::variableWrapper(n);
  }

  virtual int globalvariableHandler(Node *n) {
    Delete(variable_name);
    variable_name = Copy(Getattr(n, "sym:name"));
    global_variable_flag = true;
    int result = Language::globalvariableHandler(n);
    global_variable_flag = false;
    return result;
  }

  virtual int membervariableHandler(Node *n) {
    Delete(variable_name);
    variable_name = Copy(Getattr(n, "sym:name"));
    member_variable_flag = true;
    int result = Language::membervariableHandler(n);
    member_variable_flag = false;
    return result;
  }

  virtual int staticmembervariableHandler(Node *n) {
    Delete(variable_name);
    variable_name = Copy(Getattr(n, "sym:name"));
    static_member_variable_flag = true;
    int result = Language::staticmembervariableHandler(n);
    static_member_variable_flag = false;
    return result;
  }

  virtual int classHandler(Node *n) {
    String *old_proxy_class_name = proxy_class_name;
    String *old_proxy_class_code = proxy_class_code;
    String *old_rust_class_file_code = rust_class_file_code;
    String *old_rust_class_extra_code = rust_class_extra_code;
    String *old_destructor_call = destructor_call;
    String *classname = Getattr(n, "sym:name");

    proxy_class_name = classname ? Copy(classname) : NULL;
    proxy_class_code = NewString("");
    rust_class_file_code = NewString("");
    rust_class_extra_code = NewString("");
    destructor_call = NewString("");

    int result = Language::classHandler(n);

    if (classname) {
      String *class_code = rust_class_file_code;
      String *classtype = Getattr(n, "classtypeobj");
      String *rustattributes = rustClassTypemap(n, "rustattributes", classtype, classname);
      String *rustderive = rustClassTypemap(n, "rustderive", classtype, classname);
      String *rustbody = rustClassTypemap(n, "rustbody", classtype, classname);
      String *rusttraits = rustClassTypemap(n, "rusttraits", classtype, classname);
      String *rustdrop = rustClassTypemap(n, "rustdrop", classtype, classname);
      Dump(rust_class_attributes, class_code);
      if (Len(rustattributes))
        Printf(class_code, "%s\n", rustattributes);
      if (Len(rust_class_derives))
        Printf(class_code, "#[derive(%s)]\n", rust_class_derives);
      else if (Len(rustderive))
        Printf(class_code, "#[derive(%s)]\n", rustderive);
      Printf(class_code, "%s struct %s {\n", rust_visibility, classname);
      Printf(class_code, "  ptr: std::ptr::NonNull<c_void>,\n");
      Printf(class_code, "  ownership: RustOwnership,\n");
      Printf(class_code, "}\n\n");
      Printf(class_code, "%s struct %sBorrowed<'a> {\n", rust_visibility, classname);
      Printf(class_code, "  proxy: %s,\n", classname);
      Printf(class_code, "  _marker: std::marker::PhantomData<&'a %s>,\n", classname);
      Printf(class_code, "}\n\n");
      Printf(class_code, "%s struct %sBorrowedMut<'a> {\n", rust_visibility, classname);
      Printf(class_code, "  proxy: %s,\n", classname);
      Printf(class_code, "  _marker: std::marker::PhantomData<&'a mut %s>,\n", classname);
      Printf(class_code, "}\n\n");
      Printf(class_code, "impl<'a> %sBorrowed<'a> {\n", classname);
      Printf(class_code, "  pub fn as_proxy(&self) -> &%s {\n", classname);
      Printf(class_code, "    &self.proxy\n");
      Printf(class_code, "  }\n");
      Printf(class_code, "}\n\n");
      Printf(class_code, "impl<'a> %sBorrowedMut<'a> {\n", classname);
      Printf(class_code, "  pub fn as_proxy(&self) -> &%s {\n", classname);
      Printf(class_code, "    &self.proxy\n");
      Printf(class_code, "  }\n");
      Printf(class_code, "  pub fn as_proxy_mut(&mut self) -> &mut %s {\n", classname);
      Printf(class_code, "    &mut self.proxy\n");
      Printf(class_code, "  }\n");
      Printf(class_code, "}\n\n");
      Printf(class_code, "impl<'a> std::ops::Deref for %sBorrowed<'a> {\n", classname);
      Printf(class_code, "  type Target = %s;\n", classname);
      Printf(class_code, "  fn deref(&self) -> &Self::Target {\n");
      Printf(class_code, "    &self.proxy\n");
      Printf(class_code, "  }\n");
      Printf(class_code, "}\n\n");
      Printf(class_code, "impl<'a> std::ops::Deref for %sBorrowedMut<'a> {\n", classname);
      Printf(class_code, "  type Target = %s;\n", classname);
      Printf(class_code, "  fn deref(&self) -> &Self::Target {\n");
      Printf(class_code, "    &self.proxy\n");
      Printf(class_code, "  }\n");
      Printf(class_code, "}\n\n");
      Printf(class_code, "impl<'a> std::ops::DerefMut for %sBorrowedMut<'a> {\n", classname);
      Printf(class_code, "  fn deref_mut(&mut self) -> &mut Self::Target {\n");
      Printf(class_code, "    &mut self.proxy\n");
      Printf(class_code, "  }\n");
      Printf(class_code, "}\n\n");
      Printf(class_code, "impl %s {\n", classname);
      Printf(class_code, "  pub unsafe fn from_raw(ptr: *mut c_void) -> Option<Self> {\n");
      Printf(class_code, "    Self::from_raw_owned(ptr, true)\n");
      Printf(class_code, "  }\n");
      Printf(class_code, "  pub unsafe fn borrowed(ptr: *mut c_void) -> Option<Self> {\n");
      Printf(class_code, "    Self::from_raw_owned(ptr, false)\n");
      Printf(class_code, "  }\n");
      Printf(class_code, "  pub unsafe fn from_raw_owned(ptr: *mut c_void, owned: bool) -> Option<Self> {\n");
      Printf(class_code, "    std::ptr::NonNull::new(ptr).map(|ptr| Self {\n");
      Printf(class_code, "      ptr,\n");
      Printf(class_code, "      ownership: if owned { RustOwnership::Owned } else { RustOwnership::Borrowed },\n");
      Printf(class_code, "    })\n");
      Printf(class_code, "  }\n");
      Printf(class_code, "  pub(crate) unsafe fn from_raw_owned_unchecked(ptr: *mut c_void, owned: bool) -> Self {\n");
      Printf(class_code, "    Self::from_raw_owned(ptr, owned).expect(\"SWIG returned a null pointer for a non-null Rust proxy\")\n");
      Printf(class_code, "  }\n");
      Printf(class_code, "  pub fn as_ptr(&self) -> *const c_void {\n");
      Printf(class_code, "    self.ptr.as_ptr() as *const c_void\n");
      Printf(class_code, "  }\n");
      Printf(class_code, "  pub(crate) fn as_mut_ptr(&self) -> *mut c_void {\n");
      Printf(class_code, "    self.ptr.as_ptr()\n");
      Printf(class_code, "  }\n");
      Printf(class_code, "  pub(crate) fn as_non_null(&self) -> std::ptr::NonNull<c_void> {\n");
      Printf(class_code, "    self.ptr\n");
      Printf(class_code, "  }\n");
      Printf(class_code, "  pub fn ownership(&self) -> RustOwnership {\n");
      Printf(class_code, "    self.ownership\n");
      Printf(class_code, "  }\n");
      Printf(class_code, "  pub fn is_owned(&self) -> bool {\n");
      Printf(class_code, "    self.ownership == RustOwnership::Owned\n");
      Printf(class_code, "  }\n");
      Printf(class_code, "  pub fn is_borrowed(&self) -> bool {\n");
      Printf(class_code, "    self.ownership == RustOwnership::Borrowed\n");
      Printf(class_code, "  }\n");
      Printf(class_code, "  pub fn borrow_proxy(&self) -> %sBorrowed<'_> {\n", classname);
      Printf(
        class_code, "    %sBorrowed { proxy: Self { ptr: self.ptr, ownership: RustOwnership::Borrowed }, _marker: std::marker::PhantomData }\n", classname);
      Printf(class_code, "  }\n");
      Printf(class_code, "  pub fn borrow_proxy_mut(&mut self) -> %sBorrowedMut<'_> {\n", classname);
      Printf(
        class_code, "    %sBorrowedMut { proxy: Self { ptr: self.ptr, ownership: RustOwnership::Borrowed }, _marker: std::marker::PhantomData }\n", classname);
      Printf(class_code, "  }\n");
      Printf(class_code, "  pub fn disown(&mut self) {\n");
      Printf(class_code, "    self.ownership = RustOwnership::Borrowed;\n");
      Printf(class_code, "  }\n");
      Printf(class_code, "  pub fn into_raw(mut self) -> *mut c_void {\n");
      Printf(class_code, "    let ptr = self.ptr.as_ptr();\n");
      Printf(class_code, "    self.ownership = RustOwnership::Borrowed;\n");
      Printf(class_code, "    std::mem::forget(self);\n");
      Printf(class_code, "    ptr\n");
      Printf(class_code, "  }\n");
      if (List *baselist = Getattr(n, "bases")) {
        for (Iterator base = First(baselist); base.item; base = Next(base)) {
          SwigType *baseclassname = Getattr(base.item, "name");
          String *basename = SwigType_namestr(baseclassname);
          String *baseproxyname = Getattr(base.item, "sym:name") ? Copy(Getattr(base.item, "sym:name")) : Copy(basename);
          String *base_method_name = rustIdentifier(basename);
          Replaceall(base_method_name, "::", "_");
          Printf(class_code, "  pub fn as_%s(&self) -> %s {\n", base_method_name, baseproxyname);
          Printf(class_code, "    unsafe { %s::from_raw_owned_unchecked(self.as_mut_ptr(), false) }\n", baseproxyname);
          Printf(class_code, "  }\n");
          Printf(class_code, "  pub fn as_%s_mut(&mut self) -> %s {\n", base_method_name, baseproxyname);
          Printf(class_code, "    unsafe { %s::from_raw_owned_unchecked(self.as_mut_ptr(), false) }\n", baseproxyname);
          Printf(class_code, "  }\n");
          Delete(base_method_name);
          Delete(baseproxyname);
          Delete(basename);
        }
      }
      if (Len(destructor_call) > 0) {
        Printf(class_code, "  unsafe fn delete_owned(&mut self) {\n");
        Printf(class_code, "    if self.ownership == RustOwnership::Owned {\n");
        if (Len(rustdrop)) {
          String *drop_code = Copy(rustdrop);
          Replaceall(drop_code, "$self", "self");
          Printf(class_code, "      %s\n", drop_code);
          Delete(drop_code);
        }
        Printf(class_code, "      %s;\n", destructor_call);
        Printf(class_code, "      self.ownership = RustOwnership::Borrowed;\n");
        Printf(class_code, "    }\n");
        Printf(class_code, "  }\n");
        Printf(class_code, "  pub fn delete(mut self) {\n");
        Printf(class_code, "    unsafe { self.delete_owned(); }\n");
        Printf(class_code, "    std::mem::forget(self);\n");
        Printf(class_code, "  }\n");
      }
      Printv(class_code, proxy_class_code, NIL);
      if (Len(rustbody))
        Printf(class_code, "%s\n", rustbody);
      Dump(rust_class_code, class_code);
      Printf(class_code, "}\n\n");
      if (Len(rusttraits))
        Printf(class_code, "%s\n", rusttraits);
      if (Len(destructor_call) > 0) {
        Printf(class_code, "impl Drop for %s {\n", classname);
        Printf(class_code, "  fn drop(&mut self) {\n");
        Printf(class_code, "    unsafe { self.delete_owned(); }\n");
        Printf(class_code, "  }\n");
        Printf(class_code, "}\n\n");
      }
      Dump(rust_class_extra_code, class_code);
      if (Getattr(n, "rust:directorcode"))
        Printv(class_code, Getattr(n, "rust:directorcode"), NIL);
      writeRustItemFile("class", classname, class_code, getNSpace());
      Delete(rustattributes);
      Delete(rustderive);
      Delete(rustbody);
      Delete(rusttraits);
      Delete(rustdrop);
    }

    if (proxy_class_name && proxy_class_name != old_proxy_class_name)
      Delete(proxy_class_name);
    proxy_class_name = old_proxy_class_name;
    if (proxy_class_code && proxy_class_code != old_proxy_class_code)
      Delete(proxy_class_code);
    proxy_class_code = old_proxy_class_code;
    if (rust_class_file_code && rust_class_file_code != old_rust_class_file_code)
      Delete(rust_class_file_code);
    rust_class_file_code = old_rust_class_file_code;
    if (rust_class_extra_code && rust_class_extra_code != old_rust_class_extra_code)
      Delete(rust_class_extra_code);
    rust_class_extra_code = old_rust_class_extra_code;
    if (destructor_call && destructor_call != old_destructor_call)
      Delete(destructor_call);
    destructor_call = old_destructor_call;

    return result;
  }

  virtual int memberfunctionHandler(Node *n) {
    Language::memberfunctionHandler(n);
    emitProxyFunction(n, false);
    emitProxyFunction(n, false, true);
    return SWIG_OK;
  }

  virtual int staticmemberfunctionHandler(Node *n) {
    Language::staticmemberfunctionHandler(n);
    emitProxyFunction(n, true);
    emitProxyFunction(n, true, true);
    emitDirectorFactoryHelper(n);
    return SWIG_OK;
  }

  virtual int constructorHandler(Node *n) {
    Language::constructorHandler(n);
    if (emit_num_required(Getattr(n, "parms")) == 0)
      SetFlag(getCurrentClass(), "rust:default_constructor");
    emitProxyConstructor(n);
    emitProxyConstructor(n, true);
    return SWIG_OK;
  }

  virtual int destructorHandler(Node *n) {
    Language::destructorHandler(n);
    String *symname = Getattr(n, "sym:name");
    if (proxy_class_name && destructor_call) {
      Clear(destructor_call);
      Printf(destructor_call, "%s_raw(self.ptr.as_ptr())", Swig_name_destroy(getNSpace(), symname));
    }
    return SWIG_OK;
  }

  virtual int enumDeclaration(Node *n) {
    if (ImportMode)
      return SWIG_OK;

    String *symname = Getattr(n, "sym:name");
    String *old_enum_code = proxy_class_code;
    String *old_enum_from_i32_code = rust_enum_from_i32_code;
    String *enum_code = NewString("");
    String *rust_enum_name = symname ? rustIdentifier(symname) : NULL;
    String *scope = NULL;
    String *nspace = Getattr(n, "sym:nspace");
    proxy_class_code = enum_code;
    rust_enum_from_i32_code = NewString("");

    if (symname && !Getattr(n, "unnamedinstance")) {
      if (getCurrentClass()) {
        Delete(rust_enum_name);
        rust_enum_name = Swig_name_member(getNSpace(), getClassPrefix(), symname);
        scope = Copy(getClassPrefix());
      } else if (nspace) {
        scope = Copy(nspace);
      }
      if (!addSymbol(symname, n, scope))
        return SWIG_ERROR;
      Setattr(n, "rust:enumname", rust_enum_name);
      Printf(enum_code, "#[repr(C)]\n");
      Printf(enum_code, "#[derive(Copy, Clone, Debug, PartialEq, Eq)]\n");
      Printf(enum_code, "pub enum %s {\n", rust_enum_name);
      Language::enumDeclaration(n);
      Printf(enum_code, "}\n\n");
      Printf(enum_code, "impl %s {\n", rust_enum_name);
      Printf(enum_code, "  pub fn from_i32(value: c_int) -> Option<Self> {\n");
      Printf(enum_code, "    match value {\n");
      Dump(rust_enum_from_i32_code, enum_code);
      Printf(enum_code, "      _ => None,\n");
      Printf(enum_code, "    }\n");
      Printf(enum_code, "  }\n");
      Printf(enum_code, "  pub fn value(self) -> c_int {\n");
      Printf(enum_code, "    self as c_int\n");
      Printf(enum_code, "  }\n");
      Printf(enum_code, "}\n\n");
      Printf(enum_code, "impl std::convert::TryFrom<c_int> for %s {\n", rust_enum_name);
      Printf(enum_code, "  type Error = RustException;\n");
      Printf(enum_code, "  fn try_from(value: c_int) -> Result<Self, RustException> {\n");
      Printf(
        enum_code, "    Self::from_i32(value).ok_or_else(|| RustException::new_unknown(format!(\"invalid enum value {} for %s\", value)))\n", rust_enum_name);
      Printf(enum_code, "  }\n");
      Printf(enum_code, "}\n\n");
      Printf(enum_code, "impl From<%s> for c_int {\n", rust_enum_name);
      Printf(enum_code, "  fn from(value: %s) -> Self {\n", rust_enum_name);
      Printf(enum_code, "    value.value()\n");
      Printf(enum_code, "  }\n");
      Printf(enum_code, "}\n\n");
      if (getCurrentClass())
        Printv(rustItemTarget(), enum_code, NIL);
      else
        writeRustItemFile("enum", rust_enum_name, enum_code, nspace);
    } else {
      Language::enumDeclaration(n);
    }

    proxy_class_code = old_enum_code;
    Delete(rust_enum_from_i32_code);
    rust_enum_from_i32_code = old_enum_from_i32_code;
    Delete(scope);
    Delete(rust_enum_name);
    Delete(enum_code);
    return SWIG_OK;
  }

  bool rustEnumValueIsIntegerLiteral(String *value) const {
    if (!value)
      return false;

    const char *text = Char(value);
    if (!text || !*text)
      return false;

    if (*text == '-' || *text == '+')
      ++text;
    if (!*text)
      return false;

    if (text[0] == '0' && (text[1] == 'x' || text[1] == 'X')) {
      text += 2;
      if (!*text)
        return false;
      while (*text) {
        bool digit = (*text >= '0' && *text <= '9') || (*text >= 'a' && *text <= 'f') || (*text >= 'A' && *text <= 'F');
        if (!digit)
          return false;
        ++text;
      }
      return true;
    }

    while (*text) {
      if (*text < '0' || *text > '9')
        return false;
      ++text;
    }
    return true;
  }

  virtual int enumvalueDeclaration(Node *n) {
    Swig_require("enumvalueDeclaration", n, "*name", "?value", NIL);
    String *symname = Getattr(n, "sym:name");
    String *value = Getattr(n, "enumvalue") ? Getattr(n, "enumvalue") : Getattr(n, "value");
    Node *parent = parentNode(n);
    String *parent_name = Getattr(parent, "sym:name");

    if (parent_name && proxy_class_code) {
      String *scope = Getattr(parent, "rust:enumname") ? Copy(Getattr(parent, "rust:enumname")) : Copy(parent_name);
      String *rust_name = rustIdentifier(symname);
      if (!addSymbol(symname, n, scope)) {
        Delete(rust_name);
        Delete(scope);
        return SWIG_ERROR;
      }
      Printf(proxy_class_code, "  %s", rust_name);
      if (rustEnumValueIsIntegerLiteral(value))
        Printf(proxy_class_code, " = %s", value);
      Printf(proxy_class_code, ",\n");
      if (rust_enum_from_i32_code)
        Printf(rust_enum_from_i32_code, "      x if x == Self::%s as c_int => Some(Self::%s),\n", rust_name, rust_name);
      Delete(rust_name);
      Delete(scope);
    } else if (value) {
      String *rust_name = rustIdentifier(symname);
      if (!addSymbol(symname, n)) {
        Delete(rust_name);
        return SWIG_ERROR;
      }
      Printf(rust_proxy_code, "pub const %s: c_int = %s;\n", rust_name, value);
      Delete(rust_name);
    }

    Swig_restore(n);
    return SWIG_OK;
  }

  virtual int classDirectorInit(Node *n) {
    Delete(director_ctor_code);
    director_ctor_code = NewString("$director_new");

    directorDeclaration(n);

    Printf(f_directors_h, "%s {\n", Getattr(n, "director:decl"));
    Printf(f_directors_h, "\npublic:\n");

    first_class_dmethod = curr_class_dmethod = n_dmethods;
    director_callback_typedefs = NewString("");
    director_callbacks = NewString("");
    director_connect_parms = NewString("");
    director_trait_code = NewStringf("pub trait %sDirector {\n", Getattr(n, "sym:name"));
    director_callback_shims = NewString("");
    director_method_metadata = NewString("");
    Delete(director_rust_code);
    director_rust_code = NewString("");

    return Language::classDirectorInit(n);
  }

  virtual int classDirectorConstructor(Node *n) {
    Node *parent = parentNode(n);
    String *decl = Getattr(n, "decl");
    String *dirclassname = directorClassName(parent);
    ParmList *superparms = Getattr(n, "parms");
    ParmList *parms = CopyParmList(superparms);
    int argidx = 0;

    for (Parm *p = superparms; p; p = nextSibling(p)) {
      String *pname = Getattr(p, "name");
      if (!pname) {
        pname = NewStringf("arg%d", argidx++);
        Setattr(p, "name", pname);
      }
    }

    if (!Getattr(n, "defaultargs")) {
      String *basetype = Getattr(parent, "classtype");
      String *target = Swig_method_decl(0, decl, dirclassname, parms, 0);
      String *call = Swig_csuperclass_call(0, basetype, superparms);

      Printf(f_directors, "%s::%s : %s, %s {\n", dirclassname, target, call, Getattr(parent, "director:ctor"));
      Printf(f_directors, "  swig_init_callbacks();\n");
      Printf(f_directors, "}\n\n");

      Delete(target);
      Delete(call);

      target = Swig_method_decl(0, decl, dirclassname, parms, 1);
      Printf(f_directors_h, "    %s;\n", target);
      Delete(target);
    }

    Delete(parms);
    Delete(dirclassname);
    return Language::classDirectorConstructor(n);
  }

  virtual int classDirectorDefaultConstructor(Node *n) {
    String *dirclassname = directorClassName(n);
    Wrapper *w = NewWrapper();

    Printf(w->def, "%s::%s() : %s {", dirclassname, dirclassname, Getattr(n, "director:ctor"));
    Printf(w->code, "  swig_init_callbacks();\n");
    Printf(w->code, "}\n");
    Wrapper_print(w, f_directors);

    Printf(f_directors_h, "    %s();\n", dirclassname);
    DelWrapper(w);
    Delete(dirclassname);
    return Language::classDirectorDefaultConstructor(n);
  }

  virtual int classDirectorMethod(Node *n, Node *parent, String *super) {
    String *classname = Getattr(parent, "sym:name");
    String *c_classname = Getattr(parent, "name");
    String *name = Getattr(n, "name");
    String *symname = Getattr(n, "sym:name");
    SwigType *returntype = Getattr(n, "type");
    String *storage = Getattr(n, "storage");
    String *value = Getattr(n, "value");
    String *decl = Getattr(n, "decl");
    ParmList *l = Getattr(n, "parms");
    bool is_void = Cmp(returntype, "void") == 0;
    bool pure_virtual = Cmp(storage, "virtual") == 0 && Cmp(value, "0") == 0;
    bool ignored_method = GetFlag(n, "feature:ignore") ? true : false;
    bool output_director = true;
    String *overloaded_name = ignored_method ? NULL : getOverloadedName(n);
    String *dirclassname = directorClassName(parent);
    String *qualified_name = NewStringf("%s::%s", dirclassname, name);
    String *qualified_return = SwigType_rcaststr(returntype, "c_result");
    String *c_ret_type = NULL;
    String *callback_typedef_parms = NewString("");
    String *callback_args = NewString("");
    String *rust_callback_type = NewString("");
    String *rust_trait_params = NewString("");
    String *rust_shim_params = NewString("");
    String *rust_shim_args = NewString("");
    String *rust_shim_pre_code = NewString("");
    String *rust_shim_post_code = NewString("");
    String *rust_shim_terminator_code = NewString("");
    String *rust_method_types = NewString("");
    String *declaration = NewString("");
    Wrapper *w = NewWrapper();
    int status = SWIG_OK;

    if (!is_void && (!ignored_method || pure_virtual)) {
      if (SwigType_ispointer(returntype) || SwigType_isreference(returntype)) {
        Wrapper_add_localv(w, "c_result", SwigType_lstr(returntype, "c_result"), "= 0", NIL);
      } else {
        String *construct_result = NewStringf("= SwigValueInit< %s >()", SwigType_lstr(returntype, 0));
        Wrapper_add_localv(w, "c_result", SwigType_lstr(returntype, "c_result"), construct_result, NIL);
        Delete(construct_result);
      }
    }

    c_ret_type = Swig_typemap_lookup("ctype", n, "", 0);
    if (c_ret_type) {
      String *ctypeout = Getattr(n, "tmap:ctype:out");
      if (ctypeout)
        c_ret_type = ctypeout;
      if (!is_void && !ignored_method) {
        String *jretval_decl = NewStringf("%s jresult", c_ret_type);
        Wrapper_add_localv(w, "jresult", jretval_decl, "= 0", NIL);
        Delete(jretval_decl);
      }
    } else {
      Swig_warning(WARN_TYPEMAP_UNDEF,
                   input_file,
                   line_number,
                   "No ctype typemap defined for %s for use in %s::%s (skipping director method)\n",
                   SwigType_str(returntype, 0),
                   SwigType_namestr(c_classname),
                   SwigType_namestr(name));
      output_director = false;
    }

    Swig_director_parms_fixup(l);
    Swig_typemap_attach_parms("out", l, 0);
    Swig_typemap_attach_parms("ctype", l, 0);
    Swig_typemap_attach_parms("imtype", l, 0);
    Swig_typemap_attach_parms("rusttype", l, 0);
    Swig_typemap_attach_parms("directorin", l, w);
    Swig_typemap_attach_parms("rustdirectorin", l, 0);
    Swig_typemap_attach_parms("directorargout", l, w);

    if (!ignored_method)
      Printf(w->code, "if (!swig_callback%s) {\n", overloaded_name);

    if (!pure_virtual) {
      String *super_call = Swig_method_call(super, l);
      if (is_void) {
        Printf(w->code, "%s;\n", super_call);
        if (!ignored_method)
          Printf(w->code, "return;\n");
      } else {
        Printf(w->code, "return %s;\n", super_call);
      }
      Delete(super_call);
    } else {
      Printf(w->code, "Swig::DirectorPureVirtualException::raise(\"%s::%s\");\n", SwigType_namestr(c_classname), SwigType_namestr(name));
      if (!is_void)
        Printf(w->code, "return %s;\n", qualified_return);
      else if (!ignored_method)
        Printf(w->code, "return;\n");
    }

    if (!ignored_method)
      Printf(w->code, "} else {\n");

    int i = 0;
    for (Parm *p = l; p;) {
      while (p && checkAttribute(p, "tmap:directorin:numinputs", "0"))
        p = Getattr(p, "tmap:directorin:next");
      if (!p)
        break;

      SwigType *pt = Getattr(p, "type");
      if (SwigType_type(pt) == T_VOID) {
        p = nextSibling(p);
        i++;
        continue;
      }

      String *ln = makeParameterName(n, p, i, false);
      String *arg = NewStringf("j%s", ln);
      String *rust_arg = NewStringf("arg%d", i);
      String *c_param_type = Getattr(p, "tmap:ctype");
      String *c_decl = NewString("");
      String *im_type = Getattr(p, "tmap:imtype");
      String *rust_type = Getattr(p, "tmap:rusttype");
      String *owned_im_type = NULL;
      String *owned_rust_type = NULL;

      if (c_param_type) {
        String *ctypeout = Getattr(p, "tmap:ctype:out");
        if (ctypeout)
          c_param_type = ctypeout;
        if (im_type) {
          String *imtypeout = Getattr(p, "tmap:imtype:out");
          if (imtypeout)
            im_type = imtypeout;
        } else {
          owned_im_type = rustType(pt);
          im_type = owned_im_type;
        }
        if (rust_type) {
          String *rusttypeout = Getattr(p, "tmap:rusttype:out");
          if (rusttypeout)
            rust_type = rusttypeout;
        } else {
          owned_rust_type = rustType(pt);
          rust_type = owned_rust_type;
        }

        Printf(c_decl, "%s %s", c_param_type, arg);
        if (!ignored_method)
          Wrapper_add_localv(w, arg, c_decl, SwigType_ispointer(pt) || SwigType_isreference(pt) ? "= 0" : "", NIL);

        String *tm = Getattr(p, "tmap:directorin");
        if (tm) {
          Setattr(p, "emit:directorinput", arg);
          Replaceall(tm, "$input", arg);
          Replaceall(tm, "$owner", "0");
          if (Len(tm) && !ignored_method)
            Printf(w->code, "%s\n", tm);

          if (Len(callback_typedef_parms))
            Printf(callback_typedef_parms, ", ");
          Printf(callback_typedef_parms, "%s", c_param_type);

          Printf(callback_args, ", %s", arg);

          if (Len(rust_callback_type))
            Printf(rust_callback_type, ", ");
          Printf(rust_callback_type, "%s", im_type);

          String *enum_director_type = rustEnumNameForType(pt);
          bool proxy_director_pointer = false;
          bool proxy_director_reference = false;
          String *proxy_director_type = NULL;
          String *proxy_director_arg = NULL;
          String *proxy_director_name = NULL;
          if (!enum_director_type && rustTypeIsVoidPointer(im_type)) {
            proxy_director_name = rustProxyNameForType(pt, &proxy_director_pointer, &proxy_director_reference);
            if (proxy_director_name) {
              SwigType *resolved_pt = SwigType_typedef_resolve_all(pt);
              SwigType *stripped_pt = SwigType_strip_qualifiers(resolved_pt);
              bool proxy_director_smart = rustTypeIsSmartPointer(stripped_pt);
              bool proxy_director_smart_owned = proxy_director_smart && !SwigType_ispointer(stripped_pt) && !SwigType_isreference(stripped_pt);
              SwigType *base = Copy(pt);
              if (proxy_director_pointer) {
                if (SwigType_isreference(base))
                  SwigType_del_reference(base);
                if (SwigType_ispointer(base))
                  SwigType_del_pointer(base);
              } else if (proxy_director_reference) {
                SwigType_del_reference(base);
              }
              bool is_const = SwigType_isconst(base);
              String *proxy_var = NewStringf("arg%d_proxy", i);
              if (proxy_director_smart) {
                proxy_director_type = NewStringf("Option<%s>", proxy_director_name);
                proxy_director_arg = Copy(proxy_var);
                Printf(rust_shim_pre_code,
                       "    let %s = if arg%d.is_null() { None } else { Some(unsafe { %s::from_raw_owned_unchecked(arg%d, %s) }) };\n",
                       proxy_var,
                       i,
                       proxy_director_name,
                       i,
                       proxy_director_smart_owned ? "true" : "false");
              } else if (proxy_director_pointer) {
                if (is_const) {
                  proxy_director_type = NewStringf("Option<&%s>", proxy_director_name);
                  proxy_director_arg = NewStringf("%s.as_ref()", proxy_var);
                } else {
                  proxy_director_type = NewStringf("Option<&mut %s>", proxy_director_name);
                  proxy_director_arg = NewStringf("%s.as_mut()", proxy_var);
                }
                Printf(rust_shim_pre_code,
                       "    let %s%s = if arg%d.is_null() { None } else { Some(unsafe { %s::from_raw_owned_unchecked(arg%d, false) }) };\n",
                       is_const ? "" : "mut ",
                       proxy_var,
                       i,
                       proxy_director_name,
                       i);
              } else {
                if (proxy_director_reference) {
                  proxy_director_type = NewStringf("%s%s", is_const ? "&" : "&mut ", proxy_director_name);
                  proxy_director_arg = NewStringf("%s%s", is_const ? "&" : "&mut ", proxy_var);
                  Printf(rust_shim_pre_code,
                         "    let %s%s = unsafe { %s::from_raw_owned_unchecked(arg%d, false) };\n",
                         is_const ? "" : "mut ",
                         proxy_var,
                         proxy_director_name,
                         i);
                } else {
                  proxy_director_type = Copy(proxy_director_name);
                  proxy_director_arg = Copy(proxy_var);
                  Printf(rust_shim_pre_code, "    let %s = unsafe { %s::from_raw_owned_unchecked(arg%d, true) };\n", proxy_var, proxy_director_name, i);
                }
              }
              Delete(proxy_var);
              Delete(base);
              Delete(stripped_pt);
              Delete(resolved_pt);
            } else {
              Delete(proxy_director_name);
              proxy_director_name = NULL;
            }
          }
          String *rust_trait_type = enum_director_type ? enum_director_type : (proxy_director_type ? proxy_director_type : rust_type);
          String *enum_director_arg =
            enum_director_type
              ? NewStringf("%s::from_i32(%s).expect(\"SWIG passed an invalid value for enum %s\")", enum_director_type, rust_arg, enum_director_type)
              : NULL;

          if (Len(rust_trait_params))
            Printf(rust_trait_params, ", ");
          Printf(rust_trait_params, "_arg%d: %s", i, rust_trait_type);

          if (Len(rust_shim_params))
            Printf(rust_shim_params, ", ");
          Printf(rust_shim_params, "arg%d: %s", i, im_type);

          String *din = Copy(Getattr(p, "tmap:rustdirectorin"));
          if (din) {
            if (Len(rust_shim_args))
              Printf(rust_shim_args, ", ");
            if (enum_director_arg) {
              Printv(rust_shim_args, enum_director_arg, NIL);
            } else if (proxy_director_arg) {
              Printv(rust_shim_args, proxy_director_arg, NIL);
            } else {
              Replaceall(din, "$iminput", rust_arg);
              Replaceall(din, "$rustinput", rust_arg);
              Replaceall(din, "$input", rust_arg);
              Printv(rust_shim_args, din, NIL);
            }

            String *pre = Getattr(p, "tmap:rustdirectorin:pre");
            if (pre) {
              String *pre_code = Copy(pre);
              Replaceall(pre_code, "$iminput", rust_arg);
              Replaceall(pre_code, "$rustinput", rust_arg);
              Replaceall(pre_code, "$input", rust_arg);
              Printf(rust_shim_pre_code, "    %s\n", pre_code);
              Delete(pre_code);
            }
            String *post = Getattr(p, "tmap:rustdirectorin:post");
            if (post) {
              String *post_code = Copy(post);
              Replaceall(post_code, "$iminput", rust_arg);
              Replaceall(post_code, "$rustinput", rust_arg);
              Replaceall(post_code, "$input", rust_arg);
              Printf(rust_shim_post_code, "    %s\n", post_code);
              Delete(post_code);
            }
            String *terminator = Getattr(p, "tmap:rustdirectorin:terminator");
            if (terminator) {
              String *terminator_code = Copy(terminator);
              Replaceall(terminator_code, "$iminput", rust_arg);
              Replaceall(terminator_code, "$rustinput", rust_arg);
              Replaceall(terminator_code, "$input", rust_arg);
              String *indented_terminator_code = NewStringf("    %s\n", terminator_code);
              Insert(rust_shim_terminator_code, 0, indented_terminator_code);
              Delete(indented_terminator_code);
              Delete(terminator_code);
            }
            Delete(din);
          } else {
            Swig_warning(WARN_TYPEMAP_DIRECTORIN_UNDEF,
                         input_file,
                         line_number,
                         "No rustdirectorin typemap defined for argument %s for use in %s::%s (skipping director method)\n",
                         SwigType_str(pt, 0),
                         SwigType_namestr(c_classname),
                         SwigType_namestr(name));
            output_director = false;
          }

          if (Len(rust_method_types))
            Printf(rust_method_types, ", ");
          Printf(rust_method_types, "\"%s\"", rust_trait_type);

          Parm *next = Getattr(p, "tmap:directorin:next");
          Delete(proxy_director_arg);
          Delete(proxy_director_type);
          Delete(proxy_director_name);
          Delete(enum_director_arg);
          Delete(enum_director_type);
          p = next ? next : nextSibling(p);
        } else {
          Swig_warning(WARN_TYPEMAP_DIRECTORIN_UNDEF,
                       input_file,
                       line_number,
                       "No directorin typemap defined for argument %s for use in %s::%s (skipping director method)\n",
                       SwigType_str(pt, 0),
                       SwigType_namestr(c_classname),
                       SwigType_namestr(name));
          output_director = false;
          p = nextSibling(p);
        }
      } else {
        Swig_warning(WARN_TYPEMAP_UNDEF,
                     input_file,
                     line_number,
                     "No ctype typemap defined for argument %s for use in %s::%s (skipping director method)\n",
                     SwigType_str(pt, 0),
                     SwigType_namestr(c_classname),
                     SwigType_namestr(name));
        output_director = false;
        p = nextSibling(p);
      }

      Delete(owned_im_type);
      Delete(owned_rust_type);
      Delete(c_decl);
      Delete(arg);
      Delete(rust_arg);
      Delete(ln);
      i++;
    }

    String *target = Swig_method_decl(Getattr(n, "conversion_operator") ? 0 : Getattr(n, "classDirectorMethods:type"), decl, qualified_name, l, 0);
    Printf(w->def, "%s", target);
    Delete(target);
    target = Swig_method_decl(Getattr(n, "conversion_operator") ? 0 : Getattr(n, "classDirectorMethods:type"), decl, name, l, 1);
    Printf(declaration, "    virtual %s", target);
    Delete(target);

    if (Getattr(n, "noexcept")) {
      Append(w->def, " noexcept");
      Append(declaration, " noexcept");
    }

    ParmList *throw_parm_list = NULL;
    if ((throw_parm_list = Getattr(n, "throws")) || Getattr(n, "throw")) {
      int gencomma = 0;

      Append(w->def, " throw(");
      Append(declaration, " throw(");

      if (throw_parm_list)
        Swig_typemap_attach_parms("throws", throw_parm_list, 0);
      for (Parm *p = throw_parm_list; p; p = nextSibling(p)) {
        if (Getattr(p, "tmap:throws")) {
          if (gencomma++) {
            Append(w->def, ", ");
            Append(declaration, ", ");
          }
          Printf(w->def, "%s", SwigType_str(Getattr(p, "type"), 0));
          Printf(declaration, "%s", SwigType_str(Getattr(p, "type"), 0));
        }
      }

      Append(w->def, ")");
      Append(declaration, ")");
    }

    Append(w->def, " {");
    Append(declaration, ";\n");

    if (!ignored_method) {
      Printf(w->code, "int swig_director_error = 0;\n");
      Printf(w->code, "char swig_director_error_message[1024];\n");
      Printf(w->code, "swig_director_error_message[0] = '\\0';\n");
      if (!is_void) {
        Printf(w->code, "jresult = ");
      }
      Printf(w->code,
             "swig_callback%s(swig_rust_object%s, &swig_director_error, swig_director_error_message, sizeof(swig_director_error_message));\n",
             overloaded_name,
             callback_args);
      Printf(w->code, "if (swig_director_error) {\n");
      if (Getattr(n, "noexcept"))
        Printf(w->code, "  std::terminate();\n");
      else
        Printf(w->code,
               "  throw Swig::DirectorException(swig_director_error_message[0] ? swig_director_error_message : \"Rust director callback panicked\");\n");
      Printf(w->code, "}\n");
      if (!is_void) {
        String *jresult_str = NewString("jresult");
        String *result_str = NewString("c_result");
        String *tm = Swig_typemap_lookup("directorout", n, result_str, w);
        if (tm) {
          Replaceall(tm, "$input", jresult_str);
          Replaceall(tm, "$result", result_str);
          Printf(w->code, "%s\n", tm);
        } else {
          Swig_warning(WARN_TYPEMAP_DIRECTOROUT_UNDEF,
                       input_file,
                       line_number,
                       "Unable to use return type %s used in %s::%s (skipping director method)\n",
                       SwigType_str(returntype, 0),
                       SwigType_namestr(c_classname),
                       SwigType_namestr(name));
          output_director = false;
        }
        Delete(jresult_str);
        Delete(result_str);
      }

      for (Parm *p = l; p;) {
        String *tm = Getattr(p, "tmap:directorargout");
        if (tm) {
          Replaceall(tm, "$result", "jresult");
          Replaceall(tm, "$input", Getattr(p, "emit:directorinput"));
          Printv(w->code, tm, "\n", NIL);
          p = Getattr(p, "tmap:directorargout:next");
        } else {
          p = nextSibling(p);
        }
      }

      Printf(w->code, "}\n");
      if (!is_void)
        Printf(w->code, "return %s;\n", qualified_return);
    }

    Printf(w->code, "}");

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

    if (!ignored_method && output_director) {
      String *member_name = Swig_name_member(getNSpace(), getClassPrefix(), overloaded_name);
      String *rust_dmethod = NewStringf("SwigDirector_%s", member_name);
      UpcallData *udata = addUpcallMethod(rust_dmethod, symname, decl, overloaded_name);
      String *methid = Getattr(udata, "class_methodidx");
      String *rust_return = rustReturnType(n, returntype);
      String *im_return = Swig_typemap_lookup("imtype", n, "", 0);
      if (im_return) {
        String *imtypeout = Getattr(n, "tmap:imtype:out");
        if (imtypeout)
          im_return = imtypeout;
      } else {
        im_return = rustType(returntype);
      }
      String *rust_callback_shim = NewStringf("%s_director_callback_%s", classname, methid);
      String *rust_trait_name = rustProxyMethodName(n);

      Setattr(n, "upcalldata", udata);
      Setattr(udata, "rust_callback_shim", rust_callback_shim);
      Printf(director_callback_typedefs, "    typedef %s (* SWIG_Callback%s_t)(void *rustobj", c_ret_type, methid);
      if (Len(callback_typedef_parms))
        Printf(director_callback_typedefs, ", %s", callback_typedef_parms);
      Printf(director_callback_typedefs, ", int *swig_error, char *swig_error_message, size_t swig_error_message_len);\n");
      Printf(director_callbacks, "    SWIG_Callback%s_t swig_callback%s;\n", methid, overloaded_name);
      if (Len(director_connect_parms))
        Printf(director_connect_parms, ", ");
      Printf(director_connect_parms, "SWIG_Callback%s_t callback%s", methid, methid);

      Printf(rust_ffi_code, "pub type %sCallback%s = extern \"C\" fn(*mut c_void", classname, methid);
      if (Len(rust_callback_type))
        Printf(rust_ffi_code, ", %s", rust_callback_type);
      Printf(rust_ffi_code, ", *mut c_int, *mut c_char, usize");
      Printf(rust_ffi_code, ")");
      if (Cmp(im_return, "()") != 0)
        Printf(rust_ffi_code, " -> %s", im_return);
      Printf(rust_ffi_code, ";\n");
      String *root_prefix = rustNamespaceRootPrefix(getNSpace());
      Printf(director_rust_code ? director_rust_code : rustItemTarget(), "pub use %s::ffi::%sCallback%s;\n", root_prefix, classname, methid);
      Delete(root_prefix);

      Printf(director_trait_code, "  fn %s(&mut self%s%s)", rust_trait_name, Len(rust_trait_params) ? ", " : "", rust_trait_params);
      if (Cmp(rust_return, "()") != 0)
        Printf(director_trait_code, " -> %s", rust_return);
      if (Cmp(rust_return, "()") == 0)
        Printf(director_trait_code, " {}\n");
      else
        Printf(director_trait_code, " { panic!(\"Rust director method %s::%s is not implemented\") }\n", classname, rust_trait_name);

      Printf(director_method_metadata, "pub const %sDirectorMethodTypes%s: &[&str] = &[%s];\n", classname, methid, rust_method_types);

      Printf(director_callback_shims, "extern \"C\" fn %s<T: %sDirector>(rustobj: *mut c_void", rust_callback_shim, classname);
      if (Len(rust_shim_params))
        Printf(director_callback_shims, ", %s", rust_shim_params);
      Printf(director_callback_shims, ", swig_error: *mut c_int, swig_error_message: *mut c_char, swig_error_message_len: usize");
      Printf(director_callback_shims, ")");
      if (im_return && Cmp(im_return, "()") != 0)
        Printf(director_callback_shims, " -> %s", im_return);
      Printf(director_callback_shims, " {\n");
      Printf(director_callback_shims, "  let swig_director_result = std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| {\n");
      Printf(director_callback_shims, "    let director = unsafe { &mut *(rustobj as *mut T) };\n");
      Printv(director_callback_shims, rust_shim_pre_code, NIL);
      if (Cmp(rust_return, "()") == 0) {
        Printf(director_callback_shims, "    director.%s(%s);\n", rust_trait_name, rust_shim_args);
      } else {
        Printf(director_callback_shims, "    let swig_result = director.%s(%s);\n", rust_trait_name, rust_shim_args);
        String *proxy_directorout = rustProxyDirectorOutCode(returntype, "swig_result");
        if (proxy_directorout) {
          Printf(director_callback_shims, "    let swig_result = %s;\n", proxy_directorout);
          Delete(proxy_directorout);
        } else if (String *tm = Swig_typemap_lookup("rustdirectorout", n, "", 0)) {
          String *converted = Copy(tm);
          Replaceall(converted, "$rustcall", "swig_result");
          Replaceall(converted, "$imcall", "swig_result");
          Printf(director_callback_shims, "    let swig_result = %s;\n", converted);
          Delete(converted);
        } else {
          Swig_warning(WARN_TYPEMAP_DIRECTOROUT_UNDEF,
                       input_file,
                       line_number,
                       "Unable to use Rust return type %s used in %s::%s (skipping director method)\n",
                       SwigType_str(returntype, 0),
                       SwigType_namestr(c_classname),
                       SwigType_namestr(name));
          output_director = false;
        }
      }
      Printv(director_callback_shims, rust_shim_post_code, NIL);
      Printv(director_callback_shims, rust_shim_terminator_code, NIL);
      if (Cmp(rust_return, "()") != 0)
        Printf(director_callback_shims, "    swig_result\n");
      Printf(director_callback_shims, "  }));\n");
      Printf(director_callback_shims, "  match swig_director_result {\n");
      if (Cmp(rust_return, "()") == 0) {
        Printf(director_callback_shims, "    Ok(()) => {}\n");
        Printf(director_callback_shims,
               "    Err(payload) => unsafe { rust_set_director_panic(swig_error, swig_error_message, swig_error_message_len, payload) }\n");
      } else {
        Printf(director_callback_shims, "    Ok(swig_result) => swig_result,\n");
        Printf(director_callback_shims, "    Err(payload) => unsafe {\n");
        Printf(director_callback_shims, "      rust_set_director_panic(swig_error, swig_error_message, swig_error_message_len, payload);\n");
        Printf(director_callback_shims, "      std::mem::zeroed()\n");
        Printf(director_callback_shims, "    }\n");
      }
      Printf(director_callback_shims, "  }\n");
      Printf(director_callback_shims, "}\n\n");

      Delete(rust_trait_name);
      Delete(rust_return);
      Delete(rust_callback_shim);
      Delete(rust_dmethod);
      Delete(member_name);
    }

    if (status == SWIG_OK && output_director) {
      Replaceall(w->code, "$null", is_void ? "" : qualified_return);
      Replaceall(w->code, "$isvoid", is_void ? "1" : "0");
      Replaceall(w->code, "$symname", symname);
      if (!Getattr(n, "defaultargs")) {
        Wrapper_print(w, f_directors);
        Printv(f_directors_h, declaration, NIL);
        Printv(f_directors_h, inline_extra_method, NIL);
      }
    }

    Delete(inline_extra_method);
    Delete(qualified_return);
    Delete(qualified_name);
    Delete(dirclassname);
    Delete(callback_typedef_parms);
    Delete(callback_args);
    Delete(rust_callback_type);
    Delete(rust_trait_params);
    Delete(rust_shim_params);
    Delete(rust_shim_args);
    Delete(rust_shim_pre_code);
    Delete(rust_shim_post_code);
    Delete(rust_shim_terminator_code);
    Delete(rust_method_types);
    Delete(declaration);
    Delete(overloaded_name);
    DelWrapper(w);
    return status;
  }

  virtual int classDirectorDestructor(Node *n) {
    Node *current_class = getCurrentClass();
    String *dirclassname = directorClassName(current_class);
    Wrapper *w = NewWrapper();

    if (Getattr(n, "noexcept")) {
      Printf(f_directors_h, "    virtual ~%s() noexcept;\n", dirclassname);
      Printf(w->def, "%s::~%s() noexcept {\n", dirclassname, dirclassname);
    } else if (Getattr(n, "throw")) {
      Printf(f_directors_h, "    virtual ~%s() throw();\n", dirclassname);
      Printf(w->def, "%s::~%s() throw() {\n", dirclassname, dirclassname);
    } else {
      Printf(f_directors_h, "    virtual ~%s();\n", dirclassname);
      Printf(w->def, "%s::~%s() {\n", dirclassname, dirclassname);
    }

    Printf(w->code, "}\n");
    Wrapper_print(w, f_directors);

    DelWrapper(w);
    Delete(dirclassname);
    return SWIG_OK;
  }

  virtual int classDirectorEnd(Node *n) {
    String *dirclassname = directorClassName(n);
    Wrapper *w = NewWrapper();

    if (Len(director_callback_typedefs) > 0)
      Printf(f_directors_h, "\n%s", director_callback_typedefs);

    Printf(f_directors_h, "    void swig_connect_director(void *rustobj");
    Printf(w->def, "void %s::swig_connect_director(void *rustobj", dirclassname);
    Printf(w->code, "swig_rust_object = rustobj;\n");

    for (int i = first_class_dmethod; i < curr_class_dmethod; ++i) {
      UpcallData *udata = Getitem(dmethods_seq, i);
      String *methid = Getattr(udata, "class_methodidx");
      String *overname = Getattr(udata, "overname");

      Printf(f_directors_h, ", SWIG_Callback%s_t callback%s", methid, overname);
      Printf(w->def, ", SWIG_Callback%s_t callback%s", methid, overname);
      Printf(w->code, "swig_callback%s = callback%s;\n", overname, overname);
    }

    Printf(f_directors_h, ");\n");
    Printf(w->def, ") {");
    Printf(f_directors_h, "\nprivate:\n");
    if (Len(director_callbacks) > 0)
      Printf(f_directors_h, "%s", director_callbacks);
    Printf(f_directors_h, "    void swig_init_callbacks();\n");
    Printf(f_directors_h, "    void *swig_rust_object;\n");
    Printf(f_directors_h, "};\n\n");
    Printf(w->code, "}\n\n");

    Printf(w->code, "void %s::swig_init_callbacks() {\n", dirclassname);
    Printf(w->code, "swig_rust_object = 0;\n");
    for (int i = first_class_dmethod; i < curr_class_dmethod; ++i) {
      UpcallData *udata = Getitem(dmethods_seq, i);
      String *overname = Getattr(udata, "overname");
      Printf(w->code, "swig_callback%s = 0;\n", overname);
    }
    Printf(w->code, "}");

    Wrapper_print(w, f_directors);
    emitDirectorConnect(n);
    if (director_trait_code) {
      Printf(director_trait_code, "}\n");
      Printv(director_rust_code ? director_rust_code : rustItemTarget(), director_trait_code, NIL);
    }
    if (director_method_metadata)
      Printv(director_rust_code ? director_rust_code : rustItemTarget(), director_method_metadata, NIL);
    if (director_callback_shims)
      Printv(director_rust_code ? director_rust_code : rustItemTarget(), director_callback_shims, NIL);
    if (director_rust_code) {
      Setattr(n, "rust:directorcode", director_rust_code);
      Delete(director_rust_code);
      director_rust_code = NULL;
    }

    Delete(director_callback_typedefs);
    Delete(director_callbacks);
    Delete(director_connect_parms);
    Delete(director_trait_code);
    Delete(director_callback_shims);
    Delete(director_method_metadata);
    director_callback_typedefs = NULL;
    director_callbacks = NULL;
    director_connect_parms = NULL;
    director_trait_code = NULL;
    director_callback_shims = NULL;
    director_method_metadata = NULL;

    DelWrapper(w);
    Delete(dirclassname);
    return Language::classDirectorEnd(n);
  }

  virtual int classDirectorDisown(Node *n) {
    return Language::classDirectorDisown(n);
  }

  virtual bool extraDirectorProtectedCPPMethodsRequired() const {
    return false;
  }

private:
  bool splitRustPragmaMapping(String *mapping_string, String **left, String **right) {
    const char *mapping = Char(mapping_string);
    const char *equals = strchr(mapping, '=');
    if (!equals || equals == mapping || !*(equals + 1))
      return false;
    *left = NewStringWithSize(mapping, (int)(equals - mapping));
    *right = NewString(equals + 1);
    return true;
  }

  String *rustItemTarget() {
    return rust_class_file_code ? rust_class_file_code : rust_proxy_code;
  }

  String *rustItemModuleName(const_String_or_char_ptr kind, String *name) {
    String *module_source = NewStringf("%s_%s", kind, name);
    String *module_name = rustModuleIdentifier(module_source);
    Delete(module_source);
    return module_name;
  }

  String *rustNormalizedNamespace(String *nspace) {
    String *normalized = Copy(nspace);
    Replaceall(normalized, "::", ".");
    return normalized;
  }

  String *rustNamespacePath(String *nspace) {
    String *normalized = rustNormalizedNamespace(nspace);
    String *path = NewString("");
    const char *start = Char(normalized);
    const char *component = start;
    for (const char *p = start;; ++p) {
      if (*p == '.' || *p == 0) {
        String *component_name = NewStringf("%.*s", (int)(p - component), component);
        String *module_component = rustModuleIdentifier(component_name);
        if (Len(path))
          Printf(path, "%s", SWIG_FILE_DELIMITER);
        Printf(path, "%s", module_component);
        Delete(module_component);
        Delete(component_name);
        if (*p == 0)
          break;
        component = p + 1;
      }
    }
    Delete(normalized);
    return path;
  }

  String *rustNamespaceRootPrefix(String *nspace) {
    String *prefix = NewString("super");
    if (nspace) {
      const char *s = Char(nspace);
      for (; *s; ++s) {
        if (*s == '.')
          Printf(prefix, "::super");
      }
      Printf(prefix, "::super");
    }
    return prefix;
  }

  String *rustNamespaceParent(String *normalized) {
    const char *s = Char(normalized);
    const char *last = 0;
    for (const char *p = s; *p; ++p) {
      if (*p == '.')
        last = p;
    }
    if (!last)
      return NULL;
    return NewStringf("%.*s", (int)(last - s), s);
  }

  String *rustNamespaceLastComponent(String *normalized) {
    const char *s = Char(normalized);
    const char *last = s;
    for (const char *p = s; *p; ++p) {
      if (*p == '.')
        last = p + 1;
    }
    return NewString(last);
  }

  void createRustNamespaceDirectory(String *normalized) {
    String *output_directory = Copy(SWIG_output_directory());
    String *path = rustNamespacePath(normalized);
    String *rustdir = NewStringf("%s%s%s", rust_module_name, SWIG_FILE_DELIMITER, path);
    String *newdir_error = Swig_new_subdirectory(output_directory, rustdir);
    if (newdir_error) {
      Printf(stderr, "%s\n", newdir_error);
      Delete(newdir_error);
      Exit(EXIT_FAILURE);
    }
    Delete(rustdir);
    Delete(path);
    Delete(output_directory);
  }

  void ensureRustNamespace(String *nspace) {
    if (!nspace)
      return;

    String *normalized = rustNormalizedNamespace(nspace);
    String *parent = rustNamespaceParent(normalized);
    if (parent)
      ensureRustNamespace(parent);

    if (!Getattr(rust_namespace_modules, normalized)) {
      String *modules = NewString("");
      String *reexports = NewString("");
      Setattr(rust_namespace_modules, normalized, modules);
      Setattr(rust_namespace_reexports, normalized, reexports);
      Append(rust_namespace_list, normalized);
      createRustNamespaceDirectory(normalized);
      Delete(modules);
      Delete(reexports);
    }

    String *component = rustNamespaceLastComponent(normalized);
    String *component_module = rustModuleIdentifier(component);
    String *decl_key = parent ? NewStringf("%s.%s", parent, component) : NewStringf(".%s", component);
    if (!Getattr(rust_namespace_declared, decl_key)) {
      String *modules = parent ? Getattr(rust_namespace_modules, parent) : rust_item_modules;
      String *reexports = parent ? Getattr(rust_namespace_reexports, parent) : rust_item_reexports;
      Printf(modules, "pub mod %s;\n", component_module);
      Printf(reexports, "pub use self::%s::*;\n", component_module);
      Setattr(rust_namespace_declared, decl_key, "1");
    }

    Delete(decl_key);
    Delete(component_module);
    Delete(component);
    Delete(parent);
    Delete(normalized);
  }

  void writeRustNamespaceFiles() {
    for (Iterator i = First(rust_namespace_list); i.item; i = Next(i)) {
      String *nspace = i.item;
      String *path = rustNamespacePath(nspace);
      String *rustfile = NewStringf("%s%s%s%smod.rs", rust_module_name, SWIG_FILE_DELIMITER, path, SWIG_FILE_DELIMITER);
      File *f_namespace = NewFile(rustfile, "w", SWIG_output_files());
      if (!f_namespace) {
        FileErrorDisplay(rustfile);
        Exit(EXIT_FAILURE);
      }

      Swig_banner_target_lang(f_namespace, "//");
      Printf(f_namespace, "\n");
      rustFileAttributes(f_namespace);
      Dump(Getattr(rust_namespace_modules, nspace), f_namespace);
      if (Len(Getattr(rust_namespace_modules, nspace)))
        Printf(f_namespace, "\n");
      Dump(Getattr(rust_namespace_reexports, nspace), f_namespace);

      Delete(f_namespace);
      Delete(rustfile);
      Delete(path);
    }
  }

  void writeRustItemFile(const_String_or_char_ptr kind, String *name, String *code, String *nspace = NULL) {
    String *item_module_name = rustItemModuleName(kind, name);
    String *rustfile = NULL;
    String *normalized_nspace = NULL;
    if (nspace) {
      ensureRustNamespace(nspace);
      normalized_nspace = rustNormalizedNamespace(nspace);
      String *path = rustNamespacePath(normalized_nspace);
      rustfile = NewStringf("%s%s%s%s%s.rs", rust_module_name, SWIG_FILE_DELIMITER, path, SWIG_FILE_DELIMITER, item_module_name);
      Delete(path);
    } else {
      rustfile = NewStringf("%s%s%s.rs", rust_module_name, SWIG_FILE_DELIMITER, item_module_name);
    }
    File *f_item = NewFile(rustfile, "w", SWIG_output_files());
    if (!f_item) {
      FileErrorDisplay(rustfile);
      Exit(EXIT_FAILURE);
    }

    String *modules = normalized_nspace ? Getattr(rust_namespace_modules, normalized_nspace) : rust_item_modules;
    String *reexports = normalized_nspace ? Getattr(rust_namespace_reexports, normalized_nspace) : rust_item_reexports;
    Printf(modules, "mod %s;\n", item_module_name);
    Printf(reexports, "pub use self::%s::*;\n", item_module_name);

    Swig_banner_target_lang(f_item, "//");
    Printf(f_item, "\n");
    rustFileAttributes(f_item);
    String *root_prefix = rustNamespaceRootPrefix(normalized_nspace);
    Printf(f_item, "use super::*;\n");
    if (normalized_nspace)
      Printf(f_item, "use %s::*;\n", root_prefix);
    Printf(f_item, "use %s::ffi::*;\n", root_prefix);
    Printf(f_item, "use %s::module::*;\n", root_prefix);
    Printf(f_item, "use %s::runtime::*;\n", root_prefix);
    Printf(f_item,
           "use std::os::raw::{c_char, c_double, c_float, c_int, c_long, c_longlong, c_schar, c_short, c_uchar, c_uint, c_ulong, "
           "c_ulonglong, c_ushort, c_void};\n");
    Dump(rust_module_imports, f_item);
    Printf(f_item, "\n");
    Dump(code, f_item);

    Delete(f_item);
    Delete(rustfile);
    Delete(root_prefix);
    Delete(normalized_nspace);
    Delete(item_module_name);
  }

  void buildRustProxyParameters(Node *n, ParmList *parms, String *rust_params, String *rust_pre_code, String *rust_post_code, String *rust_terminator_code,
                                String *rust_args, int skip_inputs = 0, bool variable_setter = false) {
    Swig_typemap_attach_parms("rusttype", parms, 0);
    Swig_typemap_attach_parms("rustin", parms, 0);
    int gencomma = 0;
    int index = 0;
    int skipped = 0;
    for (Parm *p = parms; p; p = nextSibling(p), index++) {
      if (checkAttribute(p, "varargs:ignore", "1"))
        continue;
      if (checkAttribute(p, "tmap:in:numinputs", "0"))
        continue;

      SwigType *pt = Getattr(p, "type");
      if (SwigType_type(pt) == T_VOID)
        continue;
      if (skipped < skip_inputs) {
        skipped++;
        continue;
      }

      String *arg = variable_setter && !gencomma ? NewString("value") : makeParameterName(n, p, index, false);
      String *rust_type = Getattr(p, "tmap:rusttype");
      String *rust_arg = Getattr(p, "tmap:rustin") ? Copy(Getattr(p, "tmap:rustin")) : Copy(arg);
      String *pre = Getattr(p, "tmap:rustin:pre");
      String *post = Getattr(p, "tmap:rustin:post");
      String *terminator = Getattr(p, "tmap:rustin:terminator");
      bool rust_type_owned = false;

      if (!rust_type) {
        rust_type = rustType(pt);
        rust_type_owned = true;
      } else if (Getattr(p, "tmap:rusttype:out")) {
        rust_type = Getattr(p, "tmap:rusttype:out");
      }
      applyRustProxyInput(pt, arg, &rust_type, &rust_arg, &rust_type_owned);
      applyRustEnumInput(pt, arg, &rust_type, &rust_arg, &rust_type_owned);

      Replaceall(rust_arg, "$rustinput", arg);
      Replaceall(rust_arg, "$iminput", arg);
      if (pre) {
        String *pre_code = Copy(pre);
        Replaceall(pre_code, "$rustinput", arg);
        Replaceall(pre_code, "$iminput", arg);
        Printf(rust_pre_code, "    %s\n", pre_code);
        Delete(pre_code);
      }
      if (post) {
        String *post_code = Copy(post);
        Replaceall(post_code, "$rustinput", arg);
        Replaceall(post_code, "$iminput", arg);
        Printf(rust_post_code, "    %s\n", post_code);
        Delete(post_code);
      }
      if (terminator) {
        String *terminator_code = Copy(terminator);
        Replaceall(terminator_code, "$rustinput", arg);
        Replaceall(terminator_code, "$iminput", arg);
        String *indented_terminator_code = NewStringf("    %s\n", terminator_code);
        Insert(rust_terminator_code, 0, indented_terminator_code);
        Delete(indented_terminator_code);
        Delete(terminator_code);
      }

      Printv(rust_params, gencomma ? ", " : "", arg, ": ", rust_type, NIL);
      Printv(rust_args, gencomma ? ", " : "", rust_arg, NIL);
      gencomma = 1;

      if (rust_type_owned)
        Delete(rust_type);
      Delete(rust_arg);
      Delete(arg);
    }
  }

  String *rustProxyMethodName(Node *n) {
    String *method_name = rustConfiguredIdentifier(Getattr(n, "sym:name"));
    if (Getattr(n, "sym:overloaded") && !rustIsFirstOverload(n)) {
      String *suffix = rustOverloadSuffix(Getattr(n, "sym:overname"));
      Printf(method_name, "%s", suffix);
      Delete(suffix);
    }
    return method_name;
  }

  String *rustConstructorName(Node *n) {
    String *constructor_name = NewString("new");
    if (Getattr(n, "sym:overloaded") && ParmList_len(Getattr(n, "parms")) > 0) {
      String *overname = Getattr(n, "sym:overname");
      if (overname && Strncmp(overname, "__SWIG_", 7) == 0)
        Printf(constructor_name, "_%s", Char(overname) + 7);
      else
        Printf(constructor_name, "_%s", overname);
    }
    return constructor_name;
  }

  bool rustSignatureNeedsUnsafe(String *rust_params, String *rust_return) const {
    return (rust_params && (Strstr(rust_params, "*mut ") || Strstr(rust_params, "*const "))) ||
           (rust_return && (Strstr(rust_return, "*mut ") || Strstr(rust_return, "*const ")));
  }

  Node *rustProxyClassForType(SwigType *t, bool *is_pointer, bool *is_reference) {
    *is_pointer = false;
    *is_reference = false;

    SwigType *resolved = SwigType_typedef_resolve_all(t);
    SwigType *stripped = SwigType_strip_qualifiers(resolved);
    SwigType *proxy_type = NULL;

    if ((proxy_type = rustSmartPointerValueType(stripped))) {
      /* Smart pointers are represented by the pointee proxy. */
    } else if (SwigType_ispointer(stripped)) {
      SwigType *base = SwigType_base(stripped);
      SwigType *base_stripped = SwigType_strip_qualifiers(base);
      if (!SwigType_ispointer(base_stripped) && !SwigType_isarray(base_stripped) && !SwigType_isreference(base_stripped)) {
        proxy_type = Copy(base_stripped);
        *is_pointer = true;
      }
      Delete(base_stripped);
      Delete(base);
    } else if (SwigType_isreference(stripped)) {
      String *reference_type_string = SwigType_str(stripped, 0);
      bool reference_to_pointer = Strstr(reference_type_string, "*") != 0;
      SwigType *base = SwigType_base(stripped);
      SwigType *base_stripped = SwigType_strip_qualifiers(base);
      if (SwigType_ispointer(base_stripped)) {
        SwigType *pointer_base = SwigType_base(base_stripped);
        SwigType *pointer_base_stripped = SwigType_strip_qualifiers(pointer_base);
        if (!SwigType_ispointer(pointer_base_stripped) && !SwigType_isarray(pointer_base_stripped) && !SwigType_isreference(pointer_base_stripped)) {
          proxy_type = Copy(pointer_base_stripped);
          *is_pointer = true;
        }
        Delete(pointer_base_stripped);
        Delete(pointer_base);
      } else if (reference_to_pointer) {
        proxy_type = Copy(base_stripped);
        *is_pointer = true;
      } else if (!SwigType_isarray(base_stripped) && !SwigType_isreference(base_stripped)) {
        proxy_type = Copy(base_stripped);
        *is_reference = true;
      }
      Delete(base_stripped);
      Delete(base);
      Delete(reference_type_string);
    } else if (!SwigType_isarray(stripped)) {
      proxy_type = Copy(stripped);
    }

    Node *proxy_class = proxy_type ? classLookup(proxy_type) : NULL;
    Delete(proxy_type);
    Delete(stripped);
    Delete(resolved);
    return proxy_class;
  }

  void emitDirectorFactoryHelper(Node *n) {
    if (!proxy_class_name || !proxy_class_code || !rust_class_extra_code || Getattr(n, "overload:ignore") || GetFlag(n, "explicitcall"))
      return;

    String *symname = Getattr(n, "sym:name");
    if (Cmp(symname, "create") != 0)
      return;

    bool return_is_pointer = false;
    bool return_is_reference = false;
    Node *return_class = rustProxyClassForType(Getattr(n, "type"), &return_is_pointer, &return_is_reference);
    if (!return_class || Cmp(Getattr(return_class, "sym:name"), proxy_class_name) != 0)
      return;

    ParmList *parms = Getattr(n, "parms");
    Swig_typemap_attach_parms("rusttype", parms, 0);
    Swig_typemap_attach_parms("rustin", parms, 0);

    Parm *director_parm = NULL;
    Node *director_class = NULL;
    bool director_is_pointer = false;
    bool director_is_reference = false;
    int director_inputs = 0;
    for (Parm *p = parms; p; p = nextSibling(p)) {
      if (checkAttribute(p, "varargs:ignore", "1") || checkAttribute(p, "tmap:in:numinputs", "0"))
        continue;
      SwigType *pt = Getattr(p, "type");
      if (SwigType_type(pt) == T_VOID)
        continue;
      bool is_pointer = false;
      bool is_reference = false;
      Node *candidate = rustProxyClassForType(pt, &is_pointer, &is_reference);
      if (candidate && Swig_directorclass(candidate)) {
        director_parm = p;
        director_class = candidate;
        director_is_pointer = is_pointer;
        director_is_reference = is_reference;
        director_inputs++;
      }
    }
    if (director_inputs != 1 || !director_class || (!director_is_pointer && !director_is_reference))
      return;

    String *director_name = Copy(Getattr(director_class, "sym:name"));
    String *method_name = rustProxyMethodName(n);
    String *result_method_name = rust_exception_policy_result ? Copy(method_name) : rustTryIdentifier(method_name);
    String *helper_suffix = NewString("");
    if (Strncmp(method_name, "create", 6) == 0)
      Printf(helper_suffix, "%s", Char(method_name) + 6);
    String *helper_name = NewStringf("try_create%s_with_director", helper_suffix);
    String *guard_name = NewStringf("%sCreate%sDirector", proxy_class_name, helper_suffix);
    Replaceall(guard_name, "_", "");

    String *rust_params = NewString("");
    String *rust_args = NewString("");
    String *rust_pre_code = NewString("");
    String *rust_post_code = NewString("");
    String *rust_terminator_code = NewString("");
    int gencomma = 0;
    int index = 0;
    for (Parm *p = parms; p; p = nextSibling(p), index++) {
      if (checkAttribute(p, "varargs:ignore", "1") || checkAttribute(p, "tmap:in:numinputs", "0"))
        continue;
      SwigType *pt = Getattr(p, "type");
      if (SwigType_type(pt) == T_VOID)
        continue;

      if (p == director_parm) {
        Printv(rust_params, gencomma ? ", " : "", "swig_rust_director: T", NIL);
        Printv(rust_args, gencomma ? ", " : "", director_is_pointer ? "Some(swig_director.as_proxy_mut())" : "swig_director.as_proxy_mut()", NIL);
        gencomma = 1;
        continue;
      }

      String *arg = makeParameterName(n, p, index, false);
      String *rust_type = Getattr(p, "tmap:rusttype");
      String *rust_arg = Getattr(p, "tmap:rustin") ? Copy(Getattr(p, "tmap:rustin")) : Copy(arg);
      String *pre = Getattr(p, "tmap:rustin:pre");
      String *post = Getattr(p, "tmap:rustin:post");
      String *terminator = Getattr(p, "tmap:rustin:terminator");
      bool rust_type_owned = false;

      if (!rust_type) {
        rust_type = rustType(pt);
        rust_type_owned = true;
      } else if (Getattr(p, "tmap:rusttype:out")) {
        rust_type = Getattr(p, "tmap:rusttype:out");
      }
      applyRustProxyInput(pt, arg, &rust_type, &rust_arg, &rust_type_owned);
      applyRustEnumInput(pt, arg, &rust_type, &rust_arg, &rust_type_owned);

      Replaceall(rust_arg, "$rustinput", arg);
      Replaceall(rust_arg, "$iminput", arg);
      if (pre) {
        String *pre_code = Copy(pre);
        Replaceall(pre_code, "$rustinput", arg);
        Replaceall(pre_code, "$iminput", arg);
        Printf(rust_pre_code, "    %s\n", pre_code);
        Delete(pre_code);
      }
      if (post) {
        String *post_code = Copy(post);
        Replaceall(post_code, "$rustinput", arg);
        Replaceall(post_code, "$iminput", arg);
        Printf(rust_post_code, "    %s\n", post_code);
        Delete(post_code);
      }
      if (terminator) {
        String *terminator_code = Copy(terminator);
        Replaceall(terminator_code, "$rustinput", arg);
        Replaceall(terminator_code, "$iminput", arg);
        String *indented_terminator_code = NewStringf("    %s\n", terminator_code);
        Insert(rust_terminator_code, 0, indented_terminator_code);
        Delete(indented_terminator_code);
        Delete(terminator_code);
      }

      Printv(rust_params, gencomma ? ", " : "", arg, ": ", rust_type, NIL);
      Printv(rust_args, gencomma ? ", " : "", rust_arg, NIL);
      gencomma = 1;

      if (rust_type_owned)
        Delete(rust_type);
      Delete(rust_arg);
      Delete(arg);
    }

    Printf(proxy_class_code, "  pub fn %s<T: %sDirector>(%s) -> Result<%s<T>, RustException> {\n", helper_name, director_name, rust_params, guard_name);
    Printv(proxy_class_code, rust_pre_code, NIL);
    Printf(proxy_class_code, "    let mut swig_director = %sDirectorOwned::from_proxy(%s::new(), swig_rust_director);\n", director_name, director_name);
    Printf(proxy_class_code, "    let swig_object = Self::%s(%s)?;\n", result_method_name, rust_args);
    if (return_is_pointer)
      Printf(proxy_class_code,
             "    let object = swig_object.ok_or_else(|| RustException::new_unknown(\"%s::%s returned null\"))?;\n",
             proxy_class_name,
             method_name);
    else
      Printf(proxy_class_code, "    let object = swig_object;\n");
    Printv(proxy_class_code, rust_post_code, rust_terminator_code, NIL);
    Printf(proxy_class_code, "    Ok(%s { object, director: swig_director })\n", guard_name);
    Printf(proxy_class_code, "  }\n");

    Printf(rust_class_extra_code, "#[must_use]\n");
    Printf(rust_class_extra_code, "pub struct %s<T: %sDirector> {\n", guard_name, director_name);
    Printf(rust_class_extra_code, "  object: %s,\n", proxy_class_name);
    Printf(rust_class_extra_code, "  director: %sDirectorOwned<T>,\n", director_name);
    Printf(rust_class_extra_code, "}\n");
    Printf(rust_class_extra_code, "impl<T: %sDirector> %s<T> {\n", director_name, guard_name);
    Printf(rust_class_extra_code, "  pub fn object(&self) -> &%s {\n", proxy_class_name);
    Printf(rust_class_extra_code, "    &self.object\n");
    Printf(rust_class_extra_code, "  }\n");
    Printf(rust_class_extra_code, "  pub fn object_mut(&mut self) -> &mut %s {\n", proxy_class_name);
    Printf(rust_class_extra_code, "    &mut self.object\n");
    Printf(rust_class_extra_code, "  }\n");
    Printf(rust_class_extra_code, "  pub fn director(&self) -> &T {\n");
    Printf(rust_class_extra_code, "    self.director.director()\n");
    Printf(rust_class_extra_code, "  }\n");
    Printf(rust_class_extra_code, "  pub fn director_mut(&mut self) -> &mut T {\n");
    Printf(rust_class_extra_code, "    self.director.director_mut()\n");
    Printf(rust_class_extra_code, "  }\n");
    Printf(rust_class_extra_code, "  pub fn director_proxy(&self) -> &%s {\n", director_name);
    Printf(rust_class_extra_code, "    self.director.as_proxy()\n");
    Printf(rust_class_extra_code, "  }\n");
    Printf(rust_class_extra_code, "  pub fn director_proxy_mut(&mut self) -> &mut %s {\n", director_name);
    Printf(rust_class_extra_code, "    self.director.as_proxy_mut()\n");
    Printf(rust_class_extra_code, "  }\n");
    Printf(rust_class_extra_code, "  pub fn into_parts(self) -> (%s, %sDirectorOwned<T>) {\n", proxy_class_name, director_name);
    Printf(rust_class_extra_code, "    (self.object, self.director)\n");
    Printf(rust_class_extra_code, "  }\n");
    Printf(rust_class_extra_code, "}\n");
    Printf(rust_class_extra_code, "impl<T: %sDirector> std::ops::Deref for %s<T> {\n", director_name, guard_name);
    Printf(rust_class_extra_code, "  type Target = %s;\n", proxy_class_name);
    Printf(rust_class_extra_code, "  fn deref(&self) -> &Self::Target {\n");
    Printf(rust_class_extra_code, "    &self.object\n");
    Printf(rust_class_extra_code, "  }\n");
    Printf(rust_class_extra_code, "}\n");
    Printf(rust_class_extra_code, "impl<T: %sDirector> std::ops::DerefMut for %s<T> {\n", director_name, guard_name);
    Printf(rust_class_extra_code, "  fn deref_mut(&mut self) -> &mut Self::Target {\n");
    Printf(rust_class_extra_code, "    &mut self.object\n");
    Printf(rust_class_extra_code, "  }\n");
    Printf(rust_class_extra_code, "}\n\n");

    Delete(rust_terminator_code);
    Delete(rust_post_code);
    Delete(rust_pre_code);
    Delete(rust_args);
    Delete(rust_params);
    Delete(guard_name);
    Delete(helper_name);
    Delete(helper_suffix);
    Delete(result_method_name);
    Delete(method_name);
    Delete(director_name);
  }

  String *rustClassTypemap(Node *n, const_String_or_char_ptr tmap_method, SwigType *type, String *classname = NULL) {
    Node *node = NewHash();
    Setattr(node, "type", type);
    Setfile(node, Getfile(n));
    Setline(node, Getline(n));
    String *tm = Swig_typemap_lookup(tmap_method, node, "", 0);
    String *result = tm ? Copy(tm) : NewString("");
    Swig_typemap_replace_embedded_typemap(result, node);
    if (classname) {
      Replaceall(result, "$rustclassname", classname);
      Replaceall(result, "$rustclass", classname);
    }
    List *template_args = SwigType_templateargslist(type);
    if (template_args) {
      int index = 0;
      for (Iterator i = First(template_args); i.item; i = Next(i), ++index) {
        String *arg_placeholder = NewStringf("$rusttemplarg%d", index);
        String *arg_input_placeholder = NewStringf("$rusttemplargin%d", index);
        Node *arg_node = NewHash();
        Setattr(arg_node, "type", i.item);
        Setfile(arg_node, Getfile(n));
        Setline(arg_node, Getline(n));
        String *arg_type = rustReturnType(arg_node, i.item);
        String *arg_input_type = rustTemplateInputType(arg_node, i.item);
        Replaceall(result, arg_placeholder, arg_type);
        Replaceall(result, arg_input_placeholder, arg_input_type);
        Delete(arg_input_type);
        Delete(arg_type);
        Delete(arg_node);
        Delete(arg_input_placeholder);
        Delete(arg_placeholder);
      }
      Delete(template_args);
    }
    Delete(node);
    return result;
  }

  String *rustTemplateInputType(Node *n, SwigType *t) {
    String *enum_type = rustEnumNameForType(t);
    if (enum_type)
      return enum_type;

    bool is_pointer = false;
    bool is_reference = false;
    String *proxy_name = rustProxyNameForType(t, &is_pointer, &is_reference);
    if (proxy_name) {
      String *input_type = NewStringf("&%s", proxy_name);
      Delete(proxy_name);
      return input_type;
    }

    String *tm = Swig_typemap_lookup("rusttype", n, "", 0);
    if (tm) {
      String *rusttypeout = Getattr(n, "tmap:rusttype:out");
      return Copy(rusttypeout ? rusttypeout : tm);
    }
    return rustType(t);
  }

  void emitProxyFunction(Node *n, bool is_static, bool result_mode = false) {
    if (!proxy_class_code || Getattr(n, "overload:ignore") || GetFlag(n, "explicitcall"))
      return;

    SwigType *returntype = Getattr(n, "type");
    ParmList *parms = Getattr(n, "parms");
    String *overloaded_name = getOverloadedName(n);
    String *wrapper_name = Swig_name_member(getNSpace(), getClassPrefix(), overloaded_name);
    String *method_name = rustProxyMethodName(n);
    String *rust_return = rustReturnType(n, returntype);
    String *rust_params = NewString("");
    String *rust_pre_code = NewString("");
    String *rust_post_code = NewString("");
    String *rust_terminator_code = NewString("");
    String *rust_args = NewString("");
    String *rust_call = NewString("");
    String *rust_body = NewString("");

    buildRustProxyParameters(n, parms, rust_params, rust_pre_code, rust_post_code, rust_terminator_code, rust_args);

    bool needs_unsafe = rustSignatureNeedsUnsafe(rust_params, rust_return);
    String *public_method_name = NULL;
    if (rust_exception_policy_result)
      public_method_name = result_mode ? Copy(method_name) : rustPanicIdentifier(method_name);
    else
      public_method_name = result_mode ? rustTryIdentifier(method_name) : Copy(method_name);
    Printf(proxy_class_code, "  pub %sfn %s(", needs_unsafe ? "unsafe " : "", public_method_name);
    if (!is_static)
      Printf(proxy_class_code, "&self");
    if (Len(rust_params)) {
      if (!is_static)
        Printf(proxy_class_code, ", ");
      Printv(proxy_class_code, rust_params, NIL);
    }
    Printf(proxy_class_code, ")");
    if (result_mode) {
      String *result_type = rustResultType(rust_return);
      Printf(proxy_class_code, " -> %s", result_type);
      Delete(result_type);
    } else if (Cmp(rust_return, "()") != 0) {
      Printf(proxy_class_code, " -> %s", rust_return);
    }
    Printf(proxy_class_code, " {\n");
    if (!needs_unsafe)
      Printf(proxy_class_code, "    unsafe {\n");
    Printv(proxy_class_code, rust_pre_code, NIL);
    Printf(rust_call, "%s_raw(", wrapper_name);
    if (!is_static)
      Printf(rust_call, "self.as_mut_ptr()");
    if (Len(rust_args)) {
      if (!is_static)
        Printf(rust_call, ", ");
      Printv(rust_call, rust_args, NIL);
    }
    Printf(rust_call, ")");
    rust_body = rustOutCode(n,
                            rust_call,
                            (Len(rust_post_code) || Len(rust_terminator_code)) ? (needs_unsafe ? "      " : "        ") : (needs_unsafe ? "    " : "      "),
                            result_mode);
    emitRustOutWithPost(proxy_class_code, rust_body, rust_return, result_mode, rust_post_code, rust_terminator_code, needs_unsafe ? "    " : "      ");
    if (!needs_unsafe)
      Printf(proxy_class_code, "    }\n");
    Printf(proxy_class_code, "  }\n");

    Delete(rust_body);
    Delete(rust_call);
    Delete(rust_args);
    Delete(rust_terminator_code);
    Delete(rust_post_code);
    Delete(rust_pre_code);
    Delete(rust_params);
    Delete(rust_return);
    Delete(public_method_name);
    Delete(method_name);
    Delete(wrapper_name);
    Delete(overloaded_name);
  }

  void emitProxyConstructor(Node *n, bool result_mode = false) {
    if (!proxy_class_code || Getattr(n, "overload:ignore"))
      return;

    ParmList *parms = Getattr(n, "parms");
    String *overloaded_name = getOverloadedName(n);
    String *wrapper_name = Swig_name_construct(getNSpace(), overloaded_name);
    String *constructor_name = rustConstructorName(n);
    String *rust_params = NewString("");
    String *rust_pre_code = NewString("");
    String *rust_post_code = NewString("");
    String *rust_terminator_code = NewString("");
    String *rust_args = NewString("");

    buildRustProxyParameters(n, parms, rust_params, rust_pre_code, rust_post_code, rust_terminator_code, rust_args);

    bool needs_unsafe = rustSignatureNeedsUnsafe(rust_params, 0);
    const char *rust_return = result_mode ? "Result<Self, RustException>" : "Self";
    String *public_constructor_name = NULL;
    if (rust_exception_policy_result)
      public_constructor_name = result_mode ? Copy(constructor_name) : rustPanicIdentifier(constructor_name);
    else
      public_constructor_name = result_mode ? rustTryIdentifier(constructor_name) : Copy(constructor_name);
    Printf(proxy_class_code, "  pub %sfn %s(%s) -> %s {\n", needs_unsafe ? "unsafe " : "", public_constructor_name, rust_params, rust_return);
    if (!needs_unsafe)
      Printf(proxy_class_code, "    unsafe {\n");
    Printv(proxy_class_code, rust_pre_code, NIL);
    Printf(proxy_class_code, "%slet swig_result = %s_raw(%s);\n", needs_unsafe ? "    " : "      ", wrapper_name, rust_args);
    if (Len(rust_post_code) || Len(rust_terminator_code))
      Printf(proxy_class_code, "%slet swig_rust_result = {\n", needs_unsafe ? "    " : "      ");
    if (result_mode) {
      Printf(proxy_class_code, "%sif let Some(error) = rust_take_exception() {\n", needs_unsafe ? "    " : "      ");
      Printf(proxy_class_code, "%s  return Err(error);\n", needs_unsafe ? "    " : "      ");
      Printf(proxy_class_code, "%s}\n", needs_unsafe ? "    " : "      ");
      Printf(proxy_class_code,
             "%sOk(Self::from_raw_owned_unchecked(swig_result, true))\n",
             (Len(rust_post_code) || Len(rust_terminator_code)) ? (needs_unsafe ? "      " : "        ") : (needs_unsafe ? "    " : "      "));
    } else {
      Printf(proxy_class_code, "%srust_check_exception();\n", needs_unsafe ? "    " : "      ");
      Printf(proxy_class_code,
             "%sSelf::from_raw_owned_unchecked(swig_result, true)\n",
             (Len(rust_post_code) || Len(rust_terminator_code)) ? (needs_unsafe ? "      " : "        ") : (needs_unsafe ? "    " : "      "));
    }
    if (Len(rust_post_code) || Len(rust_terminator_code)) {
      Printf(proxy_class_code, "%s};\n", needs_unsafe ? "    " : "      ");
      Printv(proxy_class_code, rust_post_code, rust_terminator_code, NIL);
      Printf(proxy_class_code, "%sswig_rust_result\n", needs_unsafe ? "    " : "      ");
    }
    if (!needs_unsafe)
      Printf(proxy_class_code, "    }\n");
    Printf(proxy_class_code, "  }\n");

    Delete(rust_args);
    Delete(rust_terminator_code);
    Delete(rust_post_code);
    Delete(rust_pre_code);
    Delete(rust_params);
    Delete(public_constructor_name);
    Delete(constructor_name);
    Delete(wrapper_name);
    Delete(overloaded_name);
  }

  String *rustSetterName(String *name) {
    String *field_name = rustConfiguredIdentifier(name);
    String *field_suffix = Strncmp(field_name, "r#", 2) == 0 ? NewString(Char(field_name) + 2) : Copy(field_name);
    String *setter = NewStringf("set_%s", field_suffix);
    String *rust_name = rustIdentifier(setter);
    Delete(field_suffix);
    Delete(field_name);
    Delete(setter);
    return rust_name;
  }

  String *rustGetterName(String *name) {
    String *field_name = rustConfiguredIdentifier(name);
    String *field_suffix = Strncmp(field_name, "r#", 2) == 0 ? NewString(Char(field_name) + 2) : Copy(field_name);
    String *getter = NewStringf("get_%s", field_suffix);
    String *rust_name = rustIdentifier(getter);
    Delete(field_suffix);
    Delete(field_name);
    Delete(getter);
    return rust_name;
  }

  String *rustWithName(String *name) {
    String *field_name = rustConfiguredIdentifier(name);
    String *field_suffix = Strncmp(field_name, "r#", 2) == 0 ? NewString(Char(field_name) + 2) : Copy(field_name);
    String *with_name = NewStringf("with_%s", field_suffix);
    String *rust_name = rustIdentifier(with_name);
    Delete(with_name);
    Delete(field_suffix);
    Delete(field_name);
    return rust_name;
  }

  void emitRustVariableAccessor(Node *n, String *wrapper_name) {
    if (!variable_name || (!global_variable_flag && !member_variable_flag && !static_member_variable_flag))
      return;

    const bool setter = Getattr(n, "varset") || Getattr(n, "memberset");
    const bool getter = Getattr(n, "varget") || Getattr(n, "memberget");
    if (!setter && !getter)
      return;

    String *rust_name = NULL;
    if (setter)
      rust_name = rustSetterName(variable_name);
    else if (global_variable_flag)
      rust_name = rustGetterName(variable_name);
    else
      rust_name = rustConfiguredIdentifier(variable_name);
    String *rust_return = rustReturnType(n, Getattr(n, "type"));
    String *rust_params = NewString("");
    String *rust_pre_code = NewString("");
    String *rust_post_code = NewString("");
    String *rust_terminator_code = NewString("");
    String *rust_args = NewString("");
    String *raw_args = NewString("");
    String *call = NewString("");
    String *target = (member_variable_flag || static_member_variable_flag) && proxy_class_code ? proxy_class_code : rust_proxy_code;

    if (setter)
      buildRustProxyParameters(
        n, Getattr(n, "parms"), rust_params, rust_pre_code, rust_post_code, rust_terminator_code, rust_args, member_variable_flag ? 1 : 0, true);

    if (member_variable_flag) {
      Printf(raw_args, "self.as_mut_ptr()");
      if (Len(rust_args))
        Printf(raw_args, ", %s", rust_args);
    } else {
      Printv(raw_args, rust_args, NIL);
    }

    Printf(call, "%s_raw(%s)", wrapper_name, raw_args);

    bool needs_unsafe = rustSignatureNeedsUnsafe(rust_params, rust_return);
    if (target == proxy_class_code) {
      Printf(target, "  pub %sfn %s(", needs_unsafe ? "unsafe " : "", rust_name);
      if (member_variable_flag)
        Printf(target, "&self");
      if (Len(rust_params)) {
        if (member_variable_flag)
          Printf(target, ", ");
        Printv(target, rust_params, NIL);
      }
      Printf(target, ")");
    } else {
      Printf(target, "pub %sfn %s(", needs_unsafe ? "unsafe " : "", rust_name);
      Printv(target, rust_params, NIL);
      Printf(target, ")");
    }
    if (Cmp(rust_return, "()") != 0)
      Printf(target, " -> %s", rust_return);
    Printf(target, " {\n");
    if (!needs_unsafe)
      Printf(target, "%sunsafe {\n", target == proxy_class_code ? "    " : "  ");
    Printv(target, rust_pre_code, NIL);
    const char *base_indent = needs_unsafe ? (target == proxy_class_code ? "    " : "  ") : (target == proxy_class_code ? "      " : "    ");
    String *body = rustOutCode(n, call, (Len(rust_post_code) || Len(rust_terminator_code)) ? (target == proxy_class_code ? "      " : "    ") : base_indent);
    emitRustOutWithPost(target, body, rust_return, false, rust_post_code, rust_terminator_code, base_indent);
    if (!needs_unsafe)
      Printf(target, "%s}\n", target == proxy_class_code ? "    " : "  ");
    Printf(target, "%s}\n", target == proxy_class_code ? "  " : "");
    if (target == rust_proxy_code)
      Printf(target, "\n");

    if (setter && member_variable_flag && target == proxy_class_code) {
      String *with_name = rustWithName(variable_name);
      Printf(target, "  pub %sfn %s(self", needs_unsafe ? "unsafe " : "", with_name);
      if (Len(rust_params))
        Printf(target, ", %s", rust_params);
      Printf(target, ") -> Self {\n");
      if (!needs_unsafe)
        Printf(target, "    unsafe {\n");
      Printv(target, rust_pre_code, NIL);
      emitRustOutWithPost(target, body, rust_return, false, rust_post_code, rust_terminator_code, needs_unsafe ? "    " : "      ");
      if (!needs_unsafe)
        Printf(target, "    }\n");
      Printf(target, "    self\n");
      Printf(target, "  }\n");
      Delete(with_name);
    }

    Delete(body);
    Delete(call);
    Delete(raw_args);
    Delete(rust_args);
    Delete(rust_terminator_code);
    Delete(rust_post_code);
    Delete(rust_pre_code);
    Delete(rust_params);
    Delete(rust_return);
    Delete(rust_name);
  }

  String *getOverloadedName(Node *n) const {
    String *overloaded_name = Copy(Getattr(n, "sym:name"));
    if (Getattr(n, "sym:overloaded"))
      Append(overloaded_name, Getattr(n, "sym:overname"));
    return overloaded_name;
  }

  UpcallData *addUpcallMethod(String *rust_method, String *class_method, String *decl, String *overloaded_name) {
    String *key = NewStringf("%s|%s", class_method, decl);

    curr_class_dmethod++;
    UpcallData *udata = NewHash();
    String *methid = NewStringf("%d", n_dmethods - first_class_dmethod);
    n_dmethods++;
    Append(dmethods_seq, udata);
    Setattr(dmethods_table, key, udata);
    Setattr(udata, "method", Copy(class_method));
    Setattr(udata, "rust_method", Copy(rust_method));
    Setattr(udata, "class_methodidx", methid);
    Setattr(udata, "overname", Copy(overloaded_name));
    Setattr(udata, "decl", Copy(decl));
    Delete(methid);
    Delete(key);
    return udata;
  }

  void directorDeclaration(Node *n) {
    String *base = Getattr(n, "classtype");
    String *class_ctor = NewString("Swig::Director()");
    String *dirclassname = directorClassName(n);
    String *declaration = Swig_class_declaration(n, dirclassname);

    Printf(declaration, " : public %s, public Swig::Director", base);
    Setattr(n, "director:decl", declaration);
    Setattr(n, "director:ctor", class_ctor);

    Delete(dirclassname);
  }

  String *cAbiType(SwigType *t) {
    SwigType *resolved = SwigType_typedef_resolve_all(t);
    SwigType *stripped = SwigType_strip_qualifiers(resolved);
    String *result = NULL;

    if (SwigType_isreference(stripped)) {
      SwigType *base = SwigType_base(stripped);
      SwigType_add_pointer(base);
      result = SwigType_str(base, 0);
      Delete(base);
    } else {
      result = SwigType_str(stripped, 0);
    }

    Delete(stripped);
    Delete(resolved);
    return result;
  }

  void emitDirectorInput(String *code, SwigType *t, String *name) {
    SwigType *resolved = SwigType_typedef_resolve_all(t);
    SwigType *stripped = SwigType_strip_qualifiers(resolved);
    if (SwigType_isreference(stripped))
      Printf(code, "&%s", name);
    else
      Printf(code, "%s", name);
    Delete(stripped);
    Delete(resolved);
  }

  void emitDirectorOutput(String *code, SwigType *t, const_String_or_char_ptr name) {
    SwigType *resolved = SwigType_typedef_resolve_all(t);
    SwigType *stripped = SwigType_strip_qualifiers(resolved);
    if (SwigType_isreference(stripped))
      Printf(code, "*%s", name);
    else
      Printf(code, "%s", name);
    Delete(stripped);
    Delete(resolved);
  }

  void emitDirectorConnect(Node *n) {
    if (!Swig_directorclass(n))
      return;

    String *norm_name = SwigType_namestr(Getattr(n, "name"));
    String *dirclassname = directorClassName(n);
    String *swig_director_connect = Swig_name_member(getNSpace(), getClassPrefix(), "director_connect");
    String *swig_director_disconnect = Swig_name_member(getNSpace(), getClassPrefix(), "director_disconnect");
    String *wname = Swig_name_wrapper(swig_director_connect);
    String *disconnect_wname = Swig_name_wrapper(swig_director_disconnect);
    String *sym_name = Getattr(n, "sym:name");
    SwigType *smart = Getattr(n, "smart");
    String *target = director_rust_code ? director_rust_code : rustItemTarget();
    Wrapper *code_wrap = NewWrapper();
    Wrapper *disconnect_wrap = NewWrapper();

    Printf(code_wrap->def, "SWIGEXPORT void %s(void *objarg, void *rustobj", wname);
    if (smart) {
      String *smartnamestr = SwigType_namestr(smart);
      Printf(code_wrap->code, "  %s *smartobj = (%s *)objarg;\n", smartnamestr, smartnamestr);
      Printf(code_wrap->code, "  %s *obj = (%s *)(smartobj ? smartobj->get() : 0);\n", norm_name, norm_name);
      Delete(smartnamestr);
    } else {
      Printf(code_wrap->code, "  %s *obj = (%s *)objarg;\n", norm_name, norm_name);
    }
    Printf(code_wrap->code, "  if (!obj) return;\n");
    Printf(code_wrap->code, "  %s *director = static_cast<%s *>(obj);\n", dirclassname, dirclassname);
    Printf(code_wrap->code, "  director->swig_connect_director(rustobj");

    Printf(rust_extern_code, "  #[link_name = \"%s\"]\n", wname);
    Printf(rust_extern_code, "  pub fn %s_raw(obj: *mut c_void, rustobj: *mut c_void", swig_director_connect);
    String *rust_connect_params = NewString("");
    String *rust_connect_args = NewString("");
    String *rust_trait_args = NewString("");

    for (int i = first_class_dmethod; i < curr_class_dmethod; ++i) {
      UpcallData *udata = Getitem(dmethods_seq, i);
      String *methid = Getattr(udata, "class_methodidx");
      String *rust_callback_shim = Getattr(udata, "rust_callback_shim");

      Printf(code_wrap->def, ", %s::SWIG_Callback%s_t callback%s", dirclassname, methid, methid);
      Printf(code_wrap->code, ", callback%s", methid);
      Printf(rust_extern_code, ", callback%s: %sCallback%s", methid, sym_name, methid);
      if (Len(rust_connect_params)) {
        Printf(rust_connect_params, ", ");
        Printf(rust_connect_args, ", ");
        Printf(rust_trait_args, ", ");
      }
      Printf(rust_connect_params, "callback%s: %sCallback%s", methid, sym_name, methid);
      Printf(rust_connect_args, "callback%s", methid);
      Printf(rust_trait_args, "%s::<T>", rust_callback_shim);
    }

    Printf(code_wrap->def, ") {\n");
    Printf(code_wrap->code, ");\n");
    Printf(code_wrap->code, "}\n");
    Printf(rust_extern_code, ");\n");
    Printf(disconnect_wrap->def, "SWIGEXPORT void %s(void *objarg) {\n", disconnect_wname);
    if (smart) {
      String *smartnamestr = SwigType_namestr(smart);
      Printf(disconnect_wrap->code, "  %s *smartobj = (%s *)objarg;\n", smartnamestr, smartnamestr);
      Printf(disconnect_wrap->code, "  %s *obj = (%s *)(smartobj ? smartobj->get() : 0);\n", norm_name, norm_name);
      Delete(smartnamestr);
    } else {
      Printf(disconnect_wrap->code, "  %s *obj = (%s *)objarg;\n", norm_name, norm_name);
    }
    Printf(disconnect_wrap->code, "  if (!obj) return;\n");
    Printf(disconnect_wrap->code, "  %s *director = static_cast<%s *>(obj);\n", dirclassname, dirclassname);
    Printf(disconnect_wrap->code, "  director->swig_connect_director(0");
    for (int i = first_class_dmethod; i < curr_class_dmethod; ++i)
      Printf(disconnect_wrap->code, ", 0");
    Printf(disconnect_wrap->code, ");\n");
    Printf(disconnect_wrap->code, "}\n");
    Printf(rust_extern_code, "  #[link_name = \"%s\"]\n", disconnect_wname);
    Printf(rust_extern_code, "  pub fn %s_raw(obj: *mut c_void);\n", swig_director_disconnect);

    Printf(target, "impl %s {\n", sym_name);
    Printf(target, "  unsafe fn connect_director(&self, rustobj: *mut c_void");
    if (Len(rust_connect_params))
      Printf(target, ", %s", rust_connect_params);
    Printf(target, ") {\n");
    Printf(target, "    %s_raw(self.as_mut_ptr(), rustobj", swig_director_connect);
    if (Len(rust_connect_args))
      Printf(target, ", %s", rust_connect_args);
    Printf(target, ");\n");
    Printf(target, "  }\n");
    Printf(target, "  unsafe fn connect_director_trait<T: %sDirector>(&self, director: &mut T) {\n", sym_name);
    Printf(target, "    self.connect_director(director as *mut T as *mut c_void");
    if (Len(rust_trait_args))
      Printf(target, ", %s", rust_trait_args);
    Printf(target, ");\n");
    Printf(target, "  }\n");
    Printf(target, "  fn disconnect_director(&self) {\n");
    Printf(target, "    unsafe {\n");
    Printf(target, "    %s_raw(self.as_mut_ptr());\n", swig_director_disconnect);
    Printf(target, "    }\n");
    Printf(target, "  }\n");
    Printf(target, "}\n\n");
    Printf(target, "#[must_use]\n");
    Printf(target, "pub struct %sDirectorHandle<T: %sDirector> {\n", sym_name, sym_name);
    Printf(target, "  object: *mut c_void,\n");
    Printf(target, "  director: Option<Box<T>>,\n");
    Printf(target, "  connected: bool,\n");
    Printf(target, "}\n");
    Printf(target, "impl<T: %sDirector> %sDirectorHandle<T> {\n", sym_name, sym_name);
    Printf(target, "  pub fn connect(object: &%s, director: T) -> Self {\n", sym_name);
    Printf(target, "    let mut handle = Self { object: object.as_mut_ptr(), director: Some(Box::new(director)), connected: false };\n");
    Printf(target, "    unsafe {\n");
    Printf(target, "      object.connect_director_trait(&mut **handle.director.as_mut().expect(\"director handle has no director\"));\n");
    Printf(target, "    }\n");
    Printf(target, "    handle.connected = true;\n");
    Printf(target, "    handle\n");
    Printf(target, "  }\n");
    Printf(target, "  pub fn is_connected(&self) -> bool {\n");
    Printf(target, "    self.connected\n");
    Printf(target, "  }\n");
    Printf(target, "  pub fn disconnect(&mut self) {\n");
    Printf(target, "    if self.connected && !self.object.is_null() {\n");
    Printf(target, "      unsafe { %s_raw(self.object); }\n", swig_director_disconnect);
    Printf(target, "      self.connected = false;\n");
    Printf(target, "    }\n");
    Printf(target, "  }\n");
    Printf(target, "  pub fn into_director(mut self) -> T {\n");
    Printf(target, "    self.disconnect();\n");
    Printf(target, "    let director = *self.director.take().expect(\"director handle has no director\");\n");
    Printf(target, "    std::mem::forget(self);\n");
    Printf(target, "    director\n");
    Printf(target, "  }\n");
    Printf(target, "  pub fn into_disowned(mut self) -> %sDirectorDisowned<T> {\n", sym_name);
    Printf(target, "    let object = self.object;\n");
    Printf(target, "    let director = self.director.take().expect(\"director handle has no director\");\n");
    Printf(target, "    let connected = self.connected && !object.is_null();\n");
    Printf(target, "    self.connected = false;\n");
    Printf(target, "    std::mem::forget(self);\n");
    Printf(target, "    %sDirectorDisowned { object, director: Some(director), connected }\n", sym_name);
    Printf(target, "  }\n");
    Printf(target, "  pub unsafe fn disown(mut self) -> *mut T {\n");
    Printf(target, "    self.connected = false;\n");
    Printf(target, "    let director = Box::into_raw(self.director.take().expect(\"director handle has no director\"));\n");
    Printf(target, "    std::mem::forget(self);\n");
    Printf(target, "    director\n");
    Printf(target, "  }\n");
    Printf(target, "  pub unsafe fn reclaim_disowned(object: &%s, director: *mut T) -> T {\n", sym_name);
    Printf(target, "    %s_raw(object.as_mut_ptr());\n", swig_director_disconnect);
    Printf(target, "    *Box::from_raw(director)\n");
    Printf(target, "  }\n");
    Printf(target, "  pub fn director(&self) -> &T {\n");
    Printf(target, "    self.director.as_ref().expect(\"director handle has no director\")\n");
    Printf(target, "  }\n");
    Printf(target, "  pub fn director_mut(&mut self) -> &mut T {\n");
    Printf(target, "    self.director.as_mut().expect(\"director handle has no director\")\n");
    Printf(target, "  }\n");
    Printf(target, "}\n");
    Printf(target, "impl<T: %sDirector> Drop for %sDirectorHandle<T> {\n", sym_name, sym_name);
    Printf(target, "  fn drop(&mut self) {\n");
    Printf(target, "    self.disconnect();\n");
    Printf(target, "  }\n");
    Printf(target, "}\n\n");
    Printf(target, "#[must_use]\n");
    Printf(target, "pub struct %sDirectorDisowned<T: %sDirector> {\n", sym_name, sym_name);
    Printf(target, "  object: *mut c_void,\n");
    Printf(target, "  director: Option<Box<T>>,\n");
    Printf(target, "  connected: bool,\n");
    Printf(target, "}\n");
    Printf(target, "impl<T: %sDirector> %sDirectorDisowned<T> {\n", sym_name, sym_name);
    Printf(target, "  pub fn is_connected(&self) -> bool {\n");
    Printf(target, "    self.connected\n");
    Printf(target, "  }\n");
    Printf(target, "  pub fn disconnect(&mut self) {\n");
    Printf(target, "    if self.connected && !self.object.is_null() {\n");
    Printf(target, "      unsafe { %s_raw(self.object); }\n", swig_director_disconnect);
    Printf(target, "      self.connected = false;\n");
    Printf(target, "    }\n");
    Printf(target, "  }\n");
    Printf(target, "  pub fn director(&self) -> &T {\n");
    Printf(target, "    self.director.as_ref().expect(\"director disown guard has no director\")\n");
    Printf(target, "  }\n");
    Printf(target, "  pub fn director_mut(&mut self) -> &mut T {\n");
    Printf(target, "    self.director.as_mut().expect(\"director disown guard has no director\")\n");
    Printf(target, "  }\n");
    Printf(target, "  pub fn into_director(mut self) -> T {\n");
    Printf(target, "    self.disconnect();\n");
    Printf(target, "    let director = *self.director.take().expect(\"director disown guard has no director\");\n");
    Printf(target, "    std::mem::forget(self);\n");
    Printf(target, "    director\n");
    Printf(target, "  }\n");
    Printf(target, "}\n");
    Printf(target, "impl<T: %sDirector> Drop for %sDirectorDisowned<T> {\n", sym_name, sym_name);
    Printf(target, "  fn drop(&mut self) {\n");
    Printf(target, "    self.disconnect();\n");
    Printf(target, "  }\n");
    Printf(target, "}\n\n");
    Printf(target, "#[must_use]\n");
    Printf(target, "pub struct %sDirectorOwned<T: %sDirector> {\n", sym_name, sym_name);
    Printf(target, "  handle: %sDirectorHandle<T>,\n", sym_name);
    Printf(target, "  object: %s,\n", sym_name);
    Printf(target, "}\n");
    Printf(target, "impl<T: %sDirector> %sDirectorOwned<T> {\n", sym_name, sym_name);
    if (proxy_class_code && Strstr(proxy_class_code, "  pub fn new() -> Self")) {
      Printf(target, "  pub fn new(director: T) -> Self {\n");
      Printf(target, "    Self::from_proxy(%s::new(), director)\n", sym_name);
      Printf(target, "  }\n");
    }
    Printf(target, "  pub fn from_proxy(object: %s, director: T) -> Self {\n", sym_name);
    Printf(target, "    let handle = %sDirectorHandle::connect(&object, director);\n", sym_name);
    Printf(target, "    Self { handle, object }\n");
    Printf(target, "  }\n");
    Printf(target, "  pub fn as_proxy(&self) -> &%s {\n", sym_name);
    Printf(target, "    &self.object\n");
    Printf(target, "  }\n");
    Printf(target, "  pub fn as_proxy_mut(&mut self) -> &mut %s {\n", sym_name);
    Printf(target, "    &mut self.object\n");
    Printf(target, "  }\n");
    Printf(target, "  pub fn handle(&self) -> &%sDirectorHandle<T> {\n", sym_name);
    Printf(target, "    &self.handle\n");
    Printf(target, "  }\n");
    Printf(target, "  pub fn handle_mut(&mut self) -> &mut %sDirectorHandle<T> {\n", sym_name);
    Printf(target, "    &mut self.handle\n");
    Printf(target, "  }\n");
    Printf(target, "  pub fn director(&self) -> &T {\n");
    Printf(target, "    self.handle.director()\n");
    Printf(target, "  }\n");
    Printf(target, "  pub fn director_mut(&mut self) -> &mut T {\n");
    Printf(target, "    self.handle.director_mut()\n");
    Printf(target, "  }\n");
    Printf(target, "  pub fn is_connected(&self) -> bool {\n");
    Printf(target, "    self.handle.is_connected()\n");
    Printf(target, "  }\n");
    Printf(target, "  pub fn disconnect(&mut self) {\n");
    Printf(target, "    self.handle.disconnect();\n");
    Printf(target, "  }\n");
    Printf(target, "  pub fn into_director(self) -> T {\n");
    Printf(target, "    let Self { handle, object: _object } = self;\n");
    Printf(target, "    handle.into_director()\n");
    Printf(target, "  }\n");
    Printf(target, "  pub fn into_disowned(self) -> (%s, %sDirectorDisowned<T>) {\n", sym_name, sym_name);
    Printf(target, "    let Self { handle, object } = self;\n");
    Printf(target, "    (object, handle.into_disowned())\n");
    Printf(target, "  }\n");
    Printf(target, "}\n");
    Printf(target, "impl<T: %sDirector> std::ops::Deref for %sDirectorOwned<T> {\n", sym_name, sym_name);
    Printf(target, "  type Target = %s;\n", sym_name);
    Printf(target, "  fn deref(&self) -> &Self::Target {\n");
    Printf(target, "    self.as_proxy()\n");
    Printf(target, "  }\n");
    Printf(target, "}\n");
    Printf(target, "impl<T: %sDirector> std::ops::DerefMut for %sDirectorOwned<T> {\n", sym_name, sym_name);
    Printf(target, "  fn deref_mut(&mut self) -> &mut Self::Target {\n");
    Printf(target, "    self.as_proxy_mut()\n");
    Printf(target, "  }\n");
    Printf(target, "}\n\n");

    Wrapper_print(code_wrap, f_wrappers);
    Wrapper_print(disconnect_wrap, f_wrappers);
    DelWrapper(code_wrap);
    DelWrapper(disconnect_wrap);

    Delete(rust_connect_params);
    Delete(rust_connect_args);
    Delete(rust_trait_args);
    Delete(norm_name);
    Delete(dirclassname);
    Delete(swig_director_connect);
    Delete(swig_director_disconnect);
    Delete(wname);
    Delete(disconnect_wname);
  }

  String *rustReturnType(Node *n, SwigType *returntype) {
    String *enum_return = rustEnumNameForType(returntype);
    if (enum_return)
      return enum_return;

    String *tm = Swig_typemap_lookup("rusttype", n, "", 0);
    if (tm) {
      String *rusttypeout = Getattr(n, "tmap:rusttype:out");
      String *rust_return = Copy(rusttypeout ? rusttypeout : tm);
      String *proxy_return = rustProxyReturnType(returntype);
      if (proxy_return && rustTypeIsVoidPointer(rust_return)) {
        Delete(rust_return);
        rust_return = proxy_return;
      } else {
        Delete(proxy_return);
      }
      return rust_return;
    }
    String *proxy_return = rustProxyReturnType(returntype);
    if (proxy_return)
      return proxy_return;
    return rustType(returntype);
  }

  String *rustResultType(String *rust_return) const {
    if (Cmp(rust_return, "()") == 0)
      return NewString("Result<(), RustException>");
    return NewStringf("Result<%s, RustException>", rust_return);
  }

  void rustEmitResultExceptionCheck(String *body, const_String_or_char_ptr indent) {
    Printf(body, "%sif let Some(error) = rust_take_exception() {\n", indent);
    Printf(body, "%s  return Err(error);\n", indent);
    Printf(body, "%s}\n", indent);
  }

  String *rustOutCode(Node *n, String *imcall, const_String_or_char_ptr indent, bool result_mode = false) {
    SwigType *returntype = Getattr(n, "type");
    String *rust_return = rustReturnType(n, returntype);
    String *body = NewString("");

    String *proxy_body = rustProxyOutCode(n, returntype, imcall, indent, result_mode);
    if (proxy_body) {
      Delete(rust_return);
      return proxy_body;
    }

    String *enum_body = rustEnumOutCode(returntype, imcall, indent, result_mode);
    if (enum_body) {
      Delete(rust_return);
      return enum_body;
    }

    String *tm = Swig_typemap_lookup("rustout", n, "", 0);
    if (tm) {
      String *converted = Copy(tm);
      Replaceall(converted, "$imcall", "swig_result");
      Replaceall(converted, "$rustcall", "swig_result");
      Replaceall(converted, "\n", NewStringf("\n%s", indent));
      Printf(body, "%slet swig_result = %s;\n", indent, imcall);
      if (result_mode) {
        rustEmitResultExceptionCheck(body, indent);
        Printf(body, "%sOk({\n", indent);
        Printv(body, indent, "  ", converted, "\n", NIL);
        Printf(body, "%s})\n", indent);
      } else {
        Printf(body, "%srust_check_exception();\n", indent);
        Printv(body, indent, converted, "\n", NIL);
      }
      Delete(converted);
      Delete(rust_return);
      return body;
    }

    if (Cmp(rust_return, "()") != 0) {
      Printf(body, "%slet swig_result = %s;\n", indent, imcall);
      if (result_mode) {
        rustEmitResultExceptionCheck(body, indent);
        Printf(body, "%sOk(swig_result)\n", indent);
      } else {
        Printf(body, "%srust_check_exception();\n", indent);
        Printf(body, "%sswig_result\n", indent);
      }
    } else {
      Printf(body, "%s%s;\n", indent, imcall);
      if (result_mode) {
        rustEmitResultExceptionCheck(body, indent);
        Printf(body, "%sOk(())\n", indent);
      } else {
        Printf(body, "%srust_check_exception();\n", indent);
      }
    }
    Delete(rust_return);
    return body;
  }

  bool rustTypeIsVoidPointer(String *rust_type) const {
    return Cmp(rust_type, "*mut c_void") == 0 || Cmp(rust_type, "*const c_void") == 0;
  }

  bool rustTypeIsSmartPointer(SwigType *t) const {
    String *type_string = SwigType_str(t, 0);
    bool result = Strstr(type_string, "shared_ptr<");
    Delete(type_string);
    return result;
  }

  SwigType *rustSmartPointerValueType(SwigType *t) const {
    if (!rustTypeIsSmartPointer(t))
      return NULL;

    SwigType *value_type = NULL;
    List *template_args = SwigType_templateargslist(t);
    if (template_args) {
      Iterator first = First(template_args);
      if (first.item) {
        SwigType *arg = Copy(first.item);
        SwigType *arg_stripped = SwigType_strip_qualifiers(arg);
        value_type = Copy(arg_stripped);
        Delete(arg_stripped);
        Delete(arg);
      }
      Delete(template_args);
    }
    return value_type;
  }

  String *rustProxyNameForType(SwigType *t, bool *is_pointer, bool *is_reference) {
    *is_pointer = false;
    *is_reference = false;

    SwigType *resolved = SwigType_typedef_resolve_all(t);
    SwigType *stripped = SwigType_strip_qualifiers(resolved);
    SwigType *proxy_type = NULL;

    if ((proxy_type = rustSmartPointerValueType(stripped))) {
      /* Smart pointers are represented by the pointee proxy. The C wrapper passes
       * the smart pointer control object as a void pointer. */
    } else if (SwigType_ispointer(stripped)) {
      SwigType *base = SwigType_base(stripped);
      SwigType *base_stripped = SwigType_strip_qualifiers(base);
      if (!SwigType_ispointer(base_stripped) && !SwigType_isarray(base_stripped) && !SwigType_isreference(base_stripped)) {
        proxy_type = Copy(base_stripped);
        *is_pointer = true;
      }
      Delete(base_stripped);
      Delete(base);
    } else if (SwigType_isreference(stripped)) {
      String *reference_type_string = SwigType_str(stripped, 0);
      bool reference_to_pointer = Strstr(reference_type_string, "*") != 0;
      SwigType *base = SwigType_base(stripped);
      SwigType *base_stripped = SwigType_strip_qualifiers(base);
      if (SwigType_ispointer(base_stripped)) {
        SwigType *pointer_base = SwigType_base(base_stripped);
        SwigType *pointer_base_stripped = SwigType_strip_qualifiers(pointer_base);
        if (!SwigType_ispointer(pointer_base_stripped) && !SwigType_isarray(pointer_base_stripped) && !SwigType_isreference(pointer_base_stripped)) {
          proxy_type = Copy(pointer_base_stripped);
          *is_pointer = true;
        }
        Delete(pointer_base_stripped);
        Delete(pointer_base);
      } else if (reference_to_pointer) {
        proxy_type = Copy(base_stripped);
        *is_pointer = true;
      } else if (!SwigType_isarray(base_stripped) && !SwigType_isreference(base_stripped)) {
        proxy_type = Copy(base_stripped);
        *is_reference = true;
      }
      Delete(base_stripped);
      Delete(base);
      Delete(reference_type_string);
    } else if (!SwigType_isarray(stripped)) {
      proxy_type = Copy(stripped);
    }

    String *proxy_name = NULL;
    if (proxy_type) {
      Node *proxy_class = classLookup(proxy_type);
      if (proxy_class)
        proxy_name = Copy(Getattr(proxy_class, "sym:name"));
      Delete(proxy_type);
    }

    Delete(stripped);
    Delete(resolved);
    return proxy_name;
  }

  String *rustEnumNameForType(SwigType *t) {
    SwigType *resolved = SwigType_typedef_resolve_all(t);
    SwigType *stripped = SwigType_strip_qualifiers(resolved);
    SwigType *enum_type = NULL;

    if (SwigType_isreference(stripped)) {
      SwigType *base = SwigType_base(stripped);
      SwigType *base_stripped = SwigType_strip_qualifiers(base);
      if (SwigType_isenum(base_stripped))
        enum_type = Copy(base_stripped);
      Delete(base_stripped);
      Delete(base);
    } else if (SwigType_isenum(stripped)) {
      enum_type = Copy(stripped);
    }

    String *enum_name = NULL;
    if (enum_type) {
      Node *enum_node = enumLookup(enum_type);
      if (enum_node) {
        String *rust_enum_name = Getattr(enum_node, "rust:enumname");
        if (rust_enum_name) {
          enum_name = Copy(rust_enum_name);
        } else {
          String *symname = Getattr(enum_node, "sym:name");
          if (symname)
            enum_name = rustIdentifier(symname);
        }
      }
      Delete(enum_type);
    }

    Delete(stripped);
    Delete(resolved);
    return enum_name;
  }

  void applyRustEnumInput(SwigType *pt, String *arg, String **rust_type, String **rust_arg, bool *rust_type_owned) {
    String *enum_name = rustEnumNameForType(pt);
    if (!enum_name)
      return;

    if (*rust_type_owned)
      Delete(*rust_type);
    Delete(*rust_arg);
    *rust_type = enum_name;
    *rust_arg = NewStringf("%s.value()", arg);
    *rust_type_owned = true;
  }

  void applyRustProxyInput(SwigType *pt, String *arg, String **rust_type, String **rust_arg, bool *rust_type_owned) {
    if (!rustTypeIsVoidPointer(*rust_type))
      return;

    bool is_pointer = false;
    bool is_reference = false;
    String *proxy_name = rustProxyNameForType(pt, &is_pointer, &is_reference);
    if (!proxy_name)
      return;

    SwigType *resolved = SwigType_typedef_resolve_all(pt);
    bool is_smart_pointer = rustTypeIsSmartPointer(resolved);
    Delete(resolved);

    if (is_smart_pointer) {
      if (*rust_type_owned)
        Delete(*rust_type);
      Delete(*rust_arg);
      *rust_type = NewStringf("&%s", proxy_name);
      *rust_arg = NewStringf("%s.as_mut_ptr()", arg);
      *rust_type_owned = true;
    } else if (is_pointer || is_reference) {
      SwigType *base = Copy(pt);
      if (is_pointer) {
        if (SwigType_isreference(base))
          SwigType_del_reference(base);
        if (SwigType_ispointer(base))
          SwigType_del_pointer(base);
      } else {
        SwigType_del_reference(base);
      }
      bool is_const = SwigType_isconst(base);
      if (*rust_type_owned)
        Delete(*rust_type);
      Delete(*rust_arg);
      if (is_pointer) {
        if (is_const) {
          *rust_type = NewStringf("Option<&%s>", proxy_name);
        } else {
          *rust_type = NewStringf("Option<&mut %s>", proxy_name);
        }
        *rust_arg = NewStringf("%s.map(|value| value.as_mut_ptr()).unwrap_or(std::ptr::null_mut())", arg);
      } else {
        if (is_const) {
          *rust_type = NewStringf("&%s", proxy_name);
        } else {
          *rust_type = NewStringf("&mut %s", proxy_name);
        }
        *rust_arg = NewStringf("%s.as_mut_ptr()", arg);
      }
      *rust_type_owned = true;
      Delete(base);
    }
    Delete(proxy_name);
  }

  String *rustProxyReturnType(SwigType *returntype) {
    bool is_pointer = false;
    bool is_reference = false;
    String *proxy_name = rustProxyNameForType(returntype, &is_pointer, &is_reference);
    if (!proxy_name)
      return NULL;

    SwigType *resolved = SwigType_typedef_resolve_all(returntype);
    bool is_smart_pointer = rustTypeIsSmartPointer(resolved);
    Delete(resolved);

    String *rust_return = NULL;
    if (is_smart_pointer || is_pointer)
      rust_return = NewStringf("Option<%s>", proxy_name);
    else if (is_reference)
      rust_return = Copy(proxy_name);
    else
      rust_return = Copy(proxy_name);

    Delete(proxy_name);
    return rust_return;
  }

  String *rustProxyOutCode(Node *n, SwigType *returntype, String *imcall, const_String_or_char_ptr indent, bool result_mode = false) {
    bool is_pointer = false;
    bool is_reference = false;
    String *proxy_name = rustProxyNameForType(returntype, &is_pointer, &is_reference);
    if (!proxy_name)
      return NULL;

    SwigType *resolved = SwigType_typedef_resolve_all(returntype);
    bool is_smart_pointer = rustTypeIsSmartPointer(resolved);
    Delete(resolved);

    String *body = NewString("");
    Printf(body, "%slet swig_result = %s;\n", indent, imcall);
    if (result_mode)
      rustEmitResultExceptionCheck(body, indent);
    else
      Printf(body, "%srust_check_exception();\n", indent);
    if (result_mode)
      Printf(body, "%sOk(", indent);
    if (is_smart_pointer || is_pointer) {
      Printf(body, "%sif swig_result.is_null() {\n", result_mode ? "" : indent);
      Printf(body, "%s  None\n", indent);
      Printf(body, "%s} else {\n", indent);
      Printf(body,
             "%s  Some(%s::from_raw_owned_unchecked(swig_result, %s))\n",
             indent,
             proxy_name,
             is_smart_pointer ? "true" : (GetFlag(n, "feature:new") ? "true" : "false"));
      Printf(body, "%s}", indent);
    } else if (is_reference) {
      Printf(body, "%s%s::from_raw_owned_unchecked(swig_result, false)", result_mode ? "" : indent, proxy_name);
    } else {
      Printf(body, "%s%s::from_raw_owned_unchecked(swig_result, true)", result_mode ? "" : indent, proxy_name);
    }
    if (result_mode)
      Printf(body, ")\n");
    else
      Printf(body, "\n");

    Delete(proxy_name);
    return body;
  }

  String *rustProxyDirectorOutCode(SwigType *returntype, const_String_or_char_ptr rustcall) {
    bool is_pointer = false;
    bool is_reference = false;
    String *proxy_name = rustProxyNameForType(returntype, &is_pointer, &is_reference);
    if (!proxy_name)
      return NULL;

    SwigType *resolved = SwigType_typedef_resolve_all(returntype);
    bool is_smart_pointer = rustTypeIsSmartPointer(resolved);
    Delete(resolved);

    String *body = NULL;
    if (is_smart_pointer || is_pointer)
      body = NewStringf("%s.map(|value| value.into_raw()).unwrap_or(std::ptr::null_mut())", rustcall);
    else
      body = NewStringf("%s.into_raw()", rustcall);

    Delete(proxy_name);
    return body;
  }

  String *rustEnumOutCode(SwigType *returntype, String *imcall, const_String_or_char_ptr indent, bool result_mode = false) {
    String *enum_name = rustEnumNameForType(returntype);
    if (!enum_name)
      return NULL;

    String *body = NewString("");
    Printf(body, "%slet swig_result = %s;\n", indent, imcall);
    if (result_mode)
      rustEmitResultExceptionCheck(body, indent);
    else
      Printf(body, "%srust_check_exception();\n", indent);
    if (result_mode) {
      Printf(body,
             "%s%s::from_i32(swig_result).ok_or_else(|| RustException::new_unknown(format!(\"invalid enum value {} for %s\", swig_result)))\n",
             indent,
             enum_name,
             enum_name);
    } else {
      Printf(body, "%s%s::from_i32(swig_result).expect(\"SWIG returned an invalid value for enum %s\")\n", indent, enum_name, enum_name);
    }

    Delete(enum_name);
    return body;
  }

  void emitRustOutWithPost(String *target, String *body, String *rust_return, bool result_mode, String *rust_post_code, String *rust_terminator_code,
                           const_String_or_char_ptr indent) {
    if (Len(rust_post_code) || Len(rust_terminator_code)) {
      if (result_mode || Cmp(rust_return, "()") != 0) {
        Printf(target, "%slet swig_rust_result = {\n", indent);
        Printv(target, body, NIL);
        Printf(target, "%s};\n", indent);
        Printv(target, rust_post_code, rust_terminator_code, NIL);
        Printf(target, "%sswig_rust_result\n", indent);
      } else {
        Printv(target, body, rust_post_code, rust_terminator_code, NIL);
      }
    } else {
      Printv(target, body, NIL);
    }
  }

  void writeRustFunction(Node *n, String *rust_name, String *c_name, String *raw_return, String *rust_im_params, String *rust_params, String *rust_pre_code,
                         String *rust_post_code, String *rust_terminator_code, String *rust_args) {
    String *public_rust_name = rustPublicFunctionName(n);
    String *public_rust_return = rustReturnType(n, Getattr(n, "type"));

    Printf(rust_extern_code, "  #[link_name = \"%s\"]\n", c_name);
    Printf(rust_extern_code, "  pub fn %s_raw(%s)", rust_name, rust_im_params);
    if (Cmp(raw_return, "()") != 0)
      Printf(rust_extern_code, " -> %s", raw_return);
    Printf(rust_extern_code, ";\n");

    bool needs_unsafe = rustSignatureNeedsUnsafe(rust_params, public_rust_return);
    String *panic_public_rust_name = rust_exception_policy_result ? rustPanicIdentifier(public_rust_name) : Copy(public_rust_name);
    Printf(rust_proxy_code, "pub %sfn %s(%s)", needs_unsafe ? "unsafe " : "", panic_public_rust_name, rust_params);
    if (Cmp(public_rust_return, "()") != 0)
      Printf(rust_proxy_code, " -> %s", public_rust_return);
    Printf(rust_proxy_code, " {\n");
    if (!needs_unsafe)
      Printf(rust_proxy_code, "  unsafe {\n");
    Printv(rust_proxy_code, rust_pre_code, NIL);
    String *imcall = NewStringf("%s_raw(%s)", rust_name, rust_args);
    String *body =
      rustOutCode(n, imcall, (Len(rust_post_code) || Len(rust_terminator_code)) ? (needs_unsafe ? "    " : "      ") : (needs_unsafe ? "  " : "    "));
    emitRustOutWithPost(rust_proxy_code, body, public_rust_return, false, rust_post_code, rust_terminator_code, needs_unsafe ? "  " : "    ");
    if (!needs_unsafe)
      Printf(rust_proxy_code, "  }\n");
    Printf(rust_proxy_code, "}\n\n");
    Delete(body);

    String *result_type = rustResultType(public_rust_return);
    String *result_public_rust_name = rust_exception_policy_result ? Copy(public_rust_name) : rustTryIdentifier(public_rust_name);
    Printf(rust_proxy_code, "pub %sfn %s(%s) -> %s {\n", needs_unsafe ? "unsafe " : "", result_public_rust_name, rust_params, result_type);
    if (!needs_unsafe)
      Printf(rust_proxy_code, "  unsafe {\n");
    Printv(rust_proxy_code, rust_pre_code, NIL);
    body =
      rustOutCode(n, imcall, (Len(rust_post_code) || Len(rust_terminator_code)) ? (needs_unsafe ? "    " : "      ") : (needs_unsafe ? "  " : "    "), true);
    emitRustOutWithPost(rust_proxy_code, body, public_rust_return, true, rust_post_code, rust_terminator_code, needs_unsafe ? "  " : "    ");
    if (!needs_unsafe)
      Printf(rust_proxy_code, "  }\n");
    Printf(rust_proxy_code, "}\n\n");
    Delete(body);
    Delete(result_type);
    Delete(result_public_rust_name);
    Delete(panic_public_rust_name);
    Delete(imcall);
    Delete(public_rust_return);
    Delete(public_rust_name);
  }

  bool isRustKeyword(const String *name) const {
    static const char *keywords[] = {"Self",     "abstract", "as",   "async",  "await",  "become", "box",    "break",  "const", "continue",
                                     "crate",    "do",       "dyn",  "else",   "enum",   "extern", "false",  "final",  "fn",    "for",
                                     "if",       "impl",     "in",   "let",    "loop",   "macro",  "match",  "mod",    "move",  "mut",
                                     "override", "priv",     "pub",  "ref",    "return", "self",   "static", "struct", "super", "trait",
                                     "true",     "try",      "type", "typeof", "unsafe", "use",    "where",  "while",  "yield"};

    for (size_t i = 0; i < sizeof(keywords) / sizeof(keywords[0]); ++i) {
      if (Cmp(name, keywords[i]) == 0)
        return true;
    }
    return false;
  }

  String *rustIdentifier(const String *name) const {
    if (!name)
      return NewString("");
    if (isRustKeyword(name))
      return NewStringf("r#%s", name);
    return Copy(name);
  }

  bool rustIsIdentifierStart(char c) const {
    return (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || c == '_';
  }

  bool rustIsIdentifierContinue(char c) const {
    return rustIsIdentifierStart(c) || (c >= '0' && c <= '9');
  }

  bool rustIsPlainIdentifier(const String *name) const {
    const char *value = Char(name);
    if (!value || !*value || !rustIsIdentifierStart(*value))
      return false;
    for (const char *c = value + 1; *c; ++c) {
      if (!rustIsIdentifierContinue(*c))
        return false;
    }
    return true;
  }

  String *rustSnakeCaseIdentifier(const String *name) const {
    String *snake = NewString("");
    const char *value = Char(name);
    bool previous_lower_or_digit = false;
    bool previous_underscore = false;

    for (const char *c = value; c && *c; ++c) {
      char ch = *c;
      bool upper = ch >= 'A' && ch <= 'Z';
      bool digit = ch >= '0' && ch <= '9';
      if (upper && previous_lower_or_digit && !previous_underscore)
        Printf(snake, "_");
      if (upper)
        ch = ch - 'A' + 'a';
      Printf(snake, "%c", ch);
      previous_lower_or_digit = (ch >= 'a' && ch <= 'z') || digit;
      previous_underscore = ch == '_';
    }

    if (isRustKeyword(snake)) {
      String *raw = NewStringf("r#%s", snake);
      Delete(snake);
      return raw;
    }
    return snake;
  }

  String *rustConfiguredIdentifier(const String *name) const {
    String *identifier = rustIdentifier(name);
    if (!rust_method_case_snake)
      return identifier;
    String *snake = rustSnakeCaseIdentifier(identifier);
    Delete(identifier);
    return snake;
  }

  String *rustModuleIdentifier(const String *name) const {
    if (!name)
      return NewString("");
    if (Strncmp(name, "r#", 2) == 0)
      return NewStringf("%s_", Char(name) + 2);
    if (isRustKeyword(name))
      return NewStringf("%s_", name);
    return Copy(name);
  }

  String *rustAssociatedConstantName(const String *name) const {
    String *rust_name = rustIdentifier(name);
    String *constant_name = NewString("");
    const char *value = Char(rust_name);
    for (const char *c = value; c && *c; ++c) {
      char ch = *c;
      if (ch >= 'a' && ch <= 'z')
        ch = ch - 'a' + 'A';
      Printf(constant_name, "%c", ch);
    }
    Delete(rust_name);
    return constant_name;
  }

  String *rustTryIdentifier(const String *name) const {
    if (Strncmp(name, "r#", 2) == 0)
      return NewStringf("r#try_%s", Char(name) + 2);
    return NewStringf("try_%s", name);
  }

  String *rustPanicIdentifier(const String *name) const {
    if (Strncmp(name, "r#", 2) == 0)
      return NewStringf("r#panic_%s", Char(name) + 2);
    return NewStringf("panic_%s", name);
  }

  String *rustOverloadSuffix(String *overname) const {
    if (overname && Strncmp(overname, "__SWIG_", 7) == 0)
      return NewStringf("_%s", Char(overname) + 7);
    return NewStringf("_%s", overname ? overname : "");
  }

  bool rustIsFirstOverload(Node *n) const {
    String *overname = Getattr(n, "sym:overname");
    return overname && Cmp(overname, "__SWIG_0") == 0;
  }

  String *rustPublicFunctionName(Node *n) const {
    String *name = rustConfiguredIdentifier(Getattr(n, "sym:name"));
    if (Getattr(n, "sym:overloaded") && !rustIsFirstOverload(n)) {
      String *suffix = rustOverloadSuffix(Getattr(n, "sym:overname"));
      Printf(name, "%s", suffix);
      Delete(suffix);
    }
    return name;
  }

  bool rustTypeIsPrimitive(SwigType *t) {
    SwigType *resolved = SwigType_typedef_resolve_all(t);
    SwigType *stripped = SwigType_strip_qualifiers(resolved);
    bool primitive = Cmp(stripped, "void") == 0 || Cmp(stripped, "bool") == 0 || Cmp(stripped, "char") == 0 || Cmp(stripped, "signed char") == 0 ||
                     Cmp(stripped, "unsigned char") == 0 || Cmp(stripped, "short") == 0 || Cmp(stripped, "unsigned short") == 0 || Cmp(stripped, "int") == 0 ||
                     Cmp(stripped, "unsigned int") == 0 || Cmp(stripped, "long") == 0 || Cmp(stripped, "unsigned long") == 0 ||
                     Cmp(stripped, "long long") == 0 || Cmp(stripped, "unsigned long long") == 0 || Cmp(stripped, "float") == 0 || Cmp(stripped, "double") == 0;
    Delete(stripped);
    Delete(resolved);
    return primitive;
  }

  String *rustType(SwigType *t) {
    SwigType *resolved = SwigType_typedef_resolve_all(t);
    SwigType *stripped = SwigType_strip_qualifiers(resolved);
    String *result = NULL;

    if (SwigType_ispointer(stripped) || SwigType_isarray(stripped)) {
      SwigType *base = SwigType_base(stripped);
      SwigType *base_stripped = SwigType_strip_qualifiers(base);
      if (Cmp(base_stripped, "char") == 0) {
        result = NewString("*mut c_char");
      } else if (Cmp(base_stripped, "void") == 0) {
        result = NewString("*mut c_void");
      } else {
        result = NewString("*mut c_void");
      }
      Delete(base_stripped);
      Delete(base);
    } else if (SwigType_isreference(stripped)) {
      result = NewString("*mut c_void");
    } else if (Cmp(stripped, "void") == 0) {
      result = NewString("()");
    } else if (Cmp(stripped, "bool") == 0) {
      result = NewString("bool");
    } else if (Cmp(stripped, "char") == 0) {
      result = NewString("c_char");
    } else if (Cmp(stripped, "signed char") == 0) {
      result = NewString("c_schar");
    } else if (Cmp(stripped, "unsigned char") == 0) {
      result = NewString("c_uchar");
    } else if (Cmp(stripped, "short") == 0) {
      result = NewString("c_short");
    } else if (Cmp(stripped, "unsigned short") == 0) {
      result = NewString("c_ushort");
    } else if (Cmp(stripped, "int") == 0) {
      result = NewString("c_int");
    } else if (Cmp(stripped, "unsigned int") == 0) {
      result = NewString("c_uint");
    } else if (Cmp(stripped, "long") == 0) {
      result = NewString("c_long");
    } else if (Cmp(stripped, "unsigned long") == 0) {
      result = NewString("c_ulong");
    } else if (Cmp(stripped, "long long") == 0) {
      result = NewString("c_longlong");
    } else if (Cmp(stripped, "unsigned long long") == 0) {
      result = NewString("c_ulonglong");
    } else if (Cmp(stripped, "float") == 0) {
      result = NewString("c_float");
    } else if (Cmp(stripped, "double") == 0) {
      result = NewString("c_double");
    } else {
      result = NewString("*mut c_void");
    }

    Delete(stripped);
    Delete(resolved);
    return result;
  }
};

/* -----------------------------------------------------------------------------
 * swig_rust()    - Instantiate module
 * ----------------------------------------------------------------------------- */

static Language *new_swig_rust() {
  return new RUST();
}

extern "C" Language *swig_rust(void) {
  return new_swig_rust();
}
