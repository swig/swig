/* ----------------------------------------------------------------------
 * Simplified Wrapper and Interface Generator (SWIG)
 * 
 * Authors : David Beazley
 *           Dustin Mitchell  
 *
 * Department of Computer Science        
 * University of Chicago
 * 1100 E 58th Street
 * Chicago, IL  60637
 * beazley@cs.uchicago.edu
 *
 * Please read the file LICENSE for the copyright and terms by which SWIG
 * can be used and distributed.
 ---------------------------------------------------------------------- */

#include "doh.h"
#include "swigcore.h"
#if 0
static char cvstag[] = "$Header$";

/*
 * SuperStrings are just like strings, except that they maintain
 * information as to the origininal file/line of each character they
 * contain.
 */

typedef struct SSTag {
  int length;			/* distance to the next tag */
  int line;			/* of this character */
  DOH *filename;		/* of this character */
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

  int curtag;			/* last tag before point */
  int curtag_offset;		/* offset into current tag */
} Super;

/* Forward references for member functions */

static DOH *CopySuper(DOH *s);
static void DelSuper(DOH *s);
static void *Super_data(DOH *s);
static int Super_dump(DOH *s, DOH *out);
static int Super_len(DOH *s);
static int Super_cmp(DOH *, DOH *);
static int Super_hash(DOH *s);
static void Super_clear(DOH *s);
static int Super_insert(DOH *s, int pos, DOH *DOH);
static int Super_delitem(DOH *s, int where);
static DOH *Super_str(DOH *s);
static int Super_read(DOH *s, void *buffer, int length);
static int Super_write(DOH *s, void *buffer, int length);
static int Super_seek(DOH *s, long offset, int whence);
static long Super_tell(DOH *s);
static int Super_putc(DOH *s, int ch);
static int Super_getc(DOH *s);
static int Super_ungetc(DOH *s, int ch);
static int Super_replace(DOH *str, DOH *token, DOH *rep, int flags);    
static int Super_setfile(DOH *s, DOH *f);
static int Super_setline(DOH *s, int);
static void Super_chop(DOH *str);

/* internal functions */

static void Super_move(Super *s, int delta);
static int Super_get_tag(Super *s, int pos, int *offset);
static void Super_add_space(Super *s, int more_bytes);
static void Super_insert_tag(Super *s, int index, int length, 
			     int line, DOH *filename);
static void Super_delete_tag(Super *s, int index);
static void Super_count_newlines(char *s, int len);
static void Super_string_insert(Super *s, int pos, char *str,
				int len, DOH *filename, int line);
static void Super_super_insert2(Super *s, int pos, Super *str,
				int, DOH *, int);
static void Super_super_insert(Super *s, int pos, Super *str);

typedef void (*callback)(Super *, int, DOH *, int, DOH *, int);
static int Super_raw_replace(Super *str, char *token, int flags,
			     callback insert, DOH *rep, int rep_len, 
			     DOH *rep_fn, int rep_line);

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
  0,
  Super_setfile,
  0,
  Super_setline
};

static DohSuperMethods SuperSuperMethods = {
  Super_replace,
  Super_chop
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

    str->line = firstline;
    str->file = filename;	/* don't incref: it's 'owned' by the
				   tag it comes from. */

    str->maxtags = INIT_MAXTAGS;
    str->numtags = 1;
    str->curtag = 0;
    str->curtag_offset = 0;

    str->tags = (SSTag *) DohMalloc(max * sizeof(SSTag));
    assert(str->tags);
    str->tags[0].position = 0;
    str->tags[0].line = 1;
    if (!String_check(filename) && !SuperString_check(filename))
      filename = NewString(filename);
    else
      Incref(filename);
    str->tags[0].filename = filename;

    str->len = l;
    return (DOH *) str;
}

