%module xxx

#warning Print this warning

#error This is an error

#error Another error

#warning Another warning

/* Regression tests for #657 */
#error Test it's OK to use an apostrophe
#warning An unmatched " should be OK too
