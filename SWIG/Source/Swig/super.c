# ----------------------------------------------------------------------
# Simplified Wrapper and Interface Generator (SWIG)
# 
# Authors : David Beazley
#           Dustin Mitchell  
#
# Department of Computer Science        
# University of Chicago
# 1100 E 58th Street
# Chicago, IL  60637
# beazley@cs.uchicago.edu
#
# Please read the file LICENSE for the copyright and terms by which SWIG
# can be used and distributed.
# ----------------------------------------------------------------------

#include "doh.h"
#include "swigcore.h"

#if 0
/*
 * SuperStrings are just like strings, except that they maintain
 * information as to the origininal file/line of each character they
 * contain.
 */

typedef struct SSTag {
  int position;
  int line;
  DOH *filename;
} SSTag;

typedef struct Super {
  DOHCOMMON;

  /* -- from the regular string implementation */
  int maxsize;			/* Max size allocated */
  int len;			/* Current length     */
  int hashkey;			/* Hash key value     */
  int sp;			/* Current position   */
  int lsp;			/* Last returned position */
  char *str;			/* String data        */
  char pb[4];			/* Pushback data      */
  int pbi;

  /* -- specific to the SuperString implementation */
  SSTag *tags;			/* array of tags */
  int maxtags;			/* max size allocated for tags */
  int numtags;			/* count of tags */
} Super;

/* Forward references for member functions */

static void DelSuper(DOH *s);
static DOH *CopySuper(DOH *s);
static void Super_clear(DOH *s);
static DOH *Super_str(DOH *s);
static int Super_delitem(DOH *s, int where);
static int Super_len(DOH *s);
static void Super_appendfv(DOH *s, char *fmt, va_list ap);
static int Super_insertfv(DOH *s, int pos, char *fmt, va_list ap);
static int Super_insert(DOH *s, int pos, DOH *DOH);
static void *Super_data(DOH *s);
static int Super_cmp(DOH *, DOH *);
static int Super_hash(DOH *s);
static int Super_dump(DOH *s, DOH *out);
static int Super_read(DOH *s, void *buffer, int length);
static int Super_write(DOH *s, void *buffer, int length);
static int Super_getc(DOH *s);
static int Super_putc(DOH *s, int ch);
static int Super_ungetc(DOH *s, int ch);
static int Super_seek(DOH *s, long offset, int whence);
static long Super_tell(DOH *s);
static int Super_replace(DOH *str, DOH *token, DOH *rep, int flags);    
static void Super_chop(DOH *str);

/* internal functions */

static void Super_add(Super *s, const char *newstr);
static void Super_addchar(DOH *so, char c);
static void Super_raw_insert(Super *s, int pos, char *data, int len);
static void Super_tags_insert(Super *s, int pos, Super *new, int len);

/* method tables */

static DohSequenceMethods SuperSeqMethods = {
  0,				/* doh_getitem */
  0,				/* doh_setitem */
  Super_delitem,		/* doh_delitem */
  Super_insert,			/* doh_insitem */
  0,				/* doh_first   */
  0,				/* doh_next    */
};

static DohFileMethods SuperFileMethods = {
  Super_read,
  Super_write,
  Super_putc,
  Super_getc,
  Super_ungetc,
  Super_seek,
  Super_tell,
  0,
};

static DohSuperMethods SuperSuperMethods = {
  Super_replace,
};

static DohObjInfo SuperType = {
    "SuperString",		/* objname */
    sizeof(Super),		/* objsize */
    DelSuper,			/* doh_del */
    CopySuper,			/* doh_copy */
    Super_clear,		/* doh_clear */
    0,				/* doh_scope */
    Super_str,			/* doh_str */
    Super_data,			/* doh_data */
    Super_dump,			/* doh_dump */
    0,				/* doh_load */
    Super_len,			/* doh_len */
    Super_hash,			/* doh_hash    */
    Super_cmp,			/* doh_cmp */
    0,				/* doh_mapping */
    &SuperSeqMethods,		/* doh_sequence */
    &SuperFileMethods,		/* doh_file */
    &SuperStringMethods,	/* doh_string */ 
    0,				/* doh_callable */ 
};

#define INIT_MAXSIZE  16
#define INIT_MAXTAGS  2

/* ---- Public Functions ---- */

/* -------------------------------------------------------------------------
 * NewSuperString(const char *c) - Create a new SuperString
 * ------------------------------------------------------------------------- */
