exec("swigtest.start", -1);

try
    // This call must fail
    abstract_foo_meth(1);
    swigtesterror();
catch
end

try
    // This call must fail
    abstract_bar_meth(1);
    swigtesterror();
catch
end

exec("swigtest.quit", -1);
