use strict;
use warnings;
use Test::More tests => 8;
BEGIN { use_ok 'abstract_inherit' }
require_ok 'abstract_inherit';

is(abstract_inherit::Foo->can('new'), undef, 'Foo.new()');
isnt(abstract_inherit::Foo->can('blah'), undef, 'Foo.blah()');

is(abstract_inherit::Bar->can('new'), undef, 'Bar.new()');
isnt(abstract_inherit::Bar->can('blah'), undef, 'Bar.blah()');

is(abstract_inherit::Spam->can('new'), undef, 'Spam.new()');
isnt(abstract_inherit::Spam->can('blah'), undef, 'Spam.blah()');
