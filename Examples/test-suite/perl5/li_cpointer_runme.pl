use strict;
use warnings;
use Test::More tests => 3;
BEGIN { use_ok('li_cpointer') }
require_ok('li_cpointer');

my $p = li_cpointer::new_intp();
li_cpointer::intp_assign($p, 3);
is(li_cpointer::intp_value($p), 3);
li_cpointer::delete_intp($p);
