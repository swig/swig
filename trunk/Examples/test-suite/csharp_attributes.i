%module csharp_attributes

// Test the inattributes and outattributes typemaps
%typemap(cstype, outattributes="[IntOut]", inattributes="[IntIn]") int "int"
%typemap(imtype, outattributes="[IntegerOut]", inattributes="[IntegerIn]") int "int"

%inline %{
class Stations {
public:
  Stations(int myInt) { }
  int Reading(int myInt) { return myInt; }
  static int Swindon(int myInt) { return myInt; }
};
#define TESTMACRO 10
int GlobalFunction(int myInt) { return myInt; }
%}


// Test the attributes feature
%csattributes MoreStations::MoreStations()      "[InterCity1]"
%csattributes MoreStations::Chippenham()        "[InterCity2]"
%csattributes MoreStations::Bath()              "[InterCity3]"
%csattributes Bristol                           "[InterCity4]"
%csattributes WestonSuperMare                   "[InterCity5]"
%csattributes Wales                             "[InterCity6]"
%csattributes Paddington()                      "[InterCity7]"
%csattributes DidcotParkway                     "[InterCity8]"

%typemap(csattributes) MoreStations "[Eurostar1]"
%typemap(csattributes) MoreStations::Wales "[Eurostar2]"
%typemap(csattributes) Cymru "[Eurostar3]"

%inline %{
struct MoreStations {
  MoreStations() : Bristol(0) {}
  void Chippenham() {}
  static void Bath() {}
  int Bristol;
  static double WestonSuperMare;
  enum Wales { Cardiff = 1, Swansea };
};
void Paddington() {}
float DidcotParkway;
enum Cymru { Llanelli };

double MoreStations::WestonSuperMare = 0.0;
%}

