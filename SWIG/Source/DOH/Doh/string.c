/****************************************************************************
 * DOH (Dynamic Object Hack)
 * 
 * Author : David Beazley
 *
 * Department of Computer Science        
 * University of Chicago
 * 1100 E 58th Street
 * Chicago, IL  60637
 * beazley@cs.uchicago.edu
 *
 * Please read the file LICENSE for the copyright and terms by which SWIG
 * can be used and distributed.
 ****************************************************************************/

#include "doh.h"

/* ---------------------------------------------------------------------------
 * $Header$
 * string.c
 *
 * String support.
 * --------------------------------------------------------------------------- */

typedef struct String {
    DOHCOMMON;
    int            maxsize;                   /* Max size allocated */
    int            len;                       /* Current length     */
    int            hashkey;                   /* Hash key value     */
    int            sp;                        /* Current position   */
    int            lsp;                       /* Last returned position */
    char          *str;                       /* String data        */
} String;

/* Forward references */

void    DelString(DOH *s);
DOH    *CopyString(DOH *s);
void    String_clear(DOH *s);
DOH    *String_str(DOH *s);
int     String_delitem(DOH *s, int where);
int     String_len(DOH *s);
void    String_appendfv(DOH *s, char *fmt, va_list ap);
int     String_insertfv(DOH *s, int pos, char *fmt, va_list ap);
int     String_insert(DOH *s, int pos, DOH *DOH);
void   *String_data(DOH *s);
int     String_cmp(DOH *, DOH *);
int     String_hash(DOH *s);
int     String_read(DOH *s, void *buffer, int length);
int     String_write(DOH *s, void *buffer, int length);
int     String_seek(DOH *s, long offset, int whence);
long    String_tell(DOH *s);
int     String_printf(DOH *s, char *fmt, va_list ap);

static DohSequenceMethods StringSeqMethods = {
  0,
  0,
  String_delitem,
  String_insert,
  String_insertfv,
  0,
  0,
};

static DohFileMethods StringFileMethods = {
  String_read,
  String_write,
  String_seek,
  String_tell,
  String_printf,
};

static DohObjInfo StringType = {
    "String",          /* objname */
    0,
    DelString,         /* sm_del */
    CopyString,        /* sm_copy */
    String_clear,      /* sm_clear */
    String_str,        /* sm_str */
    String_data,       /* doh_data */
    String_len,        /* sm_len */
    String_hash,       /* sm_hash    */
    String_cmp,        /* doh_cmp */
    0,                 /* doh_mapping */
    &StringSeqMethods, /* doh_sequence */
    &StringFileMethods,/* doh_file */
    0,
    0,
    0,
    0,
};

#define INIT_MAXSIZE  16

DohObjInfo *String_type() {
  return &StringType;
}

/* -----------------------------------------------------------------------------
 * void *String_data(DOH *so) - Return as a 'void *'
 * ----------------------------------------------------------------------------- */
void *String_data(DOH *so) {
    return (void *) ((String *) so)->str;
}

/* -----------------------------------------------------------------------------
 * NewString(const char *c) - Create a new string
 * ----------------------------------------------------------------------------- */
DOH *
NewString(char *s)
{
    int l, max;
    String *str;
    str = (String *) malloc(sizeof(String));
    DohInit(str);
    str->objinfo = &StringType;
    str->hashkey = -1;
    str->sp = 0;
    str->lsp = 0;
    str->line = 1;
    max = INIT_MAXSIZE;
    if (s) {
      l = (int) strlen(s);
      if ((l+1) > max) max = l+1;
    }
    str->str = (char *) malloc(max);
    str->maxsize = max;
    if (s) {
	strcpy(str->str,s);
	str->len = l;
    } else {
	str->str[0] = 0;
	str->len = 0;
    }
    return (DOH *) str;
}

/* -----------------------------------------------------------------------------
 * CopyString(DOH *s) - Copy a string
 * ----------------------------------------------------------------------------- */
DOH *
CopyString(DOH *so) {
  String *s;
  int l, max;
  String *str;
  s = (String *) so;
  str = (String *) malloc(sizeof(String));
  DohInit(str);
  str->objinfo = &StringType;
  str->hashkey = -1;
  str->sp = 0;
  str->lsp = 0;
  str->line = 1;
  max = s->maxsize;
  str->str = (char *) malloc(max);
  memmove(str->str, s->str, max);
  str->maxsize= max;
  return (DOH *) str;
}
  
/* -----------------------------------------------------------------------------
 * DelString(DOH *s) - Delete a string
 * ----------------------------------------------------------------------------- */
void
DelString(DOH *so) {
  String *s;
  s = (String *) so;
  assert(s->refcount <= 0);
  free(s->str);
  free(s);
}

