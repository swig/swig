# Draw some simple shapes
puts "Drawing some basic shapes"

catch { load ./simple[info sharedlibextension] simple}

set cmap [new_ColorMap]
set f    [new_FrameBuffer 400 400]

# Clear the picture
FrameBuffer_clear $f $BLACK

# Make a red box
FrameBuffer_box $f 40 40 200 200 $RED

# Make a blue circle
FrameBuffer_circle $f 200 200 40 $BLUE

# Make green line
FrameBuffer_line $f 10 390 390 200 $GREEN

# Write an image out to disk
FrameBuffer_writeGIF $f $cmap image.gif
puts "Wrote image.gif"

delete_FrameBuffer $f
delete_ColorMap $cmap

