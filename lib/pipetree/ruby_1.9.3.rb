module Pipetree::Index193
  def index(func=nil)
    super() { |item| item.object_id == func.object_id }
  end
end
