class Pipetree
  class Railway
    require "pipetree/insert"
    require "pipetree/railway/operator"

    def initialize(*args)
      @steps   = Array.new(*args)
      @index   = Hash.new
      @inspect = Hash.new
    end

    # TODO: don't inherit from Array, because we don't want Array[].

    # Actual implementation of Pipetree:Railway. Yes, it's that simple!
    def call(input, options)
      input = [Right, input]

      @steps.inject(input) do |(last, memo), step|
        step.call(last, memo, options)
      end
    end

    module Add
      def add(track, strut, options={})
        _insert On.new(track, strut), options, track, strut
      end

      require "uber/delegates"
      extend Uber::Delegates
      # TODO: make Insert properly decoupled! it still relies on Array interface on pipe`.
      delegates :@steps, :<<, :each_with_index, :[]=, :delete_at, :insert, :unshift, :index

    private
      def _insert(tie, options, track, strut)
        insert_operation = (::Pipetree::Function::Insert::Operations & options.keys).first || :append

        old_tie = @index[ options[insert_operation] ] # name --> tie

        # todo: step, old_tie (e.g. for #delete!).
        Insert.(self, insert_operation, old_tie, tie)

        @index[options[:name]] = tie
        @inspect[tie] = [ track, options[:name] ]

        self
      end
    end
    include Add

    # Tracks emitted by steps.
    Track = Class.new
    Left  = Class.new(Track)
    Right = Class.new(Track)

    # Incoming direction must be Left/Right.
    # Struts
    class On
      def initialize(track, proc)
        @track, @proc = track, proc
      end

      def call(last, input, options)
        return [last, input] unless last == @track # return unless incoming track is Right (or Left).
        @proc.(last, input, options)
      end
    end

    class Tie
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
    class And < Tie
      # Deciders return the new track.
      Decider = ->(result, config, *) do
        result ?
          config[:on_true]  || Right :
          config[:on_false] || Left
      end
    end

    # Call step proc and return incoming last step.
    class Stay < Tie
      # simply pass through the current direction: e.g. Left or Right.
      Decider = ->(result, cfg, last, *) { last }
    end

    require "pipetree/railway/inspect"
    include Inspect
  end
end
