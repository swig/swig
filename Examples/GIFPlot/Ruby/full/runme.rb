# Plot a 3D function
require 'gifplot'
include Gifplot
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

cmap  = new_ColorMap("cmap")
frame = new_FrameBuffer(500,500)
FrameBuffer_clear(frame,BLACK)

P3    = new_Plot3D(frame,XMIN,YMIN,ZMIN,XMAX,YMAX,ZMAX)
Plot3D_lookat(P3,2*[XMAX-XMIN,YMAX-YMIN,ZMAX-ZMIN].max)
Plot3D_autoperspective(P3,40)
Plot3D_rotu(P3,60)
Plot3D_rotr(P3,30)
Plot3D_rotd(P3,10)

def drawsolid()
  Plot3D_clear(P3,BLACK)
  Plot3D_start(P3)
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
      Plot3D_solidquad(P3,x,y,z1,x+dx,y,z2,x+dx,y+dy,z3,x,y+dy,z4,c+16)
      y = y + dy
    end
    x = x + dx
  end
end

puts "Making a nice 3D plot..."
drawsolid()

FrameBuffer_writeGIF(frame,cmap,"image.gif")
puts "Wrote image.gif"
