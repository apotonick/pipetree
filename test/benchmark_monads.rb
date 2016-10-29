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

require "pipetree/monad"

# 254.186k (± 1.2%) i/s -      1.289M in   5.071256s # pure dry-monads
# 268.407k (± 1.6%) i/s -      1.353M in   5.043612s # pipetree-flow

pipe = Pipetree::Monad[
  Pipetree::Monad::OnRight.new( ->(value, options) { #puts "|>DESERIALIZATION"
      value.nil? ? [Pipetree::Monad::Left, value] : [Pipetree::Monad::Right, value] } ),
  Pipetree::Monad::OnRight.new( ->(value, options) { #puts "|>VALIDATION"
      value[:ok?] ? [Pipetree::Monad::Right, value] : [Pipetree::Monad::Left, value] } ),
  Pipetree::Monad::OnRight.new( ->(value, options) { #puts "|>PERSISTENCE";
      value[:persist?] ? [Pipetree::Monad::Right, value] : [Pipetree::Monad::Left, value] } ),
  Pipetree::Monad::OnLeft.new( ->(value, options) { #puts "|| INVALID=CALLBACK";
      [Pipetree::Monad::Left, value] } ),
  Pipetree::Monad::OnRight.new( ->(value, options) { #puts "|>OK=CALLBACK";
      [Pipetree::Monad::Right, value] } ),
  Pipetree::Monad::OnLeft.new( ->(value, options) { #puts "|| SECOND-INVALID=CALLBACK";
      [Pipetree::Monad::Left, value] } ),

  Pipetree::Monad::OnLeft.new( ->(value, options) { #puts "|| FIXING IT=CALLBACK";
      [Pipetree::Monad::Right, value] } ),
]

puts "Pipetree"
pipe.({ok?: true}, {})

 # exit


flow = Pipetree::Monad[]
flow.& ->(value, options) {
  #puts "|>DESERIALIZATION"
  !value.nil? }
flow.& ->(value, options) {
  #puts "|>VALIDATION"
  value[:ok?] }
flow.& ->(value, options) {
  #puts "|>PERSISTENCE";
  value[:persist?] }
flow.| ->(value, options) {
  #puts "|| INVALID=CALLBACK";
  value }
flow.& ->(value, options) {
  #puts "|>OK=CALLBACK";
  value }
flow.| ->(value, options) {
  #puts "|| SECOND-INVALID=CALLBACK";
  value }
flow.| ->(value, options) {
  #puts "|| FIXING IT=CALLBACK"
  value }

puts "FLOW"
flow.({ok?: true}, {})

require "benchmark/ips"
Benchmark.ips do |x|
  x.report { c.calculate({ok?: true}) }
  x.report { pipe.({ok?: true}, {}) }
  x.report { flow.({ok?: true}, {}) }
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
