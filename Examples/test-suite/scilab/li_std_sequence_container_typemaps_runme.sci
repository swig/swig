// test STL sequence containers typemaps

exec("swigtest.start", -1);

// test sequence container of pointers returned from fonction (expected a list)
function [classAPtr_list, classAPtr1, classAPtr2] = testCreateSequenceContainerPtr(container, value1, value2)
  classAPtr1 = new_ClassA(value1);
  classAPtr2 = new_ClassA(value2);
  cmd = msprintf("classAPtr_list = ret_ClassAPtr_%s(classAPtr1, classAPtr2);", container);
  ierr = execstr(cmd, "errcatch");
  if ierr <> 0 then swigtesterror(); end
  if ~exists('classAPtr_list') | (size(classAPtr_list) <> 2) then swigtesterror(); end
  if (ClassA_a_get(classAPtr_list(1)) <> value1) | (ClassA_a_get(classAPtr_list(2)) <> value2) then swigtesterror(); end
endfunction

// test sequence containers of pointers
// -container: type of container: "vector", "list"...
// -value1, value2: values to store in container
// -expected_accumulate_value: expected value of an accumulation function
//    computed on the container
function testSequenceContainerPtr(container, value1, value2, expected_accumulate_value)
  // test sequence container of pointers returned from fonction (expected a list)
  [classAPtr_list, classAPtr1, classAPtr2] = testCreateSequenceContainerPtr(container, value1, value2);

  // test sequence container passed as value of function
  cmd = msprintf("classAPtr = val_ClassAPtr_%s(classAPtr_list);", container);
  ierr = execstr(cmd, "errcatch");
  if ierr <> 0 then swigtesterror(); end
  if ClassA_a_get(classAPtr1) <> expected_accumulate_value then swigtesterror(); end

  // recreate a container
  [classAPtr_list, classAPtr1, classAPtr2] = testCreateSequenceContainerPtr(container, value1, value2);

  // test sequence container passed as refererence of function
  cmd = msprintf("classAPtr = ref_ClassAPtr_%s(classAPtr_list);", container);
  ierr = execstr(cmd, "errcatch");
  if ierr <> 0 then swigtesterror(); end
  if ClassA_a_get(classAPtr) <> expected_accumulate_value then swigtesterror(); end
endfunction

// test sequence containers of primitive type
// -container: type of container: "vector", "list"...
// -value_type: type of element stored in container: "int", ...
// -value1, value2: values to store in container
// -expected_accumulate_value: expected value of an accumulation function
//     computed on the container
function testSequenceContainer(container, value_type, value1, value2, expected_accumulate_value)
  // test sequence container of basic type returned from fonction (expect a row matrix)
  if value_type = "string" then
    cmd = msprintf("c = ret_%s_%s(''%s'', ''%s'');", value_type, container, value1, value2);
  elseif value_type = "bool" then
    cmd = msprintf("c = ret_%s_%s(%s, %s);", value_type, container, "%"+string(value1), "%"+string(value2));
  else
    cmd = msprintf("c = ret_%s_%s(%d, %d);", value_type, container, value1, value2);
  end
  ierr = execstr(cmd, "errcatch");

  if ierr <> 0 then swigtesterror(); end
  if ~isdef('c') | c <> [value1, value2] then swigtesterror(); end

  // test sequence container passed as value of function
  cmd = msprintf("s = val_%s_%s(c);", value_type, container);
  ierr = execstr(cmd, "errcatch");
  if ierr <> 0 then swigtesterror(); end
  if s <> expected_accumulate_value then swigtesterror(); end

  // test sequence container passed as matrix as value of function
  //cmd = msprintf("s = val_%s_%s([value1, value2]);", value_type, container);
  //ierr = execstr(cmd, "errcatch");
  //if ierr <> 0 then swigtesterror(); end
  //if s <> expected_accumulate_value then swigtesterror(); end

  // test sequence container passed as reference of function
  cmd = msprintf("s = ref_%s_%s(c);", value_type, container);
  ierr = execstr(cmd, "errcatch");
  if ierr <> 0 then swigtesterror(); end
  if s <> expected_accumulate_value then swigtesterror(); end

  // test sequence container passed as matrix as reference of function
  //cmd = msprintf("s = val_%s_%s([value1, value2]);", value_type, container);
  //ierr = execstr(cmd, "errcatch");
  //if ierr <> 0 then swigtesterror(); end
  //if s <> expected_accumulate_value then swigtesterror(); end
endfunction

// test vector
testSequenceContainer("vector", "int", 1, 2, 4);
testSequenceContainer("vector", "double", 2., 3., 7.);
testSequenceContainer("vector", "string", "a", "b", "aab");
testSequenceContainer("vector", "bool", %T, %F, %T);
testSequenceContainer("vector", "Color", RED_get(), BLUE_get(), MAGENTA_get());
testSequenceContainerPtr("vector", 1, 3, 5);

// test list
testSequenceContainer("list", "int", 1, 2, 4);
testSequenceContainer("list", "double", 2., 3., 7.);
testSequenceContainer("list", "string", "a", "b", "aab");
testSequenceContainer("list", "bool", %T, %F, %T);
testSequenceContainer("list", "Color", RED_get(), BLUE_get(), MAGENTA_get());
testSequenceContainerPtr("list", 1, 3, 5);

exec("swigtest.quit", -1);


