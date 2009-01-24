/* ----------------------------------------------------------------------------- 
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * swigwrap.h
 *
 * Functions related to wrapper objects.
 * ----------------------------------------------------------------------------- */

/* $Id: swig.h 9635 2007-01-12 01:44:16Z beazley $ */

typedef struct Wrapper {
    Hash *localh;
    String *def;
    String *locals;
    String *code;
} Wrapper;

extern Wrapper *NewWrapper(void);
extern void     DelWrapper(Wrapper *w);
extern void     Wrapper_compact_print_mode_set(int flag);
extern void     Wrapper_pretty_print(String *str, File *f);
extern void     Wrapper_compact_print(String *str, File *f);
extern void     Wrapper_print(Wrapper *w, File *f);
extern int      Wrapper_add_local(Wrapper *w, const_String_or_char_ptr name, const_String_or_char_ptr decl);
extern int      Wrapper_add_localv(Wrapper *w, const_String_or_char_ptr name, ...);
extern int      Wrapper_check_local(Wrapper *w, const_String_or_char_ptr name);
extern char    *Wrapper_new_local(Wrapper *w, const_String_or_char_ptr name, const_String_or_char_ptr decl);
extern char    *Wrapper_new_localv(Wrapper *w, const_String_or_char_ptr name, ...);
