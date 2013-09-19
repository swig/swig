use strict;
use warnings;
use Test::More 'no_plan';
BEGIN {
  use_ok('import_stl_a');
  use_ok('import_stl_b');
}
require_ok('import_stl_a');
require_ok('import_stl_b');

my $v_new = import_stl_b::process_vector([1, 2, 3]);
is_deeply($v_new, [1, 2, 3, 4]);
