clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))
dyn.load(paste("argcargvtest", .Platform$dynlib.ext, sep=""))
source("argcargvtest.R")
cacheMetaData(1)

largs = c("hi", "hola", "hello")
unittest(3, mainc(largs))

targs = c("hi", "hola")
unittest("hi", mainv(targs, 0))
unittest("hola", mainv(targs, 1))
unittest("<<NULL>>", mainv(targs, 2))

# R convert the string to a string vector with a single string.
# So instead of exception we simply get null
unittest(NULL, mainv("hello", 1))

tryCatch({
    mainv(c(1, 2, 3), 1)
    # force an error if the previous line doesn't raise an exception
    stop("Test Failure A")
}, error = function(e) {
    if (e$message == "Test Failure A") {
      # Raise the error again to cause a failed test
      stop(e)
    }
    message("PASS")
})

initializeApp(largs)
initializeApp(largs, TRUE)

# Check that an empty array works.
empty_args = c()
unittest(0, mainc(empty_args))
unittest("<<NULL>>", mainv(empty_args, 0))

# check dispatcher with empty array.
initializeApp(empty_args)
initializeApp(empty_args, FALSE, TRUE)

# Check that empty strings are handled.
empty_string = c("hello", "", "world")
unittest(3, mainc(empty_string))
unittest("hello", mainv(empty_string, 0))
unittest("", mainv(empty_string, 1))
unittest("world", mainv(empty_string, 2))
unittest("<<NULL>>", mainv(empty_string, 3))
