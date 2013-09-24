use strict;
use warnings;
use Test::More tests => 11;
BEGIN { use_ok('li_cstring') }
require_ok('li_cstring');

is(li_cstring::count("ab\0ab\0ab\0", 0), 3);
is(li_cstring::test1(), 'Hello World');
is(li_cstring::test2(), ' !"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_');
is(li_cstring::test3('hello'), 'hello-suffix');
is(li_cstring::test4('hello'), 'hello-suffix');
is(li_cstring::test5(4), 'xxxx');
is(li_cstring::test6(10), 'xxxxx');
is(li_cstring::test7(), 'Hello world!');
is(li_cstring::test8(), ' !"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_');
