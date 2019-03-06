use strict;
use warnings;
use Test::More tests => 9;
BEGIN { use_ok('rename_wildcard') }
require_ok 'rename_wildcard';

sub run_ok(&$) {
  my($test, $name) = @_;
  my $tb = Test::More->builder();
  eval { $test->() };
  return $tb->is_eq($@, '', $name);
}

run_ok {
  rename_wildcard::GlobalWildStruct->new()->mm1();
  rename_wildcard::GlobalWildTemplateStructInt->new()->mm1();
  rename_wildcard::SpaceWildStruct->new()->mm1();
  rename_wildcard::SpaceWildTemplateStructInt->new()->mm1();
} 'Wildcard check';
run_ok {
  rename_wildcard::GlobalWildStruct->new()->mm2a();
  rename_wildcard::GlobalWildTemplateStructInt->new()->mm2b();
  rename_wildcard::SpaceWildStruct->new()->mm2c();
  rename_wildcard::SpaceWildTemplateStructInt->new()->mm2d();

  rename_wildcard::GlobalWildTemplateStructInt->new()->tt2b();
  rename_wildcard::SpaceWildTemplateStructInt->new()->tt2d();
}'No declaration';
run_ok {
  rename_wildcard::GlobalWildStruct->new()->mm3a();
  rename_wildcard::GlobalWildTemplateStructInt->new()->mm3b();
  rename_wildcard::SpaceWildStruct->new()->mm3c();
  rename_wildcard::SpaceWildTemplateStructInt->new()->mm3d();

  rename_wildcard::GlobalWildTemplateStructInt->new()->tt3b();
  rename_wildcard::SpaceWildTemplateStructInt->new()->tt3d();
} 'With declaration';
run_ok {
  rename_wildcard::GlobalWildStruct->new()->mm4a();
  rename_wildcard::GlobalWildTemplateStructInt->new()->mm4b();
  rename_wildcard::SpaceWildStruct->new()->mm4c();
  rename_wildcard::SpaceWildTemplateStructInt->new()->mm4d();

  rename_wildcard::GlobalWildTemplateStructInt->new()->tt4b();
  rename_wildcard::SpaceWildTemplateStructInt->new()->tt4d();
} 'Global override too';
run_ok {
  rename_wildcard::GlobalWildStruct->new()->mm5a();
  rename_wildcard::GlobalWildTemplateStructInt->new()->mm5b();
  rename_wildcard::SpaceWildStruct->new()->mm5c();
  rename_wildcard::SpaceWildTemplateStructInt->new()->mm5d();

  rename_wildcard::GlobalWildTemplateStructInt->new()->tt5b();
  rename_wildcard::SpaceWildTemplateStructInt->new()->tt5d();
} '%extend renames';
run_ok {
  rename_wildcard::GlobalWildStruct->new()->opinta();
  rename_wildcard::GlobalWildTemplateStructInt->new()->opintb();
  rename_wildcard::SpaceWildStruct->new()->opintc();
  rename_wildcard::SpaceWildTemplateStructInt->new()->opintd();

  rename_wildcard::GlobalWildTemplateStructInt->new()->opdoubleb();
  rename_wildcard::SpaceWildTemplateStructInt->new()->opdoubled();
} 'operators';
run_ok {
  rename_wildcard::NoChangeStruct->new()->mm1();
  rename_wildcard::NoChangeStruct->new()->mm2();
  rename_wildcard::NoChangeStruct->new()->mm3();
  rename_wildcard::NoChangeStruct->new()->mm4();
  rename_wildcard::NoChangeStruct->new()->mm5();
  rename_wildcard::NoChangeStruct->new()->opint();
  rename_wildcard::SpaceNoChangeStruct->new()->mm1();
  rename_wildcard::SpaceNoChangeStruct->new()->mm2();
  rename_wildcard::SpaceNoChangeStruct->new()->mm3();
  rename_wildcard::SpaceNoChangeStruct->new()->mm4();
  rename_wildcard::SpaceNoChangeStruct->new()->mm5();
  rename_wildcard::SpaceNoChangeStruct->new()->opint();
} 'Wildcard renames expected for these';
