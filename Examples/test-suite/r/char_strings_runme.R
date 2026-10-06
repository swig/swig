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
  ping = paste0("Ping", i) # char[16] buffer, keep short enough to fit
  unittest(CharArrayDimsPingPong(ping), ping)
}

unittest(CharArrayDimsLength("Ping"), 4)
unittest(CharArrayDimsLength("0123456789abcde"), 15)
exception_thrown = FALSE
tryCatch(CharArrayDimsLength("0123456789abcdef"), error = function(e) exception_thrown <<- TRUE)
unittest(exception_thrown, TRUE)

# variables
for (i in 0:(count-1)) {
  expected = paste0(OTHERLAND_MSG, i)
  global_char_set(expected)
  unittest(global_char_get(), expected)
}

# global_char_array1 is a char[] with no size, so it is read only
unittest(exists("global_char_array1_set"), FALSE)
unittest(global_char_array1_get(), CPLUSPLUS_MSG)
for (i in 0:(count-1)) {
  expected = paste0(OTHERLAND_MSG, i)
  global_char_array2_set(expected)
  unittest(global_char_array2_get(), expected)
}
exception_thrown = FALSE
tryCatch(global_char_array2_set(paste0(CPLUSPLUS_MSG, CPLUSPLUS_MSG)), error = function(e) exception_thrown <<- TRUE)
unittest(exception_thrown, TRUE)

no_nul = char_array_no_nul_get()
unittest(no_nul$full, "abcd")
unittest(no_nul$after, "XYZ")

global_char_one_set("a")
unittest(global_char_one_get(), "a")
one = CharArrayOne()
one$one <- "b"
unittest(one$one, "b")

null_message = function(f) {
  msg = ""
  tryCatch(f(), error = function(e) msg <<- conditionMessage(e))
  msg
}
null_member = char_array_null_get()
unittest(grepl("^SWIG:TypeError", null_message(function() CharArrayPingPong(NULL))), TRUE)
unittest(grepl("^SWIG:TypeError", null_message(function() CharArrayDimsPingPong(NULL))), TRUE)
unittest(grepl("^SWIG:TypeError", null_message(function() null_member$four <- NULL)), TRUE)
unittest(grepl("^SWIG:TypeError", null_message(function() global_char_array_null_set(NULL))), TRUE)
unittest(null_member$four, "qqq")
unittest(global_char_array_null_get(), "qqq")

for (i in 0:(count-1)) {
  unittest(global_const_char_get(), CPLUSPLUS_MSG)
}

unittest(global_const_char_array1_get(), CPLUSPLUS_MSG)
unittest(global_const_char_array2_get(), CPLUSPLUS_MSG)

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
