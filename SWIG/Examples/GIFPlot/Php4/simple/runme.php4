<?

# Draw some simple shapes
print "Drawing some basic shapes\n";

require "simple.php";

$cmap = new_ColorMap();
$f    = new_FrameBuffer(400,400);

# Clear the picture
FrameBuffer_clear($f,BLACK);

# Make a red box
FrameBuffer_box($f,40,40,200,200,RED);

# Make a blue circle
FrameBuffer_circle($f,200,200,40,BLUE);

# Make green line
FrameBuffer_line($f,10,390,390,200, GREEN);

# Write an image out to disk

FrameBuffer_writeGIF($f,$cmap,"image.gif");
print "Wrote image.gif\n";

delete_FrameBuffer($f);
delete_ColorMap($cmap);

?>