/* -------------------------------------------------------------------------
 * int Super_check(DOH *s) - Check if s is a Super
 * ------------------------------------------------------------------------- */
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
  int max, i;
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

  str->line = s->line;
  str->file = s->file; Incref(str->file);

  max = s->maxtags;
  str->numtags = s->numtags;
  str->maxtags = s->maxtags;
  str->curtag = s->curtag;
  str->curtag_offset = s->curtag_offset;

  str->tags = (SSTag *) DohMalloc(max * sizeof(SSTag));
  memmove(str->tags, s->tags, s->numtags * sizeof(SSTag));

  for (i = 0; i < str->numtags; i++)
    Incref(str->tags[i].filename);

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
    {
      int i;
      for (i = 0; i < s->numtags; i++)
	Delete(s->tags[i].filename);

      DohFree(s->tags);
    }
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

static void
Super_clear(DOH *so)
{
  Super *s;
  int i;

  s = (Super *) so;
  s->hashkey = -1;
  s->len = 0;
  *(s->str) = 0;
  s->sp = 0;
  s->lsp = 0;
  s->pbi = 0;

  for (i = 1; i < s->numtags; i++)
    Delete(s->tags[i].filename);
  s->tags[0].length = 0;

  s->line = s->tags[0].line;
  s->file = s->tags[0].filename;
  s->numtags = 1;
  s->curtag = 0;
  s->curtag_offset = 0;
}
  
/* -------------------------------------------------------------------------
 * void Super_insert(DOH *so, int pos, SO *str) - Insert a Super
 * ------------------------------------------------------------------------- */
static int
Super_insert(DOH *so, int pos, DOH *str)
{
    Super *s;
    s = (Super *) so;

    if (Super_check(str))
      Super_super_insert(s, pos, (Super *)str);
    else if (DohCheck(str))
      Super_string_insert(s, pos, Char(str), Len(str), 
			  Getfile(str), Getline(str));
    else
      /* hmph. Nothin. */
      Super_string_insert(s, pos, char *str, 0, 0);
    
    return 0;
}

/* -------------------------------------------------------------------------
 * int Super_delitem(DOH *so, int pos)
 * 
 * Delete an individual item
 * ------------------------------------------------------------------------- */

static int Super_delitem(DOH *so, int pos)
{
  Super *s = (Super *) so;
  int thistag, nexttag;

  s->hashkey = -1;
  if (pos == DOH_END) pos = s->len-1;
  if (pos == DOH_BEGIN) pos = 0;
  if (s->len == 0) return 0;

  tag = Super_get_tag(s, pos, 0);

  /* special handling for deleting the current character */
  if (s->sp == pos)
    Super_move(s, 1);	/* move ahead off of the character */
    
  /* move the current point */
  else if (s->sp > pos)
    {
      s->sp--;
      if (s->curtag == tag)
	s->curtag_offset--;
    }

  /* move the string data */
  memmove(s->str+pos, s->str+pos+1, ((s->len-1) - pos));
  s->len--;
  s->str[s->len] = 0;

  /* and move the tags */
  if (! --s->tags[tag].length)
    Super_delete_tag(tag);

  return 0;
}
  
/* -------------------------------------------------------------------------
 * DOH *Super_str(DOH *so) - Returns a Super (used by printing commands)
 * ------------------------------------------------------------------------- */

static DOH *
Super_str(DOH *so)
{
  DOH *nstr;
  Super *s = (Super *) so;
  nstr = CopySuper(s);
  return nstr;
}

/* -------------------------------------------------------------------------
 * int Super_read(DOH *so, void *buffer, int len)
 * 
 * Read data from the Super
 * ------------------------------------------------------------------------- */

static int
Super_read(DOH *so, void *buffer, int len)
{
  int    reallen, retlen;
  char   *cb;
  Super *s = (Super *) so;

  if (((s->sp - s->pbi) + len) > s->len)
    len = (s->len - (s->sp - s->pbi));

  cb = (char *) buffer;
  retlen = len;

  /* Read the push-back buffer contents first */
  while (len > 0 && s->pbi)
    {
      *cb = s->pb[--s->pbi];
      if (*cb == (int)'\n') s->line++;
      cb++, len--;
    }
  if (len > 0) {
    memmove(cb, s->str+s->sp, len);
    Super_move(s, len);
  }
  return retlen;
}

/* -------------------------------------------------------------------------
 * int Super_write(DOH *so, void *buffer, int len)
 * 
 * Write data to the Super
 * ------------------------------------------------------------------------- */

