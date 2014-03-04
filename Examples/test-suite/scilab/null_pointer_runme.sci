exec("swigtest.start", -1);


try
  p = getnull();
  if func(p) = %F then swigtesterror(); end
  if func([]) = %F then swigtesterror(); end
catch
  swigtesterror();
end


exec("swigtest.quit", -1);
