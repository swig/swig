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

slow <- enumToInteger("slow", "_SpeedClass_speed")
medium <- enumToInteger("medium", "_SpeedClass_speed")
fast <- enumToInteger("fast", "_SpeedClass_speed")
lightning <- enumToInteger("lightning", "_SpeedClass_speed")

unittest(c(slow, medium, fast, lightning), c(10, 20, 30, 31))

one <- enumToInteger("one", "_RepeatSpace_repeat")
initial <- enumToInteger("initial", "_RepeatSpace_repeat")
two <- enumToInteger("two", "_RepeatSpace_repeat")
three <- enumToInteger("three", "_RepeatSpace_repeat")
llast <- enumToInteger("llast", "_RepeatSpace_repeat")
end <- enumToInteger("end", "_RepeatSpace_repeat")

unittest(c(one, initial, two, three, llast, end), c(1, 1, 2, 3, 3, 3))
