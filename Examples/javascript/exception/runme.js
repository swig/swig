//file: runme.js
// Throw a lot of exceptions

t = new example.Test();
try{
  t.unknown();
  throw -1;
} catch(error)
{
  if(error == -1) {
    print("t.unknown() didn't throw");
  }
}

try{
    t.simple();
    throw -1;
}
catch(error){
  if(error == -1) {
    print("t.simple() did not throw");
  }
}

try{
  t.message();
  throw -1;
} catch(error){
  if(error == -1) {
    print("t.message() did not throw");
  }
}
    
try{
  t.hosed();
  throw -1;
}
catch(error){ 
  if(error == -1) {
    print("t.hosed() did not throw");
  }
}

for (var i=1; i<4; i++) {
  try{
      t.multi(i);
      throw -1;
  }
  catch(error){
    if(error == -1) {
      print("t.mulit(" + i + ") did not throw");
    }
  }
}      
