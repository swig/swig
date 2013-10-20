use strict;
use warnings;
use Scalar::Util ();
use Test::More tests => 29;
BEGIN { use_ok 'director_finalizer' }
require_ok 'director_finalizer';

{
    package MyFoo;
    use base 'director_finalizer::Foo';
    our($lcount, $dcount) = (0, 0);
    sub new {
        $lcount++;
        return shift->SUPER::new(@_);
    }
    sub DESTROY { my($self) = @_;
        $dcount++;
        $self->orStatus(2);
    }
}

{
    director_finalizer::resetStatus();
    my $f;
    {   # get a director subclass
        my $mf = MyFoo->new();
        isa_ok $mf, 'MyFoo';
        is(director_finalizer::getStatus(), 0);
        is($MyFoo::lcount, 1);
        is($MyFoo::dcount, 0);

        # hide it's perl side implementation
        $f = director_finalizer::launder($mf);
        isa_ok $f, 'director_finalizer::Foo';
    }
    is(director_finalizer::getStatus(), 0);
    is($MyFoo::lcount, 1);
    is($MyFoo::dcount, 0);

    undef $f;
    is(director_finalizer::getStatus(), 3);
    is($MyFoo::lcount, 1);
    is($MyFoo::dcount, 1);
}
{
    director_finalizer::resetStatus();
    my $f;
    {
        my $mf = MyFoo->new();
        isa_ok $mf, 'MyFoo';
        # claim that ownership has been passed over to c++
        is(director_finalizer::getStatus(), 0);
        is($MyFoo::lcount, 2);
        is($MyFoo::dcount, 1);
        $f = director_finalizer::launder($mf);
        isa_ok $f, 'director_finalizer::Foo';
        $mf->_swig_own('');
    }
    # letting go of $mf shouldn't change a thing
    is(director_finalizer::getStatus(), 0);
    is($MyFoo::lcount, 2);
    is($MyFoo::dcount, 1);

    Scalar::Util::weaken($f);
    # because we claim we don't own this one, dropping $f also shouldn't
    # change a thing.
    isnt($f, undef);
    is(director_finalizer::getStatus(), 0);
    is($MyFoo::lcount, 2);
    is($MyFoo::dcount, 1);
    # but asking c++ to drop it should.
    director_finalizer::deleteFoo($f);
    is(director_finalizer::getStatus(), 3);
    is($MyFoo::lcount, 2);
    is($MyFoo::dcount, 2);
    is($f, undef);
    # TODO: functionally that's a thing of beauty, but the API to let go
    # of something is just silly, we can do better.
}
