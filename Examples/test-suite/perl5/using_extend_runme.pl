use strict;
use warnings;
use Test::More tests => 8;
BEGIN { use_ok('using_extend') }
require_ok('using_extend');

my $f = using_extend::FooBar->new();
is($f->blah(3), 3, 'blah(int)');
is($f->blah(3.5), 3.5, 'blah(double)');
is($f->blah('hello'), 'hello', 'blah(char *)');
is($f->blah(3, 4), 7, 'blah(int,int)');
is($f->blah(3.2, 7.3), 10.5, 'blah(double,double)');
is($f->duh(3), 3, 'duh(int)');
