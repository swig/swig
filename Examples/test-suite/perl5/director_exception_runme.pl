use strict;
use warnings;
use Test::More 'no_plan';
BEGIN { use_ok 'director_exception' }
require_ok 'director_exception';

{
    package MyFoo;
    use base 'director_exception::Foo';
    sub ping {
        die "MyFoo::ping() EXCEPTION";
    }
}
{
    package MyFoo2;
    use base 'director_exception::Foo';
    sub ping {
        # error should return a string
        return bless [ 1 ], 'main';
    }
}

{
    my $a = MyFoo->new();
    my $b = director_exception::launder($a);
    isa_ok $b, 'MyFoo';
    eval { $b->pong() };
    like($@, qr/\bMyFoo::ping\(\) EXCEPTION\b/,
        'MyFoo.pong() error contet preserved');
}
{
    my $a = MyFoo2->new();
    my $b = director_exception::launder($a);
    isa_ok $b, 'MyFoo2';
    eval { $b->pong() };
    like($@, qr/\bTypeError\b/,
        'MyFoo2.pong() error contet preserved');
}

__END__

$a = MyFoo2->new();
$b = director_exception::launder($a);

eval { $b->pong() };
die "should have thrown" unless $@;
die "error content not preserved" unless $@ =~ /\bstd::string\b/;

eval { die director_exception::Exception2->new() };

eval { die director_exception::Exception1->new() };
