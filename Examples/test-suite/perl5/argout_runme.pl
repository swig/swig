use strict;
use warnings;
use Test::More tests => 9;
BEGIN { use_ok('argout') }
require_ok('argout');

sub check { my($c, $l) = @_;
  my $ptr = argout::new_intp();
  argout::intp_assign($ptr, 5);
  is($c->($ptr), 5, "rv $l");
  is(argout::intp_value($ptr), 6, "av $l");
  argout::delete_intp($ptr);
}

check(\&argout::incp, 'incp');
check(\&argout::incr, 'incp');
check(\&argout::inctr, 'incp');

# TODO:
# if we add this to argout.i
#    %inline %{
#      typedef void *vptr;
#    %}
#    %pointer_functions(vptr, vpp);
# then this test will work
SKIP: {
  skip 'need voidpp handler', 1, unless argout->can('new_vpp');
  my $vpp = argout::new_vpp();
  argout::voidhandle($vpp);
  my $vp = argout::vpp_value($vpp);
  argout::delete_vpp($vpp);
  is(argout::handle($vp), 'Here it is', 'opaque void ptr');
}
