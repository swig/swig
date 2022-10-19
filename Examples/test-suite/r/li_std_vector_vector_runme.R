clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("li_std_vector_vector", .Platform$dynlib.ext, sep=""))
source("li_std_vector_vector.R")
cacheMetaData(1)

v = make_vector_int()
unittest_sequence(v, list(1, 2, 3, 4, 5))
v = make_vector_vector_int()
unittest(length(v), 1)
unittest_sequence(v[[1]], list(1, 2, 3, 4, 5))

v = make_vector_bool()
unittest_sequence(v, list(TRUE, FALSE, FALSE, FALSE, TRUE))
print(v)
v = make_vector_vector_bool()
unittest(length(v), 1)
print(v)
unittest_sequence(v[[1]], list(FALSE, TRUE, TRUE, TRUE, FALSE)) # Does not actually fail if no match, arg, needs fixing

v = make_vector_string()
unittest_sequence(v, list("aa", "bb", "cc", "dd", "ee"))
v = make_vector_vector_string()
unittest(length(v), 1)
unittest_sequence(v[[1]], list("1", "2", "3", "4", "5"))

q(save="no")
