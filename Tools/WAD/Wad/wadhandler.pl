package libwadpl;
sub wad_handler_traceback {
    package DB;
    my $es = "";
    ($pack,$file,$line) = caller(1);

    for ($i = 2; ($p,$f,$l,$s,$h,$w,$e,$r) = caller($i); $i++) {
        @a = ();
        for $arg (@args) {
            $_ = "$arg";
            s/([\'\\])/\\$1/g;
            s/([^\0]*)/'$1'/
              unless /^(?: -?[\d.]+ | \*[\w:]* )$/x;
            s/([\200-\377])/sprintf("M-%c",ord($1)&0177)/eg;
            s/([\0-\37\177])/sprintf("^%c",ord($1)^64)/eg;
            push(@a, $_);
        }
        $w = $w ? '@ = ' : '$ = ';
        $a = $h ? '(' . join(', ', @a) . ')' : '';
        $e =~ s/\n\s*\;\s*\Z// if $e;
        $e =~ s/[\\\']/\\$1/g if $e;
        if ($r) {
            $s = "require '$e'";
        } elsif (defined $r) {
            $s = "eval '$e'";
        } elsif ($s eq '(eval)') {
            $s = "eval {...}";
        }
        $f = "file `$f'" unless $f eq '-e';
        $mess = "$w$s$a called from $f line $l\n";
	$es = $mess . $es;

    }
    $es = "Signal at $file line $line\n" . $es;
    return $es;
}
