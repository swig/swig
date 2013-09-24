use strict;
use warnings;
use Test::More tests => 52;
BEGIN { use_ok('smart_pointer_const_overload') }
require_ok('smart_pointer_const_overload');

$smart_pointer_const_overload::CONST_ACCESS = 1;
$smart_pointer_const_overload::MUTABLE_ACCESS = 2;

sub test { my($b, $f) = @_;
  is($f->{x}, 0);

  # Test member variable get
  is($b->{x}, 0);
 
  is($f->{access}, $smart_pointer_const_overload::CONST_ACCESS);

  # Test member variable set
  $b->{x} = 1;

  is($f->{x}, 1);
  
  is($f->{access}, $smart_pointer_const_overload::MUTABLE_ACCESS);
  
  # Test const method
  is($b->getx(), 1);
  
  is($f->{access}, $smart_pointer_const_overload::CONST_ACCESS);
  
  # Test mutable method
  $b->setx(2);

  is($f->{x}, 2);
  
  is($f->{access}, $smart_pointer_const_overload::MUTABLE_ACCESS);
  
  # Test extended const method
  is($b->getx2(), 2);
  
  is($f->{access}, $smart_pointer_const_overload::CONST_ACCESS);

  # Test extended mutable method
  $b->setx2(3);

  is($f->{x}, 3);

  is($f->{access}, $smart_pointer_const_overload::MUTABLE_ACCESS);

  # Test static method
  $b->stat();

  is($f->{access}, $smart_pointer_const_overload::CONST_ACCESS);

  # Test const member
  $f->{access} = $smart_pointer_const_overload::MUTABLE_ACCESS;

  is($b->{y}, 0);

  is($f->{access}, $smart_pointer_const_overload::CONST_ACCESS);
  
  # Test get through mutable pointer to const member
  $f->{access} = $smart_pointer_const_overload::MUTABLE_ACCESS;

  is(smart_pointer_const_overload::get_int($b->{yp}), 0);

  is($f->{access}, $smart_pointer_const_overload::CONST_ACCESS);

  # Test get through const pointer to mutable member
  $f->{x} = 4;
  $f->{access} = $smart_pointer_const_overload::MUTABLE_ACCESS;

  is(smart_pointer_const_overload::get_int($b->{xp}), 4);
 
  is($f->{access}, $smart_pointer_const_overload::CONST_ACCESS);

  # Test set through const pointer to mutable member
  $f->{access} = $smart_pointer_const_overload::MUTABLE_ACCESS;
  smart_pointer_const_overload::set_int($b->{xp}, 5);
  
  is($f->{x}, 5);

  is($f->{access}, $smart_pointer_const_overload::CONST_ACCESS);

  # Test set pointer to const member
  $b->{yp} = smart_pointer_const_overload::new_int(6);

  is($f->{y}, 0);

  is(smart_pointer_const_overload::get_int($f->{yp}), 6);
  
  is($f->{access}, $smart_pointer_const_overload::MUTABLE_ACCESS);
    
  smart_pointer_const_overload::delete_int($f->{yp});
}

my $f = smart_pointer_const_overload::Foo->new();
my $b = smart_pointer_const_overload::Bar->new($f);

my $f2 = smart_pointer_const_overload::Foo->new();
my $b2 = smart_pointer_const_overload::Bar2->new($f2);

test($b, $f);
test($b2, $f2);
