#import <Foundation/Foundation.h>
#import "multiple_inheritance_proxy.h"

#include <assert.h>

int main(int argc, char *argv[]) {
  (void)argc;
  (void)argv;

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  FooBar *foobar = [[FooBar alloc] init];
  assert([foobar foo] == 2);
  assert([foobar fooBar] == 3);

  Bar *bar = [foobar asBar];
  assert(bar != 0);
  assert([bar bar] == 1);

  FooBarSpam *foobarspam = [[FooBarSpam alloc] init];
  assert([foobarspam foo] == 2);
  assert([foobarspam fooBarSpam] == 4);

  Bar *spam_bar = [foobarspam asBar];
  assert(spam_bar != 0);
  assert([spam_bar bar] == 1);

  int value = 5;
  SpamInt *spam = [foobarspam asSpamInt];
  assert(spam != 0);
  assert([spam spam:&value] == 100);

  IgnoreDerived1 *ignored1 = [[IgnoreDerived1 alloc] init];
  assert([ignored1 bar] == 1);
  assert([ignored1 ignorederived1] == 7);

  IgnoreDerived2 *ignored2 = [[IgnoreDerived2 alloc] init];
  assert([ignored2 bar] == 1);
  assert([ignored2 ignorederived2] == 8);

  IgnoreDerived3 *ignored3 = [[IgnoreDerived3 alloc] init];
  assert([ignored3 bar] == 1);
  assert([ignored3 ignorederived3] == 9);

  IgnoreDerived4 *ignored4 = [[IgnoreDerived4 alloc] init];
  assert([ignored4 bar] == 1);
  assert([ignored4 ignorederived4] == 10);

  [ignored4 release];
  [ignored3 release];
  [ignored2 release];
  [ignored1 release];
  [foobarspam release];
  [foobar release];
  [pool release];

  return 0;
}
