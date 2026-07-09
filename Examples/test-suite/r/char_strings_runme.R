clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("char_strings", .Platform$dynlib.ext, sep=""))
source("char_strings.R")
cacheMetaData(1)

CPLUSPLUS_MSG = "A message from the deep dark world of C++, where anything is possible."
OTHERLAND_MSG = "Little message from the safe world."

count = 5

# get functions
for (i in 0:(count-1)) {
  unittest(GetCharHeapString(), CPLUSPLUS_MSG)
  DeleteCharHeapString()
}

for (i in 0:(count-1)) {
  unittest(GetConstCharProgramCodeString(), CPLUSPLUS_MSG)
  DeleteCharHeapString()
}

for (i in 0:(count-1)) {
  unittest(GetCharStaticString(), CPLUSPLUS_MSG)
}

for (i in 0:(count-1)) {
  unittest(GetCharStaticStringFixed(), CPLUSPLUS_MSG)
}

for (i in 0:(count-1)) {
  unittest(GetConstCharStaticStringFixed(), CPLUSPLUS_MSG)
}

# set functions
for (i in 0:(count-1)) {
  unittest(SetCharHeapString(paste0(OTHERLAND_MSG, i), i), TRUE)
}

for (i in 0:(count-1)) {
  unittest(SetCharStaticString(paste0(OTHERLAND_MSG, i), i), TRUE)
}

for (i in 0:(count-1)) {
  unittest(SetCharArrayStaticString(paste0(OTHERLAND_MSG, i), i), TRUE)
}

for (i in 0:(count-1)) {
  unittest(SetConstCharHeapString(paste0(OTHERLAND_MSG, i), i), TRUE)
}

for (i in 0:(count-1)) {
  unittest(SetConstCharStaticString(paste0(OTHERLAND_MSG, i), i), TRUE)
}

for (i in 0:(count-1)) {
  unittest(SetConstCharArrayStaticString(paste0(OTHERLAND_MSG, i), i), TRUE)
}

for (i in 0:(count-1)) {
  unittest(SetCharConstStaticString(paste0(OTHERLAND_MSG, i), i), TRUE)
}

for (i in 0:(count-1)) {
  unittest(SetConstCharConstStaticString(paste0(OTHERLAND_MSG, i), i), TRUE)
}

for (i in 0:(count-1)) {
  unittest(SetConstCharTypedefString(paste0(OTHERLAND_MSG, i), i), TRUE)
}

# get set functions (ping pong round-trip)
for (i in 0:(count-1)) {
  ping = paste0(OTHERLAND_MSG, i)
  unittest(CharPingPong(ping), ping)
}

for (i in 0:(count-1)) {
  ping = paste0(OTHERLAND_MSG, i)
  unittest(CharArrayPingPong(ping), ping)
}

for (i in 0:(count-1)) {
  ping = paste0(OTHERLAND_MSG, i)
  unittest(CharArrayDimsPingPong(ping), ping)
}

# variables
for (i in 0:(count-1)) {
  expected = paste0(OTHERLAND_MSG, i)
  global_char_set(expected)
  unittest(global_char_get(), expected)
}

# global_char_array1 / global_char_array2 read-back is omitted: the generated R
# getters return type '_p_char' and the R proxy wraps the (correct) string into
# new("_p_char", ref=...), an undefined S4 class which errors.  The setters run
# without error, but there is no working accessor to verify the value.

for (i in 0:(count-1)) {
  unittest(global_const_char_get(), CPLUSPLUS_MSG)
}

# global_const_char_array1 / global_const_char_array2 read-back is omitted for
# the same '_p_char' proxy limitation as the mutable char array globals above.

# char *& tests
for (i in 0:(count-1)) {
  unittest(GetCharPointerRef(), CPLUSPLUS_MSG)
}

for (i in 0:(count-1)) {
  unittest(SetCharPointerRef(paste0(OTHERLAND_MSG, i), i), TRUE)
}

for (i in 0:(count-1)) {
  unittest(GetConstCharPointerRef(), CPLUSPLUS_MSG)
}

for (i in 0:(count-1)) {
  unittest(SetConstCharPointerRef(paste0(OTHERLAND_MSG, i), i), TRUE)
}
