require "test_helper"

class AlteringTest < Minitest::Spec
  A = ->(*) { }
  B = ->(*) { }
  C = ->(*) { }

  # constructor.
  it do
    pipe = ::Pipetree[A, B]
    pipe.inspect.must_equal %{[A|>B]}
  end

  it { Pipetree[].insert(0, B).inspect.must_equal %{[B]} }
  it { Pipetree[].unshift(B).inspect.must_equal %{[B]} }
  it { Pipetree[].unshift(B, A).inspect.must_equal %{[B|>A]} }

  it { Pipetree[A,B].insert!(C, before: A).inspect.must_equal %{[C|>A|>B]} }
  it { Pipetree[A,B].insert!(C, before: B).inspect.must_equal %{[A|>C|>B]} }

  it { Pipetree[A,B].insert!(C, after: A).inspect.must_equal %{[A|>C|>B]} }
  it { Pipetree[A,B].insert!(C, after: B).inspect.must_equal %{[A|>B|>C]} }

  it { Pipetree[A,B].insert!(C, append: true).inspect.must_equal %{[A|>B|>C]} }
  it { Pipetree[].insert!(C, append: true).inspect.must_equal %{[C]} }

  it { Pipetree[A,B].insert!(C, prepend: true).inspect.must_equal %{[C|>A|>B]} }
  it { Pipetree[].insert!(C, prepend: true).inspect.must_equal %{[C]} }
end
