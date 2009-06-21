use strict;
use warnings;
use Test::More tests => 68;
BEGIN { use_ok('byreference') }
require_ok('byreference');

sub chk { my($type, $call, $v1, $v2) = @_;
    $byreference::FrVal = $v1;
    my $v = $v2;
    eval { $call->(\$v) };
    is($@, '', "$type check");
    is($byreference::ToVal, $v2, "$type out");
    is($v, $v1, "$type in");
}
chk("double*", \&byreference::PDouble, 12.2, 18.6);
chk("double&", \&byreference::RDouble, 32.5, 64.8);
chk("float*",  \&byreference::PFloat,  64.5, 96.0);
chk("float&",  \&byreference::RFloat,  98.5, 6.25);
chk("int*",    \&byreference::PInt,    1887, 3356);
chk("int&",    \&byreference::RInt,    2622, 9867);
chk("short*",  \&byreference::PShort,  4752, 3254);
chk("short&",  \&byreference::RShort,  1898, 5757);
chk("long*",   \&byreference::PLong,   6687, 7132);
chk("long&",   \&byreference::RLong,   8346, 4398);
chk("uint*",   \&byreference::PUInt,   6853, 5529);
chk("uint&",   \&byreference::RUInt,   5483, 7135);
chk("ushort*", \&byreference::PUShort, 9960, 9930);
chk("ushort&", \&byreference::RUShort, 1193, 4178);
chk("ulong*",  \&byreference::PULong,  7960, 4788);
chk("ulong&",  \&byreference::RULong,  8829, 1603);
chk("uchar*",  \&byreference::PUChar,  110,  239);
chk("uchar&",  \&byreference::RUChar,  15,   97);
chk("char*",   \&byreference::PChar,   -7,   118);
chk("char&",   \&byreference::RChar,   -3,  -107);
chk("bool*",   \&byreference::PBool,   0,    1);
chk("bool&",   \&byreference::RBool,   1,    0);