/* -----------------------------------------------------------------------------
 * int String_check(DOH *s) - Check if s is a string
 * ----------------------------------------------------------------------------- */
int
String_check(DOH *s) 
{
  char *c = (char *) s;
  if (!s) return 0;
  if (*c == DOH_MAGIC) {
    if (((String *) c)->objinfo == &StringType)
      return 1;
    return 0;
  }
  else return 0;
}

/* -----------------------------------------------------------------------------
 * int String_len(DOH *s) - Length of a string
 * ----------------------------------------------------------------------------- */

int 
String_len(DOH *so) {
  String *s = (String *)so;
  return s->len;
}


/* -----------------------------------------------------------------------------
 * int String_cmp(DOH *s1, DOH *s2) - Compare two strings
 * ----------------------------------------------------------------------------- */

int
String_cmp(DOH *so1, DOH *so2)
{
    String *s1, *s2;
    s1 = (String *) so1;
    s2 = (String *) so2;
    return strcmp(s1->str,s2->str);
}

/* -----------------------------------------------------------------------------
 * int String_hash(DOH *s) - Compute string hash value
 * ----------------------------------------------------------------------------- */

int String_hash(DOH *so) {
  String *s = (String *) so;
  char *c;
  int   i, h = 0, len;
  if (s->hashkey >= 0) return s->hashkey;
  c = s->str;
  len = s->len > 50 ? 50 : s->len;
  for (i = 0; i < len; i++) {
    h = (((h << 5) + *(c++))); 
  }
  h = h & 0x7fffffff;
  s->hashkey = h;
  return h;
}  

/* -----------------------------------------------------------------------------
 * static add(String *s, const char *newstr) - Append to s
 * ----------------------------------------------------------------------------- */

static void
add(String *s, const char *newstr) {
  int   newlen, newmaxsize, l;
  if (!newstr) return;
  s->hashkey = -1;
  l = (int) strlen(newstr);
  newlen = s->len+l + 1;
  if (newlen >= s->maxsize-1) {
    newmaxsize = 2*s->maxsize;
    if (newlen >= newmaxsize -1) newmaxsize = newlen + 1;
    assert(s->str = (char *) realloc(s->str,newmaxsize));
    s->maxsize = newmaxsize;
  }
  strcpy(s->str+s->len,newstr);
  s->len += l;
}  

static void
addstr(String *s, String *s1) {
  int   newlen, newmaxsize, l;
  s->hashkey = -1;
  l = s1->len;
  newlen = s->len+l + 1;
  if (newlen >= s->maxsize-1) {
    newmaxsize = 2*s->maxsize;
    if (newlen >= newmaxsize -1) newmaxsize = newlen + 1;
    assert(s->str = (char *) realloc(s->str,newmaxsize));
    s->maxsize = newmaxsize;
  }
  memmove(s->str+s->len,s1->str,s1->len);
  s->len += l;
}  


/* Add a single character to s */

void
String_addchar(DOH *so, char c) {
  String *s = (String *) so;
  s->hashkey = -1;
  if ((s->len+1) > (s->maxsize-1)) {
    assert(s->str = (char *) realloc(s->str,2*s->maxsize));
    s->maxsize *= 2;
  }
  s->str[s->len++] = c;
  s->str[s->len] = 0;
}

/* -----------------------------------------------------------------------------
 * void String_clear(DOH *s) - Clear a string
 * ----------------------------------------------------------------------------- */

void
String_clear(DOH *so)
{
  String *s;
  s = (String *) so;
  s->hashkey = -1;
  s->len = 0;
  s->str[0] = 0;
  s->sp = 0;
  s->lsp = 0;
  s->line = 1;
}

/* -----------------------------------------------------------------------------
 * void String_appendfv(DOH *so, char *format, ...) - Append to string
 * -----------------------------------------------------------------------------*/

void
String_appendfv(DOH *so, char *format, va_list ap)
{
  char        *p, *sval;
  String      *Sval;
  DohBase     *b;
  int         ival;
  double      dval;
  char        cval;
  char        temp[64];
  String      *s; 
  
  s = (String *) so;
  
  assert(s->refcount <= 1);
  
  for (p = format; *p; p++) {
    if (*p != '%') {
      String_addchar(s,*p);
      continue;
    }
    switch(*++p) {
    case 'c':
      cval = va_arg(ap,char);
      String_addchar(s,cval);
      break;
    case 'd':
      ival = va_arg(ap,int);
      sprintf(temp,"%d",ival);
      add(s,temp);
      break;
    case 'x':
      ival = va_arg(ap,int);
      sprintf(temp,"%x", ival);
      add(s,temp);
      break;
    case 'f':
      dval = va_arg(ap,double);
      sprintf(temp,"%f",dval);
      add(s,temp);
      break;
    case 's':
      Sval = va_arg(ap, String *);
      if (String_check(Sval)) {
	addstr(s,Sval);
      } else {
	add(s,(char *) Sval);
      }
      break;
    case 'o':
      b = va_arg(ap, DohBase *);
      Sval = Str(b);
      addstr(s, Sval);
      Delete(Sval);
      break;
      
      /* Automatically deletes whatever object was passed */
    case 'O':
      b = va_arg(ap, DohBase *);
      Sval = Str(b);
      addstr(s, Sval);
      Delete(Sval);
      Delete(b);
      break;
    default:
      String_addchar(s,*p);
      break;
    }
  }
}

