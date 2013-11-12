#!/usr/bin/perl
use strict;
use warnings;
use example;

{
  package PerlCallback;
  use base 'example::Callback';
  sub run {
    print "PerlCallback.run()\n";
  }
}

print "Adding and calling a normal C++ callback\n";
print "----------------------------------------\n";

my $caller = example::Caller->new();
my $callback = example::Callback->new();

$caller->setCallback($callback);
$caller->call();
$caller->delCallback();

$callback = PerlCallback->new();

print "\n";
print "Adding and calling a Perl callback\n";
print "------------------------------------\n";

$caller->setCallback($callback);
$caller->call();
$caller->delCallback();

# Note that letting go of $callback will not attempt to destroy the
# object, ownership passed to $caller in the ->setCallback() call, and
# $callback was already destroyed in ->delCallback().
undef $callback;

print "\n";
print "perl exit\n";
