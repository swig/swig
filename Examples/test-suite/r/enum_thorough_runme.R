clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))
nn <- "enum_thorough"
shared <- paste(nn, .Platform$dynlib.ext, sep="")
rfile <- paste(nn, ".R", sep="")
dyn.load(shared)
source(rfile)

red <- enumToInteger("red", "_colour")
blue <- enumToInteger("blue", "_colour")
green <- enumToInteger("green", "_colour")

unittest(c(red, blue, green), c(-1, 0, 10))

slow <- enumToInteger("slow", "_SpeedClass__speed")
medium <- enumToInteger("medium", "_SpeedClass__speed")
fast <- enumToInteger("fast", "_SpeedClass__speed")
lightning <- enumToInteger("lightning", "_SpeedClass__speed")

unittest(c(slow, medium, fast, lightning), c(10, 20, 30, 31))

one <- enumToInteger("one", "_RepeatSpace__repeat")
initial <- enumToInteger("initial", "_RepeatSpace__repeat")
two <- enumToInteger("two", "_RepeatSpace__repeat")
three <- enumToInteger("three", "_RepeatSpace__repeat")
llast <- enumToInteger("llast", "_RepeatSpace__repeat")
end <- enumToInteger("end", "_RepeatSpace__repeat")

unittest(c(one, initial, two, three, llast, end), c(1, 1, 2, 3, 3, 3))