DOH *
NewSuper(char *s, DOH *filename, int firstline)
{
    int l = 0, max;
    Super *str;

    str = (Super *) DohObjMalloc(sizeof(Super));
    str->objinfo = &SuperType;
    str->hashkey = -1;
    str->sp = 0;
    str->lsp = 0;
    str->pbi = 0;

    max = INIT_MAXSIZE;
    if (s)
      {
	l = (int) strlen(s);
	if ((l+1) > max) max = l+1;
      }
    str->maxsize = max;

    str->str = (char *) DohMalloc(max);
    assert(str);
    if (s)
      copy_string(str->str,s);
    else
      str->str[0] = 0;

    str->maxtags = INIT_MAXTAGS;
    str->numtags = 1;

    str->tags = (SSTag *) DohMalloc(max * sizeof(SSTag));
    assert(str->tags);
    str->tags[0].position = 0;
    if (!String_check(filename) && !SuperString_check(filename))
      filename = NewString(filename);
    str->tags[0].filename = filename;

    str->len = l;
    return (DOH *) str;
}

/* -----------------------------------------------------------------------------
 * int Super_check(DOH *s) - Check if s is a Super
 * ----------------------------------------------------------------------------- */
int
SuperString_check(DOH *s) 
{
  return (s && DohCheck(s) && ((Super *) c)->objinfo == &SuperType);
}

/* ---- "Member" Functions ---- */

/* -------------------------------------------------------------------------
 * CopySuper(DOH *s) - Copy a Super
 * ------------------------------------------------------------------------- */
static DOH *
CopySuper(DOH *so)
{
  Super *s;
  int max;
  Super *str;
  s = (Super *) so;
  str = (Super *) DohObjMalloc(sizeof(Super));
  str->objinfo = &SuperType;
  str->hashkey = -1;
  str->sp = 0;
  str->lsp = 0;
  str->pbi = 0;

  max = s->maxsize;
  str->str = (char *) DohMalloc(max);
  memmove(str->str, s->str, s->len);
  str->maxsize = max;
  str->len = s->len;
  str->str[str->len] = 0;

  max = s->maxtags;
  str->tags = (SSTag *) DohMalloc(max * sizeof(SSTag));
  memmove(str->tags, s->tags, s->numtags * sizeof(SSTag));
  str->numtags = s->numtags;
  str->maxtags = s->maxtags;

  return (DOH *) str;
}
  
/* -------------------------------------------------------------------------
 * DelSuper(DOH *s) - Delete a Super
 * ------------------------------------------------------------------------- */
static void
DelSuper(DOH *so) 
{
  Super *s;
  s = (Super *) so;
  assert(s->refcount <= 0);

  if (s->str) 
    DohFree(s->str);
  s->str = 0;

  if (s->tags)
    DohFree(s->tags);
  s->tags = 0;

  DohObjFree(s);
}

/* -------------------------------------------------------------------------
 * void *Super_data(DOH *so) - Return as a 'void *'
 * ------------------------------------------------------------------------- */
static void *
Super_data(DOH *so) 
{
  Super *s = (Super *) so;
  s->str[s->len] = 0;
  return (void *) s->str;
}

/* -------------------------------------------------------------------------
 * int  Super_dump(DOH *so, DOH *out) 
 *
 * Serialize a Super onto out
 * ------------------------------------------------------------------------- */

static int
Super_dump(DOH *so, DOH *out) 
{
  int nsent;
  int ret;
  Super *s;
  
  s = (Super *) so;
  nsent = 0;
  while (nsent < s->len) 
    {
      ret = Write(out,s->str+nsent,(s->len-nsent));
      if (ret < 0) return ret;
      nsent += ret;
    }
  return nsent;
}

/* -------------------------------------------------------------------------
 * int Super_len(DOH *s) - Length of a Super
 * ------------------------------------------------------------------------- */

static int 
Super_len(DOH *so) 
{
  Super *s = (Super *)so;
  return s->len;
}

/* -------------------------------------------------------------------------
 * int Super_cmp(DOH *s1, DOH *s2) - Compare two Supers
 * ------------------------------------------------------------------------- */

static int
Super_cmp(DOH *so1, DOH *so2)
{
  /* we ignore all line number information */
  Super *s1, *s2;
  char *c1, *c2;
  int  maxlen,i;
  s1 = (Super *) so1;
  s2 = (Super *) so2;
  maxlen = s1->len;
  if (s2->len < maxlen)
    maxlen = s2->len;
  c1 = s1->str;
  c2 = s2->str;
  for (i = 0; i < maxlen; i++,c1++,c2++) 
    if (*c1 != *c2) break;
  if (i < maxlen) 
    {
      if (*c1 < *c2) return -1;
      else return 1;
    }
  if (s1->len == s2->len) return 0;
  if (s1->len > s2->len) return 1;
  return -1;
}

