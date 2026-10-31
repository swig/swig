clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("typedef_funcptr", .Platform$dynlib.ext, sep=""))
source("typedef_funcptr.R")
cacheMetaData(1)

# C function pointers
unittest(do_op(10, 3, get_op(0)), 13)
unittest(do_op(10, 3, get_op(1)), 7)
unittest(do_op_typedef_int(10, 3, get_op_typedef_int(1)), 7)
unittest(do_op_typedef_Integer(10, 3, get_op(0)), 13)
unittest(do_name(1, get_name_op()), "one")
unittest(do_name_typedef(2, get_name_op()), "many")

# R functions
unittest(do_op(10, 3, function(x, y) as.integer(x * y)), 30)
unittest(do_op_typedef_int(10, 3, function(x, y) as.integer(x - y)), 7)
unittest(do_op_typedef_Integer(10, 3, function(x, y) as.integer(x + y)), 13)
unittest(do_name(1, function(i) "one"), "one")
unittest(do_name_typedef(1, function(i) "one"), "one")

# A 'char *' returned by an R function is a copy that can be modified
name <- paste0("abc", "def")
unittest(do_name_modify(1, function(i) name), "Nbcdef")
unittest(name, "abcdef")
