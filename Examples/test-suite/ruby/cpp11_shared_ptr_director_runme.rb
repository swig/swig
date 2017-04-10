require 'cpp11_shared_ptr_director'

include Cpp11_shared_ptr_director

class Derived < Creator

  def initialize(flag)
    @return_none = flag
    super()
  end

  def create
    if @return_none
      nil
    else
      Created.new
    end
  end

end

p crash(Derived.new(false))
p crash(Derived.new(true))

