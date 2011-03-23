exec("swigtest.start", -1);

smallnum = -127;
if CharValFunction(smallnum) <> smallnum then swigtesterror(); end
if CCharValFunction(smallnum) <> smallnum then swigtesterror(); end
if CCharRefFunction(smallnum) <> smallnum then swigtesterror(); end

try
  globalchar_set(smallnum);
catch
  swigtesterror();
end
if globalchar_get() <> smallnum then swigtesterror(); end

if globalconstchar_get() <> -110 then swigtesterror(); end

exec("swigtest.quit", -1);
