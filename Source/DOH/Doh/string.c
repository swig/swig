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
    char           pb[4];                     /* Pushback data      */
    int            pbi;
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
int     String_dump(DOH *s, DOH *out);
int     String_read(DOH *s, void *buffer, int length);
int     String_write(DOH *s, void *buffer, int length);
int     String_getc(DOH *s);
int     String_putc(DOH *s, int ch);
int     String_ungetc(DOH *s, int ch);
int     String_seek(DOH *s, long offset, int whence);
long    String_tell(DOH *s);
    
static DohSequenceMethods StringSeqMethods = {
  0,                      /* doh_getitem */
  0,                      /* doh_setitem */
  String_delitem,         /* doh_delitem */
  String_insert,          /* doh_insitem */
  0,                      /* doh_first   */
  0,                      /* doh_next    */
};

static DohFileMethods StringFileMethods = {
  String_read,
  String_write,
  String_putc,
  String_getc,
  String_ungetc,
  String_seek,
  String_tell,
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
    String_dump,       /* doh_dump */
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
 * int  String_dump(DOH *so, DOH *out) 
 *
 * Serialize a string onto out
 * ----------------------------------------------------------------------------- */

int String_dump(DOH *so, DOH *out) {
  int nsent;
  int ret;
  String *s;
  
  s = (String *) so;
  nsent = 0;
  while (nsent < s->len) {
    ret = Write(out,s->str+nsent,(s->len-nsent));
    if (ret < 0) return ret;
    nsent += ret;
  }
  return nsent;
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
    str->pbi = 0;
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
  str->pbi = 0;
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
  if (s->sp >= s->len) s->sp+=l;
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
  if (s->sp >= s->len) s->sp+=l;
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
  s->str[s->len] = c;
  if (s->sp >= s->len) s->sp++;
  s->len++;
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
  s->pbi = 0;
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
  int    reallen, retlen;
  int    i;
  char   *cb;
  String *s = (String *) so;
  if (((s->sp-s->pbi) + len) > s->len) reallen = (s->len - (s->sp-s->pbi));

  cb = (char *) buffer;
  retlen = reallen;

  /* Read the push-back buffer contents first */
  while (reallen > 0) {
    if (s->pbi <= 0) break;
    *(cb++) = (char) s->pb[--s->pbi];
    reallen--;
  }
  if (reallen > 0) {
    memmove(cb, s->str+s->sp, reallen);
    s->sp += reallen;
  }
  return retlen;
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
  if (newlen > s->len) s->len = newlen;
  memmove(s->str+s->sp,buffer,len);
  s->sp += len;
  s->pbi = 0;
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
  s->pbi = 0;
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
  return (long) (s->sp - s->pbi);
}

/* -----------------------------------------------------------------------------
 * int String_putc(DOH *so, int ch)
 *
 * Put a character into the string.
 * ----------------------------------------------------------------------------- */

int
String_putc(DOH *so, int ch) {
  String *s = (String *) so;
  if (s->sp >= s->len) {
    String_addchar(s,(char) ch);
  } else {
    s->str[s->sp] = (char) ch;
    s->sp++;
  }
  s->pbi = 0;
  return ch;
}

/* -----------------------------------------------------------------------------
 * int String_getc(DOH *so)
 *
 * Get a character from the string
 * ----------------------------------------------------------------------------- */

int String_getc(DOH *so) {
  String *s = (String *) so;
  if (s->pbi) {
    return (int) s->pb[--s->pbi];
  }
  if (s->sp >= s->len) return EOF;
  else return (int) s->str[s->sp++];
}

/* -----------------------------------------------------------------------------
 * int String_ungetc(DOH *so, int ch)
 *
 * Put a character back on to the input stream.
 * ----------------------------------------------------------------------------- */

int String_ungetc(DOH *so, int ch) {
  String *s = (String *) so;
  int i;
  if (ch == EOF) return ch;
  if ((s->sp - s->pbi) <= 0) return EOF;
  if (s->pbi == 4) {
    s->pb[0] = s->pb[1];
    s->pb[1] = s->pb[2];
    s->pb[2] = s->pb[3];
    s->pb[3] = (char) ch;
  } else {
    s->pb[s->pbi++] = (char) ch;
  }
  return ch;
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
