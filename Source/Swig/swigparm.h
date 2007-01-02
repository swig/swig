/* ----------------------------------------------------------------------------- 
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * swigparm.h
 *
 * Functions related to the handling of function/method parameters and
 * parameter lists.  
 * ----------------------------------------------------------------------------- */

/* $Id: swig.h 9629 2006-12-30 18:27:47Z beazley $ */

/* Individual parameters */
extern Parm      *NewParm(SwigType *type, const String_or_char *name);
extern Parm      *NewParmFromNode(SwigType *type, const String_or_char *name, Node *n);
extern Parm      *CopyParm(Parm *p);

/* Parameter lists */
extern ParmList  *CopyParmList(ParmList *);
extern ParmList  *CopyParmListMax(ParmList *, int count);
extern int        ParmList_len(ParmList *);
extern int        ParmList_numarg(ParmList *);
extern int        ParmList_numrequired(ParmList *);
extern String    *ParmList_str(ParmList *);
extern String    *ParmList_str_defaultargs(ParmList *);
extern String    *ParmList_protostr(ParmList *);
extern int        ParmList_is_compactdefargs(ParmList *p);
extern int        ParmList_has_defaultargs(ParmList *p);
extern ParmList  *ParmList_copy_all_except_last_parm(ParmList *p);
