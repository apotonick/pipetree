class Pipetree::Flow < Array # yes, we could inherit, and so on.
  require "pipetree/flow/inspect"
  include Inspect

  module Operators
    # Optimize the most common steps with Stay/And objects that are faster than procs.
    def <(proc, options=nil) # TODO: allow aliases, etc.
      insert On.new(Left, Stay.new(proc)), options, proc, "<"
    end

    # OnRight-> ? Right, input : Left, input
    def &(proc, options=nil)
      insert On.new(Right, And.new(proc)), options, proc, "&"
    end

    # TODO: test me.
    def >(proc, options=nil)
      insert On.new(Right, Stay.new(proc)), options, proc, ">"
    end

    def >>(proc, options=nil)
      insert On.new(Right,
        ->(input, options) { [Right, proc.(input, options)] } ), options, proc, ">>"
    end

    def %(proc, options=nil)
      # no condition is needed, and we want to stay on the same track, too.
      insert Stay.new(proc), options, proc, "%"
    end

    def insert(step, options, proc, operator)
      options ||= { append: true } # DISCUSS: needed?

      insert!(step, options).tap do
        @debug ||= {}
        @debug[step] = Inspect::Proc.new(proc, operator)
      end
    end
  end
  include Operators

  # Actual implementation of Pipetree:Flow. Yes, it's that simple!
  def call(input, options)
    input = [Right, input]

    inject(input) do |memooo, step|
      last, memo = memooo
      step.call(last, memo, options)
    end
  end

  def index(func) # FIXME: test me.
    super(find { |on| on.proc == func } )
  end

  # Directions emitted by steps.
  Left  = Class.new
  Right = Class.new

  # Incoming direction must be Left/Right.
  class On
    def initialize(direction, proc)
      @direction, @proc = direction, proc
    end

    def call(last, input, options)
      return [last, input] unless last == @direction # return unless incoming direction is Right (or Left).
      @proc.(last, input, options)
    end
  end

  # Call step proc and return (Right || Left).
  class And
    def initialize(proc)
      @proc = proc
    end

    def call(last, input, options)
      @proc.(input, options) ? [Right, input] : [Left,  input]
    end
  end

  # Call step proc and return incoming last step.
  class Stay < And
    def call(last, input, options)
      @proc.(input, options)
      [last, input] # simply pass through the current direction: either [Left, input] or [Right, input].
    end
  end





  require "pipetree/insert"
  module Macros
    def insert!(new_function, options)
      Pipetree::Insert.(self, new_function, options)
    end
  end
  include Macros # FIXME: we shouldn't expose #insert!
end
