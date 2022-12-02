/* ----------------------------------------------------------------------------- 
 * This file is part of SWIG, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at https://www.swig.org/legal.html.
 *
 * misc.c
 *
 * Miscellaneous functions that don't really fit anywhere else.
 * ----------------------------------------------------------------------------- */

#include "swig.h"
#include <errno.h>
#include <ctype.h>
#include <limits.h>
#include <sys/types.h>
#include <sys/stat.h>

#ifdef _WIN32
#include <direct.h>
#ifndef S_ISDIR
#define S_ISDIR(mode) (((mode) & S_IFDIR) == S_IFDIR)
#endif
#endif

static char *fake_version = 0;

/* -----------------------------------------------------------------------------
 * Swig_copy_string()
 *
 * Duplicate a NULL-terminate string given as a char *.
 * ----------------------------------------------------------------------------- */

char *Swig_copy_string(const char *s) {
  char *c = 0;
  if (s) {
    c = (char *) Malloc(strlen(s) + 1);
    strcpy(c, s);
  }
  return c;
}

/* -----------------------------------------------------------------------------
 * Swig_set_fakeversion()
 *
 * Version string override
 * ----------------------------------------------------------------------------- */

void Swig_set_fakeversion(const char *version) {
  fake_version = Swig_copy_string(version);
}

/* -----------------------------------------------------------------------------
 * Swig_package_version()
 *
 * Return the package string containing the version number
 * ----------------------------------------------------------------------------- */

const char *Swig_package_version(void) {
  return fake_version ? fake_version : PACKAGE_VERSION;
}

/* -----------------------------------------------------------------------------
 * Swig_package_version_hex()
 *
 * Return the package version in hex format "0xAABBCC" such as "0x040200" for 4.2.0
 * ----------------------------------------------------------------------------- */

String *Swig_package_version_hex(void) {
  String *package_version = NewString(Swig_package_version());
  char *token;
  String *vers = NewString("SWIG_VERSION 0x");
  int count = 0;
  token = strstr(Char(package_version), "+");
  if (token) {
    // Remove '+' suffix
    *token = '\0';
  }
  token = strtok(Char(package_version), ".");
  while (token) {
    int len = (int)strlen(token);
    assert(len == 1 || len == 2);
    Printf(vers, "%s%s", (len == 1) ? "0" : "", token);
    token = strtok(NULL, ".");
    count++;
  }
  Delete(package_version);
  assert(count == 3); /* Check version format is correct */
  return vers;
}

/* -----------------------------------------------------------------------------
 * Swig_obligatory_macros()
 *
 * Generates the SWIG_VERSION and SWIGXXX macros where XXX is the target language
 * name (must be provided uppercase).
 * ----------------------------------------------------------------------------- */

void Swig_obligatory_macros(String *f_runtime, const char *language) {
  String *version_hex = Swig_package_version_hex();
  Printf(f_runtime, "\n\n");
  Printf(f_runtime, "#define %s\n", version_hex);
  Printf(f_runtime, "#define SWIG%s\n", language);
  Delete(version_hex);
}

/* -----------------------------------------------------------------------------
 * Swig_banner()
 *
 * Emits the SWIG identifying banner for the C/C++ wrapper file.
 * ----------------------------------------------------------------------------- */

void Swig_banner(File *f) {
  Printf(f, "/* ----------------------------------------------------------------------------\n");
  Swig_banner_target_lang(f, " *");
  Printf(f, " * ----------------------------------------------------------------------------- */\n");

}

/* -----------------------------------------------------------------------------
 * Swig_banner_target_lang()
 *
 * Emits a SWIG identifying banner in the target language
 * ----------------------------------------------------------------------------- */

void Swig_banner_target_lang(File *f, const_String_or_char_ptr commentchar) {
  Printf(f, "%s This file was automatically generated by SWIG (https://www.swig.org).\n", commentchar);
  Printf(f, "%s Version %s\n", commentchar, Swig_package_version());
  Printf(f, "%s\n", commentchar);
  Printf(f, "%s Do not make changes to this file unless you know what you are doing - modify\n", commentchar);
  Printf(f, "%s the SWIG interface file instead.\n", commentchar);
}

/* -----------------------------------------------------------------------------
 * Swig_strip_c_comments()
 *
 * Return a new string with C comments stripped from the input string. NULL is
 * returned if there aren't any comments.
 * ----------------------------------------------------------------------------- */

String *Swig_strip_c_comments(const String *s) {
  const char *c = Char(s);
  const char *comment_begin = 0;
  const char *comment_end = 0;
  String *stripped = 0;

  while (*c) {
    if (!comment_begin && *c == '/') {
      ++c;
      if (!*c)
        break;
      if (*c == '*')
        comment_begin = c-1;
    } else if (comment_begin && !comment_end && *c == '*') {
      ++c;
      if (*c == '/') {
        comment_end = c;
        break;
      }
    }
    ++c;
  }

  if (comment_begin && comment_end) {
    int size = (int)(comment_begin - Char(s));
    String *stripmore = 0;
    stripped = NewStringWithSize(s, size);
    Printv(stripped, comment_end + 1, NIL);
    do {
      stripmore = Swig_strip_c_comments(stripped);
      if (stripmore) {
        Delete(stripped);
        stripped = stripmore;
      }
    } while (stripmore);
  }
  return stripped;
}

