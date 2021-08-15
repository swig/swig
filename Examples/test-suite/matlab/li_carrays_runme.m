import li_carrays.*

d = zeros(1,10);

d(1) = 7;
d(6) = d(1) + 3;

if (d(1) + d(6) ~= 17)
    error('Failed!! sum is %g but should be 17', d(1) + d(6))
end
