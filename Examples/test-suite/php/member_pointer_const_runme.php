<?php

require "tests.php";

// Check functions.
check::functions(array('do_op','do_op_td','areapt','perimeterpt','perimeterpt_td','call1'));

// Check classes.
check::classes(array('member_pointer_const','Circle','Funktions','Shape','Square'));

// Check global variables.
check::globals(array('areavar','perimetervar','perimetervar_td'));

# Get the pointers

$area_pt = member_pointer_const::areapt();
$perim_pt = member_pointer_const::perimeterpt();

# Create some objects

$s = new Square(10);

# Do some calculations

check::equal(100.0, member_pointer_const::do_op($s, $area_pt), "Square area");
check::equal(40.0, member_pointer_const::do_op($s, $perim_pt), "Square perim");


$memberPtr = member_pointer_const::areavar_get();
$memberPtr = member_pointer_const::perimetervar_get();

# Try the variables
check::equal(100.0, member_pointer_const::do_op($s, member_pointer_const::areavar_get()), "Square area");
check::equal(40.0, member_pointer_const::do_op($s, member_pointer_const::perimetervar_get()), "Square perim");

# Modify one of the variables
member_pointer_const::areavar_set($perim_pt);

check::equal(40.0, member_pointer_const::do_op($s, member_pointer_const::areavar_get()), "Square perimeter");

# Try the constants

/*
$memberPtr = member_pointer_const::AREAPT;
$memberPtr = member_pointer_const::PERIMPT;
$memberPtr = member_pointer_const::NULLPT;

check::equal(100.0, member_pointer_const::do_op($s, member_pointer_const::AREAPT), "Square area");
check::equal(40.0, member_pointer_const::do_op($s, member_pointer_const::PERIMPT), "Square perim");
*/

# Typedefs
check::equal(40.0, member_pointer_const::do_op_td($s, $perim_pt), "Square perim");

/*
check::equal(3, member_pointer_const::call1(member_pointer_const::ADD_BY_VALUE, 1, 2), "Add by value");
check::equal(7, member_pointer_const::call2(member_pointer_const::ADD_BY_VALUE, 3, 4), "Add by pointer");
check::equal(11, member_pointer_const::call3(member_pointer_const::ADD_BY_VALUE, 5, 6), "Add by reference");
 */

check::done();