/* -----------------------------------------------------------------------------
 * is_directory()
 * ----------------------------------------------------------------------------- */
static int is_directory(String *directory) {
  int last = Len(directory) - 1;
  int statres;
  struct stat st;
  char *dir = Char(directory);
  if (dir[last] == SWIG_FILE_DELIMITER[0]) {
    /* remove trailing slash - can cause S_ISDIR to fail on Windows, at least */
    dir[last] = 0;
    statres = stat(dir, &st);
    dir[last] = SWIG_FILE_DELIMITER[0];
  } else {
    statres = stat(dir, &st);
  }
  return (statres == 0 && S_ISDIR(st.st_mode));
}

/* -----------------------------------------------------------------------------
 * Swig_new_subdirectory()
 *
 * Create the subdirectory only if the basedirectory already exists as a directory.
 * basedirectory can be empty to indicate current directory but not NULL.
 * ----------------------------------------------------------------------------- */

String *Swig_new_subdirectory(String *basedirectory, String *subdirectory) {
  String *error = 0;
  int current_directory = Len(basedirectory) == 0;

  if (current_directory || is_directory(basedirectory)) {
    Iterator it;
    String *dir = NewString(basedirectory);
    List *subdirs = Split(subdirectory, SWIG_FILE_DELIMITER[0], INT_MAX);

    for (it = First(subdirs); it.item; it = Next(it)) {
      int result;
      String *subdirectory = it.item;
      Printf(dir, "%s", subdirectory);
#ifdef _WIN32
      result = _mkdir(Char(dir));
#else
      result = mkdir(Char(dir), 0777);
#endif
      if (result != 0 && errno != EEXIST) {
	error = NewStringf("Cannot create directory %s: %s", dir, strerror(errno));
	break;
      }
      if (!is_directory(dir)) {
	error = NewStringf("Cannot create directory %s: it may already exist but not be a directory", dir);
	break;
      }
      Printf(dir, SWIG_FILE_DELIMITER);
    }
  } else {
    error = NewStringf("Cannot create subdirectory %s under the base directory %s. Either the base does not exist as a directory or it is not readable.", subdirectory, basedirectory);
  }
  return error;
}

/* -----------------------------------------------------------------------------
 * Swig_filename_correct()
 *
 * Corrects filename paths by removing duplicate delimiters and on non-unix
 * systems use the correct delimiter across the whole name.
 * ----------------------------------------------------------------------------- */

void Swig_filename_correct(String *filename) {
  int network_path = 0;
  if (Len(filename) >= 2) {
    const char *fname = Char(filename);
    if (fname[0] == '\\' && fname[1] == '\\')
      network_path = 1;
    if (fname[0] == '/' && fname[1] == '/')
      network_path = 1;
  }
#if defined(_WIN32)
  /* accept Unix path separator on non-Unix systems */
  Replaceall(filename, "/", SWIG_FILE_DELIMITER);
#endif
#if defined(__CYGWIN__)
  /* accept Windows path separator in addition to Unix path separator */
  Replaceall(filename, "\\", SWIG_FILE_DELIMITER);
#endif
  /* remove all duplicate file name delimiters */
  while (Replaceall(filename, SWIG_FILE_DELIMITER SWIG_FILE_DELIMITER, SWIG_FILE_DELIMITER)) {
  }
  /* Network paths can start with a double slash on Windows - unremove the duplicate slash we just removed */
  if (network_path)
    Insert(filename, 0, SWIG_FILE_DELIMITER);
}

/* -----------------------------------------------------------------------------
 * Swig_filename_escape()
 *
 * Escapes backslashes in filename - for Windows
 * ----------------------------------------------------------------------------- */

String *Swig_filename_escape(String *filename) {
  String *adjusted_filename = Copy(filename);
  Swig_filename_correct(adjusted_filename);
#if defined(_WIN32)		/* Note not on Cygwin else filename is displayed with double '/' */
  Replaceall(adjusted_filename, "\\", "\\\\");
#endif
  return adjusted_filename;
}

/* -----------------------------------------------------------------------------
 * Swig_filename_escape()
 *
 * Escapes spaces in filename - for Makefiles
 * ----------------------------------------------------------------------------- */

String *Swig_filename_escape_space(String *filename) {
  String *adjusted_filename = Copy(filename);
  Swig_filename_correct(adjusted_filename);
  Replaceall(adjusted_filename, " ", "\\ ");
  return adjusted_filename;
}

/* -----------------------------------------------------------------------------
 * Swig_filename_unescape()
 *
 * Remove double backslash escaping in filename - for Windows
 * ----------------------------------------------------------------------------- */

void Swig_filename_unescape(String *filename) {
  (void)filename;
#if defined(_WIN32)
  Replaceall(filename, "\\\\", "\\");
#endif
}

/* -----------------------------------------------------------------------------
 * Swig_storage_isextern()
 *
 * Determine if the storage class specifier is extern (but not externc)
 * ----------------------------------------------------------------------------- */

