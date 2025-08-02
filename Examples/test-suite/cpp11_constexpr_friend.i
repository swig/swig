%module cpp11_constexpr_friend

%rename("isEqual") operator==(FriendA const& lhs, FriendA const& rhs) noexcept;
%rename("isEqual") operator==(FriendB const& lhs, FriendB const& rhs) noexcept;

%inline %{
  class FriendA final
  {
    public:
      FriendA(int const v) noexcept : _v(v)
      {
      }

      constexpr friend bool operator==(FriendA const& lhs, FriendA const& rhs) noexcept
      {
        return lhs._v == rhs._v;
      }
    private:
      int _v{};
  };
  class FriendB final
  {
    public:
      FriendB(int const v) noexcept : _v(v)
      {
      }

      constexpr friend bool operator==(FriendB const& lhs, FriendB const& rhs) noexcept
      {
        return lhs._v == rhs._v;
      }
    private:
      int _v{};
  };
%}
