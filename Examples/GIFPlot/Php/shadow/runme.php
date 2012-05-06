<?

# Plot a 3D function
include("gifplot.php");

# Here is the function to plot
function func($x, $y) {
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

$cmap  = new ColorMap("cmap");
$frame = new FrameBuffer(500,500);
$frame->clear(BLACK);


$p3    = new Plot3D($frame,$xmin,$ymin,$zmin,$xmax,$ymax,$zmax);
$p3->lookat(2*($zmax-$zmin));
$p3->autoperspective(40);
$p3->rotu(60);
$p3->rotr(30);
$p3->rotd(10);

function drawsolid() {
	global $xmax;
	global $xmin;
	global $ymax;
	global $ymin;
	global $zmin;
	global $zmax;
	global $nxpoints;
	global $nypoints;
	global $p3;

    $p3->clear(BLACK);
    $p3->start();
    $dx = 1.0*($xmax-$xmin)/$nxpoints;
    $dy = 1.0*($ymax-$ymin)/$nypoints;
    $cscale = 240.0/($zmax-$zmin);
    $x = $xmin;
    for ($i = 0; $i < $nxpoints; $i++) {
	$y = $ymin;
	for ($j = 0; $j < $nypoints; $j++) {
	    $z1 = func($x,$y);
	    $z2 = func($x+$dx,$y);
	    $z3 = func($x+$dx,$y+$dy);
	    $z4 = func($x,$y+$dy);
	    $c1 = $cscale*($z1-$zmin);
	    $c2 = $cscale*($z2-$zmin);
	    $c3 = $cscale*($z3-$zmin);
	    $c4 = $cscale*($z4-$zmin);
	    $c = ($c1+$c2+$c3+$c4)/4;
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

?>