int Swig_storage_isextern(Node *n) {
  const String *storage = Getattr(n, "storage");
  return storage ? Strcmp(storage, "extern") == 0 || Strncmp(storage, "extern ", 7) == 0 : 0;
}

/* -----------------------------------------------------------------------------
 * Swig_storage_isexternc()
 *
 * Determine if the storage class specifier is externc (but not plain extern)
 * ----------------------------------------------------------------------------- */

int Swig_storage_isexternc(Node *n) {
  const String *storage = Getattr(n, "storage");
  return storage ? Strcmp(storage, "externc") == 0 || Strncmp(storage, "externc ", 8) == 0 : 0;
}

/* -----------------------------------------------------------------------------
 * Swig_storage_isstatic_custom()
 *
 * Determine if the storage class specifier is static
 * ----------------------------------------------------------------------------- */

int Swig_storage_isstatic_custom(Node *n, const_String_or_char_ptr storage_name) {
  const String *storage = Getattr(n, storage_name);
  return storage ? Strncmp(storage, "static", 6) == 0 : 0;
}

/* -----------------------------------------------------------------------------
 * Swig_storage_isstatic()
 *
 * Determine if the storage class specifier is static
 * ----------------------------------------------------------------------------- */

int Swig_storage_isstatic(Node *n) {
  return Swig_storage_isstatic_custom(n, "storage");
}

/* -----------------------------------------------------------------------------
 * Swig_string_escape()
 *
 * Takes a string object and produces a string with escape codes added to it.
 * Octal escaping is used.
 * ----------------------------------------------------------------------------- */

String *Swig_string_escape(String *s) {
  String *ns;
  int c;
  ns = NewStringEmpty();

  while ((c = Getc(s)) != EOF) {
    if (c == '\n') {
      Printf(ns, "\\n");
    } else if (c == '\r') {
      Printf(ns, "\\r");
    } else if (c == '\t') {
      Printf(ns, "\\t");
    } else if (c == '\\') {
      Printf(ns, "\\\\");
    } else if (c == '\'') {
      Printf(ns, "\\'");
    } else if (c == '\"') {
      Printf(ns, "\\\"");
    } else if (c == ' ') {
      Putc(c, ns);
    } else if (!isgraph(c)) {
      if (c < 0)
	c += UCHAR_MAX + 1;
      Printf(ns, "\\%o", c);
    } else {
      Putc(c, ns);
    }
  }
  return ns;
}

/* -----------------------------------------------------------------------------
 * Swig_string_hexescape()
 *
 * Takes a string object and produces a string with escape codes added to it.
 * Hex escaping is used.
 * ----------------------------------------------------------------------------- */

String *Swig_string_hexescape(String *s) {
  String *ns;
  int c;
  ns = NewStringEmpty();

  while ((c = Getc(s)) != EOF) {
    if (c == '\n') {
      Printf(ns, "\\n");
    } else if (c == '\r') {
      Printf(ns, "\\r");
    } else if (c == '\t') {
      Printf(ns, "\\t");
    } else if (c == '\\') {
      Printf(ns, "\\\\");
    } else if (c == '\'') {
      Printf(ns, "\\'");
    } else if (c == '\"') {
      Printf(ns, "\\\"");
    } else if (c == ' ') {
      Putc(c, ns);
    } else if (!isgraph(c)) {
      if (c < 0)
	c += UCHAR_MAX + 1;
      Printf(ns, "\\x%X", c);
    } else {
      Putc(c, ns);
    }
  }
  return ns;
}

/* -----------------------------------------------------------------------------
 * Swig_string_upper()
 *
 * Takes a string object and returns a copy that is uppercase
 * ----------------------------------------------------------------------------- */

String *Swig_string_upper(String *s) {
  String *ns;
  int c;
  ns = NewStringEmpty();

  Seek(s, 0, SEEK_SET);
  while ((c = Getc(s)) != EOF) {
    Putc(toupper(c), ns);
  }
  return ns;
}

/* -----------------------------------------------------------------------------
 * Swig_string_lower()
 *
 * Takes a string object and returns a copy that is lowercase
 * ----------------------------------------------------------------------------- */

String *Swig_string_lower(String *s) {
  String *ns;
  int c;
  ns = NewStringEmpty();

  Seek(s, 0, SEEK_SET);
  while ((c = Getc(s)) != EOF) {
    Putc(tolower(c), ns);
  }
  return ns;
}


/* -----------------------------------------------------------------------------
 * Swig_string_title()
 *
 * Takes a string object and returns a copy that is lowercase with first letter
 * capitalized
 * ----------------------------------------------------------------------------- */

String *Swig_string_title(String *s) {
  String *ns;
  int first = 1;
  int c;
  ns = NewStringEmpty();

  Seek(s, 0, SEEK_SET);
  while ((c = Getc(s)) != EOF) {
    Putc(first ? toupper(c) : tolower(c), ns);
    first = 0;
  }
  return ns;
}

/* -----------------------------------------------------------------------------
 * Swig_string_ccase()
 *
 * Takes a string object and returns a copy that is lowercase with the first
 * letter capitalized and the one following '_', which are removed.
 *
 *      camel_case -> CamelCase
 *      camelCase  -> CamelCase
 * ----------------------------------------------------------------------------- */

