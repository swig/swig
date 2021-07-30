use strict;
use warnings;
use Test::More tests => 44;
BEGIN { use_ok('scilab_multivalue') }
require_ok('scilab_multivalue');

my($a, $b, $c, $d, $ret);

# OUTPUT

($a, $b) = scilab_multivalue::output2();
is($a, 1, "[a, b] = output2(): a");
is($b, 2, "[a, b] = output2(): b");

($ret, $a, $b) = scilab_multivalue::output2Ret();
is($ret, 3, "[a, b] = output2Ret(): b");
is($a, 1, "[a, b] = output2Ret(): a");
is($b, 2, "[a, b] = output2Ret(): b");

($c, $d) = scilab_multivalue::output2Input2(1, 2);
is($c, 2, "[c, d] = output2Input2(1, 2): c");
is($d, 4, "[c, d] = output2Input2(1, 2): d");

($ret, $c, $d) = scilab_multivalue::output2Input2Ret(1, 2);
is($ret, 6, "[ret, c, d] = output2Input2Ret(1, 2): ret");
is($c, 2, "[ret, c, d] = output2Input2Ret(1, 2): c");
is($d, 4, "[ret, c, d = output2Input2Ret(1, 2): d");

($ret, $a, $b, $c) = scilab_multivalue::output3Input1Ret(10);
is($ret, 10, "[ret, a, b, c] = output3Input1Ret(10): ret");
is($a, 11, "[ret, a, b, c] = output3Input1Ret(10): a");
is($b, 12, "[ret, a, b, c] = output3Input1Ret(10): b");
is($c, 13, "[ret, a, b, c] = output3Input1Ret(10): c");

($ret, $a, $b, $c) = scilab_multivalue::output3Input3Ret(10, 20, 30);
is($ret, 66, "[ret, a, b, c] = output3Input1Ret(10, 20, 30): ret");
is($a, 11, "[ret, a, b, c] = output3Input1Ret(10, 20, 30): a");
is($b, 22, "[ret, a, b, c] = output3Input1Ret(10, 20, 30): b");
is($c, 33, "[ret, a, b, c] = output3Input1Ret(10, 20, 30): c");


# INOUT

($a, $b) = scilab_multivalue::inout2(1, 2);
is($a, 2, "[a, b] = output2(1, 2): a");
is($b, 4, "[a, b] = output2(1, 2): b");

($ret, $a, $b) = scilab_multivalue::inout2Ret(1, 2);
is($ret, 6, "[a, b] = inout2Ret(1, 2): b");
is($a, 2, "[a, b] = inout2Ret(1, 2): a");
is($b, 4, "[a, b] = inout2Ret(1, 2): b");

($c, $d) = scilab_multivalue::inout2Input2(1, 2, 1, 1);
is($c, 2, "[c, d] = inout2Input2(1, 2): c");
is($d, 3, "[c, d] = inout2Input2(1, 2): d");

($ret, $c, $d) = scilab_multivalue::inout2Input2Ret(1, 2, 1, 1);
is($ret, 5, "[c, d] = inout2Input2Ret(1, 2): ret");
is($c, 2, "[c, d] = inout2Input2Ret(1, 2): c");
is($d, 3, "[c, d] = inout2Input2Ret(1, 4): d");

($ret, $a, $b, $c) = scilab_multivalue::inout3Input1Ret(10, 1, 2, 3);
is($ret, 10, "[ret, a, b, c] = output3Input1Ret(ret, 1, 2, 3): ret");
is($a, 11, "[ret, a, b, c] = output3Input1Ret(ret, 1, 2, 3): a");
is($b, 12, "[ret, a, b, c] = output3Input1Ret(ret, 1, 2, 3): b");
is($c, 13, "[ret, a, b, c] = output3Input1Ret(ret, 1, 2, 3): c");

($ret, $a, $b, $c) = scilab_multivalue::inout3Input3Ret(10, 1, 20, 2, 30, 3);
is($ret, 66, "[ret, a, b, c] = output3Input1Ret(10, 20, 30): ret");
is($a, 11, "[ret, a, b, c] = inout3Input1Ret(10, 1, 20, 2, 30, 3): a");
is($b, 22, "[ret, a, b, c] = inout3Input1Ret(10, 1, 20, 2, 30, 3): b");
is($c, 33, "[ret, a, b, c] = inout3Input1Ret(10, 1, 20, 2, 30, 3): c");


# CLASS

$a = scilab_multivalue::ClassA->new();

($ret, $c, $d) = $a->output2Input2Ret(1, 2);
is($ret, 6, "[ret, c, d] = ClassA_output2Input2Ret(a, 1, 2): ret");
is($c, 2, "[c, d] = ClassA_output2Input2Ret(a, 1, 2): c");
is($d, 4, "[c, d] = ClassA_output2Input2Ret(a, 1, 2): d");

($ret, $c, $d) = $a->inout2Input2Ret(1, 2, 1, 1);
is($ret, 5, "[ret, c, d] = ClassA_inout2Input2Ret(a, 1, 2): ret");
is($c, 2, "[c, d] = ClassA_inout2Input2(a, 1, 2): c");
is($d, 3, "[c, d] = ClassA_inout2Input2(a, 1, 2): d");