static int
Super_write(DOH *so, void *buffer, int len) 
{
  int    newsize;
  Super *s = (Super *) so;
  
  /* zero the hash and pushback */
  s->hashkey = -1;
  s->pbi = 0;

  /* update size */
  newsize = s->sp + len + 1;
  if (newsize > s->maxsize) {
    s->str = (char *) DohRealloc(s->str,newsize);
    assert(s->str);
    s->maxsize = newsize;
  }

  /* update length */
  if ((s->sp + len) > s->len) 
    s->len = s->sp + len;

  /* update tag */
  s->tag[s->curtag].length += len;

  /* and copy the data */
  memmove(s->str + s->sp, buffer, len);

  /* move the point */
  Super_move(s, len);		/* counts newlines */
  return len;
}

/* -------------------------------------------------------------------------
 * int Super_seek(DOH *so, long offset, int whence)
 * 
 * Seek to a new position
 * ------------------------------------------------------------------------- */

static int
Super_seek(DOH *so, long offset, int whence) 
{
  Super *s = (Super *) so;
  s->pbi = 0;

  if (whence == SEEK_SET) offset = -s->sp;
  else if (whence == SEEK_END) offset = s->len - offset;

  Super_move(s, offset);

  return 0;
}

/* -------------------------------------------------------------------------
 * long Super_tell(DOH *so)
 * 
 * Return current position
 * ------------------------------------------------------------------------- */
static long
Super_tell(DOH *so)
{
  Super *s = (Super *) so;
  return (long) (s->sp - s->pbi);
}

/* -------------------------------------------------------------------------
 * int Super_putc(DOH *so, int ch)
 *
 * Put a character into the Super.
 * ------------------------------------------------------------------------- */

static int
Super_putc(DOH *so, int ch)
{
  Super *s = (Super *) so;

  s->hashkey = -1;
  s->pbi = 0;

  /* either append or overwrite */
  if (s->sp >= s->len)
    {
      if (s->len + 1 >= s->maxsize) {
	s->str = (char *) DohRealloc(s->str ,2 * s->maxsize);
	assert(s->str);
	s->maxsize *= 2;
      }
      s->str[s->len++] = c;
      s->str[s->len] = 0;
    }
  else
    s->str[s->sp] = (char) ch;

  /* and move ahead over the new character */
  Super_move(s, 1)
  return ch;
}

/* -------------------------------------------------------------------------
 * int Super_getc(DOH *so)
 *
 * Get a character from the Super.  Updates the line number.
 * ------------------------------------------------------------------------- */

static int
Super_getc(DOH *so)
{
  int c;
  Super *s = (Super *) so;

  if (s->pbi)
    return ((c = s->pb[--s->pbi]) == (int)'\n') ? (s->line++, c) : c;
  else if (s->sp >= s->len)
    return EOF;

  c = (int) s->str[s->sp];
  Super_move(s, 1);
  return c;
}

/* -------------------------------------------------------------------------
 * int Super_ungetc(DOH *so, int ch)
 *
 * Put a character back on to the input stream.  Updates the line count.
 * ------------------------------------------------------------------------- */
static int
Super_ungetc(DOH *so, int ch) 
{
  Super *s = (Super *) so;

  if (ch == EOF) return ch;
  if ((s->sp - s->pbi) <= 0) return EOF;
  if (s->pbi == 4)
    {
      s->pb[0] = s->pb[1], s->pb[1] = s->pb[2];
      s->pb[2] = s->pb[3], s->pb[3] = (char)ch;
    }
  else
    s->pb[s->pbi++] = (char) ch;
  if (ch == (int)'\n')
    s->line--;
  return ch;
}


/* -------------------------------------------------------------------------
 * int Super_replace(DOH *str, DOH *token, DOH *rep, int flags)
 * ------------------------------------------------------------------------- */

static int 
Super_replace(DOH *stro, DOH *token, DOH *rep, int flags)
{
}

/* -------------------------------------------------------------------------
 * void Super_setfile(DOH *obj, DOH *f)
 * ------------------------------------------------------------------------- */

static void
Super_setfile(DOH *obj, DOH *f)
{
  assert(0);			/* illegal operation */
}

/* -------------------------------------------------------------------------
 * void Super_setline(DOH *obj, int l)
 * ------------------------------------------------------------------------- */

