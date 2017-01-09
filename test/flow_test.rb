require "test_helper"

require "pipetree/flow"

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

class FlowTest < Minitest::Spec
  F = Pipetree::Flow

  describe "#add" do
    let (:pipe) do
      pipe = F.new

      #       add: (track, proc)
      # macro returns [signal, input]: (can be added to pipe via #add)
      step_1 = F::And.new(->(input, options) { options["x"] = true })
      step_2 = F::And.new(->(input, options) { input })
      step_3 = F::And.new(->(input, options) { options["step_3"] = true })

      fail_1 = F::Stay.new(->(input, options) { options["fail_1"] = true })
      fail_2 = F::And.new(->(input, options) { options["fail_2"] = true }, on_true: left_1, on_false: F::Left)
      fail_3 = F::Stay.new(->(input, options) { options["fail_3"] = true })


      pipe.add(F::Right, step_1)
      pipe.add(F::Right, step_2)
      pipe.add(F::Left, fail_1)
      pipe.add(F::Left, fail_2)
      pipe.add(F::Left, fail_3)
      pipe.add(F::Right, step_3)
    end

    let (:left_1) { Class.new(F::Left) }

    # only right
    it { [pipe.(true, options={}), options].must_equal [[F::Right, true], {"x"=>true, "step_3"=>true}] }
    # jumps to left at step_2
    it { [pipe.(false, options={}), options].must_equal [[left_1, false], {"x"=>true, "fail_1"=>true, "fail_2"=>true}] }

    # options for #add
    # chainability of #add.
    it do
      F.new
        .add(F::Right, Object, name: "operation.new")
        .add(F::Right, Module, name: "nested.create", before: "operation.new")
        .inspect.must_equal %{[nested.create,operation.new]}
    end
  end
  # TODO: test name:, etc. for #add

  # TODO: test each function from & to > is only called once!
  # describe "#call" do
  #   let (:pipe) { Pipetree::Flow.new }
  #   it do
  #     pipe.>> ->(*) { puts "snippet" }
  #     pipe.({},{})
  #   end
  # end

  Aaa = ->(*) { "yo" }
  B   = ->(*) {  }

  let (:pipe) { pipe = Pipetree::Flow.new
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

  it do
    options = {}
    pipe.(%{{"key": 1,"key2":null}}, options)#.must_equal ""

    options.must_equal({"deserializer.result"=>{"key"=>1, "key2"=>nil}, "contract.errors.2"=>"screwd", "after_deserialize.fail"=>true, "meantime"=>true, "after_meantime.left?"=>true})
  end

  #---
  # return value is new input.
  it do
    pipe = Pipetree::Flow.new [
      Pipetree::Flow::On.new(Pipetree::Flow::Right, ->(last, value, options) { [Pipetree::Flow::Right, value.reverse] } )
    ]
    pipe.("Hello", {}).must_equal [Pipetree::Flow::Right, "olleH"]
  end

  #---
  # #>
  describe "#>" do
    let (:pipe) { Pipetree::Flow.new }
    it {
      pipe.> ->(input, options) { input.reverse }
      # pipe.| B
      # pipe.% A
      pipe.("Hallo", {}).must_equal [Pipetree::Flow::Right, "Hallo"]
     }
  end

  #---
  # #inspect
  Seventeen = ->(*) { snippet }
  Long      = ->(*) { snippet }
  Callable  = Object.new # random callable object.

  describe "#inspect" do
    let (:pipe) { Pipetree::Flow.new.&(Aaa).<(B).%(Aaa).<(Seventeen).>(Long).>(Callable) }

    it { pipe.inspect.must_equal %{[&Aaa,<B,%Aaa,<Seventeen,>Long,>#<Object:>]} }

    it { pipe.inspect(style: :rows).must_equal %{
 0 ==================================&Aaa
 1 <B====================================
 2 =================%Aaa=================
 3 <Seventeen============================
 4 =================================>Long
 5 ===========================>#<Object:>} }
  end

  describe "#index" do
    let (:pipe) { Pipetree::Flow.new.&(Aaa).<(B).%(Aaa, name: "a.triple") }

    it { pipe.index(B).must_equal 1 }
    it { pipe.index(Aaa).must_equal 0 }
    # with alias
    it { pipe.index("a.triple").must_equal 2 }

    # without steps
    it { Pipetree::Flow.new.index(B).must_equal nil }
  end

  #---
  # with aliases
  it do
    pipe = Pipetree::Flow.new.
      >(Aaa, name: "pipe.aaa").
      >(B, name: "pipe.b").
      >(Aaa, name: "pipe.aaa.aaa")

    pipe.inspect.must_equal %{[>pipe.aaa,>pipe.b,>pipe.aaa.aaa]}
    pipe.inspect(style: :rows).must_equal %{
 0 =============================>pipe.aaa
 1 ===============================>pipe.b
 2 =========================>pipe.aaa.aaa}

    pipe.>(Long, after: "pipe.b").inspect.must_equal %{[>pipe.aaa,>pipe.b,>Long,>pipe.aaa.aaa]}
  end

  #---
  # test decompose array
  it do
    pipe = Pipetree::Flow.new.
      &( ->((value, input), options) { input["x"] = value } ) # decomposes input.

    options={key: 1}
    input = {}

    pipe.([options[:key], input], options).must_equal [Pipetree::Flow::Right, [1, {"x"=>1}]]
    input.inspect.must_equal %{{"x"=>1}}
    options.inspect.must_equal %{{:key=>1}}
  end
end

#- StepMap
class StepMapTest < Minitest::Spec
  it do
    map = Pipetree::Flow::StepMap.new

    original_proc = ->(*) { snippet }
    step          = ->(*) { original_proc }

    original_proc2 = ->(*) { snippet }
    step2          = ->(*) { original_proc2 }

    map[step]  = "my.step", original_proc, ">"
    map[step2] = "my.step2", original_proc2, ">"

    map.find_proc(original_proc).must_equal step
    map.find_proc("my.step").must_equal step
    map.find_proc(original_proc2).must_equal step2
    map.find_proc("my.step2").must_equal step2
  end
end

# TODO: instead of testing #index, test all options like :before, etc.
