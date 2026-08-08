
var overload_numeric = require("overload_numeric");

nums = new overload_numeric.Nums();
limits = new overload_numeric.Limits();

function check(got, expected) {
    if (got != expected) {
        throw new Error("got: " + got + " expected: " + expected);
    }
}

check(nums.over(0), "signed char");

check(nums.over(limits.schar_min()), "signed char");
check(nums.over(limits.schar_max()), "signed char");

check(nums.over(limits.schar_min() - 1), "short");
check(nums.over(limits.schar_max() + 1), "short");
check(nums.over(limits.shrt_min()), "short");
check(nums.over(limits.shrt_max()), "short");

check(nums.over(limits.shrt_min() - 1), "int");
check(nums.over(limits.shrt_max() + 1), "int");
check(nums.over(limits.int_min()), "int");
check(nums.over(limits.int_max()), "int");

check(nums.over(limits.flt_min()), "float");
check(nums.over(limits.flt_max()), "float");

check(nums.over(limits.flt_max() * 10), "double");
check(nums.over(-limits.flt_max() * 10), "double");
check(nums.over(limits.dbl_max()), "double");
check(nums.over(-limits.dbl_max()), "double");

check(nums.over(Infinity), "float");
check(nums.over(-Infinity), "float");
check(nums.over(NaN), "float");

// Just check if the following are accepted without exceptions being thrown;
nums.doublebounce(Infinity);
nums.doublebounce(-Infinity);
nums.doublebounce(NaN);
