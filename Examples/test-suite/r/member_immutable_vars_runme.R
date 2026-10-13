clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("member_immutable_vars", .Platform$dynlib.ext, sep=""))
source("member_immutable_vars.R")
cacheMetaData(1)

v <- ImmutableVars()
v$mutable_var <- 80
unittest(v$mutable_var, 80)
unittest(grepl("read only", error_message(function() v$specific_immutable_var <- 81)), TRUE)
unittest(v$specific_immutable_var, 41)
unittest(grepl("read only", error_message(function() v$const_var <- 82)), TRUE)
unittest(grepl("read only", error_message(function() v[["const_var"]] <- 82)), TRUE)
unittest(v$const_var, 42)

# A name that is not a member variable cannot be set and reads as NULL
unittest(grepl("not a member variable", error_message(function() v$not_a_member <- 1)), TRUE)
unittest(is.null(v$not_a_member), TRUE)

d <- DerivedImmutableVars()
d$derived_mutable_var <- 83
unittest(d$derived_mutable_var, 83)
d$mutable_var <- 84
unittest(d$mutable_var, 84)
d[["mutable_var"]] <- 85
unittest(d$mutable_var, 85)
unittest(grepl("read only", error_message(function() d$specific_immutable_var <- 86)), TRUE)
unittest(d$specific_immutable_var, 41)

q(save="no")
