/*
 *  This file is part of SWIG.
 *
 *  SWIG is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  SWIG is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with SWIG.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "doh.h"
#include <cstring>
#include <cstdarg>
#include <cassert>
namespace doh {

  /* class String */
  
  /* Constructors */
  String::String() 
    : sp(0)
  {}

  String::String(const String& str)
    : Filelike(str), std::string(str), sp(str.sp)
  {}

  String::String(const std::string& str)
    : Filelike(), std::string(str), sp(0)
  {}


  String::String(const char * s)
    : std::string(s), sp(0) {
  }
    
  String::String(const char *s, size_t n)
    : std::string(s, n), sp(0) {  
  }

  /* inherit from DOH */
  DOH* String::clone() const {
    return new String(*this);
  }

  void String::clear() {
    sp = 0;
    std::string::clear();
    DOH::clear();
    return;
  }

  int String::size() const {
    return std::string::size();
  }

  /* inherit from Filelike */

  int String::write(const char *buffer, size_t length) {
    replace(sp, length, buffer);
    sp += length;
    return length;
  }

  int String::read(char *buffer, size_t length) {    
    size_t readlen;
    readlen = size() - sp;
    if (readlen < 0)
      return 0;
    if (readlen > length)
      readlen = length;
    memmove(buffer, data(), readlen);
    sp += readlen;
    return readlen;
  }

  /* count the occurrence of '\n' in a closed range */  
  static int countline(const char *str, size_t l, size_t r) {
    register int count = 0;
    register const char *i = str + l;
    register const char *rr = str + r;
    while (i <= rr) {
      /* XXX In the original DOH there is '++i',
       * (accutally ++sp and --sp)
       * but to conform with getc(), it should
       * be i++.  */
      if (*(i++) == '\n')
        ++count;      
    }
    return count;
  }
  int String::seek(off_t offset, int whence) {
    int pos, nsp, inc;
    int len = size();

    if (whence == SEEK_SET)
      pos = 0;
    else if (whence == SEEK_CUR)
      pos = sp;
    else if (whence == SEEK_END) {
      pos = len;
      offset = -offset;
    } else
      pos = sp;

    nsp = pos + offset;
    if (nsp < 0)
      nsp = 0;
    if ( len > 0 && nsp > len)
      nsp = len;
    
    /* Set line number */
    if (sp < nsp)
      _line += countline(c_str(), sp, nsp-1);
    else
      _line -= countline(c_str(), nsp+1, sp);

    sp = nsp;
    assert( sp >= 0 );
    return 0;
  }

  off_t String::tell() {
    return sp;
  }

  char String::getc() {
    char c;
    if (sp >= size())
      c = EOF;
    else
      c = c_str()[sp++];
    if (c == '\n')
      _line++;
    return c;
  }
  char String::putc(char ch) {
    register int len = size();
    if (sp < len) {
      at(sp++) = ch;
    } else {
      /* append to tail of the string */
      push_back(ch);
      sp++;
    }
    return ch;
  }

  char String::ungetc(char ch) {
    if (ch == EOF)
      return ch;
    if (sp <= 0)
      return EOF;
    sp--;
    if (ch == '\n')
      _line--;
    return ch;
  }
 
  /* Override std::string methods */
  String& String::insert(size_t pos, const std::string &str) {
    size_t len = str.size();
    std::string::insert(pos, str);
    if (sp >= pos) {
      _line += countline(str.c_str(), 0, len-1);
      sp += len;
    }
    return *this;
  }
    
  String& String::erase(size_t pos, size_t n) {
    int eindex = pos + n;
    int end;
    /* Adjust file pointer sp and line count */
    if (sp > pos) {
      if (sp > eindex) {
        end = eindex;
        sp -= n;
      } else {
        end = sp;
        sp = pos;
      }
      _line -= countline(c_str(), pos, end-1);
    }
    std::string::erase(pos, n);
    return *this;
  }


  /* DOH String methods */

  String *NewStringEmpty() {
    return new String();
  }

  String *NewString(String_or_char_ptr c) {
    return new String(c);
  }

  String *NewStringWithSize(const String_or_char_ptr c, int len) {
    const char *p = c;
    return new String(c, len);
  }
  
  /*XXX const char* fmt is enough */
  String *NewStringf(const String_or_char_ptr fmt, VA_DEF) {
    //va_list ap;
    String *r = new String();
    const char * fmtstr = fmt;
    //va_start(ap, fmt);
    Printf(r, fmtstr, VA_CALL);
    //va_end(ap);
    return r;
  }

  int Cmp(String_or_char_ptr obj1, String_or_char_ptr obj2) {
    const String *str1 = obj1; // implicit cast
    const String *str2 = obj2;
    return str1->compare(*str2);
  }
  
  const char *Char(const String_or_char_ptr s) {
    return s;
  }
  
  int Equal(const String_or_char_ptr obj1, const String_or_char_ptr obj2) {
    return Cmp(obj1, obj2)==0;
  }

  int Strcmp(const String_or_char_ptr s1, const String_or_char_ptr s2) {
    const char *c1 = Char(s1);
    const char *c2 = Char(s2);
    if (c1 && c2) {
      return strcmp(c1, c2);
    } else {
      return c1 < c2;
    }
  }

  int Strncmp(const String_or_char_ptr s1, const String_or_char_ptr s2, int n) {
    return strncmp(Char(s1), Char(s2), n);
  }
  const char *Strstr(const String_or_char_ptr s1, const String_or_char_ptr s2) {
    const char *p1 = Char(s1);
    const char *p2 = Char(s2);
    return p1 == 0 || p2 == 0 || *p2 == '\0' ? p1 : strstr(p1, p2);
  }

  const char *Strchr(const String_or_char_ptr s1, int ch) {
    return strchr(Char(s1), ch);
  }

