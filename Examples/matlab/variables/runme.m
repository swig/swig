% file: runme.m

% Try to set the values of some global variables

example.ivar   (42)
example.svar   (-31000)
example.lvar   (65537)
example.uivar  (123456)
example.usvar  (61000)
example.ulvar  (654321)
example.scvar  (-13)
example.ucvar  (251)
example.cvar   ('S')
example.fvar   (3.14159)
example.dvar   (2.1828)
example.strvar ('Hello World')
example.iptrvar(example.new_int(37))
example.ptptr  (example.new_Point(37,42))
example.name   ('Bill')

% Now print out the values of the variables

disp(sprintf('Variables (values printed from Octave)'))

disp(sprintf('ivar      = %i', example.ivar))
disp(sprintf('svar      = %i', example.svar))
disp(sprintf('lvar      = %i', example.lvar))
disp(sprintf('uivar     = %i', example.uivar))
disp(sprintf('usvar     = %i', example.usvar))
disp(sprintf('ulvar     = %i', example.ulvar))
disp(sprintf('scvar     = %i', example.scvar))
disp(sprintf('ucvar     = %i', example.ucvar))
disp(sprintf('fvar      = %i', example.fvar))
disp(sprintf('dvar      = %i', example.dvar))
disp(sprintf('cvar      = %s', example.cvar))
disp(sprintf('strvar    = %s', example.strvar))
%disp(sprintf('cstrvar   = %s', example.cstrvar))
example.iptrvar
disp(sprintf('name      = %i', example.name))
disp(sprintf('ptptr     = %s', example.Point_print(example.ptptr)))
%disp(sprintf('pt        = %s', example.Point_print(example.pt)))

disp(sprintf('Variables (values printed from C)'))

example.print_vars();

disp(sprintf('Now I''m going to try and modify some read only variables'))

disp(sprintf('     Tring to set ''path'''))
try
    example.path('Whoa!');
    disp(sprintf('Hey, what''s going on?!?! This shouldn''t work'))
catch
    disp(sprintf('Good.'))
end

disp(sprintf('     Trying to set ''status'''))
try
    example.status(0);
    disp(sprintf('Hey, what''s going on?!?! This shouldn''t work'))
catch
    disp(sprintf('Good.'))
end


disp(sprintf('I''m going to try and update a structure variable.'))

example.pt(example.ptptr);

disp(sprintf('The new value is %s', example.Point_print(example.pt)))