/* -------------------------------------------------------------------------
 * int Super_hash(DOH *s) - Compute Super hash value
 * ------------------------------------------------------------------------- */

static int
Super_hash(DOH *so)
{
  /* again, we ignore the line number information */
  Super *s = (Super *) so;
  char *c;
  int   i, h = 0, len;
  if (s->hashkey >= 0) return s->hashkey;
  c = s->str;
  len = s->len > 50 ? 50 : s->len;
  for (i = 0; i < len; i++) 
    {
      h = (((h << 5) + *(c++))); 
    }
  h = h & 0x7fffffff;
  s->hashkey = h;
  return h;
}  

/* -------------------------------------------------------------------------
 * void Super_clear(DOH *s) - Clear a Super
 * ------------------------------------------------------------------------- */

void
Super_clear(DOH *so)
{
  Super *s;
  s = (Super *) so;
  s->hashkey = -1;
  s->len = 0;
  *(s->str) = 0;
  s->sp = 0;
  s->lsp = 0;
  s->line = 1;
  s->pbi = 0;
  s->numtags = 0;
}
  
/* -------------------------------------------------------------------------
 * void Super_insert(DOH *so, int pos, SO *str) - Insert a Super
 * ------------------------------------------------------------------------- */
int
Super_insert(DOH *so, int pos, DOH *str)
{
    Super *s, *s1;
    char   *c;
    int     len;
    s = (Super *) so;
    /*    assert(s->refcount <= 1); */ /* quasi-immutability?!? */
    s1 = (Super *) str;
    len = s1->len;
    c = s1->str;
    Super_raw_insert(s,pos,c,len);
    Super_tags_insert(s,pos,s1,len);
    return 0;
}

/* -----------------------------------------------------------------------------
 * int Super_delitem(DOH *so, int pos)
 * 
 * Delete an individual item
 * ----------------------------------------------------------------------------- */

int Super_delitem(DOH *so, int pos)
{
  Super *s = (Super *) so;
  s->hashkey = -1;
  if (pos == DOH_END) pos = s->len-1;
  if (pos == DOH_BEGIN) pos = 0;
  if (s->len == 0) return 0;

  if (s->sp > pos) {
    s->sp--;
#ifdef DOH_Super_UPDATE_LINES
    if (s->str[pos] == '\n') s->line--;
#endif
  }
  memmove(s->str+pos, s->str+pos+1, ((s->len-1) - pos));
  s->len--;
  s->str[s->len] = 0;
  return 0;
}
  
/* -----------------------------------------------------------------------------
 * DOH *Super_str(DOH *so) - Returns a Super (used by printing commands)
 * ----------------------------------------------------------------------------- */

DOH *
Super_str(DOH *so) {
    DOH *nstr;
    Super *s = (Super *) so;
    nstr = CopySuper(s);
    return nstr;
}

/* -----------------------------------------------------------------------------
 * int Super_read(DOH *so, void *buffer, int len)
 * 
 * Read data from the Super
 * ----------------------------------------------------------------------------- */
