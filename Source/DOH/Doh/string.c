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
int     String_scanfv(DOH *s, char *fmt, va_list ap);
    
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
  String_scanfv,
  0,
};

static DohObjInfo StringType = {
    "String",          /* objname */
    sizeof(String),    /* objsize */
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
    str = (String *) DohMalloc(sizeof(String));
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
  str = (String *) DohMalloc(sizeof(String));
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
  str->len = s->len;
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
  DohFree(s);
}

/* -----------------------------------------------------------------------------
 * int String_check(DOH *s) - Check if s is a string
 * ----------------------------------------------------------------------------- */
int
String_check(DOH *s) 
{
  char *c = (char *) s;
  if (!s) return 0;
  if (DohCheck(s)) {
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

/* Expand a string to accomodate a write */
void
String_expand(String *s, int width) {
  if ((s->len + width) > (s->maxsize-1)) {
    assert(s->str = (char *) realloc(s->str,(s->len + width)+1));
    s->maxsize = s->len + width + 1;
  }
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
 * void String_appendfv(String *s, char *format, va_list ap) 
 *
 * Formats a string into s.   This is an incredibly gross hack.
 * -----------------------------------------------------------------------------*/
void
String_appendfv(DOH *so, char *format, va_list ap)
{
  static char *fmt_codes = "dioxXucsSfeEgGpnbB";
  int state = 0;
  char *p = format;
  char  newformat[256];
  char *fmt;
  char  temp[64];
  int   widthval = 0;
  int   precval = 0;
  int   maxwidth;
  char *w, *prec;
  int   ivalue;
  int   dvalue;
  String *s;

  s = (String *) so;

  while (*p) {
    switch(state) {
    case 0:  /* Ordinary text */
      if (*p != '%') {
	String_addchar(s,*p);
      } else{
	fmt = newformat;
	widthval = 0;
	precval = 0;
	*(fmt++) = *p;
	state = 10;
      }
      break;
    case 10: /* Look for a width and precision */
      if (isdigit(*p) && (*p != '0')) {
	w = temp;
	*(w++) = *p;
	*(fmt++) = *p;
	state = 20;
      } else if (strchr(fmt_codes,*p)) {
	/* Got one of the formatting codes */
	p--;
	state = 100;
      } else if (*p == '*') {
	/* Width field is specified in the format list */
	widthval = va_arg(ap,int);
	sprintf(temp,"%d",widthval);
	for (w = temp; *w; w++) {
	  *(fmt++) = *w;
	}
	state = 30;
      } else if (*p == '%') {
	String_addchar(s,*p);	
	fmt = newformat;
	state = 0;
      } else {
	*(fmt++) = *p;
      }
      break;
      
    case 20: /* Hmmm. At the start of a width field */
      if (isdigit(*p)) {
	*(w++) = *p;
	*(fmt++) = *p;
      } else if (strchr(fmt_codes,*p)) {
	/* Got one of the formatting codes */
	/* Figure out width */
	*w = 0;
	widthval = atoi(temp);
	p--;
	state = 100;
      } else if (*p == '.') {
	*w = 0;
	widthval = atoi(temp);
	w = temp;
	*(fmt++) = *p;
	state = 40;
      } else {
	/* ??? */
	*w = 0;
	widthval = atoi(temp);
	state = 50;
      }
      break;

    case 30:   /* Parsed a width from an argument.  Look for a . */
      if (*p == '.') {
	w = temp;
	*(fmt++) = *p;
	state = 40;
      } else if (strchr(fmt_codes,*p)) {
	/* Got one of the formatting codes */
	/* Figure out width */
	p--;
	state = 100;
      } else {
	/* hmmm. Something else. */
	state = 50;
      }
      break;

    case 40:
      /* Start of precision expected */
      if (isdigit(*p) && (*p != '0')) {
	*(fmt++) = *p;
	*(w++) = *p;
	state = 41;
      } else if (*p == '*') {
	/* Precision field is specified in the format list */
	precval = va_arg(ap,int);
	sprintf(temp,"%d",precval);
	for (w = temp; *w; w++) {
	  *(fmt++) = *w;
	}
	state = 50;
      } else if (strchr(fmt_codes,*p)) {
	p--;
	state = 100;
      } else {
	*(fmt++) = *p;
	state = 50;
      }
      break;
    case 41:
      if (isdigit(*p)) {
	*(fmt++) = *p;
	*(w++) = *p;
      } else if (strchr(fmt_codes,*p)) {
	/* Got one of the formatting codes */
	/* Figure out width */
	*w = 0;
	precval = atoi(temp);
	p--;
	state = 100;
      } else {
	*w = 0;
	precval = atoi(temp);
	*(fmt++) = *p;
	state = 50;
      }
      break;
      /* Hang out, wait for format specifier */
    case 50:
      if (strchr(fmt_codes,*p)) {
	p--;
	state = 100;
      } else {
	*(fmt++) = *p;
      }
      break;
    case 100:
      /* Got a formatting code */
      if (widthval < precval) maxwidth = precval;
      else maxwidth = widthval;
      if ((*p == 's') || (*p == 'S')) {       /* Null-Terminated string */
	DOH    *doh;
	String *Sval;
	doh = va_arg(ap, DOH *);
	if (DohCheck(doh)) {
	  /* Is an object at least */
	  if (String_check(doh)) {
	    Sval = (String *) doh;
	  } else {
	    Sval = (String *) Str(doh);
	  }
	  maxwidth = maxwidth+strlen(newformat)+strlen(Sval->str);
	  String_expand(s,maxwidth);
	  *(fmt++) = 's';
	  *fmt = 0;
	  sprintf(s->str+s->len,newformat,Sval->str);
	  s->len = s->len + strlen(s->str+s->len);
	  if ((DOH *) Sval != doh) {
	    Delete(Sval);
	  }
	  if (*p == 'S') {
	    Delete(doh);
	  }
	} else {
	  maxwidth = maxwidth+strlen(newformat)+strlen((char *) doh);
	  String_expand(s,maxwidth);
	  *(fmt++) = 's';
	  *fmt = 0;
	  sprintf(s->str+s->len,newformat,doh);
	  s->len = s->len + strlen(s->str+s->len);
	}
      } else if ((*p == 'b') || (*p == 'B')) {
	/* Raw binary mode */
	DOH    *doh, *Sval;
	doh = va_arg(ap, DOH *);
	if (DohCheck(doh)) {
	  void *ptr;
	  int   len;
	  Sval = Str(doh);
	  ptr = Data(Sval);
	  len = Len(Sval);
	  if ((widthval > 0) && (widthval < len)) len = widthval;
	  String_expand(s,len);
	  if (ptr) {
	    memmove(s->str+s->len,ptr,len);
	    s->len += len;
	  }
	  if (*p == 'B') {
	    Delete(doh);
	  }
	  Delete(Sval);
	} else {
	  String_expand(s,widthval);
	  memmove(s->str+s->len,doh,widthval);
	  s->len+=widthval;
	}
      } else {
	int ivalue;
	double dvalue;
	void  *pvalue;
	*(fmt++) = *p;
	*fmt = 0;
	maxwidth = maxwidth+strlen(newformat)+64;
	String_expand(s,maxwidth);
	switch(*p) {
	case 'd':
	case 'i':
	case 'o':
	case 'u':
	case 'x':
	case 'X':
	case 'c':
	  ivalue = va_arg(ap,int);
	  sprintf(s->str+s->len,newformat,ivalue);
	  break;
	case 'f':
	case 'g':
	case 'e':
	case 'E':
	case 'G':
	  dvalue = va_arg(ap,double);
	  sprintf(s->str+s->len,newformat,dvalue);
	  break;
	case 'p':
	  pvalue = va_arg(ap,void *);
	  sprintf(s->str+s->len,newformat,pvalue);	  
	  break;
	default:
	  break;
	}
	s->len = s->len + strlen(s->str+s->len);
      }
      state = 0;
      break;
    }
    p++;
  }
  if (state) {
    *fmt = 0;
    add(s,fmt);
  }
}

/* ----------------------------------------------------------------------
 * int String_scanfv(DOH *doh, char *format, va_list ap)
 *
 * Do a string scanf.  Somewhat broken compared to C scanf.
 * ---------------------------------------------------------------------- */

int String_scanfv(DOH *doh, char *format, va_list ap) {
  static char *fmt_chars = "diouxcsefgp";
  String *s;
  char    newformat[256];
  char   *fmt;
  char    *p;
  int     state;
  void    *ptr;
  int     total = 0;
  int     i;

  s = (String *) doh;
  state = 0;
  p = format;
  while (*p) {
    switch(state) {
    case 0:
      if (*p == '%') {
	fmt = newformat;
	*(fmt++) = *p;
	state = 10;
      }
      break;
    case 10:
      if (strchr(fmt_chars,*p)) {
	int len;
	*(fmt++) = *p;
	*fmt = 0;
	ptr = va_arg(ap, void *);
	len = sscanf(s->str+s->sp,newformat,ptr);
	for (i = 0; i < len; i++) {
	  while (s->sp < s->len) {
	    if (!isspace(s->str[s->sp])) break;
	    s->sp++;
	  }
	  while (s->sp < s->len) {
	    if (isspace(s->str[s->sp])) break;
	    s->sp++;
	  }
	}
	total += len;
	state = 0;
	fmt = newformat;
      } else {
	*(fmt++) = *p;
      }
      break;
    }
    p++;
  }
  return total;
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
    nstr = CopyString(s);
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
