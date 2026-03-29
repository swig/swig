clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("li_cpointer_dynamic_cast", .Platform$dynlib.ext, sep=""))
source("li_cpointer_dynamic_cast.R")

checknotnull <- function (x,m) {
  if (identical(x, NULL)) {
    print("FAIL")
    print(paste(x, " == NULL"))
    stop("Test failed")
  } else {
    print("PASS")
  }
}
checknull <- function (x,m) {
  if (identical(x, NULL)) {
    print("PASS")
  } else {
    print("FAIL")
    print(paste(x, " == NULL"))
    stop("Test failed")
  }
}

# Get a Derived object using a Base pointer
base_point_derived = Derived_NewDerived()
unittest(Base_val1(base_point_derived), 11)
unittest(Base_val2(base_point_derived), 2)
# Dynamic cast to original Derived class
derived_dyn = dynDerivedCast(base_point_derived)
checknotnull(derived_dyn, "dynamic cast to derived_dyn fail")
unittest(Derived_val1(derived_dyn), 11)
unittest(Derived_val2(derived_dyn), 12)
# Static cast work the same as dynamic cast, when used with the derived class!
derived_static = staticDerivedCast(base_point_derived)
checknotnull(derived_static, "static cast to derived_static fail")
unittest(Derived_val1(derived_static), 11)
unittest(Derived_val2(derived_static), 12)

# Get an Other object using a Base pointer
base_point_other = Other_NewOther()
unittest(Base_val1(base_point_other), 21)
unittest(Base_val2(base_point_other), 2)
# Dynamic cast to original Other class
other_dyn = dynOtherCast(base_point_other)
checknotnull(other_dyn, "dynamic cast to other_dyn fail")
unittest(Other_val1(other_dyn), 21)
unittest(Other_val2(other_dyn), 22)
# Static cast work the same as dynamic cast, when used with the other class!
other_static = staticOtherCast(base_point_other)
checknotnull(other_static, "static cast to other_static fail")
unittest(Other_val1(other_static), 21)
unittest(Other_val2(other_static), 22)

# Get a Base object
base = Base()
unittest(Base_val1(base), 1)
unittest(Base_val2(base), 2)

# Dynamic cast gives NULL as expected
checknull(dynOtherCast(base_point_derived), "''Derived'' object can not cast to ''Other''")
checknull(dynDerivedCast(base_point_other), "''Other'' object can not cast to ''Derived''")
checknull(dynOtherCast(base), "''Base'' object can not cast to ''Other''")
checknull(dynDerivedCast(base), "''Base'' object can not cast to ''Derived''")

# Static cast gives a hybrid result
# The virtual method point to original object class, as we expect!
# While the non-virtual method uses the new pointed class method!
non_cpp_other_derived = staticOtherCast(base_point_derived)
checknotnull(non_cpp_other_derived, "static cast to non_cpp_other_derived fail")
unittest(Other_val1(non_cpp_other_derived), 11)
unittest(Other_val2(non_cpp_other_derived), 22)
non_cpp_derived_other = staticDerivedCast(base_point_other)
checknotnull(non_cpp_derived_other, "static cast to non_cpp_derived_other fail")
unittest(Derived_val1(non_cpp_derived_other), 21)
unittest(Derived_val2(non_cpp_derived_other), 12)
non_cpp_base_derived = staticDerivedCast(base)
checknotnull(non_cpp_base_derived, "static cast to non_cpp_base_derived fail")
unittest(Derived_val1(non_cpp_base_derived), 1)
unittest(Derived_val2(non_cpp_base_derived), 12)
non_cpp_base_other = staticOtherCast(base)
checknotnull(non_cpp_base_other, "static cast to non_cpp_base_other fail")
unittest(Other_val1(non_cpp_base_other), 1)
unittest(Other_val2(non_cpp_base_other), 22)

q(save="no")
