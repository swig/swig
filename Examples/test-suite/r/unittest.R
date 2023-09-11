unittest <- function (x,y) {
  if (all(x==y)) {
    print("PASS")
  } else {
    print("FAIL")
    print(paste(x, " != ", y))
    stop("Test failed")
  }
}

unittesttol <- function(x,y,z) {
  if (all(abs(x-y) < z)) {
    print("PASS")
  } else {
    print("FAIL")
    stop("Test failed")
  }
}

unittest_sequence <- function (x,y) {
  x = as.vector(x)
  y = as.vector(y)
  
  if (length(x) == 0 && length(y) == 0) {
    print("PASS")
    return()
  }
  
  if (class(x[1]) != class(y[1])) {
    print("FAILED")
    stop(paste("Test failed: ", class(x[1]), " != ", class(y[1])))
  }
  
  try(expr = {
    if (!any(x != y)) {
      print("PASS")
      return()
    }
  }, silent = T)
  
  print("FAIL")
  stop("Test failed")
}
