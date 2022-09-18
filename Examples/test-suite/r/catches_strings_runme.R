clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("catches_strings", .Platform$dynlib.ext, sep=""))
source("catches_strings.R")
cacheMetaData(1)

exception_thrown = FALSE
tryCatch({
    StringsThrower_charstring()
}, error = function(e) {
    exception_thrown <<- grepl(e$message, "charstring message", fixed=TRUE)
}
)
unittest(exception_thrown, TRUE)

exception_thrown = FALSE
tryCatch({
    StringsThrower_stdstring()
}, error = function(e) {
    exception_thrown <<- grepl(e$message, "stdstring message", fixed=TRUE)
}
)
unittest(exception_thrown, TRUE)
