//
// $Header$
//
// timers.i
// A SWIG file for adding various timing functions. 
// Really, this is modeled after the timers in the CMMD
// message passing library for the CM-5.
// 
// Dave Beazley
// April 2, 1996
//
/* Revision history 
 * $Log$
 * Revision 1.1.4.1  2002/05/23 21:48:55  beazley
 * cleanup
 *
 * Revision 1.1  2000/01/11 21:15:49  beazley
 * Added files
 *
 * Revision 1.1.1.1  1999/02/28 02:00:53  beazley
 * Swig1.1
 *
 * Revision 1.1  1996/05/22 17:27:01  beazley
 * Initial revision
 *
 */

%module timers
%{

#include <time.h>
#define  SWIG_NTIMERS     64

static clock_t  telapsed[SWIG_NTIMERS];
static clock_t  tstart[SWIG_NTIMERS];
static clock_t  tend[SWIG_NTIMERS];

/*-----------------------------------------------------------------
 * SWIG_timer_clear(int i)
 *
 * Clears timer i.
 *----------------------------------------------------------------- */

static void
SWIG_timer_clear(int i)
{
  if ((i >= 0) && (i < SWIG_NTIMERS))
   telapsed[i] = 0;
}


/*-----------------------------------------------------------------
 * SWIG_timer_start(int i)
 *
 * Starts timer i
 *----------------------------------------------------------------- */

static void
SWIG_timer_start(int i)
{
  if ((i >= 0) && (i < SWIG_NTIMERS))
    tstart[i] = clock();
}


/*-----------------------------------------------------------------
 * SWIG_timer_stop(int i)
 *
 * Stops timer i and accumulates elapsed time
 *----------------------------------------------------------------- */

static void
SWIG_timer_stop(int i)
{
  if ((i >= 0) && (i < SWIG_NTIMERS)) {
    tend[i] = clock();
    telapsed[i] += (tend[i] - tstart[i]);
  }
}

/*-----------------------------------------------------------------
 * SWIG_timer_elapsed(int i)
 *
 * Returns the time elapsed on timer i in seconds.
 *----------------------------------------------------------------- */

static double
SWIG_timer_elapsed(int i)
{
  double   t;
  if ((i >= 0) && (i < SWIG_NTIMERS)) {
    t = (double) telapsed[i]/(double) CLOCKS_PER_SEC;
    return(t);
  } else {
    return 0;
  }
}

%}

/*

This module provides a collection of timing functions designed for
performance analysis and benchmarking of different code fragments. 

A total of 64 different timers are available.   Each timer can be
managed independently using four functions :

    timer_clear(int n)          Clears timer n
    timer_start(int n)          Start timer n
    timer_stop(int n)           Stop timer n
    timer_elapsed(int n)        Return elapsed time (in seconds)

All timers measure CPU time.

Since each timer can be accessed independently, it is possible
to use groups of timers for measuring different aspects of code
performance.   To use a timer, simply use code like this :

      timer_clear(0)
      timer_start(0)
      ... a bunch of code ...
      timer_stop(0)
      print timer_elapsed(0)," seconds of CPU time"

A single timer can be stopped and started repeatedly to provide
a cummulative timing effect.

As a general performance note, making frequent calls to the timing
functions can severely degrade performance (due to operating system
overhead).   The resolution of the timers may be poor for extremely
short code fragments.   Therefore, the timers work best for
computationally intensive operations.
*/


%name(timer_clear)   void SWIG_timer_clear(int n);   
/* Clears timer n. */

%name(timer_start)   void SWIG_timer_start(int n);   
/* Starts timer n. */

%name(timer_stop)    void SWIG_timer_stop(int n);    
/* Stops timer n. */

%name(timer_elapsed) double SWIG_timer_elapsed(int n); 
/* Return the elapsed time (in seconds) of timer n */




