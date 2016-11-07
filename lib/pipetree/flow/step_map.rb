# Map original proc or its name to the wrapped On.
# This class is solely dedicated for inspect and insert operations, and not
# involved at run-time at all.
class Pipetree::Flow::StepMap
  def initialize
    @hash = {}
  end

  def []=(step, (name, original_proc, operator))
    @hash[step] = Pipetree::Flow::Inspect::Proc.new(name, original_proc, operator)
  end

  def [](key)
    @hash[key]
  end

  def find_proc(original_proc)
    method = original_proc.is_a?(String) ? :name : :proc

    @hash.find do |step, inspect_proc|
      inspect_proc.send(method) == original_proc and return step
    end
  end
end