String *Swig_string_ccase(String *s) {
  String *ns;
  int first = 1;
  int c;
  ns = NewStringEmpty();

  Seek(s, 0, SEEK_SET);
  while ((c = Getc(s)) != EOF) {
    if (c == '_') {
      first = 1;
      continue;
    }
    Putc(first ? toupper(c) : c, ns);
    first = 0;
  }
  return ns;
}

/* -----------------------------------------------------------------------------
 * Swig_string_lccase()
 *
 * Takes a string object and returns a copy with the character after
 * each '_' capitalised, and the '_' removed.  The first character is
 * also forced to lowercase.
 *
 *      camel_case -> camelCase
 *      CamelCase  -> camelCase
 * ----------------------------------------------------------------------------- */

String *Swig_string_lccase(String *s) {
  String *ns;
  int first = 1;
  int after_underscore = 0;
  int c;
  ns = NewStringEmpty();

  Seek(s, 0, SEEK_SET);
  while ((c = Getc(s)) != EOF) {
    if (c == '_') {
      after_underscore = 1;
      continue;
    }
    if (first) {
      Putc(tolower(c), ns);
      first = 0;
    } else {
      Putc(after_underscore ? toupper(c) : c, ns);
    }
    after_underscore = 0;
  }
  return ns;
}

/* -----------------------------------------------------------------------------
 * Swig_string_ucase()
 *
 * This is the reverse case of ccase, ie
 *
 *      CamelCase -> camel_case
 *      get2D     -> get_2d
 *      asFloat2  -> as_float2
 * ----------------------------------------------------------------------------- */

String *Swig_string_ucase(String *s) {
  String *ns;
  int c;
  int lastC = 0;
  int nextC = 0;
  int underscore = 0;
  ns = NewStringEmpty();

  /* We insert a underscore when:
     1. Lower case char followed by upper case char
     getFoo > get_foo; getFOo > get_foo; GETFOO > getfoo
     2. Number preceded by char and not end of string
     get2D > get_2d; get22D > get_22d; GET2D > get_2d
     but:
     asFloat2 > as_float2
  */

  Seek(s, 0, SEEK_SET);

  while ((c = Getc(s)) != EOF) {
    nextC = Getc(s); Ungetc(nextC, s);
    if (isdigit(c) && isalpha(lastC) && nextC != EOF)
      underscore = 1;
    else if (isupper(c) && isalpha(lastC) && !isupper(lastC))
      underscore = 1;

    lastC = c;

    if (underscore) {
      Putc('_', ns);
      underscore = 0;
    }

    Putc(tolower(c), ns);
  }
  return ns;
}

/* -----------------------------------------------------------------------------
 * Swig_string_first_upper()
 *
 * Make the first character in the string uppercase, leave all the 
 * rest the same.  This is used by the Ruby module to provide backwards
 * compatibility with the old way of naming classes and constants.  For
 * more info see the Ruby documentation.
 *
 *      firstUpper -> FirstUpper 
 * ----------------------------------------------------------------------------- */

String *Swig_string_first_upper(String *s) {
  String *ns = NewStringEmpty();
  char *cs = Char(s);
  if (cs && cs[0] != 0) {
    Putc(toupper((int)cs[0]), ns);
    Append(ns, cs + 1);
  }
  return ns;
}

/* -----------------------------------------------------------------------------
 * Swig_string_first_lower()
 *
 * Make the first character in the string lowercase, leave all the 
 * rest the same.  This is used by the Ruby module to provide backwards
 * compatibility with the old way of naming classes and constants.  For
 * more info see the Ruby documentation.
 *
 *      firstLower -> FirstLower 
 * ----------------------------------------------------------------------------- */

String *Swig_string_first_lower(String *s) {
  String *ns = NewStringEmpty();
  char *cs = Char(s);
  if (cs && cs[0] != 0) {
    Putc(tolower((int)cs[0]), ns);
    Append(ns, cs + 1);
  }
  return ns;
}

/* -----------------------------------------------------------------------------
 * Swig_string_schemify()
 *
 * Replace underscores with dashes, to make identifiers look nice to Schemers.
 *
 *      under_scores -> under-scores
 * ----------------------------------------------------------------------------- */

String *Swig_string_schemify(String *s) {
  String *ns = NewString(s);
  Replaceall(ns, "_", "-");
  return ns;
}

/* -----------------------------------------------------------------------------
 * Swig_string_typecode()
 *
 * Takes a string with possible type-escapes in it and replaces them with
 * real C datatypes.
 * ----------------------------------------------------------------------------- */

String *Swig_string_typecode(String *s) {
  String *ns;
  int c;
  String *tc;
  ns = NewStringEmpty();
  while ((c = Getc(s)) != EOF) {
    if (c == '`') {
      String *str = 0;
      tc = NewStringEmpty();
      while ((c = Getc(s)) != EOF) {
	if (c == '`')
	  break;
	Putc(c, tc);
      }
      str = SwigType_str(tc, 0);
      Append(ns, str);
      Delete(str);
    } else {
      Putc(c, ns);
      if (c == '\'') {
	while ((c = Getc(s)) != EOF) {
	  Putc(c, ns);
	  if (c == '\'')
	    break;
	  if (c == '\\') {
	    c = Getc(s);
	    Putc(c, ns);
	  }
	}
      } else if (c == '\"') {
	while ((c = Getc(s)) != EOF) {
	  Putc(c, ns);
	  if (c == '\"')
	    break;
	  if (c == '\\') {
	    c = Getc(s);
	    Putc(c, ns);
	  }
	}
      }
    }
  }
  return ns;
}