void
raw_insert(String *s, int pos, char *data, int len)
{
    char *nstr;
    nstr = s->str;
    s->hashkey = -1;
    if (pos == DOH_END) {
	add(s, data);
	return;
    }
    if (pos < 0) pos = 0;
    else if (pos > s->len) pos = s->len;

    /* See if there is room to insert the new data */

    while (s->maxsize <= s->len+len) {
	assert(s->str = (char *) realloc(s->str,2*s->maxsize));
	s->maxsize *= 2;
    }
    memmove(s->str+pos+len, s->str+pos, (s->len - pos));
    memcpy(s->str+pos,data,len);
    s->len += len; 
    s->str[s->len] = 0;
}  

/* -----------------------------------------------------------------------------
 * void String_insert(DOH *so, int pos, SO *str) - Insert a string
 * ----------------------------------------------------------------------------- */
int
String_insert(DOH *so, int pos, DOH *str)
{
    String *s, *s1;
    char   *c;
    int     len;
    s = (String *) so;
    assert(s->refcount <= 1);
    s1 = (String *) str;
    len = s1->len;
    c = s1->str;
    raw_insert(s,pos,c,len);
    return 0;
}

/* -----------------------------------------------------------------------------
 * void String_insertf(DOH *so, char *format, ...) - Insert a string
 * -----------------------------------------------------------------------------*/

int
String_insertfv(DOH *so, int pos, char *format, va_list ap)
{
    String      *s; 
    String      *temp;
    s = (String *) so;
    if (pos == DOH_END) {
      String_appendfv(so,format,ap);
      return 0;
    }
    temp = NewString("");
    String_appendfv(temp,format,ap);
    raw_insert(s,pos, temp->str,temp->len);
    Delete(temp);
    return 0;
}

/* -----------------------------------------------------------------------------
 * int String_delitem(DOH *so, int pos)
 * 
 * Delete an individual item
 * ----------------------------------------------------------------------------- */

int String_delitem(DOH *so, int pos)
{
  String *s = (String *) so;
  if (pos == DOH_END) pos = s->len-1;
  if (pos == DOH_BEGIN) pos = 0;

  if (s->len == 0) return;
  
  memmove(s->str+pos, s->str+pos+1, ((s->len-1) - pos));
  s->len--;
  s->str[s->len] = 0;
  return 0;
}
  
/* -----------------------------------------------------------------------------
 * DOH *String_str(DOH *so) - Returns a string (used by printing commands)
 * ----------------------------------------------------------------------------- */

DOH *
String_str(DOH *so) {
    DOH *nstr;
    String *s = (String *) so;
    nstr = NewString(s->str);
    return nstr;
}

/* -----------------------------------------------------------------------------
 * int String_read(DOH *so, void *buffer, int len)
 * 
 * Read data from the string
 * ----------------------------------------------------------------------------- */
int
String_read(DOH *so, void *buffer, int len) {
  int    reallen;
  String *s = (String *) so;
  if ((s->sp + len) > s->len) reallen = (s->len - s->sp);
  memmove(buffer, s->str+s->sp, reallen);
  s->sp += reallen;
  return reallen;
}

/* -----------------------------------------------------------------------------
 * int String_write(DOH *so, void *buffer, int len)
 * 
 * Write data to the string
 * ----------------------------------------------------------------------------- */
int
String_write(DOH *so, void *buffer, int len) {
  int    reallen, newlen, newmaxsize;
  String *s = (String *) so;
  newlen = s->sp + len + 1;
  if (newlen > s->maxsize) {
    assert(s->str = (char *) realloc(s->str,newlen));
    s->maxsize = newlen;
    s->len = s->sp + len;
  }
  memmove(s->str+s->sp,buffer,len);
  s->sp += len;
  return len;
}

/* -----------------------------------------------------------------------------
 * int String_seek(DOH *so, long offset, int whence)
 * 
 * Seek to a new position
 * ----------------------------------------------------------------------------- */