int
Super_read(DOH *so, void *buffer, int len) {
  int    reallen, retlen;
  char   *cb;
  Super *s = (Super *) so;
  if (((s->sp-s->pbi) + len) > s->len) reallen = (s->len - (s->sp-s->pbi));
  else reallen = len;

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
 * int Super_write(DOH *so, void *buffer, int len)
 * 
 * Write data to the Super
 * ----------------------------------------------------------------------------- */
int
Super_write(DOH *so, void *buffer, int len) {
  int    newlen;
  Super *s = (Super *) so;
  s->hashkey = -1;
  newlen = s->sp + len+1;
  if (newlen > s->maxsize) {
    s->str = (char *) DohRealloc(s->str,newlen);
    assert(s->str);
    s->maxsize = newlen;
    s->len = s->sp + len;
  }
  if ((s->sp+len) > s->len) s->len = s->sp + len;
  memmove(s->str+s->sp,buffer,len);
  s->sp += len;
  s->pbi = 0;
  return len;
}

/* -----------------------------------------------------------------------------
 * int Super_seek(DOH *so, long offset, int whence)
 * 
 * Seek to a new position
 * ----------------------------------------------------------------------------- */
int
Super_seek(DOH *so, long offset, int whence) {
  int    pos, nsp, inc;
  Super *s = (Super *) so;
  if (whence == SEEK_SET) pos = 0;
  else if (whence == SEEK_CUR) pos = s->sp;
  else if (whence == SEEK_END) {
    pos = s->len;
    offset = -offset;
  }
  else pos = s->sp;

  nsp = pos + offset;
  if (nsp < 0) nsp = 0;
  if (nsp > s->len) nsp = s->len;
  if (nsp > s->sp) inc = 1;
  else inc = -1;
#ifdef DOH_Super_UPDATE_LINES
  while (s->sp != nsp) { 
    if (s->str[s->sp-1] == '\n') s->line += inc;
    s->sp += inc;
  }
#endif
  s->sp = nsp;
  s->pbi = 0;
  return 0;
}

/* -----------------------------------------------------------------------------
 * long Super_tell(DOH *so)
 * 
 * Return current position
 * ----------------------------------------------------------------------------- */
long
Super_tell(DOH *so) {
  Super *s = (Super *) so;
  return (long) (s->sp - s->pbi);
}

/* -----------------------------------------------------------------------------
 * int Super_putc(DOH *so, int ch)
 *
 * Put a character into the Super.
 * ----------------------------------------------------------------------------- */

int
Super_putc(DOH *so, int ch) {
  Super *s = (Super *) so;
  s->hashkey = -1;
  if (s->sp >= s->len) {
    Super_addchar(s,(char) ch);
  } else {
    s->str[s->sp] = (char) ch;
    s->sp++;
#ifdef DOH_Super_UPDATE_LINES
  if (ch == '\n') s->line++;
#endif
  }
  s->pbi = 0;
  return ch;
}

/* -----------------------------------------------------------------------------
 * int Super_getc(DOH *so)
 *
 * Get a character from the Super.  Updates the line number.
 * ----------------------------------------------------------------------------- */

int Super_getc(DOH *so) {
  int c;
  Super *s = (Super *) so;

  if (s->pbi) {
    c = (int) s->pb[--s->pbi];
  } else if (s->sp >= s->len) c = EOF;
  else c = (int) s->str[s->sp++];
#ifdef DOH_Super_UPDATE_LINES
  if (c == '\n') s->line++;
#endif
  return c;
}

/* -----------------------------------------------------------------------------
 * int Super_ungetc(DOH *so, int ch)
 *
 * Put a character back on to the input stream.  Updates the line count.
 * ----------------------------------------------------------------------------- */
int Super_ungetc(DOH *so, int ch) {
  Super *s = (Super *) so;
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
#ifdef DOH_Super_UPDATE_LINES
  if (ch == '\n') s->line--;
#endif
  return ch;
}

/* -----------------------------------------------------------------------------
 * int replace_internal(Super *str, char *token, char *rep, int flags, char *start, int count)
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

static
int replace_internal(Super *str, char *token, char *rep, int flags, char *start, int count)
{
    char *s, *c, *t;
    int  tokenlen;
    int  state;
    int  repcount = 0;

    /* Copy the current Super representation */

    s = str->str;
    str->hashkey = -1;

    tokenlen = strlen(token);

    /* If a starting position was given, dump those characters first */
  
    if (start) {
	c = start;
    } else {
	c = s;
    }

    /* Now walk down the old Super and search for tokens */
    t = strstr(c,token);
    if (t) {
	str->len = 0;
	str->str = (char *) DohMalloc(str->maxsize);
	if (start) {
	    char temp = *start;
	    *start = 0;
	    Super_add(str,s);
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
			    Super_add(str,t);
			    *c = temp;
			    Super_add(str,rep);
			    c += (tokenlen-1);
			    t = c+1;
			    count--;
			    repcount++;
			}
		    } else if (isalpha(*c) || (*c == '_') || (*c == '$')) {
			char temp = *c;
			*c = 0;
			Super_add(str,t);
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
			Super_add(str,rep);
			count--;
			repcount++;
		    } else {
			Super_add(str,t);
		    }
		    *c = temp;
		    t = c;
		    state = 0;
		}
		break;
	    case 20: /* A Super */
		if (*c == '\"') state = 0;
		else if (*c == '\\') c++;
		break;
	    case 30: /* A Single quoted Super */
		if (*c == '\'') state = 0;
		else if (*c == '\\') c++;
		break;
	    }
	    c++;
	}
	if ((count) && (state == 10)) {
	    if (strcmp(token,t) == 0) {
		Super_add(str,rep);
	    } else {
		Super_add(str,t);
	    }
	} else {
	    Super_add(str,t);
	}
	DohFree(s);
    }
    return repcount;
}

