/* ports.i --- Guile typemaps for handling ports -*- c -*-
   Copyright (C) 2000 Matthias Koeppe <mkoeppe@mail.math.uni-magdeburg.de>

   $Header$
*/

%{
  #ifndef _POSIX_SOURCE
  /* This is needed on Solaris for fdopen(). */
  #  define _POSIX_SOURCE 199506L
  #endif
  #include <stdio.h>
  #include <errno.h>
%}

/* Feed FILE * arguments from file ports */

%typemap(guile, in) FILE *
{
  if(!(SCM_FPORTP($source)))
    scm_wrong_type_arg("$name", $argnum, $source);
  else {
    int fd;
    if (SCM_OUTPUT_PORT_P($source))
      scm_force_output($source);
    fd=dup(SCM_FPORT_FDES($source));
    if(fd==-1) 
      scm_misc_error("$name", strerror(errno), SCM_EOL);
    $target=fdopen(fd,
		   SCM_OUTPUT_PORT_P($source)
		   ? (SCM_INPUT_PORT_P($source)
		      ? "rw" : "w")
		   : "r");
    if($target==NULL)
      scm_misc_error("$name", strerror(errno), SCM_EOL);
  }
}

%typemap(guile, indoc) FILE * "($arg <port>)";

%typemap(guile, freearg) FILE* {
  fclose($target);
}

