/* ----------------------------------------------------------------------------- 
 * fio.c
 *
 *     This file implements a number of standard I/O operations included
 *     formatted output, readline, and splitting.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include "doh.h"
#include <map>
#include <string>
#include <cstring>
#include <cstdarg>
#include <cstdlib>
using namespace std;
namespace doh {
#define OBUFLEN  512

typedef DOH *(*encoding_fn) (DOH *s);
typedef map<std::string, encoding_fn> encoding_map;

static encoding_map *encodings = 0;	/* Encoding hash */

/* -----------------------------------------------------------------------------
 * Writen()
 *
 * Write's N characters of output and retries until all characters are
 * written.  This is useful should a write operation encounter a spurious signal.
 * ----------------------------------------------------------------------------- */

static int Writen(DOH *out, void *buffer, int len) {
  int nw = len, ret;
  char *cb = (char *) buffer;
  while (nw) {
    ret = Write(out, cb, nw);
    if (ret < 0)
      return -1;
    nw = nw - ret;
    cb += ret;
  }
  return len;
}

/* -----------------------------------------------------------------------------
 * DohEncoding()
 *
 * Registers a new printf encoding method.  An encoder function should accept
 * two file-like objects and operate as a filter.
 * ----------------------------------------------------------------------------- */

void DohEncoding(char *name, DOH *(*fn) (DOH *s)) {
  if (!encodings)
    encodings = new encoding_map();
  (*encodings)[name] = fn;
  //Setattr(encodings, (void *) name, NewVoid((void *) fn, 0));
}

/* internal function for processing an encoding */
static DOH *encode(char *name, DOH *s) {
  DOH *ns;
  DOH *(*fn) (DOH *);
  long pos;
  char *cfmt = strchr(name, ':');
  DOH *tmp = 0;
  if (cfmt) {
    tmp = NewString(cfmt + 1);
    Append(tmp, s);
    Setfile(tmp, Getfile((DOH *) s));
    Setline(tmp, Getline((DOH *) s));
    *cfmt = '\0';
  }
  //if (!encodings || !(handle = Getattr(encodings, name))) {
  if (!encodings || encodings->count(name)) {
    return Copy(s);
  } else {
    fn = (*encodings)[name];
  }
  if (tmp)
    s = tmp;
  pos = Tell(s);
  Seek(s, 0, SEEK_SET);
  //fn = (DOH *(*)(DOH *)) Data(handle);
  ns = (*fn) (s);
  Seek(s, pos, SEEK_SET);
  if (tmp)
    Delete(tmp);
  return ns;
}

/* -----------------------------------------------------------------------------
 * DohvPrintf()
 *
 * DOH implementation of printf.  Output can be directed to any file-like object
 * including bare FILE * objects.  The same formatting codes as printf are
 * recognized with two extensions:
 *
 *       %s          - Prints a "char *" or the string representation of any
 *                     DOH object.  This will implicitly result in a call to
 *                     Str(obj).
 *
 *       %(encoder)* - Filters the output through an encoding function registered
 *                     with DohEncoder().
 *
 * Note: This function is not particularly memory efficient with large strings.
 * It's better to use Dump() or some other method instead.
 * ----------------------------------------------------------------------------- */

