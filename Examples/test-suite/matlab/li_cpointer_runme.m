p = li_cpointer.new_intp();
li_cpointer.intp_assign(p,3);

if (li_cpointer.intp_value(p) ~= 3)
    error
end

li_cpointer.delete_intp(p);

