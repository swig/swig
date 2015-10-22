clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))
nn <- "enum_thorough"
shared <- paste(nn, .Platform$dynlib.ext, sep="")
rfile <- paste(nn, ".R", sep="")
dyn.load(shared)
source(rfile)

red <- enumToInteger("red", "colour")
blue <- enumToInteger("blue", "colour")
green <- enumToInteger("green", "colour")

unittest(c(red, blue, green), c(-1, 0, 10))

slow <- enumToInteger("slow", "SpeedClass_speed")
medium <- enumToInteger("medium", "SpeedClass_speed")
fast <- enumToInteger("fast", "SpeedClass_speed")
lightning <- enumToInteger("lightning", "SpeedClass_speed")

unittest(c(slow, medium, fast, lighting), c(10, 20, 30, 31))

one <- enumToInteger("one", "RepeatSpace_repeat")
initial <- enumToInteger("initial", "RepeatSpace_repeat")
two <- enumToInteger("two", "RepeatSpace_repeat")
three <- enumToInteger("three", "RepeatSpace_repeat")
llast <- enumToInteger("llast", "RepeatSpace_repeat")
end <- enumToInteger("end", "RepeatSpace_repeat")

unittest(c(one, initial, two, three, llast, end), c(1, 1, 2, 3, 3, 3))