void Chop(DOH *src) {
  String &so = ref_cast<String>(src);
  int len = so.size();
  int i = len;
  while (i>0 && isspace(so[i-1])) {
    i--;
  }
  so.erase(i, len-i);
}
  
int Replace(DOH * src, const String_or_char_ptr token, 
            const String_or_char_ptr rep, int flags) {
  String *so = doh_cast<String*>(src);
  so->doh_replace(token, rep, flags);
}


  /* The powerful DOH string replace function */
  
  static int replace_simple(char* &str, int &str_len, off_t &str_sp, 
      const char *token, const char *rep, int flags, int count, 
      char *(*match) (char *, char *, const char *, int));
  static char *match_identifier(char *base, char *s, const char *token, int tokenlen);
  static char *match_identifier_begin(char *base, char *s, const char *token, int tokenlen);
  static char *match_identifier_end(char *base, char *s, const char *token, int tokenlen);
  static char *match_simple(char *base, char *s, const char *token, int tokenlen);

  int String::doh_replace(const char *token, const char *rep, int flags) {
    int len = size();
    int count = -1;
    int ret;
    char *str = new char[len+1];
    strcpy(str, c_str());
    if (flags & DOH_REPLACE_FIRST)
      count = 1;

    if (flags & DOH_REPLACE_ID_END) {
      ret = replace_simple(str, len, sp, token, rep, flags, count,
                  match_identifier_end);
    } else if (flags & DOH_REPLACE_ID_BEGIN) {
      ret = replace_simple(str, len, sp, token, rep, flags, count,
                  match_identifier_begin);      
    } else if (flags & DOH_REPLACE_ID) {
      ret = replace_simple(str, len, sp, token, rep, flags, count,
                  match_identifier);      
    } else {
      ret = replace_simple(str, len, sp, token, rep, flags, count,
                  match_simple);      
    }

    assert(strlen(str)==len);
    assign(str);
    delete[] str;
    /* sp already set since we passed it as reference */
    return ret;
  }


/* below code is adapted from old DOH */

/* -----------------------------------------------------------------------------
 * replace_simple(String *str, char *token, char *rep, int flags, int count)
 *
 * Replaces count non-overlapping occurrences of token with rep in a string.   
 * ----------------------------------------------------------------------------- */

