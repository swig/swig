a = li_std_wstream.A();

o = li_std_wstream.wostringstream();

o << a << u' ' << 2345 << u' ' << 1.435 << wends;

if (o.str() ~=  'A class 2345 1.435\0')
  error
end

