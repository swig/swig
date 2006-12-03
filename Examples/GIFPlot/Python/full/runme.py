# Plot a 3D function
# This example uses the low-level C interface.

from _gifplot import *
from math import *

# Here is the function to plot
def func(x,y):
	return 5*cos(2*sqrt(x*x+y*y))*exp(-0.3*sqrt(x*x+y*y))

# Here are some plotting parameters
xmin = -5.0
xmax =  5.0
ymin = -5.0
ymax =  5.0
zmin = -5.0
zmax =  5.0

# Grid resolution
nxpoints =  60
nypoints =  60

cmap  = new_ColorMap("cmap")
frame = new_FrameBuffer(500,500)
FrameBuffer_clear(frame,BLACK)

p3    = new_Plot3D(frame,xmin,ymin,zmin,xmax,ymax,zmax)
Plot3D_lookat(p3,2*max([xmax-xmin,ymax-ymin,zmax-zmin]))
Plot3D_autoperspective(p3,40)
Plot3D_rotu(p3,60)
Plot3D_rotr(p3,30)
Plot3D_rotd(p3,10)

def drawsolid():
	Plot3D_clear(p3,BLACK)
	Plot3D_start(p3)
	dx = 1.0*(xmax-xmin)/nxpoints
	dy = 1.0*(ymax-ymin)/nypoints
	cscale = 240.0/(zmax-zmin)
	x = xmin
	for i in xrange(0,nxpoints):
		y = ymin
		for j in xrange(0,nypoints):
			z1 = func(x,y)
			z2 = func(x+dx,y)
			z3 = func(x+dx,y+dy)
			z4 = func(x,y+dy)
			c1 = cscale*(z1-zmin)
			c2 = cscale*(z2-zmin)
			c3 = cscale*(z3-zmin)
			c4 = cscale*(z4-zmin)
			c = int((c1+c2+c3+c4)/4)
			if (c < 0) : c = 0
			if c > 239 : c = 239
			Plot3D_solidquad(p3,x,y,z1,x+dx,y,z2,x+dx,y+dy,z3,x,y+dy,z4,c+16)
			y = y + dy		
		x = x + dx

print "Making a nice 3D plot..."
drawsolid()

FrameBuffer_writeGIF(frame,cmap,"image.gif")
print "Wrote image.gif"

