<?

# Draw some simple shapes
print "Drawing some basic shapes\n";

dl("simple.so");

$cmap = new_ColorMap();
$f    = new_FrameBuffer(400,400);

# Clear the picture
FrameBuffer_clear($f,$simple::BLACK);

# Make a red box
FrameBuffer_box($f,40,40,200,200,$simple::RED);

# Make a blue circle
FrameBuffer_circle($f,200,200,40,$simple::BLUE);

# Make green line
FrameBuffer_line($f,10,390,390,200, $simple::GREEN);

# Write an image out to disk

FrameBuffer_writeGIF($f,$cmap,"image.gif");
print "Wrote image.gif\n";

delete_FrameBuffer($f);
delete_ColorMap($cmap);

?>

