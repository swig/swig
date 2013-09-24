use strict;
use warnings;
use Test::More tests => 3;
BEGIN { use_ok('li_cmalloc') }
require_ok('li_cmalloc');

my $p = li_cmalloc::malloc_int();
li_cmalloc::free_int($p);

eval {
  my $p = li_cmalloc::calloc_int(-1);
  li_cmalloc::free_int($p);
};
isnt($@, undef);
