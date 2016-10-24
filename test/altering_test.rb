require "test_helper"

class AlteringTest < Minitest::Spec
  A = ->(*) { }
  B = ->(*) { }
  C = ->(*) { }

  # constructor.
  it do
    pipe = ::Pipetree[A, B]
    pipe.inspect(",").must_equal %{ 0) A, 1) B}
  end

  it { Pipetree[].insert(0, B).inspect.must_equal %{ 0) B} }
  it { Pipetree[].unshift(B).inspect.must_equal %{ 0) B} }
  it { Pipetree[].unshift(B, A).inspect(",").must_equal %{ 0) B, 1) A} }

  it { Pipetree[A,B].insert!(C, before: A).inspect(",").must_equal %{ 0) C, 1) A, 2) B} }
  it { Pipetree[A,B].insert!(C, before: B).inspect(",").must_equal %{ 0) A, 1) C, 2) B} }

  it { Pipetree[A,B].insert!(C, after: A).inspect(",").must_equal %{ 0) A, 1) C, 2) B} }
  it { Pipetree[A,B].insert!(C, after: B).inspect(",").must_equal %{ 0) A, 1) B, 2) C} }
end
