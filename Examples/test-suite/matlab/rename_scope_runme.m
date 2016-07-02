a = rename_scope.Natural_UP();
b = rename_scope.Natural_BP();

if (a.rtest() ~= 1)
    error
end

if (b.rtest() ~= 1)
    error
end

f = @equals;

