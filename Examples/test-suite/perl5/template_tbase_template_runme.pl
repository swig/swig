use strict;
use warnings;
use Test::More tests => 3;
BEGIN { use_ok('template_tbase_template') }
require_ok('template_tbase_template');

is(template_tbase_template::make_Class_dd()->test(), 'test');
