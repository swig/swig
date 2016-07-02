a = li_std_stream.A();

o = li_std_stream.ostringstream();

o << a << ' ' << 2345 << ' ' << 1.435;


if (o.str() ~=  'A class 2345 1.435')
  error
end

