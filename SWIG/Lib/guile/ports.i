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
  #include <unistd.h>
%}

/* Feed temporary FILE * arguments from file ports */

%typemap(in, doc="$NAME is a port") FILE *
{
  if(!(SCM_FPORTP($input)))
    scm_wrong_type_arg("$name", $argnum, $input);
  else {
    int fd;
    if (SCM_OUTPUT_PORT_P($input))
      scm_force_output($input);
    fd=dup(SCM_FPORT_FDES($input));
    if(fd==-1) 
      scm_misc_error("$name", strerror(errno), SCM_EOL);
    $1=fdopen(fd,
		   SCM_OUTPUT_PORT_P($input)
		   ? (SCM_INPUT_PORT_P($input)
		      ? "rw" : "w")
		   : "r");
    if($1==NULL)
      scm_misc_error("$name", strerror(errno), SCM_EOL);
  }
}

%typemap(freearg) FILE* {
  fclose($1);
}