static char *end_quote(char *s) {
  char *qs;
  char qc;
  char *q;
  char *nl;
  qc = *s;
  qs = s;
  while (1) {
    q = strpbrk(s + 1, "\"\'");
    nl = strchr(s + 1, '\n');
    if (nl && (nl < q)) {
      /* A new line appears before the end of the string */
      if (*(nl - 1) == '\\') {
	s = nl + 1;
	continue;
      }
      /* String was terminated by a newline.  Wing it */
      return qs;
    }
    if (!q && nl) {
      return qs;
    }
    if (!q)
      return 0;
    if ((*q == qc) && (*(q - 1) != '\\'))
      return q;
    s = q;
  }
}

static char *match_simple(char *base, char *s, const char *token, int tokenlen) {
  (void) base;
  (void) tokenlen;
  return strstr(s, token);
}

static char *match_identifier(char *base, char *s, const char *token, int tokenlen) {
  while (s) {
    s = strstr(s, token);
    if (!s)
      return 0;
    if ((s > base) && (isalnum((int) *(s - 1)) || (*(s - 1) == '_'))) {
      s += tokenlen;
      continue;
    }
    if (isalnum((int) *(s + tokenlen)) || (*(s + tokenlen) == '_')) {
      s += tokenlen;
      continue;
    }
    return s;
  }
  return 0;
}


static char *match_identifier_begin(char *base, char *s, const char *token, int tokenlen) {
  while (s) {
    s = strstr(s, token);
    if (!s)
      return 0;
    if ((s > base) && (isalnum((int) *(s - 1)) || (*(s - 1) == '_'))) {
      s += tokenlen;
      continue;
    }
    return s;
  }
  return 0;
}

static char *match_identifier_end(char *base, char *s, const char *token, int tokenlen) {
  (void) base;
  while (s) {
    s = strstr(s, token);
    if (!s)
      return 0;
    if (isalnum((int) *(s + tokenlen)) || (*(s + tokenlen) == '_')) {
      s += tokenlen;
      continue;
    }
    return s;
  }
  return 0;
}

