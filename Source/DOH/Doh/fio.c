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

/* -----------------------------------------------------------------------------
 * fio.c
 *
 * Support for formatted I/O via fprintf, fscanf.
 * ----------------------------------------------------------------------------- */

#define OBUFLEN  512
/* -----------------------------------------------------------------------------
 * DohvPrintf(DOH *so, char *format, va_list ap)
 *
 * printf
 * ----------------------------------------------------------------------------- */

int
DohvPrintf(DOH *so, char *format, va_list ap)
{
  static char *fmt_codes = "dioxXucsSfeEgGpn";
  int state = 0;
  char *p = format;
  char  newformat[256];
  char  obuffer[OBUFLEN];
  char *fmt;
  char  temp[64];
  int   widthval = 0;
  int   precval = 0;
  int   maxwidth;
  char  *w, *prec;
  int   ivalue;
  int   dvalue;
  void  *pvalue;
  char  *stemp;
  int   nbytes = 0;

  while (*p) {
    switch(state) {
    case 0:  /* Ordinary text */
      if (*p != '%') {
	Putc(*p,so);
	nbytes++;
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
	Putc(*p,so);
	fmt = newformat;
	nbytes++;
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
	DOH    *Sval;
	doh = va_arg(ap, DOH *);
	if (DohCheck(doh)) {
	  /* Is a DOH object. */
	  if (String_check(doh)) {
	    Sval = doh;
	  } else {
	    Sval = Str(doh);
	  }
	  maxwidth = maxwidth+strlen(newformat)+Len(Sval);
	  *(fmt++) = 's';
	  *fmt = 0;
	  if ((maxwidth + 1) < OBUFLEN) {
	    stemp = obuffer;
	  } else {
	    stemp = (char *) malloc(maxwidth+1);
	  }
	  nbytes+=sprintf(stemp,newformat,Data(Sval));
	  Write(so,stemp,strlen(stemp));
	  if ((DOH *) Sval != doh) {
	    Delete(Sval);
	  }
	  if (*p == 'S') {
	    Delete(doh);
	  }
	  if (stemp != obuffer) {
	    free(stemp);
	  }
	} else {
	  maxwidth = maxwidth+strlen(newformat)+strlen((char *) doh);
	  *(fmt++) = 's';
	  *fmt = 0;
	  if ((maxwidth+1) < OBUFLEN) {
	    stemp = obuffer;
	  } else {
	    stemp = (char *) malloc(maxwidth + 1);
	  }
	  nbytes+=sprintf(stemp,newformat,doh);
	  Write(so,stemp,strlen(stemp));
	  if (stemp != obuffer) {
	    free(stemp);
	  }
	}
      } else {
	*(fmt++) = *p;
	*fmt = 0;
	maxwidth = maxwidth+strlen(newformat)+64;
	
	/* Only allocate a buffer if it is too big to fit.  Shouldn't have to do
           this very often */

	if (maxwidth < OBUFLEN)
	  stemp = obuffer;
	else 
	  stemp = (char *) malloc(maxwidth+1);
	switch(*p) {
	case 'd':
	case 'i':
	case 'o':
	case 'u':
	case 'x':
	case 'X':
	case 'c':
	  ivalue = va_arg(ap,int);
	  nbytes+=sprintf(stemp,newformat,ivalue);
	  break;
	case 'f':
	case 'g':
	case 'e':
	case 'E':
	case 'G':
	  dvalue = va_arg(ap,double);
	  nbytes+=sprintf(stemp,newformat,dvalue);
	  break;
	case 'p':
	  pvalue = va_arg(ap,void *);
	  nbytes+=sprintf(stemp,newformat,pvalue);	  
	  break;
	default:
	  break;
	}
	Write(so,stemp,strlen(stemp));
	if (stemp != obuffer) free(stemp);
      }
      state = 0;
      break;
    }
    p++;
  }
  if (state) {
    *fmt = 0;
    nbytes += Write(so,fmt,strlen(fmt));
  }
  return nbytes;
}

/* Printf */
int DohPrintf(DOH *obj, char *format, ...) {
  va_list ap;
  int ret;
  va_start(ap,format);
  ret = DohvPrintf(obj,format,ap);
  va_end(ap);
  return ret;
}

/* Split by a character */

DOH *DohSplit(DOH *in, char *chs, int nsplits) {
  DOH *list;
  DOH *str;
  int c;
  
  list = NewList();
  if (String_check(in)) {
    Seek(in,0,SEEK_SET);
  }
  while (1) {
    do {
      c = Getc(in);
    } while ((c != EOF) && (c == *chs));
    if (c != EOF) {
      str = NewString("");
      Putc(c,str);
      while (1) {
	c = Getc(in);
	if ((c == EOF) || ((c == *chs) && (nsplits != 0))) break;
	Putc(c,str);
      }
      Append(list,str);
      nsplits--;
    }
    if (c == EOF) break;
  }
  return list;
}