static String *string_mangle(String *s) {
  return Swig_name_mangle_string(s);
}


/* -----------------------------------------------------------------------------
 * Swig_scopename_split()
 *
 * Take a qualified name like "A::B::C" and splits off the last name.
 * In this case, returns "C" as last and "A::B" as prefix.
 * Always returns non NULL for last, but prefix may be NULL if there is no prefix.
 * ----------------------------------------------------------------------------- */

void Swig_scopename_split(const String *s, String **rprefix, String **rlast) {
  char *tmp = Char(s);
  char *c = tmp;
  char *cc = c;
  char *co = 0;
  if (!strstr(c, "::")) {
    *rprefix = 0;
    *rlast = Copy(s);
  }

  co = strstr(cc, "operator ");
  if (co) {
    if (co == cc) {
      *rprefix = 0;
      *rlast = Copy(s);
      return;
    } else {
      *rprefix = NewStringWithSize(cc, (int)(co - cc - 2));
      *rlast = NewString(co);
      return;
    }
  }
  while (*c) {
    if ((*c == ':') && (*(c + 1) == ':')) {
      cc = c;
      c += 2;
    } else {
      if (*c == '<') {
	int level = 1;
	c++;
	while (*c && level) {
	  if (*c == '<')
	    level++;
	  if (*c == '>')
	    level--;
	  c++;
	}
      } else {
	c++;
      }
    }
  }

  if (cc != tmp) {
    *rprefix = NewStringWithSize(tmp, (int)(cc - tmp));
    *rlast = NewString(cc + 2);
    return;
  } else {
    *rprefix = 0;
    *rlast = Copy(s);
  }
}

/* -----------------------------------------------------------------------------
 * Swig_scopename_prefix()
 *
 * Take a qualified name like "A::B::C" and return the scope name.
 * In this case, "A::B".   Returns NULL if there is no base.
 * ----------------------------------------------------------------------------- */

String *Swig_scopename_prefix(const String *s) {
  char *tmp = Char(s);
  char *c = tmp;
  char *cc = c;
  char *co = 0;
  if (!strstr(c, "::"))
    return 0;
  co = strstr(cc, "operator ");

  if (co) {
    if (co == cc) {
      return 0;
    } else {
      String *prefix = NewStringWithSize(cc, (int)(co - cc - 2));
      return prefix;
    }
  }
  while (*c) {
    if ((*c == ':') && (*(c + 1) == ':')) {
      cc = c;
      c += 2;
    } else {
      if (*c == '<') {
	int level = 1;
	c++;
	while (*c && level) {
	  if (*c == '<')
	    level++;
	  if (*c == '>')
	    level--;
	  c++;
	}
      } else {
	c++;
      }
    }
  }

  if (cc != tmp) {
    return NewStringWithSize(tmp, (int)(cc - tmp));
  } else {
    return 0;
  }
}

/* -----------------------------------------------------------------------------
 * Swig_scopename_last()
 *
 * Take a qualified name like "A::B::C" and returns the last.  In this
 * case, "C". 
 * ----------------------------------------------------------------------------- */

String *Swig_scopename_last(const String *s) {
  char *tmp = Char(s);
  char *c = tmp;
  char *cc = c;
  char *co = 0;
  if (!strstr(c, "::"))
    return NewString(s);

  co = strstr(cc, "operator ");
  if (co) {
    return NewString(co);
  }


  while (*c) {
    if ((*c == ':') && (*(c + 1) == ':')) {
      c += 2;
      cc = c;
    } else {
      if (*c == '<') {
	int level = 1;
	c++;
	while (*c && level) {
	  if (*c == '<')
	    level++;
	  if (*c == '>')
	    level--;
	  c++;
	}
      } else {
	c++;
      }
    }
  }
  return NewString(cc);
}

/* -----------------------------------------------------------------------------
 * Swig_scopename_first()
 *
 * Take a qualified name like "A::B::C" and returns the first scope name.
 * In this case, "A".   Returns NULL if there is no base.
 * ----------------------------------------------------------------------------- */

String *Swig_scopename_first(const String *s) {
  char *tmp = Char(s);
  char *c = tmp;
  char *co = 0;
  if (!strstr(c, "::"))
    return 0;

  co = strstr(c, "operator ");
  if (co) {
    if (co == c) {
      return 0;
    }
  } else {
    co = c + Len(s);
  }

  while (*c && (c != co)) {
    if ((*c == ':') && (*(c + 1) == ':')) {
      break;
    } else {
      if (*c == '<') {
	int level = 1;
	c++;
	while (*c && level) {
	  if (*c == '<')
	    level++;
	  if (*c == '>')
	    level--;
	  c++;
	}
      } else {
	c++;
      }
    }
  }
  if (*c && (c != tmp)) {
    return NewStringWithSize(tmp, (int)(c - tmp));
  } else {
    return 0;
  }
}


