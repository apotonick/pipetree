# Optimize the most common steps with Stay/And objects that are faster than procs.
# This is experimental API and might be removed/changed without prior warning.
class Pipetree::Flow
  module Operator
    def <(proc, options={})
      _insert On.new(Left, Stay.new(proc)), options, Left, proc#, "<"
    end

    def &(proc, options={})
      _insert On.new(Right, And.new(proc)), options, Right, proc#, "&"
    end

    def >(proc, options={})
      _insert On.new(Right, Stay.new(proc)), options, Right, proc#, ">"
    end
  end
end
