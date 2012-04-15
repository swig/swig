source("unittest.R")
dyn.load(paste("r_base_test", .Platform$dynlib.ext, sep=""))
source("r_base_test.R")
cacheMetaData(1)

b <- Base()
Base_method(b)
Base_overloaded_method(b)
Base_overloaded_method(b, 43)
Base_overloaded_method(b)
b$method()

b$overloaded_method()
