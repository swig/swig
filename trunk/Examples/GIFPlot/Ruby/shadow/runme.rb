# Plot a 3D function
require 'gifplot'
include Math

# Here is the function to plot
def func(x,y)
  return 5*cos(2*sqrt(x*x+y*y))*exp(-0.3*sqrt(x*x+y*y))
end

# Here are some plotting parameters
XMIN = -5.0
XMAX =  5.0
YMIN = -5.0
YMAX =  5.0
ZMIN = -5.0
ZMAX =  5.0

# Grid resolution
NXPOINTS =  60
NYPOINTS =  60

cmap  = Gifplot::ColorMap.new("cmap")
frame = Gifplot::FrameBuffer.new(500,500)
frame.clear(Gifplot::BLACK)

P3    = Gifplot::Plot3D.new(frame,XMIN,YMIN,ZMIN,XMAX,YMAX,ZMAX)
P3.lookat(2*[XMAX-XMIN,YMAX-YMIN,ZMAX-ZMIN].max)
P3.autoperspective(40)
P3.rotu(60)
P3.rotr(30)
P3.rotd(10)

def drawsolid()
  P3.clear(Gifplot::BLACK)
  P3.start()
  dx = 1.0*(XMAX-XMIN)/NXPOINTS
  dy = 1.0*(YMAX-YMIN)/NYPOINTS
  cscale = 240.0/(ZMAX-ZMIN)
  x = XMIN
  for i in 0...NXPOINTS
    y = YMIN
    for j in 0...NYPOINTS
      z1 = func(x,y)
      z2 = func(x+dx,y)
      z3 = func(x+dx,y+dy)
      z4 = func(x,y+dy)
      c1 = cscale*(z1-ZMIN)
      c2 = cscale*(z2-ZMIN)
      c3 = cscale*(z3-ZMIN)
      c4 = cscale*(z4-ZMIN)
      c = (c1+c2+c3+c4)/4
      c = 0 if (c < 0)
      c = 239 if c > 239
      P3.solidquad(x,y,z1,x+dx,y,z2,x+dx,y+dy,z3,x,y+dy,z4,c+16)
      y = y + dy
    end
    x = x + dx
  end
end

puts "Making a nice 3D plot..."
drawsolid()

frame.writeGIF(cmap,"image.gif")
puts "Wrote image.gif"