static void
Super_setline(DOH *obj, int l)
{
  assert(0);			/* illegal operation */
}

/* -------------------------------------------------------------------------
 * void Super_chop(DOH *str)
 * ------------------------------------------------------------------------- */

void
Super_chop(DOH *so) {
  char *c;
  int len, tag, offset;
  Super *s = (Super *) so;
  
  /* check this one for obiwans */

  s->hashkey = -1;
  s->pbi = 0;

  /* find trailing whitespace */
  c = s->str + s->len - 1;
  while ((s->len >= 0) && (isspace(*c))) 
    c--;
  len = c - str->str + 1;

  /* Move the point back if necessary */
  if (s->sp > len)
    Super_move(len - s->sp);

  tag = Super_get_tag(s, len, &offset);

  /* Delete any relevant tags... */
  while (--s->numtags > tag)
      Delete(s->tags[s->numtags].filename);
  s->numtags++;
  s->tags[tag].length = offset;

  s->len = len;
}

/* ---- internal functions ---- */
  
/* -------------------------------------------------------------------------
 * static Super_move(Super *s, int delta)
 * ------------------------------------------------------------------------- */

static void 
Super_move(Super *s, int delta)
{
  int changed_tag = 0;
  int curtag_offset = s->curtag_offset;
  int line_offset;

  if (delta > len - s->sp)
    delta = len - s->sp;

  while (1)
    {
      int remaining = s->tags[s->curtag].length - curtag_offset;
      
      if (delta > remaining)
	{
	  delta -= remaining;
	  s->sp += remaining;
	  s->curtag++;
	  curtag_offset = 0;
	}
      else
	{
	  line_offset = Super_count_newlines(s->str + s->sp, delta);
	  curtag_offset += delta;
	  s->sp += delta;

	  break;
	}
    }

  s->curtag_offset = curtag_offset;
  s->file = s->tags[s->curtag].filename;
  s->line = s->tags[s->curtag].line + line_offset;
}

/* -------------------------------------------------------------------------
 * static int Super_get_tag(Super *s, int pos, int *offset)
 * ------------------------------------------------------------------------- */

static int
Super_get_tag(Super *s, int pos, int *offset)
{
  int tag = 0;
  SSTag *tags = s->tags;

  while (pos > tags->length)
    {
      pos -= tags->length;
      tags++;
      tag++;
    }

  if (offset) *offset = pos;
  return tag;
}

/* -------------------------------------------------------------------------
 * static int Super_insert_tag(Super *s, int index, int length, 
 *                             int line, DOH *filename)
 * ------------------------------------------------------------------------- */

static void
Super_insert_tag(Super *s, int index, int length, 
		 int line, DOH *filename)
{
  if (s->numtags + 1 >= s->maxtags)
    {
      s->maxtags *= 2;
      s->tags = (SSTag *)DohRealloc(s->tags,
				    s->maxtags * sizeof(SStag));
      assert(s->tags);
    }
  
  memmove(s->tags + index + 1, s->tags + index, 
	  (s->numtags - index) * sizeof(SStag));
  s->tags[index].length = length;
  s->tags[index].line = line;
  s->tags[index].filename = filename;
  s->numtags++;
}

/* -------------------------------------------------------------------------
 * static int Super_delete_tag(Super *s, int index)
 * ------------------------------------------------------------------------- */

static void
Super_delete_tag(Super *s, int index)
{
  if (!tag) return;		/* don't delete first tag */
  Delete(s->tags[index].filename);

  memmove(s->tags + index, s->tags + index + 1, 
	  (s->numtags - index - 1) * sizeof(SStag));
  s->numtags--;
}

/* -------------------------------------------------------------------------
 * static int Super_add_space(Super *s, int more_bytes) -- room to grow
 * ------------------------------------------------------------------------- */

static void
Super_count_newlines(char *s, int len)
{
  register int retval = 0;
  char *stop = s + len;
  while (s < stop)
    if (*(s++) == '\n') retval++;
  return retval;
}

/* -------------------------------------------------------------------------
 * static int Super_add_space(Super *s, int more_bytes) -- room to grow
 * ------------------------------------------------------------------------- */

