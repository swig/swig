/* File : director.h */
#include <string>
#include <vector>

class Joiner {
 public:
  virtual ~Joiner() = 0;

  //! Add quotes to the string or whatever
  virtual std::string transform(const std::string& s) const = 0;

  //! Join all stored strings
  std::string join(const std::string& conjunction) const;

  //! Add an item to be joined
  void append(const std::string& s) { items_.push_back(s); }

  //! Add several items for convenience
  void append_several();

 private:
  typedef std::vector<std::string> VecStr;
  VecStr items_;
};

class PassthroughJoiner : public Joiner {
 public:
  virtual std::string transform(const std::string& s) const { return s; }
};

class QuoteJoiner : public Joiner {
 public:
  virtual std::string transform(const std::string& s) const;
};

std::string join_with_commas(const Joiner& j);

/* vim: set ts=2 sw=2 sts=2 tw=129 : */
