% Example using pointers to member functions

import member_pointer.*

% Get the pointers

area_pt = areapt;
perim_pt = perimeterpt;

% Create some objects

s = Square(10);

% Do some calculations

member_pointer_helper ('Square area ', 100.0, do_op(s,area_pt));
member_pointer_helper ('Square perim', 40.0, do_op(s,perim_pt));

memberPtr = cvar.areavar;
memberPtr = cvar.perimetervar;

% Try the variables
member_pointer_helper ('Square area ', 100.0, do_op(s,cvar.areavar));
member_pointer_helper ('Square perim', 40.0, do_op(s,cvar.perimetervar));

% Modify one of the variables
cvar.areavar = perim_pt;

member_pointer_helper ('Square perimeter', 40.0, do_op(s,cvar.areavar));

% Try the constants

memberPtr = AREAPT;
memberPtr = PERIMPT;
memberPtr = NULLPT;

member_pointer_helper ('Square area ', 100.0, do_op(s,AREAPT));
member_pointer_helper ('Square perim', 40.0, do_op(s,PERIMPT));

