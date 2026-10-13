clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("cpp11_rvalue_reference_array", .Platform$dynlib.ext, sep=""))
source("cpp11_rvalue_reference_array.R")
cacheMetaData(1)

# TODO: the R module does not define the classes for the pointers to arrays returned by the address functions
setClass("_p_a_4__int", contains = "ExternalReference")
setClass("_p_a___int", contains = "ExternalReference")
setClass("_p_a_2__RvalueRefArrayItem", contains = "ExternalReference")

# An rvalue reference to an array is passed as a reference to an array, which cannot be NULL
unittest(sum_of(others_address()), 100)
unittest(first_of(others_unsized_address()), 10)
unittest(items_sum(items_address()), 3)
unittest(grepl("^SWIG:NullReferenceError", error_message(function() sum_of(NULL))), TRUE)
unittest(grepl("^SWIG:NullReferenceError", error_message(function() first_of(NULL))), TRUE)

# An rvalue reference to an array of char is a string
unittest(length_of("abc"), 3)
unittest(length_of_writable("xy"), 2)
unittest(grepl("^SWIG:NullReferenceError", error_message(function() length_of(NULL))), TRUE)

# Setting a variable that is an rvalue reference to an array copies into the array it refers to
unittest(numbers_sum(), 10)
numbers_rref_set(others_address())
unittest(numbers_sum(), 100)
unittest(letters_rref_get(), "abc")
letters_rref_set("xy")
unittest(letters_are(), "xy")

member <- RvalueRefArrayMember()
unittest(member$sum(), 10)
member$member_rref <- others_address()
unittest(member$sum(), 100)
unittest(member$text_rref, "hi")
member$text_rref <- "bye"
unittest(member$text_is(), "bye")

q(save="no")
