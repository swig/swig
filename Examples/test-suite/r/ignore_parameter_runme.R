clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("ignore_parameter", .Platform$dynlib.ext, sep=""))
source("ignore_parameter.R")
cacheMetaData(1)

# A function with parameter bb returns a list with the result first, as bb has an argout typemap
unittest(jaguar(200, 0), "hello")
unittest(lotus("foo", 1)[[1]], 101)
unittest(tvr("bar", 2), 8.8)
unittest(ferrari()[[1]], 101)
unittest(called_argout_get(), 1)
unittest(called_freearg_get(), 1)
unittest(fiat(17), 17)
unittest(peugeot(), 5)

car <- SportsCars()
unittest(car$daimler(200, 0), "hello")
unittest(car$astonmartin("foo", 1)[[1]], 101)
unittest(car$bugatti("bar", 2), 8.8)
unittest(car$lamborghini()[[1]], 101)
unittest(car$maseratti(289), 289)
unittest(car$audi(), 8.8)

MiniCooper(200, 0)
MorrisMinor("baz", 0)
FordAnglia("quux", 200)
AustinAllegro()

q(save="no")
