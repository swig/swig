/* -------------------------------------------------------------------------
 * super.c
 *
 *     SuperStrings are just like strings, except that they maintain
 *     information as to the origininal file/line of each character they
 *     contain.
 *
 * Author(s) : Dustin Mitchell (djmitche@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.
 * ------------------------------------------------------------------------- */

#include <ctype.h>
#include "doh.h"
#include "swig.h"

static char cvstag[] = "$Header$";

typedef struct SSTag
{
   int length;			/* distance to the next tag */
   int line;			/* of this character */
   DOH *filename;		/* of this character */
} SSTag;

typedef struct Super
{
   DOHCOMMON;

   /* -- from the regular string implementation */
   int maxsize;			/* Max size allocated */
   int len;			/* Current length     */
   int hashkey;			/* Hash key value     */
   int sp;			/* Current position   */
   char *str;			/* String data        */
   char pb[4];			/* Pushback data      */
   int pbi;

   /* -- that silly line and file -- */
   int line;
   DOH *file;

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
static void Super_scope(DOH *s, int sc);
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
static void Super_setfile(DOH *s, DOH *f);
static void Super_setline(DOH *s, int);
static DOH * Super_getfile(DOH *s);
static int Super_getline(DOH *s);
static void Super_chop(DOH *str);

/* internal functions */

static void Super_move(Super *s, int delta);
static int Super_get_tag(Super *s, int pos, int *offset);
static void Super_add_space(Super *s, int more_bytes);
static void Super_insert_tag(Super *s, int index, int length,
			     int line, DOH *filename);
static void Super_Delete_tag(Super *s, int index);
static int Super_count_newlines(char *s, int len);
static void Super_string_insert(Super *s, int pos, char *str,
				int len, DOH *filename, int line);
static void Super_super_insert2(Super *s, int pos, char *str,
				int, DOH *, int);
static void Super_super_insert(Super *s, int pos, Super *str);

typedef void (*callback)(Super *, int, char *, int, DOH *, int);
static int Super_raw_replace(Super *str, char *token, int flags,
			     callback insert, DOH *rep, int rep_len,
			     DOH *rep_fn, int rep_line);

/* method tables */

static DohSequenceMethods SuperSeqMethods =
{
   0,				/* doh_getitem */
   0,				/* doh_setitem */
   Super_delitem,		/* doh_delitem */
   Super_insert,		/* doh_insitem */
   0,				/* doh_first   */
   0,				/* doh_next    */
};

static DohPositionalMethods SuperPositionalMethods =
{
   Super_setfile,
   Super_getfile,
   Super_setline,
   Super_getline
};

static DohFileMethods SuperFileMethods =
{
   Super_read,
   Super_write,
   Super_putc,
   Super_getc,
   Super_ungetc,
   Super_seek,
   Super_tell,
   0,
};

static DohStringMethods SuperStringMethods =
{
  Super_replace,
  Super_chop
};

static DohObjInfo SuperType =
{
   "SuperString",		/* objname */
   sizeof(Super),		/* objsize */
   DelSuper,			/* doh_del */
   CopySuper,			/* doh_copy */
   Super_clear,			/* doh_clear */
   Super_scope,			/* doh_scope */
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
   &SuperStringMethods,		/* doh_string */
   0,				/* doh_callable */
   &SuperPositionalMethods,	/* doh_position */
};

#define INIT_MAXSIZE  16
#define INIT_MAXTAGS  2

/* ---- Public Functions ---- */

/* -------------------------------------------------------------------------
 * NewSuperString(const char *c) - Create a new SuperString
 * ------------------------------------------------------------------------- */
DOH *
NewSuperString(char *s, DOH *filename, int firstline)
{
   int l = 0, max;
   Super *str;

   str = (Super *) DohObjMalloc(sizeof(Super));
   str->objinfo = &SuperType;
   str->hashkey = -1;
   str->sp = 0;
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
      strcpy(str->str,s);
   else
      str->str[0] = 0;

   str->maxtags = INIT_MAXTAGS;
   str->numtags = 1;
   str->curtag = 0;
   str->curtag_offset = 0;

   str->tags = (SSTag *) DohMalloc(max * sizeof(SSTag));
   assert(str->tags);
   str->tags[0].length = strlen(str->str);
   str->tags[0].line = firstline;
   if (!DohCheck(filename) ||
       (!String_check(filename) && !SuperString_check(filename)))
      filename = NewString(filename);
   else
      Incref(filename);
   str->tags[0].filename = filename;

   str->line = firstline;
   str->file = filename;	/* don't Incref: it's 'owned' by the
				   tag it comes from. */
   str->len = l;
   return (DOH *) str;
}

/* -------------------------------------------------------------------------
 * int SuperString_check(DOH *s) - Check if s is a Super
 * ------------------------------------------------------------------------- */
int
SuperString_check(DOH *s)
{
   return (s && DohCheck(s) && ((Super *) s)->objinfo == &SuperType);
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
   str->sp = s->sp;
   str->pbi = 0;

   max = s->maxsize;
   str->str = (char *) DohMalloc(max);
   memmove(str->str, s->str, s->len);
   str->maxsize = max;
   str->len = s->len;
   str->str[str->len] = 0;

   str->line = s->line;
   str->file = s->file;

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
Super_scope(DOH *o, int sc)
{
   Super *s = (Super *)o;
   int i;

   for (i = 0; i < s->numtags; i++)
      Setscope(s->tags[i].filename, sc);
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

   if (SuperString_check(str))
      Super_super_insert(s, pos, (Super *)str);
   else if (DohCheck(str))
      Super_string_insert(s, pos, Char(str), Len(str),
			  Getfile(str), Getline(str));
   else
      /* hmph. Nothin. */
      Super_string_insert(s, pos, str, 0, 0, 0);

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
   int tag;

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
      Super_Delete_tag(s, tag);

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
   nstr = NewString(s->str);
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
      newsize *= 2;
      s->str = (char *) DohRealloc(s->str,newsize);
      assert(s->str);
      s->maxsize = newsize;
   }

   /* update length */
   if ((s->sp + len) > s->len)
   {
      int newlen = s->sp + len;
      s->tags[s->numtags-1].length += newlen - s->len;

      s->len = newlen;
      s->str[s->len] = 0;
   }

   /* and copy the data */
   memmove(s->str + s->sp, buffer, len);

   /* move the point.  This does kinda weird things if the point was
      not at the end of the string -- by obliterating newlines, it can
      change line number information, but it won't change file
      information.  Such is the cost of writing inside of a string. */
   Super_move(s, len);
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

   if (whence == SEEK_SET) offset = offset - s->sp;
   else if (whence == SEEK_END) offset = s->len - s->sp - offset;

   if (offset + s->sp < 0)
      offset = -s->sp;
   else if (offset + s->sp > s->len)
      offset = s->len - s->sp;

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
	 s->maxsize *= 2;
	 s->str = (char *) DohRealloc(s->str, s->maxsize);
	 assert(s->str);
      }

      s->str[s->len++] = ch;
      s->tags[s->numtags-1].length++;
      s->str[s->len] = 0;
   }
   else
      s->str[s->sp] = (char) ch;

   /* and move ahead over the new character */
   Super_move(s, 1);
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
   if (SuperString_check(rep))
      Super_raw_replace((Super *)stro, Char(token), flags,
			Super_super_insert2, (DOH *)rep, 0, 0, 0);
   else if (String_check(rep))
   {
      Seek(rep, 0, SEEK_SET);
      Super_raw_replace((Super *)stro, Char(token), flags,
			Super_string_insert, (DOH *)rep, Len(rep),
			Getfile(rep), Getline(rep));
   }
   else
      Super_raw_replace((Super *)stro, Char(token), flags,
			Super_string_insert, (DOH *)Char(rep), Len(rep),
			0, 0);
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
 * void Super_getfile(DOH *obj, DOH *f)
 * ------------------------------------------------------------------------- */