/* -----------------------------------------------------------------------------
 * Swig_scopename_suffix()
 *
 * Take a qualified name like "A::B::C" and returns the suffix.
 * In this case, "B::C".   Returns NULL if there is no suffix.
 * ----------------------------------------------------------------------------- */

String *Swig_scopename_suffix(const String *s) {
  char *tmp = Char(s);
  char *c = tmp;
  char *co = 0;
  if (!strstr(c, "::"))
    return 0;

  co = strstr(c, "operator ");
  if (co) {
    if (co == c)
      return 0;
  }
  while (*c) {
    if ((*c == ':') && (*(c + 1) == ':')) {
      break;
    } else {
      if (*c == '<') {
	int level = 1;
	c++;
	while (*c && level) {
	  if (*c == '<')
	    level++;
	  if (*c == '>')
	    level--;
	  c++;
	}
      } else {
	c++;
      }
    }
  }
  if (*c && (c != tmp)) {
    return NewString(c + 2);
  } else {
    return 0;
  }
}

/* -----------------------------------------------------------------------------
 * Swig_scopename_tolist()
 *
 * Take a qualified scope name like "A::B::C" and convert it to a list.
 * In this case, return a list of 3 elements "A", "B", "C".
 * Returns an empty list if the input is empty.
 * ----------------------------------------------------------------------------- */

List *Swig_scopename_tolist(const String *s) {
  List *scopes = NewList();
  String *name = Len(s) == 0 ? 0 : NewString(s);

  while (name) {
    String *last = 0;
    String *prefix = 0;
    Swig_scopename_split(name, &prefix, &last);
    Insert(scopes, 0, last);
    Delete(last);
    Delete(name);
    name = prefix;
  }
  Delete(name);
  return scopes;
}

/* -----------------------------------------------------------------------------
 * Swig_scopename_check()
 *
 * Checks to see if a name is qualified with a scope name, examples:
 *   foo            -> 0
 *   ::foo          -> 1
 *   foo::bar       -> 1
 *   foo< ::bar >   -> 0
 * ----------------------------------------------------------------------------- */

