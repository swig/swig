use strict;
use warnings;
use Test::More tests => 187;
BEGIN { use_ok 'li_boost_shared_ptr' }
require_ok 'li_boost_shared_ptr';

# TODO: convert the rest of li_shared_ptr_runme.py

#$li_boost_shared_ptr::debug_shared = 1;

runtest();

sub runtest {
    my($k, $kret, $m, $kmember, $kmemberVal, $kglobal);
    # TODO: getValue should not need to be fully qualified
    my $getValue = 'li_boost_shared_ptr::Klass::getValue';

    # simple shared_ptr usage - created in C++
    $k = li_boost_shared_ptr::Klass->new("me oh my");
    is($k->$getValue(), "me oh my", 'Klass.new() value');
    is(li_boost_shared_ptr::use_count($k), 1, 'Klass.new() count');

    # simple shared_ptr usage - not created in C++
    $k = li_boost_shared_ptr::factorycreate();
    is($k->$getValue(), "factorycreate", 'factorycreate() value');
    is(li_boost_shared_ptr::use_count($k), 1, 'factorycreate() count');

    # pass by shared_ptr
    $k = li_boost_shared_ptr::Klass->new("me oh my");
    $kret = li_boost_shared_ptr::smartpointertest($k);
    is($kret->$getValue(), "me oh my smartpointertest", 'smartpointertest() value');
    is(li_boost_shared_ptr::use_count($k), 2, 'smartpointertest() count1');
    is(li_boost_shared_ptr::use_count($kret), 2, 'smartpointertest() count2');

    # pass by shared_ptr pointer
    $k = li_boost_shared_ptr::Klass->new("me oh my");
    $kret = li_boost_shared_ptr::smartpointerpointertest($k);
    is($kret->$getValue(), "me oh my smartpointerpointertest", 'smartpointerpointertest() value');
    is(li_boost_shared_ptr::use_count($k), 2, 'smartpointerpointertest() count1');
    is(li_boost_shared_ptr::use_count($kret), 2, 'smartpointerpointertest() count2');

    # pass by shared_ptr reference
    $k = li_boost_shared_ptr::Klass->new("me oh my");
    $kret = li_boost_shared_ptr::smartpointerreftest($k);
    is($kret->$getValue(), "me oh my smartpointerreftest", 'smartpointerreftest() value');
    is(li_boost_shared_ptr::use_count($k), 2, 'smartpointerreftest() count1');
    is(li_boost_shared_ptr::use_count($kret), 2, 'smartpointerreftest() count2');

    # pass by shared_ptr pointer reference
    $k = li_boost_shared_ptr::Klass->new("me oh my");
    $kret = li_boost_shared_ptr::smartpointerpointerreftest($k);
    is($kret->$getValue(), "me oh my smartpointerpointerreftest", 'smartpointerpointerreftest() value');
    is(li_boost_shared_ptr::use_count($k), 2, 'smartpointerpointerreftest() count1');
    is(li_boost_shared_ptr::use_count($kret), 2, 'smartpointerpointerreftest() count2');

    # const pass by shared_ptr
    $k = li_boost_shared_ptr::Klass->new("me oh my");
    $kret = li_boost_shared_ptr::constsmartpointertest($k);
    is($kret->$getValue(), "me oh my", 'constsmartpointertest() value');
    is(li_boost_shared_ptr::use_count($k), 2, 'constsmartpointertest() count1');
    is(li_boost_shared_ptr::use_count($kret), 2, 'constsmartpointertest() count2');

    # const pass by shared_ptr pointer
    $k = li_boost_shared_ptr::Klass->new("me oh my");
    $kret = li_boost_shared_ptr::constsmartpointerpointertest($k);
    is($kret->$getValue(), "me oh my", 'constsmartpointerpointertest() value');
    is(li_boost_shared_ptr::use_count($k), 2, 'constsmartpointerpointertest() count1');
    is(li_boost_shared_ptr::use_count($kret), 2, 'constsmartpointerpointertest() count2');

    # const pass by shared_ptr reference
    $k = li_boost_shared_ptr::Klass->new("me oh my");
    $kret = li_boost_shared_ptr::constsmartpointerreftest($k);
    is($kret->$getValue(), "me oh my", 'constsmartpointerreftest() value');
    is(li_boost_shared_ptr::use_count($k), 2, 'constsmartpointerreftest() count1');
    is(li_boost_shared_ptr::use_count($kret), 2, 'constsmartpointerreftest() count2');

    # pass by value
    $k = li_boost_shared_ptr::Klass->new("me oh my");
    $kret = li_boost_shared_ptr::valuetest($k);
    is($kret->$getValue(), "me oh my valuetest", 'valuetest() value');
    is(li_boost_shared_ptr::use_count($k), 1, 'valuetest() count1');
    is(li_boost_shared_ptr::use_count($kret), 1, 'valuetest() count2');

    # pass by pointer
    $k = li_boost_shared_ptr::Klass->new("me oh my");
    $kret = li_boost_shared_ptr::pointertest($k);
    is($kret->$getValue(), "me oh my pointertest", 'pointertest() value');
    is(li_boost_shared_ptr::use_count($k), 1, 'pointertest() count1');
    is(li_boost_shared_ptr::use_count($kret), 1, 'pointertest() count2');

    # pass by reference
    $k = li_boost_shared_ptr::Klass->new("me oh my");
    $kret = li_boost_shared_ptr::reftest($k);
    is($kret->$getValue(), "me oh my reftest", 'reftest() value');
    is(li_boost_shared_ptr::use_count($k), 1, 'reftest() count1');
    is(li_boost_shared_ptr::use_count($kret), 1, 'reftest() count2');

    # pass by pointer reference
    $k = li_boost_shared_ptr::Klass->new("me oh my");
    $kret = li_boost_shared_ptr::pointerreftest($k);
    is($kret->$getValue(), "me oh my pointerreftest", 'pointerreftest() value');
    is(li_boost_shared_ptr::use_count($k), 1, 'pointerreftest() count1');
    is(li_boost_shared_ptr::use_count($kret), 1, 'pointerreftest() count2');

    # null tests
    undef $k;

    is(li_boost_shared_ptr::smartpointertest($k), undef, 'smartpointertest(null)');

    is(li_boost_shared_ptr::smartpointerpointertest($k), undef, 'smartpointerpointertest(null)');

    is(li_boost_shared_ptr::smartpointerreftest($k), undef, 'smartpointerreftest(null)');

    is(li_boost_shared_ptr::smartpointerpointerreftest($k), undef, 'smartpointerpointerreftest(null)');

    is(li_boost_shared_ptr::nullsmartpointerpointertest(undef), "null pointer", 'nullsmartpointerpointertest(null)');

    eval { li_boost_shared_ptr::valuetest($k) };
    like($@, qr/invalid null reference/, 'valuetest(null)');

    is(li_boost_shared_ptr::pointertest($k), undef, 'pointertest(null)');

    eval { li_boost_shared_ptr::reftest($k) };
    like($@, qr/invalid null reference/, 'reftest(null)');

    # $owner
    $k = li_boost_shared_ptr::pointerownertest();
    is($k->$getValue(), "pointerownertest", 'pointerownertest() value');
    is(li_boost_shared_ptr::use_count($k), 1, 'pointerownertest() count');
    $k = li_boost_shared_ptr::smartpointerpointerownertest();
    is($k->$getValue(), "smartpointerpointerownertest", 'smartpointerpointerownertest() value');
    is(li_boost_shared_ptr::use_count($k), 1, 'smartpointerpointerownertest() count');

    # //////////////////////////////// Derived class ////////////////////////////////////////
    # derived pass by shared_ptr
    $k = li_boost_shared_ptr::KlassDerived->new("me oh my");
    $kret = li_boost_shared_ptr::derivedsmartptrtest($k);
    is($kret->$getValue(), "me oh my derivedsmartptrtest-Derived", 'derivedsmartptrtest() value');
    is(li_boost_shared_ptr::use_count($k), 2, 'derivedsmartptrtest() count1');
    is(li_boost_shared_ptr::use_count($kret), 2, 'derivedsmartptrtest() count2');

    # derived pass by shared_ptr pointer
    $k = li_boost_shared_ptr::KlassDerived->new("me oh my");
    $kret = li_boost_shared_ptr::derivedsmartptrpointertest($k);
    is($kret->$getValue(), "me oh my derivedsmartptrpointertest-Derived", 'derivedsmartptrpointertest() value');
    is(li_boost_shared_ptr::use_count($k), 2, 'derivedsmartptrpointertest() count1');
    is(li_boost_shared_ptr::use_count($kret), 2, 'derivedsmartptrpointertest() count2');

    # derived pass by shared_ptr ref
    $k = li_boost_shared_ptr::KlassDerived->new("me oh my");
    $kret = li_boost_shared_ptr::derivedsmartptrreftest($k);
    is($kret->$getValue(), "me oh my derivedsmartptrreftest-Derived", 'derivedsmartptrreftest() value');
    is(li_boost_shared_ptr::use_count($k), 2, 'derivedsmartptrreftest() count1');
    is(li_boost_shared_ptr::use_count($kret), 2, 'derivedsmartptrreftest() count2');

    # derived pass by shared_ptr pointer ref
    $k = li_boost_shared_ptr::KlassDerived->new("me oh my");
    $kret = li_boost_shared_ptr::derivedsmartptrpointerreftest($k);
    is($kret->$getValue(), "me oh my derivedsmartptrpointerreftest-Derived", 'derivedsmartptrpointerreftest() value');
    is(li_boost_shared_ptr::use_count($k), 2, 'derivedsmartptrpointerreftest() count1');
    is(li_boost_shared_ptr::use_count($kret), 2, 'derivedsmartptrpointerreftest() count2');

    # derived pass by pointer
    $k = li_boost_shared_ptr::KlassDerived->new("me oh my");
    $kret = li_boost_shared_ptr::derivedpointertest($k);
    is($kret->$getValue(), "me oh my derivedpointertest-Derived", 'derivedpointertest() value');
    is(li_boost_shared_ptr::use_count($k), 1, 'derivedpointertest() count1');
    is(li_boost_shared_ptr::use_count($kret), 1, 'derivedpointertest() count2');

    # derived pass by ref
    $k = li_boost_shared_ptr::KlassDerived->new("me oh my");
    $kret = li_boost_shared_ptr::derivedreftest($k);
    is($kret->$getValue(), "me oh my derivedreftest-Derived", 'derivedreftest() value');
    is(li_boost_shared_ptr::use_count($k), 1, 'derivedreftest() count1');
    is(li_boost_shared_ptr::use_count($kret), 1, 'derivedreftest() count2');

    # //////////////////////////////// Derived and base class mixed ////////////////////////////////////////
    # pass by shared_ptr (mixed)
    $k = li_boost_shared_ptr::KlassDerived->new("me oh my");
    $kret = li_boost_shared_ptr::smartpointertest($k);
    is($kret->$getValue, "me oh my smartpointertest-Derived", 'smartpointertest() value');
    is(li_boost_shared_ptr::use_count($k), 2, 'smartpointertest() count1');
    is(li_boost_shared_ptr::use_count($kret), 2, 'smartpointertest() count2');

    # pass by shared_ptr pointer (mixed)
    $k = li_boost_shared_ptr::KlassDerived->new("me oh my");
    $kret = li_boost_shared_ptr::smartpointerpointertest($k);
    is($kret->$getValue, "me oh my smartpointerpointertest-Derived", 'smartpointerpointertest() value');
    is(li_boost_shared_ptr::use_count($k), 2, 'smartpointerpointertest() count1');
    is(li_boost_shared_ptr::use_count($kret), 2, 'smartpointerpointertest() count2');

    # pass by shared_ptr reference (mixed)
    $k = li_boost_shared_ptr::KlassDerived->new("me oh my");
    $kret = li_boost_shared_ptr::smartpointerreftest($k);
    is($kret->$getValue, "me oh my smartpointerreftest-Derived", 'smartpointerreftest() value');
    is(li_boost_shared_ptr::use_count($k), 2, 'smartpointerreftest() count1');
    is(li_boost_shared_ptr::use_count($kret), 2, 'smartpointerreftest() count2');

    # pass by shared_ptr pointer reference (mixed)
    $k = li_boost_shared_ptr::KlassDerived->new("me oh my");
    $kret = li_boost_shared_ptr::smartpointerpointerreftest($k);
    is($kret->$getValue, "me oh my smartpointerpointerreftest-Derived", 'smartpointerpointerreftest() value');
    is(li_boost_shared_ptr::use_count($k), 2, 'smartpointerpointerreftest() count1');
    is(li_boost_shared_ptr::use_count($kret), 2, 'smartpointerpointerreftest() count2');

    # pass by value (mixed)
    $k = li_boost_shared_ptr::KlassDerived->new("me oh my");
    $kret = li_boost_shared_ptr::valuetest($k);
    is($kret->$getValue(), "me oh my valuetest", 'valuetest() value'); # note slicing
    is(li_boost_shared_ptr::use_count($k), 1, 'valuetest() count1');
    is(li_boost_shared_ptr::use_count($k), 1, 'valuetest() count2');

    # pass by pointer (mixed)
    $k = li_boost_shared_ptr::KlassDerived->new("me oh my");
    $kret = li_boost_shared_ptr::pointertest($k);
    is($kret->$getValue(), "me oh my pointertest-Derived", 'pointertest() value');
    is(li_boost_shared_ptr::use_count($k), 1, 'pointertest() count1');
    is(li_boost_shared_ptr::use_count($k), 1, 'pointertest() count2');

    # pass by ref (mixed)
    $k = li_boost_shared_ptr::KlassDerived->new("me oh my");
    $kret = li_boost_shared_ptr::reftest($k);
    is($kret->$getValue(), "me oh my reftest-Derived", 'reftest() value');
    is(li_boost_shared_ptr::use_count($k), 1, 'reftest() count1');
    is(li_boost_shared_ptr::use_count($k), 1, 'reftest() count2');

    # //////////////////////////////// Overloading tests ////////////////////////////////////////
    # Base class
    $k = li_boost_shared_ptr::Klass->new("me oh my");
    is(li_boost_shared_ptr::overload_rawbyval($k), "rawbyval", "rawbyval");
    is(li_boost_shared_ptr::overload_rawbyref($k), "rawbyref", "rawbyref");
    is(li_boost_shared_ptr::overload_rawbyptr($k), "rawbyptr", "rawbyptr");
    is(li_boost_shared_ptr::overload_rawbyptrref($k), "rawbyptrref", "rawbyptrref");

    is(li_boost_shared_ptr::overload_smartbyval($k), "smartbyval", "smartbyval");
    is(li_boost_shared_ptr::overload_smartbyref($k), "smartbyref", "smartbyref");
    is(li_boost_shared_ptr::overload_smartbyptr($k), "smartbyptr", "smartbyptr");
    is(li_boost_shared_ptr::overload_smartbyptrref($k), "smartbyptrref", "smartbyptrref");

    # Derived class
    $k = li_boost_shared_ptr::KlassDerived->new("me oh my");
    is(li_boost_shared_ptr::overload_rawbyval($k), "rawbyval", "rawbyval");
    is(li_boost_shared_ptr::overload_rawbyref($k), "rawbyref", "rawbyref");
    is(li_boost_shared_ptr::overload_rawbyptr($k), "rawbyptr", "rawbyptr");
    is(li_boost_shared_ptr::overload_rawbyptrref($k), "rawbyptrref", "rawbyptrref");

    is(li_boost_shared_ptr::overload_smartbyval($k), "smartbyval", "smartbyval");
    is(li_boost_shared_ptr::overload_smartbyref($k), "smartbyref", "smartbyref");
    is(li_boost_shared_ptr::overload_smartbyptr($k), "smartbyptr", "smartbyptr");
    is(li_boost_shared_ptr::overload_smartbyptrref($k), "smartbyptrref", "smartbyptrref");

    # 3rd derived class
    $k = li_boost_shared_ptr::Klass3rdDerived->new("me oh my");
    is($k->$getValue(), "me oh my-3rdDerived", 'Klass3rdDerived.new() value');
    is(li_boost_shared_ptr::use_count($k), 1, 'Klass3rdDerived.new() count');
    is(li_boost_shared_ptr::test3rdupcast($k), "me oh my-3rdDerived", 'test3rdupcast() value');
    is(li_boost_shared_ptr::use_count($k), 1, 'test3rdupcast() count');

    # //////////////////////////////// Member variables ////////////////////////////////////////
    # smart pointer by value
    $m = li_boost_shared_ptr::MemberVariables->new();
    $k = li_boost_shared_ptr::Klass->new("smart member value");
    $m->{SmartMemberValue} = $k;
    is($k->$getValue(), "smart member value", 'MemberVariables value');
    is(li_boost_shared_ptr::use_count($k), 2, 'MemberVariables count');

    $kmember = $m->{SmartMemberValue};
    is($kmember->$getValue(), "smart member value", 'SmartMemberValue value');
    is(li_boost_shared_ptr::use_count($kmember), 3, 'SmartMemberValue count');
    is(li_boost_shared_ptr::use_count($k), 3, 'SmartMemberValue count');

    undef $m;
    is(li_boost_shared_ptr::use_count($kmember), 2, 'SmartMemberValue count');
    is(li_boost_shared_ptr::use_count($k), 2, 'SmartMemberValue count');

    # smart pointer by pointer
    $m = li_boost_shared_ptr::MemberVariables->new();
    $k = li_boost_shared_ptr::Klass->new("smart member pointer");
    $m->{SmartMemberPointer} = $k;
    is($k->$getValue(), "smart member pointer");
    is(li_boost_shared_ptr::use_count($k), 1);

    $kmember = $m->{SmartMemberPointer};
    is($kmember->$getValue(), "smart member pointer");
    is(li_boost_shared_ptr::use_count($kmember), 2);
    is(li_boost_shared_ptr::use_count($k), 2);

    undef $m;
    is(li_boost_shared_ptr::use_count($kmember), 2);
    is(li_boost_shared_ptr::use_count($k), 2);

    # smart pointer by reference
    $m = li_boost_shared_ptr::MemberVariables->new();
    $k = li_boost_shared_ptr::Klass->new("smart member reference");
    $m->{SmartMemberReference} = $k;
    is($k->$getValue(), "smart member reference");
    is(li_boost_shared_ptr::use_count($k), 2);

    $kmember = $m->{SmartMemberReference};
    is($kmember->$getValue(), "smart member reference");
    is(li_boost_shared_ptr::use_count($kmember), 3);
    is(li_boost_shared_ptr::use_count($k), 3);

    # The C++ reference refers to SmartMemberValue...
    $kmemberVal = $m->{SmartMemberValue};
    is($kmember->$getValue(), "smart member reference");
    is(li_boost_shared_ptr::use_count($kmemberVal), 4);
    is(li_boost_shared_ptr::use_count($kmember), 4);
    is(li_boost_shared_ptr::use_count($k), 4);

    undef $m;
    is(li_boost_shared_ptr::use_count($kmemberVal), 3);
    is(li_boost_shared_ptr::use_count($kmember), 3);
    is(li_boost_shared_ptr::use_count($k), 3);

    # plain by value
    $m = li_boost_shared_ptr::MemberVariables->new();
    $k = li_boost_shared_ptr::Klass->new("plain member value");
    $m->{MemberValue} = $k;
    is($k->$getValue(), "plain member value");
    is(li_boost_shared_ptr::use_count($k), 1);

    $kmember = $m->{MemberValue};
    is($kmember->$getValue(), "plain member value");
    is(li_boost_shared_ptr::use_count($kmember), 1);
    is(li_boost_shared_ptr::use_count($k), 1);

    undef $m;
    is(li_boost_shared_ptr::use_count($kmember), 1);
    is(li_boost_shared_ptr::use_count($k), 1);

    # plain by pointer
    $m = li_boost_shared_ptr::MemberVariables->new();
    $k = li_boost_shared_ptr::Klass->new("plain member pointer");
    $m->{MemberPointer} = $k;
    is($k->$getValue(), "plain member pointer");
    is(li_boost_shared_ptr::use_count($k), 1);

    $kmember = $m->{MemberPointer};
    is($kmember->$getValue(), "plain member pointer");
    is(li_boost_shared_ptr::use_count($kmember), 1);
    is(li_boost_shared_ptr::use_count($k), 1);

    undef $m;
    is(li_boost_shared_ptr::use_count($kmember), 1);
    is(li_boost_shared_ptr::use_count($k), 1);

    # plain by reference
    $m = li_boost_shared_ptr::MemberVariables->new();
    $k = li_boost_shared_ptr::Klass->new("plain member reference");
    $m->{MemberReference} = $k;
    is($k->$getValue(), "plain member reference");
    is(li_boost_shared_ptr::use_count($k), 1);

    $kmember = $m->{MemberReference};
    is($kmember->$getValue(), "plain member reference");
    is(li_boost_shared_ptr::use_count($kmember), 1);
    is(li_boost_shared_ptr::use_count($k), 1);

    undef $m;
    is(li_boost_shared_ptr::use_count($kmember), 1);
    is(li_boost_shared_ptr::use_count($k), 1);

    # null member variables
    $m = li_boost_shared_ptr::MemberVariables->new();

    # shared_ptr by value
    $k = $m->{SmartMemberValue};
    is($k, undef);
    $m->{SmartMemberValue} = undef;
    $k = $m->{SmartMemberValue};
    is($k, undef);
    is(li_boost_shared_ptr::use_count($k), 0);

    # plain by value
    eval { $m->{MemberValue} = undef };
    like($@, qr/invalid null reference/);

    # ////////////////////////////////// Global variables ////////////////////////////////////////
    # smart pointer
    $kglobal = $li_boost_shared_ptr::GlobalSmartValue;
    is($kglobal, undef);

    $k = li_boost_shared_ptr::Klass->new("smart global value");
    $li_boost_shared_ptr::GlobalSmartValue = $k;
    is(li_boost_shared_ptr::use_count($k), 2);

    $kglobal = $li_boost_shared_ptr::GlobalSmartValue;
    is($kglobal->$getValue(), "smart global value");
    is(li_boost_shared_ptr::use_count($kglobal), 3);
    is(li_boost_shared_ptr::use_count($k), 3);
SKIP: {
    skip 'TODO: probably an issue with the const qualifier', 1;
    is(li_boost_shared_ptr::GlobalSmartValue->$getValue(), "smart global value");
}
    $li_boost_shared_ptr::GlobalSmartValue = undef;

    # plain value
    $k = li_boost_shared_ptr::Klass->new("global value");
    $li_boost_shared_ptr::GlobalValue = $k;
    is(li_boost_shared_ptr::use_count($k), 1);

    $kglobal = $li_boost_shared_ptr::GlobalValue;
    is($kglobal->$getValue(), "global value");
    is(li_boost_shared_ptr::use_count($kglobal), 1);
    is(li_boost_shared_ptr::use_count($k), 1);
    is($li_boost_shared_ptr::GlobalValue->$getValue(), "global value");

    eval { $li_boost_shared_ptr::GlobalValue = undef };
    like($@, qr/invalid null reference/);

    # plain pointer
    $kglobal = $li_boost_shared_ptr::GlobalPointer;
    is($kglobal, undef);

    $k = li_boost_shared_ptr::Klass->new("global pointer");
    $li_boost_shared_ptr::GlobalPointer = $k;
    is(li_boost_shared_ptr::use_count($k), 1);

    $kglobal = $li_boost_shared_ptr::GlobalPointer;
    is($kglobal->$getValue(), "global pointer");
    is(li_boost_shared_ptr::use_count($kglobal), 1);
    is(li_boost_shared_ptr::use_count($k), 1);
    undef $li_boost_shared_ptr::GlobalPointer;

    # plain reference
    $k = li_boost_shared_ptr::Klass->new("global reference");
    $li_boost_shared_ptr::GlobalReference = $k;
    is(li_boost_shared_ptr::use_count($k), 1);

    $kglobal = $li_boost_shared_ptr::GlobalReference;
    is($kglobal->$getValue(), "global reference");
    is(li_boost_shared_ptr::use_count($kglobal), 1);
    is(li_boost_shared_ptr::use_count($k), 1);

    eval { $li_boost_shared_ptr::GlobalReference = undef };
    like($@, qr/invalid null reference/);

    # ////////////////////////////////// Templates ////////////////////////////////////////
    my $pid = li_boost_shared_ptr::PairIntDouble->new(10, 20.2);
SKIP: {
    skip 'attributes of wrapped classes need to be mirrored', 4;
    is($pid->{baseVal1}, 20);
    is($pid->{baseVal2}, 40.4);
    is($pid->{val1}, 10);
    is($pid->{val2}, 20.2);
}
}
