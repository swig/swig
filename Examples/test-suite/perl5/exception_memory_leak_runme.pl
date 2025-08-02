#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 11;
BEGIN { use_ok('exception_memory_leak') }
require_ok('exception_memory_leak');

my $a = exception_memory_leak::Foo->new();
is(exception_memory_leak::Foo::get_count(), 1, "Should have 1 Foo objects");
my $b = exception_memory_leak::Foo->new();
is(exception_memory_leak::Foo::get_count(), 2, "Should have 2 Foo objects");

# Normal behaviour
exception_memory_leak::trigger_internal_swig_exception("no problem", $a);
is(exception_memory_leak::Foo::get_count(), 2, "Should have 2 Foo objects");
is(exception_memory_leak::Foo::get_freearg_count(), 1, "freearg should have been used once");

# SWIG exception triggered and handled (return new object case).
eval {
  exception_memory_leak::trigger_internal_swig_exception("null", $b);
};
isnt($@, '', "Should throw exception");
is(exception_memory_leak::Foo::get_count(), 2, "Should have 2 Foo objects");
is(exception_memory_leak::Foo::get_freearg_count(), 2, "freearg should have been used twice");

# SWIG exception triggered and handled (return by value case).
eval {
  exception_memory_leak::trigger_internal_swig_exception("null");
};
isnt($@, '', "Should throw exception");
is(exception_memory_leak::Foo::get_count(), 2, "Should have 2 Foo objects");
