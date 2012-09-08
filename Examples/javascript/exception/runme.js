//file: runme.js
// Throw a lot of exceptions

print("Trying to catch some exceptions.");
t = new example.Test();
try{
  t.unknown();
  throw -1;
} catch(error)
{
  if(error == -1) {
    print("t.unknown() didn't throw");
  } else {
    print("successfully catched throw in Test::unknown().");
  }
}

try{
    t.simple();
    throw -1;
}
catch(error){
  if(error == -1) {
    print("t.simple() did not throw");
  } else {
    print("successfully catched throw in Test::simple().");
  }
}

try{
  t.message();
  throw -1;
} catch(error){
  if(error == -1) {
    print("t.message() did not throw");
  } else {
    print("successfully catched throw in Test::message().");
  }
}
    
try{
  t.hosed();
  throw -1;
}
catch(error){ 
  if(error == -1) {
    print("t.hosed() did not throw");
  } else {
    print("successfully catched throw in Test::hosed().");
  }
}

for (var i=1; i<4; i++) {
  try{
      t.multi(i);
      throw -1;
  }
  catch(error){
    if(error == -1) {
      print("t.multi(" + i + ") did not throw");
    } else {
      print("successfully catched throw in Test::multi().");
    }
  }
}    