int vPrintf(DOH *so, const char *format, VA_DEF) {
  static const char *fmt_codes = "dioxXucsSfeEgGpn";
  int state = 0;
  const char *p = format;
  char newformat[256];
  char obuffer[OBUFLEN];
  char *fmt = 0;
  char temp[64];
  int widthval = 0;
  int precval = 0;
  int maxwidth;
  char *w = 0;
  int ivalue;
  double dvalue;
  void *pvalue;
  char *stemp;
  int nbytes = 0;
  char encoder[128], *ec = 0;
  int plevel = 0;

  VA_INIT;

  memset(newformat, 0, sizeof(newformat));

  while (*p) {
    switch (state) {
    case 0:			/* Ordinary text */
      if (*p != '%') {
	Putc(*p, so);
	nbytes++;
      } else {
	fmt = newformat;
	widthval = 0;
	precval = 0;
	*(fmt++) = *p;
	encoder[0] = 0;
	state = 10;
      }
      break;
    case 10:			/* Look for a width and precision */
      if (isdigit((int) *p) && (*p != '0')) {
	w = temp;
	*(w++) = *p;
	*(fmt++) = *p;
	state = 20;
      } else if (strchr(fmt_codes, *p)) {
	/* Got one of the formatting codes */
	p--;
	state = 100;
      } else if (*p == '*') {
	/* Width field is specified in the format list */
	widthval = VA_GET._int;
	sprintf(temp, "%d", widthval);
	for (w = temp; *w; w++) {
	  *(fmt++) = *w;
	}
	state = 30;
      } else if (*p == '%') {
	Putc(*p, so);
	fmt = newformat;
	nbytes++;
	state = 0;
      } else if (*p == '(') {
	++plevel;
	ec = encoder;
	state = 60;
      } else {
	*(fmt++) = *p;
      }
      break;

    case 20:			/* Hmmm. At the start of a width field */
      if (isdigit((int) *p)) {
	*(w++) = *p;
	*(fmt++) = *p;
      } else if (strchr(fmt_codes, *p)) {
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

    case 30:			/* Parsed a width from an argument.  Look for a . */
      if (*p == '.') {
	w = temp;
	*(fmt++) = *p;
	state = 40;
      } else if (strchr(fmt_codes, *p)) {
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
      if (isdigit((int) *p) && (*p != '0')) {
	*(fmt++) = *p;
	*(w++) = *p;
	state = 41;
      } else if (*p == '*') {
	/* Precision field is specified in the format list */
	precval = VA_GET._int;
	sprintf(temp, "%d", precval);
	for (w = temp; *w; w++) {
	  *(fmt++) = *w;
	}
	state = 50;
      } else if (strchr(fmt_codes, *p)) {
	p--;
	state = 100;
      } else {
	*(fmt++) = *p;
	state = 50;
      }
      break;
    case 41:
      if (isdigit((int) *p)) {
	*(fmt++) = *p;
	*(w++) = *p;
      } else if (strchr(fmt_codes, *p)) {
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
      if (strchr(fmt_codes, *p)) {
	p--;
	state = 100;
      } else {
	*(fmt++) = *p;
      }
      break;

      /* Got an encoding header */
    case 60:
      if (*p == '(') {
	++plevel;
	*ec = *p;
	ec++;
      } else if (*p == ')') {
	--plevel;
	if (plevel <= 0) {
	  *ec = 0;
	  state = 10;
	} else {
	  *ec = *p;
	  ec++;
	}
      } else {
	*ec = *p;
	ec++;
      }
      break;
    case 100:
      /* Got a formatting code */
      if (widthval < precval)
	maxwidth = precval;
      else
	maxwidth = widthval;
      if ((*p == 's') || (*p == 'S')) {	/* Null-Terminated string */
        const char *str;
	DOH *Sval;
	DOH *enc = 0;
	str = VA_GET._str;
	/* if (DohCheck(doh)) {
	  // Is a DOH object.
	  if (DohIsString(doh)) {
	    Sval = doh;
	  } else {
	    Sval = Str(doh);
	  }
	  if (strlen(encoder)) {
	    enc = encode(encoder, Sval);
	    maxwidth = maxwidth + strlen(newformat) + Len(enc);
	  } else {
	    maxwidth = maxwidth + strlen(newformat) + Len(Sval);
	  }
	  *(fmt++) = 's';
	  *fmt = 0;
	  if ((maxwidth + 1) < OBUFLEN) {
	    stemp = obuffer;
	  } else {
	    stemp = (char *) malloc(maxwidth + 1);
	  }
	  if (enc) {
	    nbytes += sprintf(stemp, newformat, Data(enc));
	  } else {
	    nbytes += sprintf(stemp, newformat, Data(Sval));
	  }
	  if (Writen(so, stemp, strlen(stemp)) < 0)
	    return -1;
	  if ((DOH *) Sval != doh) {
	    Delete(Sval);
	  }
	  if (enc)
	    Delete(enc);
	  if (*p == 'S') {
	    Delete(doh);
	  }
	  if (stemp != obuffer) {
	    free(stemp);
	  }
	} else */ {
	  //if (!doh)
	  //  doh = (char *) "";

	  if (strlen(encoder)) {
	    //DOH *s = NewString(doh);
	    DOH *s = NewString(str);
	    Seek(s, 0, SEEK_SET);
	    enc = encode(encoder, s);
	    Delete(s);
	    str = Char(enc);
	  } else {
	    enc = 0;
	  }
	  maxwidth = maxwidth + strlen(newformat) + strlen((char *) str);
	  *(fmt++) = 's';
	  *fmt = 0;
	  if ((maxwidth + 1) < OBUFLEN) {
	    stemp = obuffer;
	  } else {
	    stemp = (char *) malloc(maxwidth + 1);
	  }
	  nbytes += sprintf(stemp, newformat, str);
	  if (Writen(so, stemp, strlen(stemp)) < 0)
	    return -1;
	  if (stemp != obuffer) {
	    free(stemp);
	  }
	  if (enc)
	    Delete(enc);
	}
      } else {
	*(fmt++) = *p;
	*fmt = 0;
	maxwidth = maxwidth + strlen(newformat) + 64;

	/* Only allocate a buffer if it is too big to fit.  Shouldn't have to do
	   this very often */

	if (maxwidth < OBUFLEN)
	  stemp = obuffer;
	else
	  stemp = (char *) malloc(maxwidth + 1);
	switch (*p) {
	case 'd':
	case 'i':
	case 'o':
	case 'u':
	case 'x':
	case 'X':
	case 'c':
	  ivalue = VA_GET._int; //va_arg(ap, int);
	  nbytes += sprintf(stemp, newformat, ivalue);
	  break;
	case 'f':
	case 'g':
	case 'e':
	case 'E':
	case 'G':
	  dvalue = VA_GET._double; //va_arg(ap, double);
	  nbytes += sprintf(stemp, newformat, dvalue);
	  break;
	case 'p':
	  pvalue = VA_GET._pointer; //va_arg(ap, void *);
	  nbytes += sprintf(stemp, newformat, pvalue);
	  break;
	default:
	  break;
	}
	if (Writen(so, stemp, strlen(stemp)) < 0)
	  return -1;
	if (stemp != obuffer)
	  free(stemp);
      }
      state = 0;
      break;
    }
    p++;
  }
  if (state) {
    int r;
    *fmt = 0;
    r = Writen(so, fmt, strlen(fmt));
    if (r < 0)
      return -1;
    nbytes += r;
  }
  return nbytes;
}

/* -----------------------------------------------------------------------------
 * DohPrintf()
 *
 * Variable length argument entry point to Printf
 * ----------------------------------------------------------------------------- */

int Printf(DOH *obj, const char *format, VA_DEF) {
  int ret;
  ret = vPrintf(obj, format, VA_CALL);
  return ret;
}

int Printf(FILE *f, const char *format, VA_DEF) {
  int ret;
  String *tmp = NewStringEmpty();
  ret = vPrintf(tmp, format, VA_CALL);
  fprintf(f, tmp->c_str());
  Delete(tmp);
  return ret;
}

/* -----------------------------------------------------------------------------
 * DohPrintv()
 * 
 * Print a null-terminated variable length list of DOH objects
 * ----------------------------------------------------------------------------- */

int Printv(DOH * obj, VA_DEF) {
  int ret = 0;
  const char *str;
  VA_INIT;

  while (1) {
    /* Always assume const char* */
    str = VA_GET._str;
    if ((!str) || (str == DohNone))
      break;
      ret += Write(obj, str, strlen(str));    
  }
  return ret;
}
  
int Printv(FILE * f, VA_DEF) {
  int ret = 0;
  const char *str;
  VA_INIT;

  while (1) {
    /* Always assume const char* */
    str = VA_GET._str;
    if ((!str) || (str == DohNone))
      break;
      ret += fwrite(str, 1, strlen(str), f);
  }
  return ret;
  
}

/* ----------------------------------------------------------------------------- 
 * DohCopyto()
 *
 * Copies all of the input from an input stream to an output stream. Returns the
 * number of bytes copied.
 * ----------------------------------------------------------------------------- */

int DohCopyto(DOH *in, DOH *out) {
  int nbytes = 0, ret;
  int nwrite = 0, wret;
  char *cw;
  char buffer[16384];

  if ((!in) || (!out))
    return 0;
  while (1) {
    ret = Read(in, buffer, 16384);
    if (ret > 0) {
      nwrite = ret;
      cw = buffer;
      while (nwrite) {
	wret = Write(out, cw, nwrite);
	if (wret < 0)
	  return -1;
	nwrite = nwrite - wret;
	cw += wret;
      }
      nbytes += ret;
    } else {
      return nbytes;
    }
  }
}


/* -----------------------------------------------------------------------------
 * DohSplit()
 *
 * Split an input stream into a list of strings delimited by the specified
 * character.  Optionally accepts a maximum number of splits to perform.
 * ----------------------------------------------------------------------------- */

List *Split(DOH *in, char ch, int nsplits) {
  List *list;
  DOH *str;
  int c;

  list = NewList();

  if (DohIsString(in)) {
    Seek(in, 0, SEEK_SET);
  }

  while (1) {
    str = NewStringEmpty();
    do {
      c = Getc(in);
    } while ((c != EOF) && (c == ch));
    if (c != EOF) {
      Putc(c, str);
      while (1) {
	c = Getc(in);
	if ((c == EOF) || ((c == ch) && (nsplits != 0)))
	  break;
	Putc(c, str);
      }
      nsplits--;
    }
    Append(list, str);
    //Delete(str);
    if (c == EOF)
      break;
  }
  return list;
}

/* -----------------------------------------------------------------------------
 * DohSplitLines()
 *
 * Split an input stream into a list of strings delimited by newline characters.
 * ----------------------------------------------------------------------------- */

List *SplitLines(DOH *in) {
  List *list;
  DOH *str;
  int c = 0;

  list = NewList();

  if (DohIsString(in)) {
    Seek(in, 0, SEEK_SET);
  }

  while (c != EOF) {
    str = NewStringEmpty();
    while ((c = Getc(in)) != '\n' && c != EOF) {
      Putc(c, str);
    }
    Append(list, str);
    //Delete(str);
  }
  return list;
}


/* -----------------------------------------------------------------------------
 * DohReadline()
 *
 * Read a single input line and return it as a string.
 * ----------------------------------------------------------------------------- */

DOH *Readline(DOH *in) {
  char c;
  int n = 0;
  DOH *s = NewStringEmpty();
  while (1) {
    if (Read(in, &c, 1) < 0) {
      if (n == 0) {
	Delete(s);
	return 0;
      }
      return s;
    }
    if (c == '\n')
      return s;
    if (c == '\r')
      continue;
    Putc(c, s);
    n++;
  }
}

} /* namespace doh */