static void
Super_add_space(Super *s, int more_bytes)
{
  if (s->len + more_bytes >= s->maxsize)
    {
      newsize = (s->len + more_bytes) * 2;
      s->str = (char *)DohRealloc(s->str, newsize);
      assert(s->str);
      s->maxsize = newsize
    }
}

/* -------------------------------------------------------------------------
 * static Super_string_insert(Super *s, int pos, char *str, int len,
 *                            DOH *filename, int line)
 * ------------------------------------------------------------------------- */

static void
Super_string_insert(Super *s, int pos, char *str, int len,
		    DOH *filename, int line)
{
  int offset, tag;
  s->hashkey = -1;
  
  /* normalize the inputs */
  if (len == 0) len = strlen(str);
  if (len == 0) return;

  if (pos < 0) pos = 0;
  else if (pos > s->len) pos = s->len;

  /* do the insertion */
  Super_add_space(s, len);
  if (pos < s->len)
    memmove(s->str+pos+len, s->str+pos, (s->len - pos));
  memmove(s->str+pos,str,len);
  s->len += len; 
  s->str[s->len] = 0;

  /* insert new tags for this string if necessary */
  tag = Super_get_tag(s, pos, &offset);
  if (file)
    {
      int left_len = offset;
      int mid_len = len;
      int right_len = s->tags[tag].length - offset;
      int right_line;
      DOH *right_filename = s->tags[tag].filename;

      if (right_len)
	{
	  /* only calculate this if it will be used. */
	  right_line = s->tags[tag].line + 
	    Super_count_newlines(s->str + pos - offset, offset);

	  /* if a new tag uses filename, Incref it */
	  Incref(right_filename);
	}

      /* don't leave any zero-length tags, and avoid deleting and then
       * inserting (such waste!) */
      if (left_len)
	{
	  s->tags[tag].length = left_len;
	  Super_insert_tag(s, ++tag, mid_len, line, filename);
	}
      else
	{			/* replace the tag */
	  Delete(s->tags[tag].filename);
	  s->tags[tag].length = mid_len;
	  s->tags[tag].line = line;
	  s->tags[tag].filename = filename;
	}

      if (right_len)
	Super_insert_tag(s, ++tag, right_len, right_line,
			 right_filename);

    }
  else				/* no file/line info -- just extend */
    s->tags[tag].length += len;	/* this tag a bit */

  /* move the point if necessary */
  if (s->sp >= pos)
    {
      int offset;
      s->sp += len;

      s->curtag = Super_get_tag(s, s->sp, &offset);
      s->curtag_offset = offset;

      s->file = s->tags[s->curtag].filename;
      s->line = Super_count_newlines(s->str + s->sp - offset, offset);
    }
}  

/* -------------------------------------------------------------------------
 * static Super_super_insert(Super *s, int pos, Super *str)
 * ------------------------------------------------------------------------- */

static void
Super_super_insert2(Super *s, int pos, Super *str, 
		    int ignore1, DOH *ignore2, int ignore3)
{ /* this function's prototype matches Super_string_insert, so it can
     be used as a callback */
  Super_super_insert(s, pos, str);
}