static DOH *
Super_getfile(DOH *obj)
{
  return ((Super *)obj)->file;
}

/* -------------------------------------------------------------------------
 * void Super_getline(DOH *obj, int l)
 * ------------------------------------------------------------------------- */

static int
Super_getline(DOH *obj)
{
  return ((Super *)obj)->line;
}

/* -------------------------------------------------------------------------
 * void Super_chop(DOH *str)
 * ------------------------------------------------------------------------- */

void
Super_chop(DOH *so) {
   char *c;
   int len, tag, offset;
   Super *s = (Super *) so;

   s->hashkey = -1;
   s->pbi = 0;

   /* find trailing whitespace */
   c = s->str + s->len - 1;
   while ((s->len >= 0) && (isspace(*c)))
      c--;
   len = c - s->str + 1;

   /* Move the point back if necessary */
   if (s->sp > len)
      Super_move(s, len - s->sp);

   tag = Super_get_tag(s, len, &offset);

   /* Delete any relevant tags... */
   while (s->numtags > tag + 1)
     Super_Delete_tag(s, --s->numtags);
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
   int curtag_offset = s->curtag_offset;
   int line = s->line;

   if (s->sp + delta > s->len)
      delta = s->len - s->sp;
   else if (s->sp + delta < 0)
      delta = - s->sp;

   if (delta > 0)
   {
      while (1)
      {
	 int remaining = s->tags[s->curtag].length - curtag_offset;

	 if (delta >= remaining)
	 {
	    s->curtag++;

	    /* usually, if we're at the end of a tag, we want to be at
	       the beginning of the next one.  But if we're at the end
	       of the string, we want to be at the end of the last
	       tag, as a special case. */
	    if (s->curtag == s->numtags)
	    {
	       --s->curtag;
	       curtag_offset = s->tags[s->curtag].length;
	       line = s->tags[s->curtag].line +
		  Super_count_newlines(s->str + s->sp, remaining);
	       s->sp += remaining;

	       break;
	    }

	    delta -= remaining;
	    s->sp += remaining;
	    line = s->tags[s->curtag].line;
	    curtag_offset = 0;
	 }
	 else
	 {
	    line += Super_count_newlines(s->str + s->sp, delta);
	    curtag_offset += delta;
	    s->sp += delta;

	    break;
	 }
      }
   }
   else
   {
      delta = -delta;
      if (delta < curtag_offset)
      {
	 /* short-circuit if we won't cross a tag boundary */

	 curtag_offset -= delta;
	 s->sp -= delta;
	 line -= Super_count_newlines(s->str + s->sp, delta);
      }
      else
	 while (1)
	 {
	    int remaining = curtag_offset;

	    if (delta > remaining)
	    {
	       delta -= remaining;
	       s->sp -= remaining;
	       s->curtag--;
	       curtag_offset = s->tags[s->curtag].length;
	    }
	    else if (delta == remaining)
	    {
	       s->sp -= delta;
	       curtag_offset = 0;
	       line = s->tags[s->curtag].line;

	       break;
	    }
	    else
	    {
	       curtag_offset -= delta;
	       s->sp -= delta;
	       line = s->tags[s->curtag].line +
		  Super_count_newlines(s->str + s->sp - curtag_offset,
				       curtag_offset);

	       break;
	    }
	 }
   }

   s->curtag_offset = curtag_offset;
   s->file = s->tags[s->curtag].filename;
   s->line = line;
}

