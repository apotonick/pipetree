require "test_helper"


require "dry-monads"

class EitherCalculator
  include Dry::Monads::Either::Mixin

  attr_accessor :input

  def calculate(input)
    Right(input).bind do |value|
      # puts "|>DESERIALIZATION"
      value.nil? ? Left(value) : Right(value)
    end.bind do |value|
      # puts "|>VALIDATION"
      value[:ok?] ? Right(value) : Left(value)
    end.bind do |value|
      # puts "|>PERSISTENCE"
      value[:persist?] ? Right(value) : Left(value)
    end.or do |value|
      # puts "|| INVALID=CALLBACK"
      Left(value)
    end.bind do |value|
      # puts "|> OK=CALLBACK"
      Right(value)
    end.or do |value|
      # puts "|| SECOND-INVALID=CALLBACK"
      Left(value)
    end.or do |value|
      # puts "|| FIXING IT=CALLBACK"
      Right(value)
    end
    # .bind do |value|
    #   puts "|> WHATEVER HAPPENED=CALLBACK"
    #   Right(value)
    # end
  end
end

# EitherCalculator instance
c = EitherCalculator.new

# If everything went right
# c.calculate(nil)
# c.calculate({})
c.calculate({ok?: true})
# c.calculate({ok?: true, persist?: true})


class Pipetree < Array
  class Or
    def initialize(bla)
      @bla=bla
    end
    attr_reader :bla

    def call(input, options)
      @bla.(input, options)
    end
  end
  class Left < Or

  end
  class Right < Or

  end
  class OnRight < Or

  end

  def call(input, options)
    input = [Right, input]

    inject(input) do |memooo, step|
      # return(Stop) if Stop == res
      op, memo = memooo # op is "incoming op"
      # puts "@@@@#{op}@ #{memo.inspect} for #{step}"


      if op==Right && step.instance_of?(OnRight)
        next step.call(memo, options)
      #elsif op==Right && step.class==Left
      elsif step.instance_of?(Or) # result has to be Left

        next step.call(memo, options)
      end

      # Right-->Or
      memooo
    end
  end
end

pipe = Pipetree[
  Pipetree::OnRight.new( ->(value, options) { #puts "|>DESERIALIZATION"
      value.nil? ? [Pipetree::Left, value] : [Pipetree::Right, value] } ),
  Pipetree::OnRight.new( ->(value, options) { #puts "|>VALIDATION"
      value[:ok?] ? [Pipetree::Right, value] : [Pipetree::Left, value] } ),
  Pipetree::OnRight.new( ->(value, options) { #puts "|>PERSISTENCE";
      value[:persist?] ? [Pipetree::Right, value] : [Pipetree::Left, value] } ),
  Pipetree::Or.new( ->(value, options) { #puts "|| INVALID=CALLBACK";
      [Pipetree::Left, value] } ),
  Pipetree::OnRight.new( ->(value, options) { #puts "|>OK=CALLBACK";
      [Pipetree::Right, value] } ),
  Pipetree::Or.new( ->(value, options) { #puts "|| SECOND-INVALID=CALLBACK";
      [Pipetree::Left, value] } ),

  Pipetree::Or.new( ->(value, options) { #puts "|| FIXING IT=CALLBACK";
      [Pipetree::Right, value] } ),
]

puts "Pipetree"
pipe.({ok?: true}, {})

 # exit

require "benchmark/ips"
Benchmark.ips do |x|
  x.report { c.calculate({ok?: true}) }
  x.report { pipe.({ok?: true}, {}) }
end




# puts result = c.calculate


M = Dry::Monads

maybe_user = M.Maybe(true).bind do |u|
  M.Maybe(nil).bind do |a|
    M.Maybe(raise)
  end
end

class A
  def call
  end
end

# Benchmark.ips do |x|
#   x.report { A.new(1) } # 3.059M (± 4.4%) i/s -     15.302M in   5.012694s
#   x.report { [A, 1] }   # 6.606M (± 2.9%) i/s -     33.042M in   5.007420s
# end

#   proc = ->(*) {  }
#   a = A.new
# Benchmark.ips do |x|
#   x.report { proc.is_a?(Proc) }
#   x.report { a.()  }
# end
