use strict;
use warnings;
use Test::More tests => 3;
BEGIN { use_ok('typemap_delete') }
require_ok('typemap_delete');

my $r = typemap_delete::Rect->new(123);
is($r->{val}, 123);
