use enum_thorough;

# Just test an in and out typemap for enum SWIGTYPE and const enum SWIGTYPE & typemaps
if (enum_thorough::speedTest4(SpeedClass_slow) != SpeedClass_slow) {
    die "speedTest Global 4 failed";
}
if (enum_thorough::speedTest5(SpeedClass_slow) != SpeedClass_slow) {
    die "speedTest Global 5 failed";
}
