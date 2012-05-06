catch { load ./gifplot[info sharedlibextension] }
source display.tcl
set tcl_precision 17
set f [FrameBuffer -args 400 400]
set cmap [ColorMap -args cmap]
set p2 [Plot2D -args $f -3 -2 1 2]

set xmin -3
set xmax 1
set ymin -2.0
set ymax 2.0
set tolerance 240
set filename mandel.gif

# Make a plot from the above parms

proc make_plot {} {
    global p2 cmap tolerance
    global xmin ymin xmax ymax filename
    $p2 setrange $xmin $ymin $xmax $ymax
    $p2 start
    . config -cursor watch
    update
    mandel $p2 $tolerance
    . config -cursor arrow
    [$p2 cget -frame] writeGIF $cmap $filename
    display_image $filename $p2 set_zoom
}


# Take some screen coordinates and set global min and max values 

proc set_zoom {p2 mxmin mymin mxmax mymax x1 y1 x2 y2} {
    global xmin ymin xmax ymax

    set frame [$p2 cget -frame]
    set width [$frame cget -width]
    set height [$frame cget -height]

    if {$x1 < 0} {set x1 0}
    if {$x1 > ($width)} {set x1 $width}
    if {$x2 < 0} {set x2 0}
    if {$x2 > ($width)} {set x2 $width}
    if {$x1 < $x2} {set ixmin $x1; set ixmax $x2} {set ixmin $x2; set ixmax $x1}

    if {$y1 < 0} {set y1 0}
    if {$y1 > ($height)} {set y1 $height}
    if {$y2 < 0} {set y2 0}
    if {$y2 > ($height)} {set y2 $height}
    if {$y1 < $y2} {set iymin $y1; set iymax $y2} {set iymin $y2; set iymax $y1}

    # Now determine new min and max values based on screen location

    set xmin [expr {$mxmin + ($mxmax-$mxmin)*($ixmin)/($width)}]
    set xmax [expr {$mxmin + ($mxmax-$mxmin)*($ixmax)/($width)}]
    set ymin [expr {$mymin + ($mymax-$mymin)*(($height)-($iymax))/($height)}]
    set ymax [expr {$mymin + ($mymax-$mymin)*(($height)-($iymin))/($height)}]

    catch {make_plot}
}

# Box drag constrained to a square
proc BoxDrag { w x y} {
    global box
    catch {$w delete $box(last)}
    set x1 [lrange $box(anchor) 0 0]
    set y1 [lrange $box(anchor) 1 1]
    set dx [expr {$x - $x1}]
    set dy [expr {$y - $y1}]
    if {abs($dy) > abs($dx)} {set dx $dy}
    set newx [expr {$x1 + $dx}]
    set newy [expr {$y1 + $dx}]
    set box(last) [eval {$w create rect} $box(anchor) {$newx $newy -tag box -outline white}]
}


proc BoxFinish {w x y p2 mxmin mymin mxmax mymax func } {
    global box
    set start $box(anchor)
    set x1 [lrange $box(anchor) 0 0]
    set y1 [lrange $box(anchor) 1 1]
    set dx [expr {$x - $x1}]
    set dy [expr {$y - $y1}]
    if {($dx == 0) || ($dy == 0)} {
	catch {$w delete $box(last)}
	return
    }
    if {abs($dy) > abs($dx)} {set dx $dy}
    set newx [expr {$x1 + $dx}]
    set newy [expr {$y1 + $dx}]
    $w config -cursor watch
    update
# Call the handler function
    $func $p2 $mxmin $mymin $mxmax $mymax $x1 $y1 $newx $newy
    catch {$w delete $box(last)}
    $w config -cursor arrow
}


# Create a few frames

wm title . Mandelbrot
frame .title -relief groove -borderwidth 1
label .title.name -text "Mandelbrot Set" 
button .title.quit -text "Quit" -command "exit"
button .title.about -text "About" -command "about"
pack .title.name -side left
pack .title.quit .title.about -side right

frame .func -relief groove -borderwidth 1

frame .func.xrange
label .func.xrange.xrlabel -text "X range" -width 12
entry .func.xrange.xmin -textvar xmin -width 8
label .func.xrange.xtolabel -text "to"
entry .func.xrange.xmax -textvar xmax -width 8
pack  .func.xrange.xrlabel .func.xrange.xmin .func.xrange.xtolabel .func.xrange.xmax -side left

frame .func.yrange
label .func.yrange.yrlabel -text "Y range" -width 12
entry .func.yrange.ymin -textvar ymin -width 8
label .func.yrange.ytolabel -text "to"
entry .func.yrange.ymax -textvar ymax -width 8
pack  .func.yrange.yrlabel .func.yrange.ymin .func.yrange.ytolabel .func.yrange.ymax -side left

frame .func.npoints 
label .func.npoints.label -text "Tolerance " -width 12
entry .func.npoints.npoints -textvar tolerance -width 8
scale .func.npoints.scale -from 0 -to 2500 -variable tolerance -orient horizontal -showvalue false \
                          -sliderlength 13 -bigincrement 10 -resolution 10
pack .func.npoints.label .func.npoints.npoints .func.npoints.scale -side left

pack .func.xrange .func.yrange .func.npoints -side top -fill x

# Filename dialog

frame .save -relief groove -borderwidth 1

frame .save.file
label .save.file.label -text "Save as" -width 12
entry .save.file.filename -textvar filename -width 20
pack .save.file.label .save.file.filename -side left
pack .save.file -side left -fill x
button .save.go -text "Plot" -command "make_plot"
pack .save.go -side right

bind .save.file.filename <Return> {make_plot}

pack .title .func .save -side top -fill both

proc about { } {
    toplevel .about -width 350

    message .about.m -text "\
Mandelbrot Set\n\n\
Copyright (c) 1997\n\
Dave Beazley\n\
University of Utah\n\n\
Creates a plot of the Mandelbrot set.  Any displayed image can be zoomed by clicking and \
dragging.  Although the main calculation is written in C, it may take awhile for each \
image to be calculated (be patient).   Image quality can be improved at the expense of speed \
by increasing the tolerance value.\n"

button .about.okay -text "Ok" -command {destroy .about}

pack .about.m .about.okay -side top
focus .about.okay
}

make_plot