/* -------------------------------------------------------------------------
 * static int Super_get_tag(Super *s, int pos, int *offset)
 * ------------------------------------------------------------------------- */

static int
Super_get_tag(Super *s, int pos, int *offset)
{
   int tag = 0;
   SSTag *tags = s->tags;

   if (pos == s->len)		/* special case */
   {
      int lasttag = s->numtags - 1;
      if (offset) *offset = s->tags[lasttag].length;
      return lasttag;
   }

   while (pos >= tags->length)
   {
      pos -= tags->length;
      tags++, tag++;
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
				    s->maxtags * sizeof(SSTag));
      assert(s->tags);
   }

   memmove(s->tags + index + 1, s->tags + index,
	   (s->numtags - index) * sizeof(SSTag));
   s->tags[index].length = length;
   s->tags[index].line = line;
   s->tags[index].filename = filename;
   s->numtags++;
}

/* -------------------------------------------------------------------------
 * static int Super_Delete_tag(Super *s, int index)
 * ------------------------------------------------------------------------- */

static void
Super_Delete_tag(Super *s, int index)
{
   if (!index) return;		/* don't Delete first tag */
   Delete(s->tags[index].filename);

   memmove(s->tags + index, s->tags + index + 1,
	   (s->numtags - index - 1) * sizeof(SSTag));
   s->numtags--;
}

