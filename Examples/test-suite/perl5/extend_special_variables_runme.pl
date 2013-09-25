use strict;
use warnings;
use Test::More tests => 5;
BEGIN { use_ok('extend_special_variables') }
require_ok('extend_special_variables');

my $f = extend_special_variables::ForExtensionNewName->new();
isa_ok($f, 'extend_special_variables::ForExtensionNewName');
is($f->extended_renamed(), 'name:extended symname:extended_renamed wrapname: overname:__SWIG_0 decl:ForExtension::extended() fulldecl:char const * ForExtension::extended() parentclasssymname:ForExtensionNewName parentclassname:ForExtension', 'f.extended_renamed()');
is($f->extended_renamed(10), 'name:extended symname:extended_renamed wrapname: overname:__SWIG_1 decl:ForExtension::extended(int) fulldecl:char const * ForExtension::extended(int) parentclasssymname:ForExtensionNewName parentclassname:ForExtension', 'f.extended_renamed(i)');

