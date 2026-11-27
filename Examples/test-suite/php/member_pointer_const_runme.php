<?php

require "tests.php";

// Check functions.
check::functions(array('do_op','do_op_td','areapt','perimeterpt','perimeterpt_td','do_op_list_td',
                       'areaptlist','perimeterptlist','call1','getAddPtDeclaration'));

// Check classes.
check::classes(array('member_pointer_const','Adder','Circle','Funktions','MemberPointerGetter','Shape','Square'));

// Check global variables.
check::globals(array('areavar','perimetervar','perimetervar_td','areavarlist','perimetervarlist'));

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

$memberPtr = member_pointer_const::AREAPT;
$memberPtr = member_pointer_const::PERIMPT;
$memberPtr = member_pointer_const::NULLPT;

check::equal(100.0, member_pointer_const::do_op($s, member_pointer_const::AREAPT), "Square area");
check::equal(40.0, member_pointer_const::do_op($s, member_pointer_const::PERIMPT), "Square perim");

# Typedefs
check::equal(40.0, member_pointer_const::do_op_td($s, $perim_pt), "Square perim");

# The declarators after the first in a list
check::equal(40.0, member_pointer_const::do_op_list_td($s, $perim_pt), "Square perim");
check::equal(40.0, member_pointer_const::do_op($s, member_pointer_const::perimeterptlist()), "Square perim");
check::equal(40.0, member_pointer_const::do_op($s, member_pointer_const::perimetervarlist_get()), "Square perim");
check::equal(40.0, member_pointer_const::do_op($s, (new MemberPointerGetter())->getPerimeterPtList()), "Square perim");

# Member functions returning member pointers
$getter = new MemberPointerGetter();
check::equal(100.0, member_pointer_const::do_op($s, $getter->getAreaPt()), "Square area");
check::equal(100.0, member_pointer_const::do_op($s, $getter->getConstAreaPt()), "Square area");
check::equal(100.0, member_pointer_const::do_op($s, MemberPointerGetter::getStaticAreaPt()), "Square area");

# Member pointers to a namespaced class
$adder = new Adder();
check::equal(11, $adder->callAddPt($adder->getAddPt(), 10), "Add by member pointer");
check::equal("int (MemberPointerSpace::Adder::*MemberPointerSpace::Adder::getAddPt())(int) const", getAddPtDeclaration(), "Declaration");

check::equal(3, member_pointer_const::call1(member_pointer_const::ADD_BY_VALUE, 1, 2), "Add by value");

check::done();
