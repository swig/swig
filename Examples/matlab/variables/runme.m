% file: runme.m

% Try to set the values of some global variables

swigexample.ivar   (42)
swigexample.svar   (-31000)
swigexample.lvar   (65537)
swigexample.uivar  (123456)
swigexample.usvar  (61000)
swigexample.ulvar  (654321)
swigexample.scvar  (-13)
swigexample.ucvar  (251)
swigexample.cvar   ('S')
swigexample.fvar   (3.14159)
swigexample.dvar   (2.1828)
swigexample.strvar ('Hello World')
swigexample.iptrvar(swigexample.new_int(37))
swigexample.ptptr  (swigexample.new_Point(37,42))
swigexample.name   ('Bill')

% Now print out the values of the variables

disp(sprintf('Variables (values printed from Octave)'))

disp(sprintf('ivar      = %i', swigexample.ivar))
disp(sprintf('svar      = %i', swigexample.svar))
disp(sprintf('lvar      = %i', swigexample.lvar))
disp(sprintf('uivar     = %i', swigexample.uivar))
disp(sprintf('usvar     = %i', swigexample.usvar))
disp(sprintf('ulvar     = %i', swigexample.ulvar))
disp(sprintf('scvar     = %i', swigexample.scvar))
disp(sprintf('ucvar     = %i', swigexample.ucvar))
disp(sprintf('fvar      = %i', swigexample.fvar))
disp(sprintf('dvar      = %i', swigexample.dvar))
disp(sprintf('cvar      = %s', swigexample))
disp(sprintf('strvar    = %s', swigexample.strvar))
%disp(sprintf('cstrvar   = %s', swigexample.cstrvar))
swigexample.iptrvar
disp(sprintf('name      = %i', swigexample.name))
disp(sprintf('ptptr     = %s', swigexample.Point_print(swigexample.ptptr)))
%disp(sprintf('pt        = %s', swigexample.Point_print(swigexample.pt)))

disp(sprintf('Variables (values printed from C)'))

swigexample.print_vars();

disp(sprintf('Now I''m going to try and modify some read only variables'))

disp(sprintf('     Tring to set ''path'''))
try
    swigexample.path = 'Whoa!';
    disp(sprintf('Hey, what''s going on?!?! This shouldn''t work'))
catch
    disp(sprintf('Good.'))
end

disp(sprintf('     Trying to set ''status'''))
try
    swigexample.status = 0;
    disp(sprintf('Hey, what''s going on?!?! This shouldn''t work'))
catch
    disp(sprintf('Good.'))
end


disp(sprintf('I''m going to try and update a structure variable.'))

swigexample.pt = swigexample.ptptr;

disp(sprintf('The new value is %s', swigexample.Point_print(swigexample.pt)))
