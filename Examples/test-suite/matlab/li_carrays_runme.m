import li_carrays.*

d = doubleArray(10);

d(0) = 7;
d(5) = d(0) + 3;

if (d(5) + d(0) ~= 17)
    error('Failed!! sum is %g but should be 17', d(5)+d(0))
end
