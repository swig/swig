%module xxx

// Testing is_digits detecting gcc linemarkers

// These are valid
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 123 "header1.h"

// These are invalid
#a1 'a.h'
#1b 'b.h'
#1c1 'c.h'
#d1d 'd.h'

