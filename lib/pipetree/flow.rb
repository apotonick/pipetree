class Pipetree::Flow < Array # yes, we could inherit, and so on.
  require "pipetree/flow/inspect"
  include Inspect

  module Operators
    # Optimize the most common steps with Stay/And objects that are faster than procs.
    def <(proc, options=nil) # TODO: allow aliases, etc.
      insert OnLeft.new(Stay.new(proc)), options, proc, "<"
    end

    # OnRight-> ? Right, input : Left, input
    def &(proc, options=nil)
      insert OnRight.new(And.new(proc)), options, proc, "&"
    end

    # TODO: test me.
    def >(proc, options=nil)
      insert OnRight.new(Stay.new(proc)), options, proc, ">"
    end

    def >>(proc, options=nil)
      insert OnRight.new(
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

  # Handler wrapping the actual step logic and skip if wrong track.
  # Operators use those handlers.

  # Incoming direction must be Left.
  class OnLeft
    def initialize(proc)
      @proc = proc
    end

    def call(last, input, options)
      return [last, input] unless last==Left
      @proc.(last, input, options)
    end
  end

  # Incoming direction must be Right.
  class OnRight < OnLeft
    def call(last, input, options)
      return [last, input] unless last==Right
      @proc.(last, input, options)
    end
  end

  # Calls the actual step and provides common behavior.

  class And
    def initialize(proc)
      @proc = proc
    end

    def call(last, input, options)
      @proc.(input, options) ? [Right, input] : [Left,  input]
    end
  end

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
