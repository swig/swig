use strict;
use warnings;
use Test::More 'no_plan';
BEGIN { use_ok('global_namespace') }
require_ok('global_namespace');

BEGIN { # namespace hack
  %{*::} = (%{*global_namespace::}, %{*::});
}

my $k1 = Klass1->new();
my $k2 = Klass2->new();
my $k3 = Klass3->new();
my $k4 = Klass4->new();
my $k5 = Klass5->new();
my $k6 = Klass6->new();
my $k7 = Klass7->new();

KlassMethods->methodA($k1, $k2, $k3, $k4, $k5, $k6, $k7);
KlassMethods->methodB($k1, $k2, $k3, $k4, $k5, $k6, $k7);

$k1 = getKlass1A();
$k2 = getKlass2A();
$k3 = getKlass3A();
$k4 = getKlass4A();
$k5 = getKlass5A();
$k6 = getKlass6A();
$k7 = getKlass7A();

KlassMethods->methodA($k1, $k2, $k3, $k4, $k5, $k6, $k7);
KlassMethods->methodB($k1, $k2, $k3, $k4, $k5, $k6, $k7);

$k1 = getKlass1B();
$k2 = getKlass2B();
$k3 = getKlass3B();
$k4 = getKlass4B();
$k5 = getKlass5B();
$k6 = getKlass6B();
$k7 = getKlass7B();

KlassMethods->methodA($k1, $k2, $k3, $k4, $k5, $k6, $k7);
KlassMethods->methodB($k1, $k2, $k3, $k4, $k5, $k6, $k7);

XYZMethods->methodA(XYZ1->new(), XYZ2->new(), XYZ3->new(), XYZ4->new(), XYZ5->new(), XYZ6->new(), XYZ7->new());
XYZMethods->methodB(XYZ1->new(), XYZ2->new(), XYZ3->new(), XYZ4->new(), XYZ5->new(), XYZ6->new(), XYZ7->new());

TheEnumMethods->methodA($theenum1, $theenum2, $theenum3);
TheEnumMethods->methodA($theenum1, $theenum2, $theenum3);
