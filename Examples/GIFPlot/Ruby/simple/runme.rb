# Draw some simple shapes
puts "Drawing some basic shapes"
require 'simple'

cmap = Simple.new_ColorMap()
f    = Simple.new_FrameBuffer(400,400)

# Clear the picture
Simple.FrameBuffer_clear(f,Simple::BLACK)

# Make a red box
Simple.FrameBuffer_box(f,40,40,200,200,Simple::RED)

# Make a blue circle
Simple.FrameBuffer_circle(f,200,200,40,Simple::BLUE)

# Make green line
Simple.FrameBuffer_line(f,10,390,390,200, Simple::GREEN)

# Write an image out to disk

Simple.FrameBuffer_writeGIF(f,cmap,"image.gif")
puts "Wrote image.gif"

Simple.delete_FrameBuffer(f)
Simple.delete_ColorMap(cmap)

