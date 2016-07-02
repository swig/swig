f = extend_template_ns.Foo_One();
if (f.test1(37) ~= 37)
    error
end

if (f.test2(42) ~= 42)
    error
end