int
String_seek(DOH *so, long offset, int whence) {
  int    pos;
  String *s = (String *) so;
  if (whence == SEEK_SET) pos = 0;
  if (whence == SEEK_CUR) pos = s->sp;
  if (whence == SEEK_END) {
    pos = s->len;
    offset = -offset;
  }
  s->sp = pos + offset;
  if (s->sp < 0) s->sp = 0;
  if (s->sp > s->len) s->sp = s->len;
  return 0;
}

/* -----------------------------------------------------------------------------
 * long String_seek(DOH *so)
 * 
 * Return current position
 * ----------------------------------------------------------------------------- */
long
String_tell(DOH *so) {
  String *s = (String *) so;
  return (long) s->sp;
}

/* -----------------------------------------------------------------------------
 * int String_printf(DOH *so, char *format, ...)
 *
 * ----------------------------------------------------------------------------- */

int
String_printf(DOH *so, char *format, va_list ap) 
{
  int len;
  DOH    *nso;
  String *s = (String *) so;
  nso = NewString("");
  String_appendfv(nso,format,ap);
  len = ((String *) nso)->len;
  String_write(so,Data(nso),len);
  Delete(nso);
  return len;
}

/* -----------------------------------------------------------------------------
 * static void replace_internal(String *str, char *token, char *rep, int flags, char *start, int count)
 *
 * Replaces token with rep.  flags is as follows:
 *
 *         REPLACE_ANY           -   Replace all occurrences
 *         REPLACE_NOQUOTE       -   Don't replace in quotes
 *         REPLACE_ID            -   Only replace valid identifiers
 *         REPLACE_FIRST         -   Only replace first occurrence
 * 
 * start is a starting position. count is a count.
 * ----------------------------------------------------------------------------- */

void replace_internal(String *str, char *token, char *rep, int flags, char *start, int count)
{
    char *s, *c, *t;
    int  tokenlen;
    int  state;

    /* Copy the current string representation */

    s = str->str;
    str->hashkey = -1;

    tokenlen = strlen(token);

    /* If a starting position was given, dump those characters first */
  
    if (start) {
	c = start;
    } else {
	c = s;
    }

    /* Now walk down the old string and search for tokens */
    t = strstr(c,token);
    if (t) {
	str->len = 0;
	str->str = (char *) malloc(str->maxsize);
	if (start) {
	    char temp = *start;
	    *start = 0;
	    add(str,s);
	    *start = temp;
	}

	/* Depending on flags.  We compare in different ways */
	state = 0;
	t = c;
	while ((*c) && (count)) {
	    switch(state) {
	    case 0:
		if (*c == *token) {
		    if (!(flags & DOH_REPLACE_ID)) {
			if (strncmp(c,token,tokenlen) == 0) {
			    char temp = *c;
			    *c = 0;
			    add(str,t);
			    *c = temp;
			    add(str,rep);
			    c += (tokenlen-1);
			    t = c+1;
			    count--;
			}
		    } else if (isalpha(*c) || (*c == '_') || (*c == '$')) {
			char temp = *c;
			*c = 0;
			add(str,t);
			*c = temp;
			t = c;
			state = 10;
		    } 
		} else if (flags & DOH_REPLACE_NOQUOTE) {
		    if (*c == '\"') state = 20;
		    else if (*c == '\'') state = 30;
		}
		break;
	    case 10:  /* The start of an identifier */
		if (isalnum(*c) || (*c == '_') || (*c == '$')) state = 10;
		else {
		    char temp = *c;
		    *c = 0;
		    if (strcmp(token,t) == 0) {
			add(str,rep);
			count--;
		    } else {
			add(str,t);
		    }
		    *c = temp;
		    t = c;
		    state = 0;
		}
		break;
	    case 20: /* A string */
		if (*c == '\"') state = 0;
		else if (*c == '\\') c++;
		break;
	    case 30: /* A Single quoted string */
		if (*c == '\'') state = 0;
		else if (*c == '\\') c++;
		break;
	    }
	    c++;
	}
	if ((count) && (state == 10)) {
	    if (strcmp(token,t) == 0) {
		add(str,rep);
	    } else {
		add(str,t);
	    }
	} else {
	    add(str,t);
	}
	free(s);
    }
}

/* -----------------------------------------------------------------------------
 * void String_replace(DOH *str, DOH *token, DOH *rep, int flags)
 * ----------------------------------------------------------------------------- */

void 
String_replace(DOH *stro, DOH *token, DOH *rep, int flags)
{
    int count = -1;
    String *str;
    if (!String_check(stro)) return;
    str = (String *) stro;
    assert(!str->refcount);
    if (flags & DOH_REPLACE_FIRST) count = 1;
    replace_internal(str,Char(token),Char(rep),flags,str->str,count);
}

    






