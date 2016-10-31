# condition: Left incoming? Right incoming? Whatever!
# brings default "return behavior", e.g. > always returns [Right, input]
class Pipetree::Flow < Array # yes, we could inherit, and so on.
  require "pipetree/flow/inspect"
  include Inspect

  def <(proc, options={append: true}) # TODO: allow aliases, etc.
    self.insert! OnLeft.new(
      ->(input, options) { proc.(input, options) ; [Left, input] }, proc, "<"
    ), options
  end
  # TODO: do we need the | operator?

  # OnRight-> ? Right, input : Left, input
  def &(proc, options={append: true})
    self.insert! OnRight.new(
      ->(input, options) { proc.(input, options) ? [Right, input] : [Left, input] }, proc, "&"
    ),options
  end

  # TODO: test me.
  def >(proc, options={append: true})
    self.insert! OnRight.new(
      ->(input, options) { proc.(input, options); [Right, input] }, proc, ">"
    ), options
  end

  def >>(proc, options={append: true})
    self.insert! OnRight.new(
      ->(input, options) { [Right, proc.(input, options)] }, proc, ">>"
    ), options
  end

  def %(proc)
    self.insert! OnWhatever.new(
      ->(incoming, input, options) { proc.(input, options) ; [incoming, input] }, proc, "%"
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
    def initialize(bla, proc=nil, operator=nil)
      @bla=bla
      @proc=proc
      @operator=operator
    end

    def call(last, input, options)
      return [last, input] unless last==Left
      @bla.(input, options)
    end

    attr_reader :proc, :operator # :private:
  end

  Left  = Class.new
  Right = Class.new

  class OnRight < OnLeft
    def call(last, input, options)
      return [last, input] unless last==Right
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
