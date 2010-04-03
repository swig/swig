use strict;
use warnings;
use Test::More 'no_plan';
BEGIN { use_ok 'extend' }
require_ok 'extend';

{
    my $B = extend::Base->new();
    isa_ok $B, 'extend::Base';
    is $B->method(123), 123;
    is $B->zeroVal(), 0;
    # object is coherent, how about extensions?
    is $B->{value}, 0;
    $B->{value} = 321;
    is $B->{value}, 321;
    is $B->currentValue(), 321;
    is $B->extendmethod(456), 456 * 2;
}
{
    # now how about with inheritance?
    my $D = extend::Derived->new(321);
    $D->{actualval} = 234.56;
    is $D->{actualval}, 234.56;
    isa_ok $D, 'extend::Base';
    is $D->method(123), 246;
    is $D->zeroVal(), 0;
    is $D->{value}, 642;
    is $D->currentValue(), 642;
    is $D->extendmethod(456), 456 * 2;

    # TODO: is this really how this is supposed to work?  wow, fancy.
    is $D->{extendval}, 23456;
    $D->{extendval} = 543;
    is $D->{actualval}, 5.43;
}

