# Map original proc or its name to the wrapped On.
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
      if method == :name
        inspect_proc.name == original_proc
      else
        inspect_proc.proc.object_id == original_proc.object_id # this works with procs in Ruby 1.9, too.
      end and return step
    end
  end
end
