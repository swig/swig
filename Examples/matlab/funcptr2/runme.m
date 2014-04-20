% file: runme.m

a = 37
b = 42

% Now call our C function with a bunch of callbacks

disp(sprintf('Trying some C callback functions'))
disp(sprintf('    a        = %i', a))
disp(sprintf('    b        = %i', b))
disp(sprintf('    ADD(a,b) = %i', swigexample.do_op(a,b,swigexample.add_cb))) % was: ADD
disp(sprintf('    SUB(a,b) = %i', swigexample.do_op(a,b,swigexample.sub_cb))) % was: SUB
disp(sprintf('    MUL(a,b) = %i', swigexample.do_op(a,b,swigexample.mul_cb))) % was: MUL

disp(sprintf('Here is what the C callback function objects look like in Octave'))
swigexample.add_cb % was: ADD
swigexample.sub_cb % was: SUB
swigexample.mul_cb % was: MUL

disp(sprintf('Call the functions directly...'))
disp(sprintf('    add(a,b) = %i', swigexample.add(a,b)))
disp(sprintf('    sub(a,b) = %i', swigexample.sub(a,b)))
