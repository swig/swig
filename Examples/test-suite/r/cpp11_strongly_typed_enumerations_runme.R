clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("cpp11_strongly_typed_enumerations", .Platform$dynlib.ext, sep=""))
source("cpp11_strongly_typed_enumerations.R")
cacheMetaData(1)

# Check integer values of strongly typed enum values
unittest(0, enumToInteger("Val1", "_Enum1"))
unittest(1, enumToInteger("Val2", "_Enum1"))
unittest(13, enumToInteger("Val3", "_Enum1"))
unittest(14, enumToInteger("Val4", "_Enum1"))

unittest(23, enumToInteger("Val3", "_Enum2"))
unittest(43, enumToInteger("Val3", "_Enum4"))
unittest(53, enumToInteger("Val3", "_Enum5"))
unittest(63, enumToInteger("Val3", "_Enum6"))
unittest(73, enumToInteger("Val3", "_Enum7"))
unittest(83, enumToInteger("Val3", "_Enum8"))
unittest(0, enumToInteger("Val1", "_Enum9"))

unittest(1151, enumToInteger("Val1", "_Enum15"))
unittest(1161, enumToInteger("Val1", "_Enum16"))
unittest(1171, enumToInteger("Val1", "_Enum17"))

# Test class-scoped strongly typed enums
unittest(1121, enumToInteger("Val1", "_Class1__Enum12"))
unittest(1131, enumToInteger("Val1", "_Class1__Enum13"))
unittest(1141, enumToInteger("Val1", "_Class1__Enum14"))

# Test enum class with %rename of the enum (QEnum18 -> Enum18) and an
# enumerator (QVal1 -> Val1); both are honoured in the R layer.
unittest(1181, enumToInteger("Val1", "_Enum18"))
unittest(1182, enumToInteger("Val2", "_Enum18"))
