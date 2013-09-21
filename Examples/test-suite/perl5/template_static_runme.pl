use strict;
use warnings;
use Test::More tests => 3;
BEGIN { use_ok('template_static') }
require_ok('template_static');

is(template_static::Foo->bar_double(1), 1.0);