static int replace_simple(char* &str, int &str_len, off_t &str_sp,
    const char *token, const char *rep, int flags, int count,
    char *(*match) (char *, char *, const char *, int)) {
  int tokenlen;			/* Length of the token */
  int replen;			/* Length of the replacement */
  int delta, expand = 0;
  int ic;
  int rcount = 0;
  int noquote = 0;
  char *c, *s, *t, *first;
  char *q, *q2;
  register char *base;
  int i;

  /* Figure out if anything gets replaced */
  if (!strlen(token))
    return 0;

  //base = str->str;
  base = str;
  tokenlen = strlen(token);
  s = (*match) (base, base, token, tokenlen);

  if (!s)
    return 0;			/* No matches.  Who cares */


  if (flags & DOH_REPLACE_NOQUOTE)
    noquote = 1;

  /* If we are not replacing inside quotes, we need to do a little extra work */
  if (noquote) {
    q = strpbrk(base, "\"\'");
    if (!q) {
      noquote = 0;		/* Well, no quotes to worry about. Oh well */
    } else {
      while (q && (q < s)) {
	/* First match was found inside a quote.  Try to find another match */
	q2 = end_quote(q);
	if (!q2) {
	  return 0;
	}
	if (q2 > s) {
	  /* Find next match */
	  s = (*match) (base, q2 + 1, token, tokenlen);
	}
	if (!s)
	  return 0;		/* Oh well, no matches */
	q = strpbrk(q2 + 1, "\"\'");
	if (!q)
	  noquote = 0;		/* No more quotes */
      }
    }
  }

  first = s;
  replen = strlen(rep);

  delta = (replen - tokenlen);

  if (delta <= 0) {
    /* String is either shrinking or staying the same size */
    /* In this case, we do the replacement in place without memory reallocation */
    ic = count;
    t = s;			/* Target of memory copies */
    while (ic && s) {
      if (replen) {
	memcpy(t, rep, replen);
	t += replen;
      }
      rcount++;
      expand += delta;
      /* Find the next location */
      s += tokenlen;
      if (ic == 1)
	break;
      c = (*match) (base, s, token, tokenlen);

      if (noquote) {
	q = strpbrk(s, "\"\'");
	if (!q) {
	  noquote = 0;
	} else {
	  while (q && (q < c)) {
	    /* First match was found inside a quote.  Try to find another match */
	    q2 = end_quote(q);
	    if (!q2) {
	      c = 0;
	      break;
	    }
	    if (q2 > c)
	      c = (*match) (base, q2 + 1, token, tokenlen);
	    if (!c)
	      break;
	    q = strpbrk(q2 + 1, "\"\'");
	    if (!q)
	      noquote = 0;	/* No more quotes */
	  }
	}
      }
      if (delta) {
	if (c) {
	  memmove(t, s, c - s);
	  t += (c - s);
	} else {
	  memmove(t, s, (str + str_len) - s + 1);
	}
      } else {
	t += (c - s);
      }
      s = c;
      ic--;
    }
    if (s && delta) {
      memmove(t, s, (str + str_len) - s + 1);
    }
    str_len += expand;
    str[str_len] = 0;
    if (str_sp >= str_len)
      str_sp += expand;	/* Fix the end of file pointer */
    return rcount;
  }
  /* The string is expanding as a result of the replacement */
  /* Figure out how much expansion is going to occur and allocate a new string */
  {
    char *ns;
    int newsize;

    rcount++;
    ic = count - 1;
    s += tokenlen;
    while (ic && (c = (*match) (base, s, token, tokenlen))) {
      if (noquote) {
	q = strpbrk(s, "\"\'");
	if (!q) {
	  break;
	} else {
	  while (q && (q < c)) {
	    /* First match was found inside a quote.  Try to find another match */
	    q2 = end_quote(q);
	    if (!q2) {
	      c = 0;
	      break;
	    }
	    if (q2 > c) {
	      c = (*match) (base, q2 + 1, token, tokenlen);
	      if (!c)
		break;
	    }
	    q = strpbrk(q2 + 1, "\"\'");
	    if (!q)
	      noquote = 0;
	  }
	}
      }
      if (c) {
	rcount++;
	ic--;
	s = c + tokenlen;
      } else {
	break;
      }
    }

    expand = delta * rcount;	/* Total amount of expansion for the replacement */
    //newsize = str->maxsize;
    //while ((str->len + expand) >= newsize)
    //  newsize *= 2;
    newsize = str_len + expand + 1;

    ns = new char[newsize];
    assert(ns);
    t = ns;
    s = first;

    /* Copy the first part of the string */
    if (first > str) {
      memcpy(t, str, (first - str));
      t += (first - str);
    }
    for (i = 0; i < rcount; i++) {
      memcpy(t, rep, replen);
      t += replen;
      s += tokenlen;
      c = (*match) (base, s, token, tokenlen);
      if (noquote) {
	q = strpbrk(s, "\"\'");
	if (!q) {
	  noquote = 0;
	} else {
	  while (q && (q < c)) {
	    /* First match was found inside a quote.  Try to find another match */
	    q2 = end_quote(q);
	    if (!q2) {
	      c = 0;
	      break;
	    }
	    if (q2 > c) {
	      c = (*match) (base, q2 + 1, token, tokenlen);
	      if (!c)
		break;
	    }
	    q = strpbrk(q2 + 1, "\"\'");
	    if (!q)
	      noquote = 0;	/* No more quotes */
	  }
	}
      }
      if (i < (rcount - 1)) {
	memcpy(t, s, c - s);
	t += (c - s);
      } else {
	memcpy(t, s, (str + str_len) - s + 1);
      }
      s = c;
    }
    c = str;
    str = ns;
    if (str_sp >= str_len)
      str_sp += expand;
    str_len += expand;
    str[str_len] = 0;
    //DohFree(c);
    delete []c;
    return rcount;
  }
}


}
