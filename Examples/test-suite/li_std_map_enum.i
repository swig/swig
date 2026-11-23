%module li_std_map_enum

%include "std_map.i"

%inline %{
class MapEnum {
public:
  MapEnum() {}

  enum numbers {ten=10, twenty=20, thirty=30};

  typedef std::map<numbers, int> Nums;

  Nums nums;
};
%}

%template(MapNumbersInt) std::map<MapEnum::numbers, int>;