/* -------------------------------------------------------------------------
 * static int Super_add_space(Super *s, int more_bytes) -- room to grow
 * ------------------------------------------------------------------------- */

static int
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
      s->maxsize = (s->len + more_bytes) * 2;
      s->str = (char *)DohRealloc(s->str, s->maxsize);
      assert(s->str);
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

   if (pos == DOH_END || pos > s->len) pos = s->len;
   else if (pos < 0) pos = 0;

   tag = Super_get_tag(s, pos, &offset);

   /* do the insertion */
   Super_add_space(s, len);
   if (pos < s->len)
      memmove(s->str+pos+len, s->str+pos, (s->len - pos));
   memmove(s->str+pos,str,len);
   s->len += len;
   s->str[s->len] = 0;

   /* insert new tags for this string if necessary */
   if (filename)
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
Super_super_insert2(Super *s, int pos, char *str,
		    int ignore1, DOH *ignore2, int ignore3)
{ /* this function's prototype matches Super_string_insert, so it can
     be used as a callback */
   Super_super_insert(s, pos, (Super *)str);
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
   if (pos == DOH_END || pos > s->len) pos = s->len;
   else if (pos < 0) pos = 0;

   len = str->len;
   if (len == 0) return;

   tag = Super_get_tag(s, pos, &offset);

   /* do the insertion */
   Super_add_space(s, len);
   if (pos < s->len)
      memmove(s->str+pos+len, s->str+pos, (s->len - pos));
   memmove(s->str+pos,str->str,len);
   s->len += len;
   s->str[s->len] = 0;

   /* collect some factoids about the new layout of the tags */
   left_len = offset;
   right_len = s->tags[tag].length - offset;

   if (right_len)
   {
      right_filename = s->tags[tag].filename;

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
   }
   if (right_len == 0)
      new_tags--;

   /* allocate enough space for all those tags */
   if (s->numtags + new_tags >= s->maxtags)
   {
      s->maxtags = (s->numtags + new_tags) * 2;
      s->tags = (SSTag *)DohRealloc(s->tags, s->maxtags * sizeof(SSTag));
      assert(s->tags);
   }

   /* and move the existing tags forward. */
   memmove(s->tags + tag + new_tags, s->tags + tag,
	   (s->numtags - tag) * sizeof(SSTag));

   /* and start writing in the data */
   if (left_len)
      s->tags[tag++].length = left_len;
   memmove(s->tags + tag, str->tags, str->numtags * sizeof(SSTag));
   for (i = 0; i < str->numtags; i++)
      Incref(s->tags[tag + i].filename);
   tag += str->numtags;
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

/* static variables for use in Super_raw_replace */

static Super *rr_dest;
static Super *rr_original;

static void
Super_rr_append_chunk(int start, int len)
{
   SSTag initial, final;
   SSTag new_initial, new_final;
   int initial_tag, final_tag;
   int old_numtags, old_len;
   /* the job of this function: append a chunk to rr_dest from
      rr_original. */

   if (len == 0) return;	/* :) */

   /* we use Super_move because it lets us move relatively within the
      string instead of having to recalculate from the beginning every
      time with Super_get_tag() */
   Super_move(rr_original, start - rr_original->sp);
   initial_tag = rr_original->curtag;
   initial = rr_original->tags[initial_tag];

   new_initial.line = rr_original->line;
   new_initial.filename = rr_original->file;
   new_initial.length = initial.length - rr_original->curtag_offset;

   Super_move(rr_original, len);
   final_tag = rr_original->curtag;

   if  (rr_original->curtag_offset )
   {
      final = rr_original->tags[final_tag];
      new_final.line = final.line;
      new_final.filename = rr_original->file;
      new_final.length = rr_original->curtag_offset;
   }
   else	/* avoid zero-length final tag */
   {
      /* note: if this makes final_tag == initial_tag, that's OK -- we
	 swap final_tag before initial_tag, and we don't try to change
	 final here, so we'll just end up doing a bit of extra
	 swapping.  If that didn't make sense, don't worry about it. */
      final_tag--;
      final = rr_original->tags[final_tag];
      new_final = final;
   }

   /* tuck away some other info */
   old_numtags = rr_original->numtags;
   old_len = rr_original->len;

   /* OK, now we swap in our new tags, offset the tags and str fields
      appropriately, set the lengths correctly, and call insert. */
   rr_original->tags[final_tag] = new_final;
   rr_original->tags[initial_tag] = new_initial;
   rr_original->numtags = final_tag - initial_tag + 1;
   rr_original->tags += initial_tag;
   rr_original->len = len;
   rr_original->str += start;

   Super_super_insert(rr_dest, DOH_END, rr_original); /* easy!? */

   /* and swap things back in the opposite order. */
   rr_original->str -= start;
   rr_original->len = old_len;
   rr_original->tags -= initial_tag;
   rr_original->numtags = old_numtags;
   rr_original->tags[initial_tag] = initial;
   rr_original->tags[final_tag] = final;
}

static int
Super_raw_replace(Super *str, char *token, int flags,
		  callback insert, DOH *rep, int rep_len,
		  DOH *rep_fn, int rep_line)
{
   char *match, *lastmatch_end;
   int  tokenlen, state, i;
   int  repcount = 0;

   str->hashkey = -1;
   tokenlen = strlen(token);

   /* first see if there is a match, using the speedy library
      function */
   match = strstr(str->str, token);
   if (!match) return 0;

   /* if there is a match, then fill in the global variables. Note
      that we only copy the necessary fields. */
   rr_dest = str;
   rr_original = (Super *)CopySuper((DOH *)str);

   /* Now obliterate our "destination". */
   Super_clear(rr_dest);

   /* if we can do this using library functions, get to work. */
   if (!(flags & (DOH_REPLACE_ID | DOH_REPLACE_NOQUOTE)))
   {
      lastmatch_end = rr_original->str;
      while ((match = strstr(lastmatch_end, token)))
      {
	 /* copy the unchanged stuff from the original */
	 Super_rr_append_chunk(lastmatch_end - rr_original->str,
			       match - lastmatch_end);

	 /* and now insert the replacement */
	 (*insert)(rr_dest, DOH_END, (char *)rep,
		   rep_len, rep_fn, rep_line);

	 /* now move our pointer up.. */
	 lastmatch_end = match + tokenlen;
	 repcount++;
      }

      /* copy the unchanged stuff from the end */
      Super_rr_append_chunk(lastmatch_end - rr_original->str,
			    rr_original->str + rr_original->len -
			    lastmatch_end);

      Delete(rr_original);
      return repcount;
   }

   /* otherwise we need to do our own kind of search, with Dave's
      special little state machine to tell us when we're in quotes or
      not at the beginning of an identifier. */
#define RR_BEGIN_MATCH 0
#define RR_INSIDE_IDENTIFIER 1
#define RR_INSIDE_SINGLE_QUOTE 2
#define RR_INSIDE_DOUBLE_QUOTE 3
#define RR_DONE -1
   state = 0;
   match = lastmatch_end = rr_original->str;

   while (*match && state != RR_DONE)
   {
      switch(state)
      {
      case RR_BEGIN_MATCH:
	 if (*match == *token &&
	     strncmp(match,token,tokenlen) == 0)
	 {
	    /* skip if not the whole identifier */
	    if (flags & DOH_REPLACE_ID)
	    {
	       char after= *(match + tokenlen);
	       if (after == '_' || after == '$' || isalnum(after))
	       {
		  match += tokenlen;
		  state = RR_INSIDE_IDENTIFIER;
		  continue;
	       }
	    }

	    /* copy the unchanged stuff from the original */
	    Super_rr_append_chunk(lastmatch_end - rr_original->str,
				  match - lastmatch_end);

	    /* and now insert the replacement */
	    (*insert)(rr_dest, DOH_END, (char *)rep,
		      rep_len, rep_fn, rep_line);

	    /* now move our pointer up.. */
	    match = lastmatch_end = match + tokenlen;
	    repcount++;

	    /* bail now if we only want to replace one */
	    if (flags & DOH_REPLACE_FIRST)
	       state = RR_DONE;

	    /* we're now not ready to replace another identifier,
	       if anybody cares */
	    else if (flags & DOH_REPLACE_ID)
	       state = RR_INSIDE_IDENTIFIER;

	    continue;
	 }

	 if (flags & DOH_REPLACE_ID)
	 {
	    if (*match == '_' || *match == '*' || isalpha(*match))
	       state = RR_INSIDE_IDENTIFIER;
	 }

	 if (flags & DOH_REPLACE_NOQUOTE)
	 {
	    if (*match == '\"') state = RR_INSIDE_DOUBLE_QUOTE;
	    else if (*match == '\'') state = RR_INSIDE_SINGLE_QUOTE;
	    else if (*match == '\\' &&
		     (*(match+1) == '\'' || *(match+1) == '\"'))
	       match++;
	 }

	 break;

      case RR_INSIDE_IDENTIFIER:
	 if (!(isalnum(*match) || (*match == '_') || (*match == '$')))
	    state = RR_BEGIN_MATCH;
	 break;

      case RR_INSIDE_DOUBLE_QUOTE:
	 if (*match == '\"') state = RR_BEGIN_MATCH;
	 else if (*match == '\\') match++;
	 break;

      case RR_INSIDE_SINGLE_QUOTE:
	 if (*match == '\'') state = RR_BEGIN_MATCH;
	 else if (*match == '\\') match++;
	 break;
      }

      match++;
   }

   /* copy the unchanged stuff from the end */
   Super_rr_append_chunk(lastmatch_end - rr_original->str,
			 rr_original->str + rr_original->len -
			 lastmatch_end);


   /* and reset the pointer */
   rr_dest->sp = rr_dest->curtag =
      rr_dest->curtag_offset = rr_dest->pbi = 0;
   rr_dest->line = rr_dest->tags[0].line;
   rr_dest->file = rr_dest->tags[0].filename;

   Delete(rr_original);
   return repcount;
}

#if defined(SUPER_TEST)
#include <stdio.h>

static void dump_tags(DOH *so)
{
   Super *s = (Super *)so;
   int tag = 0;
   int pos = 0;
   while (tag < s->numtags)
   {
      Printf(stdout, "TAG %d: %d to %d (%d bytes), starting at '%s':%d\n",
	     tag, pos, pos + s->tags[tag].length - 1, s->tags[tag].length,
	     s->tags[tag].filename, s->tags[tag].line);
      pos += s->tags[tag].length;
      tag++;
   }
}

static void annotate(DOH *hyd)
{
  int len, i;
  len = Len(hyd);
  for (i = 0; i < len; i++)
    {
      DOH *file;
      int line;
      char c[3];
      char d;
      int pos;

      Seek(hyd, 0, SEEK_SET);

      Seek(hyd, i, SEEK_SET);

      file = Getfile(hyd);
      line = Getline(hyd);
      pos = Tell(hyd);
      c[0] = Getc(hyd);
      if (c[0] < ' ')
	{
	  c[2] = 0;
	  c[1] = c[0] + 'a' - 1;
	  c[0] = '\\';
	}
      else
	c[1] = 0;

      Printf(stdout, "%5d -- %5s:%3d -- %s\n", pos, file, line, c);
    }
}

int main(int argc, char **argv)
{
   DOH *a = NewSuperString("aaa\naaa", "a", 10);
   DOH *b = NewSuperString("bbb", "b", 20);
   DOH *c = NewSuperString("cc\ncc", "c", 30);
   DOH *d = NewSuperString("dd\ndd", "d", 40);

   DOH *r = NewSuperString("repl", "repl", 50);
   DOH *r2 = NewSuperString("LPER", "lepr", 60);

   Insert(a, 6, b);
   Insert(a, 5, c);
   Insert(a, 3, d);

   Insert(r, 2, r2);

   Replace(a, "ac", r, 0);
   Replace(a, "LPER", r, 0);
   dump_tags(a);
   annotate(a);

   return 0;
}
#endif
