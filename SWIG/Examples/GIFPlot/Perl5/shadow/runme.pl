# Plot a 3D function
use gifplot;
package gifplot;

# Here is the function to plot
sub func {
    my $x = shift;
    my $y = shift;
    return 5*cos(2*sqrt($x*$x+$y*$y))*exp(-0.3*sqrt($x*$x+$y*$y));
}

# Here are some plotting parameters
$xmin = -5.0;
$xmax =  5.0;
$ymin = -5.0;
$ymax =  5.0;
$zmin = -5.0;
$zmax =  5.0;

# Grid resolution
$nxpoints =  60;
$nypoints =  60;

$cmap  = new gifplot::ColorMap("cmap");
$frame = new gifplot::FrameBuffer(500,500);
$frame->clear($BLACK);

$p3    = new gifplot::Plot3D($frame,$xmin,$ymin,$zmin,$xmax,$ymax,$zmax);
$p3->lookat(2*($zmax-$zmin));
$p3->autoperspective(40);
$p3->rotu(60);
$p3->rotr(30);
$p3->rotd(10);

sub drawsolid {
    $p3->clear($BLACK);
    $p3->start();
    my $dx = 1.0*($xmax-$xmin)/$nxpoints;
    my $dy = 1.0*($ymax-$ymin)/$nypoints;
    my $cscale = 240.0/($zmax-$zmin);
    my $x = $xmin;
    for ($i = 0; $i < $nxpoints; $i++) {
	my $y = $ymin;
	for ($j = 0; $j < $nypoints; $j++) {
	    my $z1 = func($x,$y);
	    my $z2 = func($x+$dx,$y);
	    my $z3 = func($x+$dx,$y+$dy);
	    my $z4 = func($x,$y+$dy);
	    my $c1 = $cscale*($z1-$zmin);
	    my $c2 = $cscale*($z2-$zmin);
	    my $c3 = $cscale*($z3-$zmin);
	    my $c4 = $cscale*($z4-$zmin);
	    my $c = ($c1+$c2+$c3+$c4)/4;
	    if ($c < 0) { $c = 0; }
	    if ($c > 239) { $c = 239; }
	    $p3->solidquad($x,$y,$z1,$x+$dx,$y,$z2,$x+$dx,$y+$dy,$z3,$x,$y+$dy,$z4,$c+16);
	    $y = $y + $dy;
	}
	$x = $x + $dx;
    }
}

print "Making a nice 3D plot...\n";
drawsolid();

$frame->writeGIF($cmap,"image.gif");
print "Wrote image.gif\n";

