<?php

print "ICONST  = " . ICONST . " (should be 42)\n";
print "FCONST  = " . FCONST . " (should be 2.1828)\n";
print "CCONST  = " . CCONST . " (should be 'x')\n";
print "CCONST2 = " . CCONST2 . " (this should be on a new line)\n";
print "SCONST  = " . SCONST . " (should be 'Hello World')\n";
print "SCONST2 = " . SCONST2 . " (should be '\"Hello World\"')\n";
print "EXPR    = " . EXPR  . " (should be 48.5484)\n";
print "iconst  = " . iconst . " (should be 37)\n";
print "fconst  = " . fconst . " (should be 3.14)\n";

$c = get_defined_constants();
if (array_key_exists("EXTERN", $c)) {
    print "EXTERN = " . $c["EXTERN"] . " (Arg! This shouldn't print anything)\n";
}
if (array_key_exists("FOO", $c)) {
    print "FOO    = " . $c["FOO"] . " (Arg! This shouldn't print anything)\n";
}
