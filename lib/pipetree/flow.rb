class Pipetree < Array
  class Flow
    require "pipetree/flow/inspect"
    include Inspect
    require "pipetree/flow/step_map"
    require "pipetree/insert"

    def initialize(*args)
      @steps     = Array.new(*args)
      @step2proc = StepMap.new
    end

    # TODO: don't inherit from Array, because we don't want Array[].

    module Operators
      # Optimize the most common steps with Stay/And objects that are faster than procs.
      def <(proc, options={})
        _insert On.new(Left, Stay.new(proc)), options, proc, "<"
      end

      def &(proc, options={})
        _insert On.new(Right, And.new(proc)), options, proc, "&"
      end

      # TODO: test me.
      def >(proc, options={})
        _insert On.new(Right, Stay.new(proc)), options, proc, ">"
      end

      def >>(proc, options={})
        _insert On.new(Right,
          ->(last, input, options) { [Right, proc.(input, options)] } ), options, proc, ">>"
      end

      def %(proc, options={})
        # no condition is needed, and we want to stay on the same track, too.
        _insert Stay.new(proc), options, proc, "%"
      end

      def add(track, step, options={}, operator="")
        _insert On.new(track, step), options, step, operator
      end

      # :private:
      # proc is the original step proc, e.g. Validate.
      def _insert(step, options, original_proc, operator)
        options = { append: true }.merge(options)

        insert!(step, options).tap do
          @step2proc[step] = options[:name], original_proc, operator
        end

        self
      end

      # :private:
      def index(proc) # @step2proc: { <On @proc> => {proc: @proc, name: "trb.validate", operator: "&"} }
        on = @step2proc.find_proc(proc) and return @steps.index(on)
      end

      require "uber/delegates"
      extend Uber::Delegates
      delegates :@steps, :<<, :each_with_index, :[]=, :delete_at, :insert, :unshift # FIXME: make Insert properly decoupled!
    end
    include Operators

    # Actual implementation of Pipetree:Flow. Yes, it's that simple!
    def call(input, options)
      input = [Right, input]

      @steps.inject(input) do |(last, memo), step|
        step.call(last, memo, options)
      end
    end

    # Directions emitted by steps.
    Left  = Class.new
    Right = Class.new

    # Incoming direction must be Left/Right.
    class On
      def initialize(track, proc)
        @track, @proc = track, proc
      end

      def call(last, input, options)
        return [last, input] unless last == @track # return unless incoming track is Right (or Left).
        @proc.(last, input, options)
      end
    end

    # Call step proc and return (Right || Left).
    class And
      def initialize(proc, options={})
        @proc     = proc
        @on_true  = options[:on_true]  || Right
        @on_false = options[:on_false] || Left
      end

      def call(last, input, options)
        @proc.(input, options) ? [@on_true, input] : [@on_false,  input]
      end
    end

    # Call step proc and return incoming last step.
    class Stay < And
      def call(last, input, options)
        @proc.(input, options)
        [last, input] # simply pass through the current direction: either [Left, input] or [Right, input].
      end
    end

    include Function::Insert::Macros # #insert!
  end
end
