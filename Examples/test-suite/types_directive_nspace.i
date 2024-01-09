%module types_directive_nspace

// This test is broken for a number of languages
#if ! defined(SWIGJAVA) && !defined(SWIGOCTAVE) && !defined(SWIGPYTHON) && !defined(SWIGTCL)

#if defined(SWIGR)
// Avoid conflict with Date class in R
#define Date DateSwig
%inline %{
#define Date DateSwig
%}
#endif

%nspace;

%ignore time2::Time2::operator date::Date *;

// allow conversion from Date -> Time1 using the following code
%types(time1::Time1 = date::Date) %{
  time1::Time1 *t = (time1::Time1 *)$from;
  date::Date &d = t->dateFromTime();
  return (void *) &d;
%}

// allow conversion from Date -> Time2 using conversion operator (cast) in Time2
%types(time2::Time2 = date::Date);

%inline %{
namespace date {
struct Date {
  Date(unsigned int year, unsigned int month, unsigned int day) : year(year), month(month), day(day) {}
  unsigned int year;
  unsigned int month;
  unsigned int day;
};
}

namespace time1 {
struct Time1 {
  Time1(unsigned int year, unsigned int month, unsigned int day, unsigned int seconds) : padding(), date(year, month, day), seconds(seconds) {}
  date::Date &dateFromTime() {
    return date;
  }
  unsigned int padding; // so that memory layout is not the same as Date
  date::Date date;
  unsigned int seconds;
};
}

namespace time2 {
struct Time2 {
  Time2(unsigned int year, unsigned int month, unsigned int day, unsigned int seconds) : date(year, month, day), seconds(seconds) {}
  operator date::Date *() {
    return &date;
  }
  date::Date date;
  unsigned int seconds;
};
}
date::Date add(const date::Date &date, unsigned int days) {
  date::Date newDate = date;
  newDate.day += days;
  return newDate;
}
%}

#endif // SWIGJAVA
