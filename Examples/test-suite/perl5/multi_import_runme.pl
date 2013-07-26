use strict;
use warnings;
use Test::More 'no_plan';
BEGIN {
    use_ok 'multi_import_b';
    use_ok 'multi_import_a';
}
require_ok 'multi_import_b';
require_ok 'multi_import_a';

my $xxx = multi_import_b::XXX->new();
isa_ok $xxx, 'multi_import_b::XXX';
is(eval { $xxx->testx() }, 0, 'xxx.testx');
is($@, '');
is(eval { $xxx->testy() }, undef, 'xxx.testy');
like($@, qr/Can't locate object method/);
is(eval { $xxx->testz() }, undef, 'xxx.testz');
like($@, qr/Can't locate object method/);

my $yyy = multi_import_b::YYY->new();
isa_ok $yyy, 'multi_import_b::YYY';
is(eval { $yyy->testx() }, 0, 'yyy.testx');
is($@, '');
is(eval { $yyy->testy() }, 1, 'yyy.testy');
is($@, '');
is(eval { $yyy->testz() }, undef, 'yyy.testz');
like($@, qr/Can't locate object method/);

my $zzz = multi_import_a::ZZZ->new();
isa_ok $zzz, 'multi_import_a::ZZZ';
is(eval { $zzz->testx() }, 0, 'zzz.testx');
is($@, '');
is(eval { $zzz->testy() }, undef, 'zzz.testy');
like($@, qr/Can't locate object method/);
is(eval { $zzz->testz() }, 2, 'zzz.testz');
is($@, '');

# It's important to notice in the wrappers that multi_import_a does not
# implement a testx method wrapper, thus the test shows sharing between
# type tables and proper casting when a zzz->testx() is executed
# successfully.
