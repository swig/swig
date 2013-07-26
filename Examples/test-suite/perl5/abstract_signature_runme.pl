use strict;
use warnings;
use Test::More tests => 6;
BEGIN { use_ok 'abstract_signature' }
require_ok 'abstract_signature';

is(abstract_signature::abstract_foo->can('new'), undef, 'foo.new()');
isnt(abstract_signature::abstract_foo->can('meth'), undef, 'foo.meth()');

is(abstract_signature::abstract_bar->can('new'), undef, 'bar.new()');
isnt(abstract_signature::abstract_bar->can('meth'), undef, 'bar.meth()');

