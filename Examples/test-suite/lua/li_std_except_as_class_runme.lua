local v=require("li_std_except_as_class")

for i=1,3 do
    local ret, msg = pcall(function() v.test_domain_error() end)
    assert(not ret)
    assert(msg == "SWIG_ValueError:std::domain_error")
end
