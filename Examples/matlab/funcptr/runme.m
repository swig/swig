% file: runme.m

a = 37
b = 42

% Now call our C function with a bunch of callbacks

disp(sprintf('Trying some C callback functions'))
disp(sprintf('    a        = %i', a))
disp(sprintf('    b        = %i', b))
disp(sprintf('    ADD(a,b) = %i', swigexample.do_op(a,b,swigexample.ADD)))
disp(sprintf('    SUB(a,b) = %i', swigexample.do_op(a,b,swigexample.SUB)))
disp(sprintf('    MUL(a,b) = %i', swigexample.do_op(a,b,swigexample.MUL)))

disp(sprintf('Here is what the C callback function objects look like in Octave'))
swigexample.ADD
swigexample.SUB
swigexample.MUL
