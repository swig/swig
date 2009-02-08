/*
 *  This file is part of SWIG.
 *
 *  SWIG is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  SWIG is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with SWIG.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "doh.h"
#include <iostream>
#include <cstdio>
#include <cassert>
/* Test */
using namespace doh;
using namespace std;

void say(const String_or_char_ptr str) {
  const String *s = str;
  printf(str);
  return;
}

void stringtest()
{
  /* Basic string test */
  String *s = new String("Hello world\n");
  DOH* d = s;
  String* ss = DOHCaster(d);
  //cout << ss << endl;
  say(ss);
  String *r = new String(" the");
  Insertitem(s, 5, r);
  cout << *s;
  assert(*s=="Hello the world\n");
  Delslice(s, 6, 10);
  cout << *s;
  assert(*s=="Hello world\n");
  Delitem(s, DOH_END);
  assert(*s=="Hello world");
  Clear(s);
  assert(*s=="");
  Delete(s);

}

void fiotest()
{
  String *s = NewStringf("%d  %d %d", 1, 2, 3);
  cout << *s;
  Printf(s, "Hello %s\n", "world");
  cout << *s;
  Printf(stdout, "(%s)\n", s);
  Delete(s);
}

void consttest()
{
  /* const test */
  say("Hello world!\n");
  const String *cs = NewString("Const world!\n");
  say(cs);
}

void listtest()
{
    /* Basic list test */
    List *l = NewList();
    String *s = NewString("Hello");
    Append(l, s);
    Append(l, NewString("World"));
    Append(l, NewList());

    String *r = dynamic_cast<String*>(l->front());
    cout << *r <<endl;
    cout << Len(l) << endl;
    delete l;
  }

void itertest() 
   {
    /* Iterator test */
    List *l = NewList();
    String *s = NewString("Hello");
    Append(l, s);
    Append(l, NewString(" world"));
    Append(l, NewString("!\n"));
    for (Iterator i=First(l); i.item; i=Next(i)) {
      say(i.item);
    }
    Iterator i=First(l);
    for (; i.item; i=Next(i)) {
      say(i.item);
    }
   }

void filetest() {
  Printf(stdout, "foo\n");
  Printf(stderr, "bar %d bar %p\n",0, 0);
  Printv(stdout, "hello ", "hi ", NULL);
}

void hashtest() {
  Hash *h = NewHash();
  Setattr(h, "hello", "world");
  String *s = Getattr(h, "hello");
  String *s2 = Getattr(h, "world");
  assert(*s=="world");
  assert(!s2);
  SetFlag(h, s);
  assert(GetFlag(h, s));
}

void chopreplacetest() {
  String *s = NewString("int abc()      \n");
  Chop(s);
  assert(*s=="int abc()");
  Chop(s);
  assert(*s=="int abc()");
  Replaceall(s, "int", "long");
  assert(*s=="long abc()"); 
//XXX  Replaceall(0, "int", "long");
}

void splittest() {
  String *s = NewString("ns:ns2:ns3:ns4");
  List *l = Split(s, ':', -1);
  Iterator i=First(l);
  cout << Len(l) <<endl;
  for(;i.item;i=Next(i)) {
    Printf(stdout, "%s\n", i.item);
  }
}

void sorttest() {
  String *s = NewString("5:4:3:2:1:0");
  List *l = Split(s, ':', -1);
  SortList(l, 0);
  Iterator i=First(l);
  for(;i.item;i=Next(i))
    Printf(stdout, "%s\n", i.item);
}


int main()
{
  stringtest();
  consttest();
  listtest();
  itertest();
  fiotest();
  filetest();
  hashtest();     
  chopreplacetest(); 
  splittest();
  sorttest();
  return 0;
}

