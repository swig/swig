% file: runme.m

a = 37
b = 42

% Now call our C function with a bunch of callbacks

disp(sprintf('Trying some C callback functions'))
disp(sprintf('    a        = %i', a))
disp(sprintf('    b        = %i', b))
disp(sprintf('    ADD(a,b) = %i', example.do_op(a,b,example.add_cb))) % was: ADD
disp(sprintf('    SUB(a,b) = %i', example.do_op(a,b,example.sub_cb))) % was: SUB
disp(sprintf('    MUL(a,b) = %i', example.do_op(a,b,example.mul_cb))) % was: MUL

disp(sprintf('Here is what the C callback function objects look like in Octave'))
example.add_cb % was: ADD
example.sub_cb % was: SUB
example.mul_cb % was: MUL

disp(sprintf('Call the functions directly...'))
disp(sprintf('    add(a,b) = %i', example.add(a,b)))
disp(sprintf('    sub(a,b) = %i', example.sub(a,b)))
