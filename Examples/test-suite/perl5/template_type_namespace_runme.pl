use strict;
use warnings;
use Test::More tests => 3;
BEGIN { use_ok('template_type_namespace') }
require_ok('template_type_namespace');

is(template_type_namespace::foo()->[0], 'foo');
