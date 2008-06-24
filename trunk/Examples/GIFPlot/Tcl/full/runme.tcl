# Plot a 3D function

catch { load ./gifplot[info sharedlibextension] gifplot}

# Here is the function to plot
proc func { x y } {
    return [expr { 5*cos(2*sqrt($x*$x+$y*$y))*exp(-0.3*sqrt($x*$x+$y*$y)) }]
}

# Here are some plotting parameters
set xmin  -5.0
set xmax   5.0
set ymin  -5.0
set ymax   5.0
set zmin  -5.0
set zmax   5.0

# Grid resolution
set nxpoints  60
set nypoints  60

set cmap [new_ColorMap cmap]
set frame [new_FrameBuffer 500 500]
FrameBuffer_clear $frame $BLACK

set p3 [new_Plot3D $frame $xmin $ymin $zmin $xmax $ymax $zmax ]
Plot3D_lookat $p3 [expr {2*($zmax-$zmin)}]
Plot3D_autoperspective $p3 40
Plot3D_rotu $p3 60
Plot3D_rotr $p3 30
Plot3D_rotd $p3 10

proc drawsolid { } {
    global xmin ymin zmin xmax ymax zmax nxpoints nypoints p3 BLACK
    Plot3D_clear $p3 $BLACK
    Plot3D_start $p3
    set dx [expr {1.0*($xmax-$xmin)/$nxpoints}]
    set dy [expr {1.0*($ymax-$ymin)/$nypoints}]
    set cscale [expr {240.0/($zmax-$zmin)}]
    set x $xmin
    for {set i 0} {$i < $nxpoints} {incr i 1} {
	set y $ymin
	for {set j 0} {$j < $nypoints} {incr j 1} {
	    set z1  [func $x $y]
	    set z2  [func [expr {$x+$dx}] $y]
	    set z3  [func [expr {$x+$dx}] [expr {$y+$dy}]]
	    set z4  [func $x [expr {$y+$dy}]]
	    set c1  [expr {$cscale*($z1-$zmin)}]
	    set c2  [expr {$cscale*($z2-$zmin)}]
	    set c3  [expr {$cscale*($z3-$zmin)}]
	    set c4  [expr {$cscale*($z4-$zmin)}]
	    set c [expr {int(($c1+$c2+$c3+$c4)/4)}]
	    if {$c < 0} { set c 0 }
	    if {$c > 239} { set c 239 }
	    Plot3D_solidquad $p3 $x $y $z1 [expr {$x+$dx}] $y $z2 [expr {$x+$dx}] [expr {$y+$dy}] $z3 $x [expr {$y+$dy}] $z4 [expr {$c+16}]
	    set y [expr {$y + $dy}]
	}
	set x [expr {$x + $dx}]
    }
}

puts "Making a nice 3D plot..."
drawsolid

FrameBuffer_writeGIF $frame $cmap "image.gif"
puts "Wrote image.gif"

