c = static_const_member_2.Test_int();
try
    a = c.forward_field;
    a = c.current_profile;
    a = c.RightIndex;
    a = static_const_member_2.Test_int.backward_field;
    a = static_const_member_2.Test_int.LeftIndex;
    a = static_const_member_2.Test_int.cavity_flags;
catch
end


if (static_const_member_2.Foo.BAZ.val ~= 2*static_const_member_2.Foo.BAR.val)
    error
end

