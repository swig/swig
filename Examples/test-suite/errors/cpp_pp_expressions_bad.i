%module xxx


/* Spaceship operator doesn't seem to be allowed in preprocessor expressions. */
#if (4 <=> 2) < 0
#endif
