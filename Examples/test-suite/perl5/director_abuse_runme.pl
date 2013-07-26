use strict;
use warnings;
use Test::More 'no_plan';
BEGIN { use_ok 'director_abuse' }
require_ok 'director_abuse';

sub mkPair { my($tc, $hc) = @_;
    my $h = $hc->new();
    $h->{thing} = $tc->new();
    return $h;
}

# check errors emitted to $@
{
    package T1;
    use base 'director_abuse::Thing';
}
{
    package H1;
    use base 'director_abuse::Holder';
}
{
    my $h = mkPair('T1', 'H1');
    isa_ok $h, 'director_abuse::Holder';
    isa_ok $h->{thing}, 'director_abuse::Thing';

    # Have Perl set an invalid attribute
    $h->{thing}{attr} = 12;
    # this should fail
    is eval { $h->{thing}{attr} = bless [], 'Bogus' }, undef;
    # set the error val
    like $@, qr/TypeError/;
    # and not change the original value
    is $h->{thing}{attr}, 12;

    # Have Perl ask C++ to set an invalid attribute
    $h->{thing}{attr} = 34;
    is eval { $h->{thing}->set_attr(bless [], 'Bogus') }, undef;
    like $@, qr/TypeError/;
    is $h->{thing}{attr}, 34;

    # Have Perl ask C++ to set an invalid attribute indirectly
    $h->{thing}{attr} = 56;
    is eval { $h->set_attr(bless [], 'Bogus') }, undef;
    like $@, qr/TypeError/;
    is $h->{thing}{attr}, 56;
}
{
    package T2;
    use base 'director_abuse::Thing';
    sub set_attr { my($self, $v) = @_;
        $self->{attr} = bless [], 'Bogus';
    }
}
{
    my $h = mkPair('T2', 'H1');
    isa_ok $h, 'director_abuse::Holder';
    isa_ok $h->{thing}, 'director_abuse::Thing';

    # Have Perl ask C++ to set an invalid attribute
    $h->{thing}{attr} = 34;
    is eval { $h->{thing}->set_attr(bless [], 'Bogus') }, undef;
    like $@, qr/TypeError/;
    is $h->{thing}{attr}, 34;

    # Have Perl ask C++ to set an invalid attribute indirectly
    $h->{thing}{attr} = 56;
    is eval { $h->set_attr(bless [], 'Bogus') }, undef;
    like $@, qr/TypeError/;
    is $h->{thing}{attr}, 56;
}
{
    package H2;
    use base 'director_abuse::Holder';
    sub set_attr { my($self, $v) = @_;
        $self->{thing}->set_attr(bless [], 'Bogus');
    }
}
{
    my $h = mkPair('T1', 'H2');
    isa_ok $h, 'director_abuse::Holder';
    isa_ok $h->{thing}, 'director_abuse::Thing';

    # Have Perl ask C++ to set an invalid attribute indirectly
    $h->{thing}{attr} = 78;
    is eval { $h->set_attr(bless [], 'Bogus') }, undef;
    like $@, qr/TypeError/;
    is $h->{thing}{attr}, 78;
}
{
    package T3;
    use base 'director_abuse::Thing';
    sub set_attr { my($self, $v) = @_;
        die "brap";
    }
}
{
    my $h = mkPair('T3', 'H1');
    isa_ok $h, 'director_abuse::Holder';
    isa_ok $h->{thing}, 'director_abuse::Thing';
    $h->{thing}{attr} = 78;
    is eval { $h->set_attr(12) }, undef;
    like $@, qr/\bbrap\b/;
    is $h->{thing}{attr}, 78;
}
{
    package H3;
    use base 'director_abuse::Holder';
    sub set_attr { my($self, $v) = @_;
        die "ting";
    }
}
{
    my $h = mkPair('T1', 'H3');
    isa_ok $h, 'director_abuse::Holder';
    isa_ok $h->{thing}, 'director_abuse::Thing';
    $h->{thing}{attr} = 78;
    is eval { $h->set_attr(12) }, undef;
    like $@, qr/\bting\b/;
    is $h->{thing}{attr}, 78;
}

# check errors emitted in C++
{
    # no errors
    my $h = mkPair('T1', 'H1');
    is eval { director_abuse::set_attr($h, 12) }, '';
    is $@, '';
}
{
    my $h = mkPair('T2', 'H1');
    like eval { director_abuse::set_attr($h, 34) }, qr/TypeError/;
    is $@, '';
}
{
    my $h = mkPair('T1', 'H2');
    like eval { director_abuse::set_attr($h, 56) }, qr/TypeError/;
    is $@, '';
}
{
    my $h = mkPair('T3', 'H1');
    like eval { director_abuse::set_attr($h, 78) }, qr/\bbrap\b/;
    is $@, '';
}
{
    my $h = mkPair('T1', 'H3');
    like eval { director_abuse::set_attr($h, 78) }, qr/\bting\b/;
    is $@, '';
}

# now for the tricky part, let's find out if we can throw perl object
{
    package E1;
    use base 'director_abuse::Exception';
}
{
    package T4;
    use base 'director_abuse::Thing';
    sub set_attr { my($self, $v) = @_;
        die E1->new("burp");
    }
}
{
    my $h = mkPair('T4', 'H1');
    is eval { $h->set_attr(12) }, undef;
    isa_ok $@, 'director_abuse::Exception';
    is $@->{msg}, 'burp';

    my $errstr = eval { director_abuse::set_attr($h, 34) };
    like $errstr, qr/\bburp\b/;
    is $@, '';
    {
        local $TODO = 'would like to recast throws where possible';
        is $errstr, 'Exception: burp';
    }
}
