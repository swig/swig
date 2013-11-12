#!/usr/bin/perl
use strict;
use warnings;
use example;
# This file illustrates the cross language polymorphism using directors.

{
  # CEO class, which overrides Employee::getPosition().
  package CEO;
  use base 'example::Manager';
  sub getPosition {
    return 'CEO';
  }
}


# Create an instance of CEO, a class derived from the Java proxy of the 
# underlying C++ class. The calls to getName() and getPosition() are standard,
# the call to getTitle() uses the director wrappers to call CEO.getPosition().
my $e = CEO->new('Alice');
print "${\ $e->getName } is a ${\ $e->getPosition() }\n";
print "Just call her \"${\ $e->getTitle() }\"\n";
print "----------------------\n";


# Create a new EmployeeList instance.  This class does not have a C++
# director wrapper, but can be used freely with other classes that do.

my $list = example::EmployeeList->new();

$list->addEmployee($e);
print "----------------------\n";

# Now we access the first four items in list (three are C++ objects that
# EmployeeList's constructor adds, the last is our CEO). The virtual
# methods of all these instances are treated the same. For items 0, 1, and
# 2, all methods resolve in C++. For item 3, our CEO, getTitle calls
# getPosition which resolves in Perl. The call to getPosition is
# slightly different, however, because of the overidden getPosition() call, since
# now the object reference has been "laundered" by passing through
# EmployeeList as an Employee*. Previously, Perl resolved the call
# immediately in CEO, but now Perl thinks the object is an instance of
# class Employee. So the call passes through the
# Employee proxy class and on to the C wrappers and C++ director,
# eventually ending up back at the Perl CEO implementation of getPosition().
# The call to getTitle() for item 3 runs the C++ Employee::getTitle()
# method, which in turn calls getPosition(). This virtual method call
# passes down through the C++ director class to the Perl implementation
# in CEO. All this routing takes place transparently.

print "(position, title) for items 0-3:\n";

print "  ${\ $list->get_item(0)->getPosition() }, \"${\ $list->get_item(0)->getTitle() }\"\n";
print "  ${\ $list->get_item(1)->getPosition() }, \"${\ $list->get_item(1)->getTitle() }\"\n";
print "  ${\ $list->get_item(2)->getPosition() }, \"${\ $list->get_item(2)->getTitle() }\"\n";
print "  ${\ $list->get_item(3)->getPosition() }, \"${\ $list->get_item(3)->getTitle() }\"\n";
print "----------------------\n";

# Time to delete the EmployeeList, which will delete all the Employee*
# items it contains. The last item is our CEO, which gets destroyed as well.
undef $list;
print "----------------------\n";

# All done.
print "perl exit\n";
