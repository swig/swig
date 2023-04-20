%module xxx

/* Before SWIG 4.1.0 the `9%a` expression triggered:
 *
 * Error: Unknown directive '%a'
 *
 * The fix for that works by handling an apparent directive that isn't a
 * recognised directive by noting down its name, emitting MODULO and then
 * rescanning what follows, and if the parser then gives a syntax error we
 * report it as an unknown directive.
 *
 * However the initial version of this failed to reset the noted down apparent
 * directive often enough, so a later syntax error could get incorrectly
 * reported.  Here the syntax error in the declaration of `c` was confusingly
 * reported as `Error: Unknown directive '%a'`.  This was found and fixed prior
 * to 4.1.0.
 */
int a;
int test2(int b = 9%a) { return b; }
void int c;
