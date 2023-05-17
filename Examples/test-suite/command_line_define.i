%module command_line_define

// Test handling of -D without a value specified.

#if FOO-0 != 1
# error "-DFOO didn't set FOO to 1"
#endif

// Test handling of -D with a value specified

#if BAR-0 != 123
# error "-DBAR=123 didn't set BAR to 123"
#endif

// Test handling of -U

#ifdef BAZ
# error "-UBAZ didn't undefine BAZ"
#endif

#ifdef NOTSET
# error "-UNOTSET resulted in NOTSET getting set!"
#endif
