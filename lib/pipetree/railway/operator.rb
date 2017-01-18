# Optimize the most common steps with Stay/And objects that are faster than procs.
# This is experimental API and might be removed/changed without prior warning.
class Pipetree::Railway
  module Operator
    def <(proc, options={})
      _insert(Pipetree::Railway.<(proc), options, Left, proc)
    end

    def &(proc, options={})
      _insert(Pipetree::Railway.&(proc), options, Right, proc)
    end

    def >(proc, options={})
      _insert(Pipetree::Railway.>(proc), options, Right, proc)
    end
  end

  def self.<(proc)
    On.new(Left, Stay.new(proc))
  end

  def self.&(proc)
    On.new(Right, And.new(proc))
  end

  def self.>(proc)
    On.new(Right, Stay.new(proc))
  end
end
