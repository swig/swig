use strict;
use warnings;
use Test::More tests => 12;
BEGIN { use_ok('rename_qualified') }
require_ok 'rename_qualified';

sub try (&$$) {
  my($test, $want, $name) = @_;
  my $tb = Test::Builder->new();
  my $got = eval { $test->() };
  if($@) {
    my $err = $@;
    $err =~ s/^/    /mg;
    $tb->diag($err);
    return $tb->ok(0, $name);
  }
  return $tb->is_eq($got, $want, $name);
}

TODO: {
  local $TODO = q(need to diagnose "Can't wrap XXX unless renamed to a valid identifier.");
  my $s = eval { rename_qualified::New::Struct->new() };
  try { $s->{InstanceVariable} } 111, 'InstanceVariable';
  try { $s->InstanceMethod() } 222, 'InstanceMethod';
  eval { $s->{NewInstanceVariable} = 1111 };
  try { $s->{NewInstanceVariable} } 1111, 'InstanceVariable write';
  try { rename_qualified::New::Struct::StaticMethod() } 333, 'StaticMethod';
  try { $rename_qualified::New::Struct::StaticVariable } 444, 'StaticVariable';
  eval { $rename_qualified::New::Struct::NewStaticVariable = 4444 };
  try { $rename_qualified::New::Struct::NewStaticVariable } 4444, 'StaticVariable write';
  try { rename_qualified::New::Function() } 555, 'Function';
  try { $rename_qualified::New::GlobalVariable } 666, 'GlobalVariable';
  eval { $rename_qualified::New::GlobalVariable = 6666 };
  try { $rename_qualified::New::GlobalVariable } 6666, 'GlobalVariable write';
}
try { $rename_qualified::New::Macro } 777, 'Macro';