/* -----------------------------------------------------------------------------
 * int Super_replace(DOH *str, DOH *token, DOH *rep, int flags)
 * ----------------------------------------------------------------------------- */

int 
Super_replace(DOH *stro, DOH *token, DOH *rep, int flags)
{
    int count = -1;
    Super *str;
    if (!Super_check(stro)) return 0;
    str = (Super *) stro;
    assert(str->refcount);
    /* assert(!str->refcount); */
    if (flags & DOH_REPLACE_FIRST) count = 1;
    return replace_internal(str,Char(token),Char(rep),flags,str->str,count);
}

/* -----------------------------------------------------------------------------
 * void Super_chop(DOH *str)
 * ----------------------------------------------------------------------------- */

void
Super_chop(DOH *s) {
  char *c;
  Super *str = (Super *) s;
  if (!Super_check(s)) return;
  /* assert(!str->refcount); */
  
  /* Replace trailing whitespace */
  c = str->str + str->len - 1;
  while ((str->len >= 0) && (isspace(*c))) {
    if (str->sp >= str->len) {
      str->sp--;
#ifdef DOH_Super_UPDATE_LINES
      if (*c == '\n') str->line--;
#endif
    }
    str->len--;
    c--;
  }
  str->hashkey = -1;
  str->pbi = 0;
}

/* ---- internal functions ---- */
  
/* -------------------------------------------------------------------------
 * static Super_add(Super *s, const char *newstr) - Append to s
 * ------------------------------------------------------------------------- */

static void
Super_add(Super *s, const char *newstr)
{
  int   newlen, newmaxsize, l, i;
  if (!newstr) return;
  s->hashkey = -1;
  l = (int) strlen(newstr);
  newlen = s->len+l + 1;
  if (newlen >= s->maxsize-1) {
    newmaxsize = 2*s->maxsize;
    if (newlen >= newmaxsize -1) newmaxsize = newlen + 1;
    s->str = (char *) DohRealloc(s->str,newmaxsize);
    assert(s->str);
    s->maxsize = newmaxsize;
  }
  strcpy(s->str+s->len,newstr);
  if (s->sp >= s->len) {
#ifdef DOH_Super_UPDATE_LINES
    for (i = s->sp; i < s->len+l; i++) {
      if (s->str[i] == '\n') s->line++;
    }
#endif
    s->sp = s->len+l;
  }
  s->len += l;
}  

/* -------------------------------------------------------------------------
 * static Super_addchar(DOH *so, char c) - Add a single character to s
 * ------------------------------------------------------------------------- */

static void
Super_addchar(DOH *so, char c) {
  Super *s = (Super *) so;
  s->hashkey = -1;
  if ((s->len+1) > (s->maxsize-1)) {
    s->str = (char *) DohRealloc(s->str,2*s->maxsize);
    assert(s->str);
    s->maxsize *= 2;
  }
  s->str[s->len] = c;
  if (s->sp >= s->len) {
    s->sp = s->len+1;
    s->str[s->len+1] = 0;
#ifdef DOH_Super_UPDATE_LINES
    if (c == '\n') s->line++;
#endif
  }
  s->len++;
}

/* -------------------------------------------------------------------------
 * static Super_raw_insert(Super *s, int pos, char *data, int len)
 * ------------------------------------------------------------------------- */

static void
Super_raw_insert(Super *s, int pos, char *data, int len)
{
    char *nstr;
    nstr = s->str;
    s->hashkey = -1;
    if (pos == DOH_END) {
	Super_add(s, data);
	return;
    }
    if (pos < 0) pos = 0;
    else if (pos > s->len) pos = s->len;

    /* See if there is room to insert the new data */

    while (s->maxsize <= s->len+len) {
	s->str = (char *) DohRealloc(s->str,2*s->maxsize);
	assert(s->str);
	s->maxsize *= 2;
    }
    memmove(s->str+pos+len, s->str+pos, (s->len - pos));
    memcpy(s->str+pos,data,len);
    if (s->sp >= s->len) {
      int i;
      s->sp = s->len;
#ifdef DOH_Super_UPDATE_LINES
      for (i = 0; i < len; i++) {
	if (data[i] == '\n') s->line++;
      }
#endif
      s->sp+=len;
    }
    s->len += len; 
    s->str[s->len] = 0;
}  

/* -------------------------------------------------------------------------
 * static Super_tags_insert(Super *s, int pos, char *data, int len)
 * ------------------------------------------------------------------------- */

static void 
Super_tags_insert(Super *s, int pos, Super *new, int len)
{
}
#endif
