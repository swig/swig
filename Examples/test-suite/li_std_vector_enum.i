%module li_std_vector_enum

%include "std_vector.i"

%inline %{
  class EnumVector {
  public:
    EnumVector() { fill_numbers(); }

    enum numbers {ten=10, twenty=20, thirty=30};

    std::vector<numbers> nums;

    void fill_numbers() {
      nums.push_back(ten);
      nums.push_back(twenty);
      nums.push_back(thirty);
    }
  };
%}

%template(vector_numbers) std::vector<EnumVector::numbers>;

#ifdef SWIGC
SWIG_STD_VECTOR_ITERATOR(EnumVector::numbers)
#endif
