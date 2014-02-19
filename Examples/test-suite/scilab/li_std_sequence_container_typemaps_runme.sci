// test STL sequence containers typemaps

exec("swigtest.start", -1);

// test sequence containers of pointers
// -container: type of container: "vector", "list"...
// -value, count: value to store count times in container
// -expected_accumulate_value: expected value of an accumulation function
//    computed on the container
function testSequenceContainerPtr(container, count, value, expected_accumulate_value)
  // test sequence container returned from fonction (expected a list)
  classAPtr = new_ClassA(value);
  cmd = msprintf("l = ret_ClassAPtr_%s(count, classAPtr);", container);
  ierr = execstr(cmd, "errcatch");
  if ierr <> 0 then swigtesterror(); end
  if ~exists('l') | (size(l) <> count) | (ClassA_a_get(l(1)) <> value) then swigtesterror(); end
  l2 = l;

  // test sequence container passed as value of function
  cmd = msprintf("classAPtr = val_ClassAPtr_%s(l);", container);
  ierr = execstr(cmd, "errcatch");
  if ierr <> 0 then swigtesterror(); end
  if ClassA_a_get(classAPtr) <> expected_accumulate_value then swigtesterror(); end

  // recreate a container
  classAPtr = new_ClassA(value);
  cmd = msprintf("l = ret_ClassAPtr_%s(count, classAPtr);", container);
  ierr = execstr(cmd, "errcatch");
  if ierr <> 0 then swigtesterror(); end
  if ~exists('l') | (size(l) <> count) | (ClassA_a_get(l(1)) <> value) then swigtesterror(); end

  // test sequence container passed as refererence of function
  cmd = msprintf("classAPtr = ref_ClassAPtr_%s(l);", container);
  ierr = execstr(cmd, "errcatch");
  if ierr <> 0 then swigtesterror(); end
  if ClassA_a_get(classAPtr) <> expected_accumulate_value then swigtesterror(); end
endfunction

// test sequence containers of primitive type
// -container: type of container: "vector", "list"...
// -value_type: type of element stored in container: "int", ...
// -value, count: value to store count times in container
// -expected_accumulate_value: expected value of an accumulation function
//     computed on the container
function testSequenceContainer(container, value_type, value, count, expected_accumulate_value)
  // test sequence container returned from fonction (expect a row matrix)
  if value_type = "string"
    cmd = msprintf("c = ret_%s_%s(count, ''%s'');", value_type, container, value);
  elseif value_type = "bool" then
    cmd = msprintf("c = ret_%s_%s(count, %s);", value_type, container, "%"+string(value));
  else
    cmd = msprintf("c = ret_%s_%s(count, %d);", value_type, container, value);
  end
  ierr = execstr(cmd, "errcatch");
  if ierr <> 0 then swigtesterror(); end
  if ~isdef('c') | c <> repmat(value, 1, count) then swigtesterror(); end

  // test sequence container passed as value of function
  cmd = msprintf("s = val_%s_%s(c);", value_type, container);
  ierr = execstr(cmd, "errcatch");
  if ierr <> 0 then swigtesterror(); end
  if s <> expected_accumulate_value then swigtesterror(); end

  // test sequence container passed as matrix as value of function
  //m = repmat(value, 1, count);
  //cmd = msprintf("s = val_%s_%s(m);", value_type, container);
  //ierr = execstr(cmd, "errcatch");
  //if ierr <> 0 then swigtesterror(); end
  //if s <> expected_accumulate_value then swigtesterror(); end

  // test sequence container passed as reference of function
  cmd = msprintf("s = ref_%s_%s(c);", value_type, container);
  ierr = execstr(cmd, "errcatch");
  if ierr <> 0 then swigtesterror(); end
  if s <> expected_accumulate_value then swigtesterror(); end

  // test sequence container passed as matrix as reference of function
  //m = repmat(value, 1, count);
  //cmd = msprintf("s = val_%s_%s(m);", value_type, container);
  //ierr = execstr(cmd, "errcatch");
  //if ierr <> 0 then swigtesterror(); end
  //if s <> expected_accumulate_value then swigtesterror(); end
endfunction

// test vector
testSequenceContainer("vector", "int", 2, 4, 10);
testSequenceContainer("vector", "double", 2., 3., 8.);
testSequenceContainer("vector", "string", "a", 4, "aaaaa");
testSequenceContainer("vector", "bool", %T, 2, %T);
testSequenceContainerPtr("vector", 1, 3, 6.0);

// test list
testSequenceContainer("list", "int", 2, 3, 8);
testSequenceContainer("list", "double", 2., 4., 10.);
testSequenceContainer("list", "string", "a", 4, "aaaaa");
testSequenceContainer("list", "bool", %T, 2, %T);
testSequenceContainerPtr("list", 1, 3, 6.0);

exec("swigtest.quit", -1);


