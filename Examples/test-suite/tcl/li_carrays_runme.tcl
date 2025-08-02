
if [ catch { load ./li_carrays[info sharedlibextension] Li_carrays} err_msg ] {
	puts stderr "Could not load shared object:\n$err_msg"
}


# Testing for %array_functions(int,intArray)
set ary [new_intArray 2]
intArray_setitem $ary 0 0
intArray_setitem $ary 1 1
if {[intArray_getitem $ary 0] != 0} {
    error "wrong value index 0"
}
if {[intArray_getitem $ary 1] != 1} {
    error "wrong value index 1"
}
delete_intArray $ary

# Testing for %array_class(double, doubleArray)
doubleArray d 10
doubleArray_setitem d 0 7
doubleArray_setitem d 5 [expr [doubleArray_getitem d 0] + 3]
if {[expr [doubleArray_getitem d 5] + [doubleArray_getitem d 0]] != 17} {
    error "wrong value doubleArray"
}


# Tcl Array wrapper based on Tcl.html documentation "Building new kinds of Tcl interfaces (in Tcl)"
proc Array {type size} {
    set ptr [new_$type $size]
    set code {
        set method [lindex $args 0]
        set parms [concat $ptr [lrange $args 1 end]]
        switch $method {
            get {return [eval "${type}_getitem $parms"]}
            set {return [eval "${type}_setitem $parms"]}
            delete {eval "delete_$type $ptr; rename $ptr {}"}
        }
    }
    # Create a procedure
    uplevel "proc $ptr args {set ptr $ptr; set type $type;$code}"
    return $ptr
}

# The memory handling for Tcl is not working properly. 
# %newobject (not used here though) is crippled and does not take ownership of the underlying
# pointer - see SWIGTYPE * typemap overrides in tcltypemaps.swg.
#
# As soon as a is set below, it gets deleted by the interpreter, even though $a is used a
# few lines later. The interpreter seems to replace the command object created in
# SWIG_Tcl_NewInstanceObj some sort of generic one.
# The underlying C array is not actually deleted (it leaks) when $a is deleted, so the code
# using $a does actually seem to work.

set a [Array doubleArray 100]              ;# Create a double [100]
for {set i 0} {$i < 100} {incr i 1} {      ;# Clear the array
        $a set $i 0.0
}

$a set 3 3.1455                            ;# Set an individual element
set b [$a get 10]                          ;# Retrieve an element

set ia [Array intArray 50]                 ;# Create an int[50]
for {set i 0} {$i < 50} {incr i 1} {       ;# Clear it
        $ia set $i 0
}
$ia set 3 7                                ;# Set an individual element
set ib [$ia get 10]                        ;# Get an individual element

$a delete                                  ;# Destroy a
$ia delete                                 ;# Destroy ia
