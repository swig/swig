use enum_thorough;

$enum_thorough::myColour;


# Just test an in and out typemap for enum SWIGTYPE and const enum SWIGTYPE & typemaps
if (enum_thorough::speedTest4($enum_thorough::SpeedClass::slow) != $enum_thorough::SpeedClass::slow) {
    die "speedTest Global 4 failed";
}
if (enum_thorough::speedTest5($enum_thorough::SpeedClass::slow) != $enum_thorough::SpeedClass::slow) {
    die "speedTest Global 5 failed";
}


if (enum_thorough::speedTest4($enum_thorough::SpeedClass::fast) != $enum_thorough::SpeedClass::fast) {
    die "speedTest Global 4 failed";
}
if (enum_thorough::speedTest5($enum_thorough::SpeedClass::fast) != $enum_thorough::SpeedClass::fast) {
    die "speedTest Global 5 failed";
}
