require "test_helper"

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

# pipe = Pipetree[
#   Pipetree::OnRight.new( ->(value, options) { #puts "|>DESERIALIZATION"
#       value.nil? ? [Pipetree::Left, value] : [Pipetree::Right, value] } ),
#   Pipetree::OnRight.new( ->(value, options) { #puts "|>VALIDATION"
#       value[:ok?] ? [Pipetree::Right, value] : [Pipetree::Left, value] } ),
#   Pipetree::OnRight.new( ->(value, options) { #puts "|>PERSISTENCE";
#       value[:persist?] ? [Pipetree::Right, value] : [Pipetree::Left, value] } ),
#   Pipetree::OnLeft.new( ->(value, options) { #puts "|| INVALID=CALLBACK";
#       [Pipetree::Left, value] } ),
#   Pipetree::OnRight.new( ->(value, options) { #puts "|>OK=CALLBACK";
#       [Pipetree::Right, value] } ),
#   Pipetree::OnLeft.new( ->(value, options) { #puts "|| SECOND-INVALID=CALLBACK";
#       [Pipetree::Left, value] } ),

#   Pipetree::OnLeft.new( ->(value, options) { #puts "|| FIXING IT=CALLBACK";
#       [Pipetree::Right, value] } ),
# ]

# puts "Pipetree"
# pipe.({ok?: true}, {})

require "json"

class MonadTest < Minitest::Spec
  let (:pipe) { pipe = Pipetree::Monad[]
    pipe.& ->(value, options) { value && options["deserializer.result"] = JSON.parse(value) }
    pipe.& ->(value, options) { options["deserializer.result"]["key"] == 1 ? true : (options["contract.errors"]=false) }
    pipe.& ->(value, options) { options["deserializer.result"]["key2"] == 2 ? true : (options["contract.errors.2"]="screwd";false) }
    pipe.| ->(value, options) { options["after_deserialize.fail"]=true }
    pipe.% ->(value, options) { options["meantime"] = true }
    pipe.| ->(value, options) { options["after_meantime.left?"]=true; false } # false is ignored.

  }

  # success?
  it do
    options = {}
    pipe.(%{{"key": 1,"key2":2}}, options)#.must_equal ""

    options.must_equal({"deserializer.result"=>{"key"=>1, "key2"=>2}, "meantime"=>true})
  end

  # invalid?
  it do
    options = {}
    pipe.(%{{"key": 2}}, options)#.must_equal ""

    options.must_equal({"deserializer.result"=>{"key"=>2}, "contract.errors"=>false, "after_deserialize.fail"=>true, "meantime"=>true, "after_meantime.left?"=>true})
  end

  it "what" do
    options = {}
    pipe.(%{{"key": 1,"key2":null}}, options)#.must_equal ""

    options.must_equal({"deserializer.result"=>{"key"=>1, "key2"=>nil}, "contract.errors.2"=>"screwd", "after_deserialize.fail"=>true, "meantime"=>true, "after_meantime.left?"=>true})
  end
end
