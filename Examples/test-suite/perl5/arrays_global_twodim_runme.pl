use strict;
use warnings;
use Test::More tests => 19;
BEGIN { use_ok('arrays_global_twodim') }
require_ok('arrays_global_twodim');

isnt($arrays_global_twodim::array_c, undef, 'array_c');
isnt($arrays_global_twodim::array_sc, undef, 'array_sc');
isnt($arrays_global_twodim::array_uc, undef, 'array_uc');
isnt($arrays_global_twodim::array_s, undef, 'array_s');
isnt($arrays_global_twodim::array_us, undef, 'array_us');
isnt($arrays_global_twodim::array_i, undef, 'array_i');
isnt($arrays_global_twodim::array_l, undef, 'array_l');
isnt($arrays_global_twodim::array_ul, undef, 'array_ul');
isnt($arrays_global_twodim::array_ll, undef, 'array_ll');
isnt($arrays_global_twodim::array_f, undef, 'array_f');
isnt($arrays_global_twodim::array_d, undef, 'array_d');
isnt($arrays_global_twodim::array_struct, undef, 'array_struct');
isnt($arrays_global_twodim::array_structpointers, undef, 'array_structpointers');
isnt($arrays_global_twodim::array_ipointers, undef, 'array_ipointers');
isnt($arrays_global_twodim::array_enum, undef, 'array_enum');
isnt($arrays_global_twodim::array_enumpointers, undef, 'array_enumpointers');
isnt($arrays_global_twodim::array_const_i, undef, 'array_const_i');
