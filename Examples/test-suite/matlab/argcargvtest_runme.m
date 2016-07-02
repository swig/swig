largs={'hi','hola','hello'};
if (argcargvtest.mainc(largs) ~= 3)
  error('bad main typemap');
end

targs={'hi','hola'};
if (argcargvtest.mainv(targs,1) ~= 'hola')
  error('bad main typemap');
end

targs={'hi', 'hola'};
if (argcargvtest.mainv(targs,1) ~= 'hola')
  error('bad main typemap');
end

try
  error_flag = 0;
  argcargvtest.mainv('hello',1);
  error_flag = 1;
catch
end
if (error_flag)
  error('bad main typemap')
end


argcargvtest.initializeApp(largs);
