#ifndef OBJCKW_SWG_
#define OBJCKW_SWG_

/* Warnings for ObjectiveC keywords */
#define OBJCKW(x) %keywordwarn("'" `x` "' is an ObjectiveC keyword, renaming to '_"`x`"'",rename="_%s")  `x`

OBJCKW(asm);
OBJCKW(auto);
OBJCKW(bool);
OBJCKW(BOOL);
OBJCKW(case);
OBJCKW(Class);
OBJCKW(const);
OBJCKW(continue);
OBJCKW(default);
OBJCKW(do);
OBJCKW(double);
OBJCKW(else);
OBJCKW(enum);
OBJCKW(extern);
OBJCKW(false);
OBJCKW(float);
OBJCKW(for);
OBJCKW(goto);
OBJCKW(id);
OBJCKW(if);
OBJCKW(IMP);
OBJCKW(instanceof);
OBJCKW(inline);
OBJCKW(int);
OBJCKW(long);
OBJCKW(new);
OBJCKW(nil);
OBJCKW(NIL);
OBJCKW(NO);
OBJCKW(register);
OBJCKW(return);
OBJCKW(SEL);
OBJCKW(short);
OBJCKW(signed);
OBJCKW(sizeof);
OBJCKW(static);
OBJCKW(struct);
OBJCKW(switch);
OBJCKW(true);
OBJCKW(typedef);
OBJCKW(void);
OBJCKW(volatile);
OBJCKW(wchar_t);
OBJCKW(while);
OBJCKW(YES);

#undef OBJCKW

/* Names commonly reserved by Objective-C/Foundation headers. */
#define OBJCFWK(x) %keywordwarn("'" `x` "' is reserved by Objective-C/Foundation headers",rename="_%s")  `x`

OBJCFWK(NSArray);
OBJCFWK(NSAutoreleasePool);
OBJCFWK(NSData);
OBJCFWK(NSException);
OBJCFWK(NSMutableArray);
OBJCFWK(NSString);

/* Classic macOS headers imported by Foundation reserve these C identifiers. */
OBJCFWK(Point);
OBJCFWK(Rect);
OBJCFWK(Size);

#undef OBJCFWK

#endif //OBJCKW_SWG_
