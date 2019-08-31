clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("abstract_access", .Platform$dynlib.ext, sep=""))
source("abstract_access.R")

dd <- D()
unittest(1, dd$z())
unittest(1, dd$do_x())

## Original version allowed dd$z <- 2
tryCatch({
    dd$z <- 2
    # force an error if the previous line doesn't raise an exception
    stop("Test Failure A")
}, error = function(e) {
    if (e$message == "Test Failure A") {
      # Raise the error again to cause a failed test
      stop(e)
    }
    message("Correct - no dollar assignment method found")
}
)

tryCatch({
    dd[["z"]] <- 2
    # force an error if the previous line doesn't raise an exception
    stop("Test Failure B")
}, error = function(e) {
  if (e$message == "Test Failure B") {
    # Raise the error again to cause a failed test
    stop(e)
  }
  message("Correct - no dollar assignment method found")
}
)

## The methods are attached to the parent class - see if we can get
## them
tryCatch({
    m1 <- getMethod('$', "_p_A")
}, error = function(e) {
    stop("No $ method found - there should be one")
}
)

## These methods should not be present
## They correspond to the tests that are expected
## to fail above.
tryCatch({
    m2 <- getMethod('$<-', "_p_A")
    # force an error if the previous line doesn't raise an exception
    stop("Test Failure C")
}, error = function(e) {
  if (e$message == "Test Failure C") {
    # Raise the error again to cause a failed test
    stop(e)
  }
  message("Correct - no dollar assignment method found")
}
)

tryCatch({
    m3 <- getMethod('[[<-', "_p_A")
    # force an error if the previous line doesn't raise an exception
    stop("Test Failure D")
}, error = function(e) {
  if (e$message == "Test Failure D") {
    # Raise the error again to cause a failed test
    stop(e)
  }
  message("Correct - no list assignment method found")
}
)
