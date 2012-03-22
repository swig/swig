mode(-1);
lines(0);
ilib_verbose(0);
ilib_name = "examplelib";
files = "example_wrap.cxx";
files($+1) = "example.cpp";
libs = [];
ldflags = "";
cflags = ["-g -I" + get_absolute_file_path("builder.sce")];
table = ["nlopt_doublevector_empty","_wrap_nlopt_doublevector_empty";"nlopt_doublevector_size","_wrap_nlopt_doublevector_size";"nlopt_doublevector_clear","_wrap_nlopt_doublevector_clear";"nlopt_doublevector_swap","_wrap_nlopt_doublevector_swap";"nlopt_doublevector_get_allocator","_wrap_nlopt_doublevector_get_allocator";"nlopt_doublevector_pop_back","_wrap_nlopt_doublevector_pop_back";"new_nlopt_doublevector","_wrap_new_nlopt_doublevector";"nlopt_doublevector_push_back","_wrap_nlopt_doublevector_push_back";"nlopt_doublevector_front","_wrap_nlopt_doublevector_front";];

table = [table;"nlopt_doublevector_back","_wrap_nlopt_doublevector_back";"nlopt_doublevector_assign","_wrap_nlopt_doublevector_assign";"nlopt_doublevector_resize","_wrap_nlopt_doublevector_resize";"nlopt_doublevector_reserve","_wrap_nlopt_doublevector_reserve";"nlopt_doublevector_capacity","_wrap_nlopt_doublevector_capacity";"delete_nlopt_doublevector","_wrap_delete_nlopt_doublevector";"opt_set_lower_bound","_wrap_opt_set_lower_bound";"new_opt","_wrap_new_opt";"delete_opt","_wrap_delete_opt";];
if ~isempty(table) then
  ilib_build(ilib_name, table, files, libs, [], ldflags, cflags);
end
exit