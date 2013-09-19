use strict;
use warnings;
use Test::More tests => 4;
BEGIN { use_ok('keyword_rename') }
require_ok('keyword_rename');

# Perl is pretty permissive here, and SWIG isn't modifying the main
# namespace, so no renames are necessary.  Let's just make sure that the
# "tie" and "use" functions got exposed.

is(keyword_rename::use(12), 12);
is(keyword_rename::tie(16), 16);
