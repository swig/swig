smart_pointer_templatevariables

d = DiffImContainerPtr_D(create(1234, 5678));

if (d.id != 1234)
  error("failed");
endif
#if (d.xyz != 5678):
#  error("failed");

d.id = 4321;
#d.xyz = 8765

if (d.id != 4321)
  error("failed");
endif
#if (d.xyz != 8765):
#  error("failed");

