require "test_helper"

require "pipetree/monad"

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
  # TODO: test each function from & to > is only called once!
  # describe "#call" do
  #   let (:pipe) { Pipetree::Monad[] }
  #   it do
  #     pipe.>> ->(*) { puts "snippet" }
  #     pipe.({},{})
  #   end
  # end

  A = ->(*) {  }
  B = ->(*) {  }

  let (:pipe) { pipe = Pipetree::Monad[]
    pipe.& ->(value, options) { value && options["deserializer.result"] = JSON.parse(value) }
    pipe.& ->(value, options) { options["deserializer.result"]["key"] == 1 ? true : (options["contract.errors"]=false) }
    pipe.& ->(value, options) { options["deserializer.result"]["key2"] == 2 ? true : (options["contract.errors.2"]="screwd";false) }
    pipe.< ->(value, options) { options["after_deserialize.fail"]=true }
    pipe.% ->(value, options) { options["meantime"] = true }
    pipe.< ->(value, options) { options["after_meantime.left?"]=true; false } # false is ignored.

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

  #---
  # return value is new input.
  it do
    pipe = Pipetree::Monad[
      Pipetree::Monad::OnRight.new( ->(value, options) { [Pipetree::Monad::Right, value.reverse] } )
    ]
    pipe.("Hello", {}).must_equal [Pipetree::Monad::Right, "olleH"]
  end

  #---
  # #>
  describe "#>" do
    let (:pipe) { Pipetree::Monad[] }
    it {
      pipe.> ->(input, options) { input.reverse }
      # pipe.| B
      # pipe.% A
      pipe.("Hallo", {}).must_equal [Pipetree::Monad::Right, "Hallo"]
     }
  end

  #---
  # #inspect
  describe "#inspect" do
    let (:pipe) { Pipetree::Monad[].&(A).<(B).%(A) }

    it { pipe.inspect.must_equal %{[&A,<B,%A]} }

    it { pipe.inspect(style: :rows).must_equal %{
 0 &A
 1 <B
 2 %A} }
  end
end
