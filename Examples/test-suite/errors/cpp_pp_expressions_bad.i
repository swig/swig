%module xxx
/* Note: needs -Wextra to see these warnings */

/* Spaceship operator doesn't seem to be allowed in preprocessor expressions. */
#if (4 <=> 2) < 0
#endif
