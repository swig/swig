<?

dl("libexample.so");

print "ICONST  = " . ICONST . " (should be 42)\n";
print "FCONST  = " . FCONST . " (should be 2.1828)\n";
print "CCONST  = " . CCONST . " (should be 'x')\n";
print "CCONST2 = " . CCONST2 . " (this should be on a new line)\n";
print "SCONST  = " . SCONST . " (should be 'Hello World')\n";
print "SCONST2 = " . SCONST2 . " (should be '\"Hello World\"')\n";
print "EXPR    = " . EXPR  . " (should be 48.5484)\n";
print "iconst  = " . iconst . " (should be 37)\n";
print "fconst  = " . fconst . " (should be 3.14)\n";


if (EXTERN) {
    print "EXTERN = " . EXTERN . " (Arg! This shouldn't print anything)\n";
} else {
    print "EXTERN isn't defined (good)\n";
}

if (FOO) {
    print "FOO    = " . FOO . "(Arg! This shouldn't print anything)\n";
} else {
    print "FOO isn't defined (good)\n";
}


?>
