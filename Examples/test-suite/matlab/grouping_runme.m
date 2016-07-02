x = grouping.test1(42);
if (x ~= 42)
    error
end

grouping.test2(42);

x = (grouping.do_unary(37, grouping.NEGATE));
if (x ~= -37)
    error
end

grouping.test3(42);
