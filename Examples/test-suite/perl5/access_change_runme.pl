use strict;
use warnings;
use Test::More tests => 26;
BEGIN { use_ok 'access_change' }
require_ok 'access_change';

my $k = access_change::BaseInt->new();

eval { $k->PublicProtectedPublic1() };
is($@, '', 'BaseInt.PublicProtectedPublic1()');
eval { $k->PublicProtectedPublic2() };
is($@, '', 'BaseInt.PublicProtectedPublic2()');
eval { $k->PublicProtectedPublic3() };
is($@, '', 'BaseInt.PublicProtectedPublic3()');
eval { $k->PublicProtectedPublic4() };
is($@, '', 'BaseInt.PublicProtectedPublic4()');
eval { $k->WasProtected1() };
isnt($@, '', 'BaseInt.WasProtected1()');
eval { $k->WasProtected2() };
isnt($@, '', 'BaseInt.WasProtected2()');
eval { $k->WasProtected3() };
isnt($@, '', 'BaseInt.WasProtected3()');
eval { $k->WasProtected4() };
isnt($@, '', 'BaseInt.WasProtected4()');

$k = access_change::DerivedInt->new();

TODO: {
    local $TODO = '"using" support may be botched';
    eval { $k->PublicProtectedPublic1() };
    isnt($@, '', 'DerivedInt.PublicProtectedPublic1()');
    eval { $k->PublicProtectedPublic2() };
    isnt($@, '', 'DerivedInt.PublicProtectedPublic2()');
}
eval { $k->PublicProtectedPublic3() };
is($@, '', 'DerivedInt.PublicProtectedPublic3()');
eval { $k->PublicProtectedPublic4() };
is($@, '', 'DerivedInt.PublicProtectedPublic4()');
eval { $k->WasProtected1() };
is($@, '', 'DerivedInt.WasProtected1()');
eval { $k->WasProtected2() };
is($@, '', 'DerivedInt.WasProtected2()');
eval { $k->WasProtected3() };
is($@, '', 'DerivedInt.WasProtected3()');
eval { $k->WasProtected4() };
is($@, '', 'DerivedInt.WasProtected4()');

$k = access_change::BottomInt->new();

eval { $k->PublicProtectedPublic1() };
is($@, '', 'BaseInt.PublicProtectedPublic1()');
eval { $k->PublicProtectedPublic2() };
is($@, '', 'BaseInt.PublicProtectedPublic2()');
eval { $k->PublicProtectedPublic3() };
is($@, '', 'BaseInt.PublicProtectedPublic3()');
eval { $k->PublicProtectedPublic4() };
is($@, '', 'BaseInt.PublicProtectedPublic4()');
eval { $k->WasProtected1() };
is($@, '', 'BaseInt.WasProtected1()');
eval { $k->WasProtected2() };
is($@, '', 'BaseInt.WasProtected2()');
eval { $k->WasProtected3() };
TODO: {
    local $TODO = '"using" support may be botched';
    isnt($@, '', 'BaseInt.WasProtected3()');
    eval { $k->WasProtected4() };
    isnt($@, '', 'BaseInt.WasProtected4()');
}