static void
Super_super_insert(Super *s, int pos, Super *str)
{
  int offset, tag, len, i;
  int left_len, right_len, new_tags;
  int right_line;
  DOH *right_filename;

  s->hashkey = -1;
  
  /* normalize the inputs */
  if (pos < 0) pos = 0;
  else if (pos > s->len) pos = s->len;
  
  len = str->len;
  if (len == 0) return;

  /* do the insertion */
  Super_add_space(s, len);
  if (pos < s->len)
    memmove(s->str+pos+len, s->str+pos, (s->len - pos));
  memmove(s->str+pos,str,len);
  s->len += len; 
  s->str[s->len] = 0;

  /* collect some factoids about the new layout of the tags */
  tag = Super_get_tag(s, pos, &offset);
  left_len = offset;
  right_len = s->tags[tag].length - offset;
  right_filename = s->tags[tag].filename;

  if (right_len)
    {
      /* only calculate this if it will be used */
      right_line = s->tags[tag].line + 
	Super_count_newlines(s->str + pos - offset, offset);

      /* if we will have another tag using filename, Incref it */
      Incref(right_filename);
    }

  /* how many new tags shall we allocate? */
  new_tags = str->numtags + 1;
  if (left_len == 0)
    {
      new_tags--;
      Delete(s->tags[tag].filename);
      tag--;			/* back up so we overwrite it. */
    }
  if (right_len == 0)
    new_tags--;

  /* allocate enough space for all those tags */
  if (s->numtags + new_tags >= s->maxtags)
    {
      int newsize = (s->numtags + new_tags) * 2;
      s->tags = (SSTag *)DohRealloc(s->tags, newsize * sizeof(SSTag));
      assert(s->tags);
      s->maxsize = newsize;
    }
      
  /* and start writing in the data */
  if (left_len)
    s->tags[tag++].length = left_len;
  memmove(s->tags + tag, str->tags, str->numtags * sizeof(SSTag));
  tags += str->numtags;
  if (right_len)
    {
      s->tags[tag].length = right_len;
      s->tags[tag].line = right_line;
      s->tags[tag].filename = right_filename;
      tag++;
    }

  s->numtags += new_tags;

  /* move the point if necessary */
  if (s->sp >= pos)
    {
      int offset;
      s->sp += len;

      s->curtag = Super_get_tag(s, s->sp, &offset);
      s->curtag_offset = offset;

      s->file = s->tags[s->curtag].filename;
      s->line = Super_count_newlines(s->str + s->sp - offset, offset);
    }
}  

/* -------------------------------------------------------------------------
 * static int
 * Super_raw_replace(Super *str, char *token, int flags,
 * 		     callback insert, DOH *rep, int rep_len, 
 *     	             DOH *rep_fn, int rep_line);
 *
 * Replaces token with rep.  flags is as follows:
 *
 *         DOH_REPLACE_ANY           -   Replace all occurrences
 *         DOH_REPLACE_NOQUOTE       -   Don't replace in quotes
 *         DOH_REPLACE_ID            -   Only replace valid identifiers
 *         DOH_REPLACE_FIRST         -   Only replace first occurrence
 * 
 * ------------------------------------------------------------------------- */

static int
Super_raw_replace(Super *str, char *token, int flags, 
		  callback insert, DOH *rep, int rep_len, 
		  DOH *rep_fn, int rep_line)
{
    char *s, *t;
    int  tokenlen, state, i;
    int  repcount = 0;
    Super fake;			/* HACK! :) */
    SSTag *old_tags;
    int old_numtags;
    char *old_str;
    int old_len;
    
    str->hashkey = -1;

    tokenlen = strlen(token);
  
    /* first see if there is a match, using the speedy library
       function */
    t = strstr(str->str, token);
    if (!t) return 0;

    /* otherwise, keep the current text of the string and its tags. */
    old_str = str->str;
    old_len = str->len;
    old_tags = str->tags;
    old_numtags = str->numtags;
    for (i = 0; i < old_numtags; i++)
      Incref(old_tags[i].filename); /* we want to keep this! */

    /* and obliterate this super, allocating new space for both tags
       and data. */
    Super_clear(str);
    str->str = (char *) DohMalloc(str->maxsize);
    assert(str->str);
    str->tags = (SSTag *) DohMalloc(str->maxtags * sizeof(SSTag));

    /* fill in the fake Super so we can use it for appending */
    fake.str = old_str;
    fake.tags = old_tags;

    /* if we can do this using library functions, get to work. */
    if (!(flags & (DOH_REPLACE_ID | DOH_REPLACE_NOQUOTE)))
      while (1)
	{
	  int offset;
	  
	  if (t > fake.str)
	    {
	      /* append a chunk from the old string */
	      fake.len = t - fake.str;
	      fake.numtags = Super_get_tag(&fake, fake.len, &offset) + 1;
	      if (offset == 0) fake.numtags--; /* avoid an empty last tag */
	      Super_super_insert(str, DOH_END, &fake);
	      
	      /* now move 'fake' over that chunk */
	      fake.str += fake.len;
	      fake.tags += numtags - 1;
	      /* OBIWAN! */ /*
		 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! */
	    }
	}
    
    while (1)
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
#endif
