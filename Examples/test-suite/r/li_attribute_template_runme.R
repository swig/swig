clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))
#source("unittest.R")

dyn.load(paste("li_attribute_template", .Platform$dynlib.ext, sep=""))
source("li_attribute_template.R")
cacheMetaData(1)


# Check usage of template attributes
chell = Cintint(1, 2, 3)

# Testing primitive by value attribute
unittest(chell$a, 1)

chell$a = 3
unittest(chell$a, 3)

# Testing primitive by ref attribute
unittest(chell$b, 2)

chell$b = 5
unittest(chell$b, 5)

# Testing string
chell$str = "abc"
unittest(chell$str, "abc")

# Testing class by value
unittest(chell$d$value, 1)

chell$d = Foo(2)
unittest(chell$d$value, 2)

# Testing class by reference
unittest(chell$e$value, 2)

chell$e = Foo(3)
unittest(chell$e$value, 3)

chell$e$value = 4
unittest(chell$e$value, 4)


# Testing moderately complex template by value
unittest(chell$f$first, 1)
unittest(chell$f$second, 2)

pair = pair_intint(3, 4)
chell$f = pair
unittest(chell$f$first, 3)
unittest(chell$f$second, 4)

# Testing moderately complex template by ref
unittest(chell$g$first, 2)
unittest(chell$g$second, 3)

pair = pair_intint(4, 5)
chell$g = pair
unittest(chell$g$first, 4)
unittest(chell$g$second, 5)

chell$g$first = 6
chell$g$second = 7
unittest(chell$g$first, 6)
unittest(chell$g$second, 7)

q(save="no")
