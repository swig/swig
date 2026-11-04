clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("li_constraints", .Platform$dynlib.ext, sep=""))
source("li_constraints.R")
cacheMetaData(1)

check_double <- function(valid, f, name, val) {
  msg <- error_message(function() f(val))
  if (valid) {
    unittest(msg, "")
  } else {
    unittest(grepl(paste0("Expected a ", name, " value."), msg, fixed=TRUE), TRUE)
  }
}

check_double(TRUE, test_nonnegative, "non-negative", 10)
check_double(TRUE, test_nonnegative, "non-negative", 0)
check_double(FALSE, test_nonnegative, "non-negative", -10)

check_double(FALSE, test_nonpositive, "non-positive", 10)
check_double(TRUE, test_nonpositive, "non-positive", 0)
check_double(TRUE, test_nonpositive, "non-positive", -10)

check_double(TRUE, test_positive, "positive", 10)
check_double(FALSE, test_positive, "positive", 0)
check_double(FALSE, test_positive, "positive", -10)

check_double(FALSE, test_negative, "negative", 10)
check_double(FALSE, test_negative, "negative", 0)
check_double(TRUE, test_negative, "negative", -10)

check_double(TRUE, test_nonzero, "nonzero", 10)
check_double(FALSE, test_nonzero, "nonzero", 0)
check_double(TRUE, test_nonzero, "nonzero", -10)

unittest(grepl("Received a NULL pointer.", error_message(function() test_nonnull(NULL)), fixed=TRUE), TRUE)
unittest(error_message(function() test_nonnull(get_nonnull())), "")