int Swig_scopename_check(const String *s) {
  char *c = Char(s);
  char *co = strstr(c, "operator ");

  if (co) {
    if (co == c)
      return 0;
  }
  if (!strstr(c, "::"))
    return 0;
  while (*c) {
    if ((*c == ':') && (*(c + 1) == ':')) {
      return 1;
    } else {
      if (*c == '<') {
	int level = 1;
	c++;
	while (*c && level) {
	  if (*c == '<')
	    level++;
	  if (*c == '>')
	    level--;
	  c++;
	}
      } else {
	c++;
      }
    }
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * Swig_string_command()
 *
 * Feature removed in SWIG 4.1.0.
 * ----------------------------------------------------------------------------- */

String *Swig_string_command(String *s) {
  Swig_error("SWIG", Getline(s), "Command encoder no longer supported - use regex encoder instead.\n");
  Exit(EXIT_FAILURE);
  return 0;
}

/* -----------------------------------------------------------------------------
 * Swig_string_strip()
 *
 * Strip given prefix from identifiers 
 *
 *  Printf(stderr,"%(strip:[wx])s","wxHello") -> Hello
 * ----------------------------------------------------------------------------- */

String *Swig_string_strip(String *s) {
  String *ns;
  if (!Len(s)) {
    ns = NewString(s);
  } else {
    const char *cs = Char(s);
    const char *ce = Strchr(cs, ']');
    if (*cs != '[' || !ce) {
      ns = NewString(s);
    } else {
      String *fmt = NewStringf("%%.%ds", ce-cs-1);
      String *prefix = NewStringf(fmt, cs+1);
      if (0 == Strncmp(ce+1, prefix, Len(prefix))) {
        ns = NewString(ce+1+Len(prefix));
      } else {
        ns = NewString(ce+1);
      }
    }
  }
  return ns;
}

/* -----------------------------------------------------------------------------
 * Swig_string_rstrip()
 *
 * Strip given suffix from identifiers 
 *
 *  Printf(stderr,"%(rstrip:[Cls])s","HelloCls") -> Hello
 * ----------------------------------------------------------------------------- */

String *Swig_string_rstrip(String *s) {
  String *ns;
  int len = Len(s);
  if (!len) {
    ns = NewString(s);
  } else {
    const char *cs = Char(s);
    const char *ce = Strchr(cs, ']');
    if (*cs != '[' || !ce) {
      ns = NewString(s);
    } else {
      String *fmt = NewStringf("%%.%ds", ce-cs-1);
      String *suffix = NewStringf(fmt, cs+1);
      int suffix_len = Len(suffix);
      if (0 == Strncmp(cs+len-suffix_len, suffix, suffix_len)) {
	int copy_len = len-suffix_len-(int)(ce+1-cs);
        ns = NewStringWithSize(ce+1, copy_len);
      } else {
        ns = NewString(ce+1);
      }
    }
  }
  return ns;
}

/* -----------------------------------------------------------------------------
 * Swig_offset_string()
 *
 * Insert number tabs before each new line in s
 * ----------------------------------------------------------------------------- */

void Swig_offset_string(String *s, int number) {
  char *res, *p, *end, *start;
  /* count a number of lines in s */
  int lines = 1;
  int len = Len(s);
  if (len == 0)
    return;
  start = strchr(Char(s), '\n');
  while (start) {
    ++lines;
    start = strchr(start + 1, '\n');
  }
  /* do not count pending new line */
  if ((Char(s))[len-1] == '\n')
    --lines;
  /* allocate a temporary storage for a padded string */
  res = (char*)Malloc(len + lines * number * 2 + 1);
  res[len + lines * number * 2] = 0;

  /* copy lines to res, prepending tabs to each line */
  p = res; /* output pointer */
  start = Char(s); /* start of a current line */
  end = strchr(start, '\n'); /* end of a current line */
  while (end) {
    memset(p, ' ', number*2);
    p += number*2;
    memcpy(p, start, end - start + 1);
    p += end - start + 1;
    start = end + 1;
    end = strchr(start, '\n');
  }
  /* process the last line */
  if (*start) {
    memset(p, ' ', number*2);
    p += number*2;
    strcpy(p, start);
  }
  /* replace 's' contents with 'res' */
  Clear(s);
  Append(s, res);
  Free(res);
}


#ifdef HAVE_PCRE
#define PCRE2_CODE_UNIT_WIDTH 8
#include <pcre2.h>

static int split_regex_pattern_subst(String *s, String **pattern, String **subst, const char **input)
{
  const char *pats, *pate;
  const char *subs, *sube;

  /* Locate the search pattern */
  const char *p = Char(s);
  if (*p++ != '/') goto err_out;
  pats = p;
  p = strchr(p, '/');
  if (!p) goto err_out;
  pate = p;

  /* Locate the substitution string */
  subs = ++p;
  p = strchr(p, '/');
  if (!p) goto err_out;
  sube = p;

  *pattern = NewStringWithSize(pats, (int)(pate - pats));
  *subst   = NewStringWithSize(subs, (int)(sube - subs));
  *input   = p + 1;
  return 1;

err_out:
  Swig_error("SWIG", Getline(s), "Invalid regex substitution: '%s'.\n", s);
  Exit(EXIT_FAILURE);
  return 0;
}

/* This function copies len characters from src to dst, possibly applying case conversions to them: if convertCase is 1, to upper case and if it is -1, to lower
 * case. If convertNextOnly is 1, only a single character is converted (and convertCase is reset), otherwise all of them are. */
static void copy_with_maybe_case_conversion(String *dst, const char *src, int len, int *convertCase, int convertNextOnly)
{
  /* Deal with the trivial cases first. */
  if (!len)
    return;

  if (!*convertCase) {
      Write(dst, src, len);
      return;
  }

  /* If we must convert only the first character, do it and write the rest at once. */
  if (convertNextOnly) {
    int src_char = *src;
    Putc(*convertCase == 1 ? toupper(src_char) : tolower(src_char), dst);
    *convertCase = 0;
    if (len > 1) {
      Write(dst, src + 1, len - 1);
    }
  } else {
    /* We need to convert all characters. */
    int i;
    for (i = 0; i < len; i++, src++) {
      int src_char = *src;
      Putc(*convertCase == 1 ? toupper(src_char) : tolower(src_char), dst);
    }
  }
}

String *replace_captures(int num_captures, const char *input, String *subst, size_t captures[], String *pattern, String *s)
{
  int convertCase = 0, convertNextOnly = 0;
  String *result = NewStringEmpty();
  const char *p = Char(subst);

  while (*p) {
    /* Copy part without substitutions */
    const char *q = strchr(p, '\\');
    if (!q) {
      copy_with_maybe_case_conversion(result, p, (int)strlen(p), &convertCase, convertNextOnly);
      break;
    }
    copy_with_maybe_case_conversion(result, p, (int)(q - p), &convertCase, convertNextOnly);
    p = q + 1;

    /* Handle substitution */
    if (*p == '\0') {
      Putc('\\', result);
    } else if (isdigit((unsigned char)*p)) {
      int group = *p++ - '0';
      if (group < num_captures) {
	int l = (int)captures[group*2], r = (int)captures[group*2 + 1];
	if (l != -1) {
	  copy_with_maybe_case_conversion(result, input + l, r - l, &convertCase, convertNextOnly);
	}
      } else {
	Swig_error("SWIG", Getline(s), "PCRE capture replacement failed while matching \"%s\" using \"%s\" - request for group %d is greater than the number of captures %d.\n",
	    Char(pattern), input, group, num_captures-1);
      }
    } else {
	/* Handle Perl-like case conversion escapes. */
	switch (*p) {
	case 'u':
	  convertCase = 1;
	  convertNextOnly = 1;
	  break;
	case 'U':
	  convertCase = 1;
	  convertNextOnly = 0;
	  break;
	case 'l':
	  convertCase = -1;
	  convertNextOnly = 1;
	  break;
	case 'L':
	  convertCase = -1;
	  convertNextOnly = 0;
	  break;
	case 'E':
	  convertCase = 0;
	  break;
	default:
	  Swig_error("SWIG", Getline(s), "Unrecognized escape character '%c' in the replacement string \"%s\".\n",
	      *p, Char(subst));
	}
	p++;
    }
  }

  return result;
}

/* -----------------------------------------------------------------------------
 * Swig_string_regex()
 *
 * Executes a regular expression substitution. For example:
 *
 *   Printf(stderr,"gsl%(regex:/GSL_(.*)_/\\1/)s", "GSL_Hello_") -> gslHello
 * ----------------------------------------------------------------------------- */
String *Swig_string_regex(String *s) {
  const int pcre_options = 0;

  String *res = 0;
  pcre2_code *compiled_pat = 0;
  const char *input;
  PCRE2_UCHAR pcre_error[256];
  int pcre_errornum;
  size_t pcre_errorpos;
  String *pattern = 0, *subst = 0;
  size_t *captures = 0;
  pcre2_match_data *match_data = 0;
  if (split_regex_pattern_subst(s, &pattern, &subst, &input)) {
    int rc;

    compiled_pat = pcre2_compile(
          (PCRE2_SPTR8)Char(pattern), PCRE2_ZERO_TERMINATED, pcre_options, &pcre_errornum, &pcre_errorpos, NULL);
    if (!compiled_pat) {
      pcre2_get_error_message (pcre_errornum, pcre_error, sizeof pcre_error);
      Swig_error("SWIG", Getline(s), "PCRE compilation failed: '%s' in '%s':%i.\n",
          pcre_error, Char(pattern), pcre_errorpos);
      Exit(EXIT_FAILURE);
    }
    match_data = pcre2_match_data_create_from_pattern (compiled_pat, NULL);
    rc = pcre2_match(compiled_pat, (PCRE2_SPTR8)input, PCRE2_ZERO_TERMINATED, 0, 0, match_data, NULL);
    captures = pcre2_get_ovector_pointer (match_data);
    if (rc >= 0) {
      res = replace_captures(rc, input, subst, captures, pattern, s);
    } else if (rc != PCRE2_ERROR_NOMATCH) {
      Swig_error("SWIG", Getline(s), "PCRE execution failed: error %d while matching \"%s\" using \"%s\".\n",
	rc, Char(pattern), input);
      Exit(EXIT_FAILURE);
    }
  }

  DohDelete(pattern);
  DohDelete(subst);
  pcre2_code_free(compiled_pat);
  pcre2_match_data_free(match_data);
  return res ? res : NewStringEmpty();
}

String *Swig_pcre_version(void) {
  int len = pcre2_config(PCRE2_CONFIG_VERSION, NULL);
  char *buf = Malloc(len);
  String *result;
  pcre2_config(PCRE2_CONFIG_VERSION, buf);
  result = NewStringf("PCRE2 Version: %s", buf);
  Free(buf);
  return result;
}

#else

String *Swig_string_regex(String *s) {
  Swig_error("SWIG", Getline(s), "PCRE regex support not enabled in this SWIG build.\n");
  Exit(EXIT_FAILURE);
  return 0;
}

String *Swig_pcre_version(void) {
  return NewStringf("PCRE not used");
}

#endif

/* ------------------------------------------------------------
 * Swig_is_generated_overload()
 * Check if the function is an automatically generated
 * overload created because a method has default parameters. 
 * ------------------------------------------------------------ */
int Swig_is_generated_overload(Node *n) {
  Node *base_method = Getattr(n, "sym:overloaded");
  Node *default_args = Getattr(n, "defaultargs");
  return ((base_method != NULL) && (default_args != NULL) && (base_method == default_args));
}

/* -----------------------------------------------------------------------------
 * Swig_init()
 *
 * Initialize the SWIG core
 * ----------------------------------------------------------------------------- */

void Swig_init(void) {
  /* Set some useful string encoding methods */
  DohEncoding("escape", Swig_string_escape);
  DohEncoding("hexescape", Swig_string_hexescape);
  DohEncoding("upper", Swig_string_upper);
  DohEncoding("lower", Swig_string_lower);
  DohEncoding("title", Swig_string_title);
  DohEncoding("ctitle", Swig_string_ccase);
  DohEncoding("lctitle", Swig_string_lccase);
  DohEncoding("utitle", Swig_string_ucase);
  DohEncoding("typecode", Swig_string_typecode);
  DohEncoding("mangle", string_mangle);
  DohEncoding("command", Swig_string_command);
  DohEncoding("schemify", Swig_string_schemify);
  DohEncoding("strip", Swig_string_strip);
  DohEncoding("rstrip", Swig_string_rstrip);
  DohEncoding("regex", Swig_string_regex);

  /* aliases for the case encoders */
  DohEncoding("uppercase", Swig_string_upper);
  DohEncoding("lowercase", Swig_string_lower);
  DohEncoding("camelcase", Swig_string_ccase);
  DohEncoding("lowercamelcase", Swig_string_lccase);
  DohEncoding("undercase", Swig_string_ucase);
  DohEncoding("firstuppercase", Swig_string_first_upper);
  DohEncoding("firstlowercase", Swig_string_first_lower);

  /* Initialize typemaps */
  Swig_typemap_init();

  /* Initialize symbol table */
  Swig_symbol_init();

  /* Initialize type system */
  SwigType_typesystem_init();

  /* Initialize template system */
  SwigType_template_init();
}
