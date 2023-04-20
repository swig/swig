%module command_line_define

// Test handling of -D without a value specified.

#if FOO-0 != 1
# error "-DFOO didn't set FOO to 1"
#endif
