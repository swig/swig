use li_cdata_carrays;

$a = li_cdata_carrays::intArray->new(5);
for (0..4) {
  $a->setitem($_, $_**2);
}
$x = pack q{I5}, map $_**2, (0..4);
$y = li_cdata_carrays::cdata_int($a->cast, 5);
if ( $x ne $y ) {
  die "$x  vs   $y";
}
