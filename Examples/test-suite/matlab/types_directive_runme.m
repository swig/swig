d1 = types_directive.Time1(2001, 2, 3, 60);
newDate = types_directive.add(d1, 7); % check that a Time1 instance is accepted where Date is expected
if (newDate.day ~= 10)
  error
end

d2 = types_directive.Time2(1999, 8, 7, 60);
newDate = types_directive.add(d2, 7); % check that a Time2 instance is accepted where Date is expected
if (newDate.day ~= 14)
  error
end


