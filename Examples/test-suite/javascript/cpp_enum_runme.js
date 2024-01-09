var cpp_enum = require("cpp_enum");

var f = new cpp_enum.Foo()

if(f.hola != cpp_enum.Hello){
  console.error(f.hola);
  throw "Error";
}

f.hola = cpp_enum.Foo.Hi
if(f.hola != cpp_enum.Foo.Hi){
  console.error(f.hola);
  throw "Error";
}

f.hola = cpp_enum.Hello

if(f.hola != cpp_enum.Hello){
  console.error(f.hola);
  throw "Error";
}

/* @ts-ignore : setting an invalid property is OK in JS but not in TS */
cpp_enum.Foo.hi = cpp_enum.Hello;
/* @ts-ignore */
if (cpp_enum.Foo.hi != cpp_enum.Hello) {
  /* @ts-ignore */
  console.error(cpp_enum.Foo.hi);
  throw "Error";
}
