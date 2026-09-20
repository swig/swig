exec("swigtest.start", -1);

// Setting a reference to an array of arrays copies every element.
grid_ref_set(other_grid_get());
if grid_element(0, 1) <> 20 then swigtesterror(); end
if grid_element(1, 2) <> 60 then swigtesterror(); end

grid_member = new_GridRefMember();
GridRefMember_rows_ref_set(grid_member, other_grid_address());
if GridRefMember_element(grid_member, 0, 1) <> 20 then swigtesterror(); end
if GridRefMember_element(grid_member, 1, 2) <> 60 then swigtesterror(); end

exec("swigtest.quit", -1);
