%module xxx

/* This used to give the rather cryptic "Syntax error in input(1)." prior to
 * SWIG 3.0.4.  This testcase checks that the improved message is actually
 * issued.
 */
%remane("typo") tyop;
