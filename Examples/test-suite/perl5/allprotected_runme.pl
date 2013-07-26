use strict;
use warnings;
use Test::More tests => 13;
BEGIN { use_ok 'allprotected' }
require_ok 'allprotected';

{
    package MyProtected;
    use base 'allprotected::ProtectedBase';
    use Test::More;
    sub accessProtected { my($self) = @_;
        my $s = $self->virtualMethod();
        is($s, 'ProtectedBase', 'virtualMethod');

        my $k = $self->instanceMethod(allprotected::Klass->new("xyz"));
        is($k->getName(), "xyz", 'instanceMethod');

        $k = $self->instanceOverloaded(allprotected::Klass->new("xyz"));
        is($k->getName(), "xyz", 'instanceOverloaded1');

        $k = $self->instanceOverloaded(allprotected::Klass->new("xyz"), "abc");
        is($k->getName(), "abc", 'instanceOverloaded2');

        $k = allprotected::ProtectedBase->staticMethod(
            allprotected::Klass->new("abc"));
        is($k->getName(), "abc", 'staticMethod');

        $k = allprotected::ProtectedBase->staticOverloaded(
            allprotected::Klass->new("xyz"));
        is($k->getName(), "xyz", 'staticOverloaded1');

        $k = allprotected::ProtectedBase->staticOverloaded(
            allprotected::Klass->new("xyz"), "abc");
        is($k->getName(), "abc", 'staticOverloaded2');

        $self->{instanceMemberVariable} = 30;
        is($self->{instanceMemberVariable}, 30, 'instanceMemberVariable');

        $allprotected::PublicBase::staticMemberVariable = 40;
        is($allprotected::PublicBase::staticMemberVariable, 40,
            'staticMemberVariable');

        is($allprotected::PublicBase::staticConstMemberVariable, 20,
            'staticConstMemberVariable');

        $self->{anEnum} = $allprotected::PublicBase::EnumVal1;
        is($self->{anEnum}, $allprotected::PublicBase::EnumVal1, 'AnEnum');
    }
}

{
    my $mp = MyProtected->new("MyProtected");
    $mp->accessProtected();
}
