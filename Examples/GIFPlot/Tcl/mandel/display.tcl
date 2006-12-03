# Tcl code to display a image in a widget

set __imageno 0

proc dismiss {t i} {
    destroy $t
    image delete $i
}

proc BoxInit { c p2 mxmin mymin mxmax mymax func } {
    bind $c <Button-1> {BoxBegin %W %x %y}
    bind $c <B1-Motion> {BoxDrag %W %x %y}
    bind $c <ButtonRelease-1> "BoxFinish %W %x %y $p2 $mxmin $mymin $mxmax $mymax $func"
}

proc BoxBegin {w x y} {
    global box
    set box(anchor) [list $x $y]
    catch {unset box(last)}
}

proc BoxDrag { w x y} {
    global  box
    catch {$w delete $box(last)}
    set box(last) [eval {$w create rect} $box(anchor) {$x $y -tag box -outline white}]
}

proc BoxFinish {w x y p2 mxmin mymin mxmax mymax func } {
    global box
    set start $box(anchor)
    set x1 [lrange $start 0 0]
    set y1 [lrange $start 1 1]
    catch {$w delete $box(last)}
# Call the handler function
    $func $p2 $mxmin $mymin $mxmax $mymax $x1 $y1 $x $y
}

proc display_image {filename p2 handler} {
    global __imageno __images
    set i [image create photo -file $filename]
    set tl .image$__imageno
    toplevel $tl 
    frame $tl.img
    frame $tl.button

    set width [image width $i]
    set height [image height $i]
    canvas $tl.img.c -width [expr {$width+0}] -height [expr {$height+0}]
    pack $tl.img.c
    $tl.img.c create image 0 0 -image $i -anchor nw 
    label $tl.button.label -text $filename 
    pack $tl.button.label -side left
    button $tl.button.dismiss -text "Dismiss" -command "dismiss $tl $i" -width 10 
    pack $tl.button.dismiss -side right
    pack $tl.img $tl.button -side top -fill x   
    BoxInit $tl.img.c $p2 [$p2 cget -xmin] [$p2 cget -ymin] [$p2 cget -xmax] [$p2 cget -ymax] $handler
    bind $tl <Key-q> "dismiss $tl $i"
    bind $tl <Key-Escape> "dismiss $tl $i"

    # Bind some actions to the canvas

    incr __imageno 1
}

proc test {} {
    puts "hello"
}

