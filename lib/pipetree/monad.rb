# condition: Left incoming? Right incoming? Whatever!

class Pipetree::Monad < Array # yes, we could inherit, and so on.
  def |(proc) # TODO: allow aliases, etc.
    self << OnLeft.new(
      ->(input, options) { proc.(input, options) ; [Left, input] }
    )
  end

  def &(proc)
    self << OnRight.new(
      ->(input, options) { (res = proc.(input, options)) ? [Right, input] : [Left, input] }
    )
  end

  def %(proc)
    self << OnWhatever.new(
      ->(incoming, input, options) { proc.(input, options) ; [incoming, input] }
    )
  end

  def call(input, options)
    input = [Right, input]

    inject(input) do |memooo, step|
      last, memo = memooo

      step.call(last, memo, options)
    end
  end

  class OnLeft # Or
    def initialize(bla)
      @bla=bla
    end

    def call(last, input, options)
      return [last, input] unless last==Left
      @bla.(input, options)
    end
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
end
