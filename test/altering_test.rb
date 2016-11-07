require "test_helper"

class AlteringTest < Minitest::Spec
  A = ->(*) { "bla ruby 1.9 needs that" }
  B = ->(*) { }
  C = ->(*) { "otherwise it'll confuse empty procs" }

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

require "pipetree/flow"
class FlowInsertTest < Minitest::Spec
  A = ->{ }
  B = ->{ }
  C = ->{ }

  it { pipe = Pipetree::Flow[].>(A).>(B).inspect.must_equal %{[>A,>B]} }
  it { pipe = Pipetree::Flow[].>(A).>(B, before: A).inspect.must_equal %{[>B,>A]} }
  it { pipe = Pipetree::Flow[].>(A).>(B).>(C, after: A).inspect.must_equal %{[>A,>C,>B]} }
  it { pipe = Pipetree::Flow[].>(A).>(C, append: true).inspect.must_equal %{[>A,>C]} }
  it { pipe = Pipetree::Flow[].>(A).>(C, prepend: true).inspect.must_equal %{[>C,>A]} }
  it { pipe = Pipetree::Flow[].>(A).>(C, replace: A).inspect.must_equal %{[>C]} }
  it { pipe = Pipetree::Flow[].>(A)._insert(A, {delete: true}, nil, nil).inspect.must_equal %{[]} }

  # FIXME: add :delete and :replace.
end
