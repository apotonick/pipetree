class Pipetree
  class Railway
    require "pipetree/insert"
    require "pipetree/railway/operator"

    def initialize(*args)
      @steps   = Array.new(*args)
      @index   = Hash.new
      @inspect = Hash.new
    end

    # Actual implementation of Pipetree:Railway. Yes, it's that simple!
    def call(input, options)
      input = [Right, input]

      @steps.inject(input) do |(last, memo), step|
        step.call(last, memo, options)
      end
    end

    # Naming:
    # * Track
    # * Tie: the callable that's usually an On instance and is sitting directly in the pipe, on a Track.
    # * Strut: the callable that's wrapped by the Tie and implements the decider logic (e.g. And).
    # * Step: the user callable with interface `Step.(input, options)`.
    module Add
      def add(track, strut, options={})
        _insert On.new(track, strut), options, track, strut
      end

      extend Forwardable
      # TODO: make Insert properly decoupled! it still relies on Array interface on pipe`.
      def_delegators :@steps, :<<, :each_with_index, :[]=, :delete_at, :insert, :unshift, :index

    private
      def _insert(tie, options, track, strut)
        insert_operation = (options.keys & ::Pipetree::Function::Insert::Operations).last || :append

        old_tie = @index[ options[insert_operation] ] # name --> tie

        # todo: step, old_tie (e.g. for #delete!).
        Insert.(self, insert_operation, old_tie, tie)

        @index[options[:name]] = tie
        @inspect[tie]          = [ track, options[:name] ]

        self
      end
    end
    include Add

    # Tracks emitted by steps.
    Track = Class.new
    Left  = Class.new(Track)
    Right = Class.new(Track)

    # Incoming direction must be Left/Right.
    # Tie
    class On
      def initialize(track, proc)
        @track, @proc = track, proc
      end

      def call(last, input, options)
        return [last, input] unless last == @track # return unless incoming track is Right (or Left).
        @proc.(last, input, options)
      end
    end

    class Strut
      def initialize(proc, config={})
        @proc    = proc
        @config  = config
      end

      def call(last, input, options)
        result = @proc.(input, options) # call the actual step.

        [self.class::Decider.(result, @config, last, input, options), input] # decide about the track and return Flow-compliant response.
      end
    end

    # Call step proc and return (Right || Left).
    class And < Strut
      # Deciders return the new track.
      Decider = ->(result, config, *) do
        result ?
          config[:on_true]  || Right :
          config[:on_false] || Left
      end
    end

    # Call step proc and return incoming last step.
    class Stay < Strut
      # simply pass through the current direction: e.g. Left or Right.
      Decider = ->(result, cfg, last, *) { last }
    end

    require "pipetree/railway/inspect"
    include Inspect
  end
end
