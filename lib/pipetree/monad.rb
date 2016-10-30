# condition: Left incoming? Right incoming? Whatever!
# brings default "return behavior", e.g. > always returns [Right, input]
require "pipetree/inspect"

class Pipetree::Monad < Array # yes, we could inherit, and so on.
  include Pipetree::Inspect
  def inspect_for(on)
    super(on.proc)
  end


  def |(proc, options={append: true}) # TODO: allow aliases, etc.
    self.insert! OnLeft.new(
      ->(input, options) { proc.(input, options) ; [Left, input] }, proc
    ), options
  end

  # OnRight-> ? Right, input : Left, input
  def &(proc, optionss={append: true})
    self.insert! OnRight.new(
      ->(input, options) { proc.(input, options) ? [Right, input] : [Left, input] }, proc
    ),optionss
  end

  # TODO: test me.
  def >(proc, optionss={append: true})
    self.insert! OnRight.new(
      ->(input, options) { proc.(input, options); [Right, input] }, proc
    ), optionss
  end
  def <(proc)

  end

  def >>(proc, optionss={append: true})
    self.insert! OnRight.new(
      ->(input, options) { [Right, proc.(input, options)] }, proc
    ), optionss
  end

  def %(proc)
    self.insert! OnWhatever.new(
      ->(incoming, input, options) { proc.(input, options) ; [incoming, input] }, proc
    ),{append: true}
  end

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

  class OnLeft # Or
    def initialize(bla, proc=nil)
      @bla=bla
      @proc=proc
    end

    def call(last, input, options)
      return [last, input] unless last==Left
      @bla.(input, options)
    end

    attr_reader :proc # :private:
  end

  Left  = Class.new
  Right = Class.new

  class OnRight < OnLeft
    def call(last, input, options)
      return [last, input] unless last==Right
      puts "calling #{@bla}"
      @bla.(input, options)
    end
  end

  class OnWhatever < OnLeft
    def call(last, input, options)
      @bla.(last, input, options)
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
