require "test_helper"

require "pipetree/flow"
class FlowInsertTest < Minitest::Spec
  A = ->{ }
  B = ->{ }
  C = ->{ }

  let (:pipe) { Pipetree::Flow.new.extend(Pipetree::Flow::Operator) }

  it { pipe.>(A, name: :A).>(B, name: :B).inspect.must_equal %{[>A,>B]} }
  it { pipe.>(A, name: :A).>(B, before: :A, name: :B).inspect.must_equal %{[>B,>A]} }
  it { pipe.>(A, name: :A).>(B, name: :B).>(C, after: :A, name: :C).inspect.must_equal %{[>A,>C,>B]} }
  it { pipe.>(A, name: "A").>(C, append: true, name: :C).inspect.must_equal %{[>A,>C]} }
  it { pipe.>(A, name: :A).>(C, prepend: true, name:  "C").inspect.must_equal %{[>C,>A]} }
  it { pipe.>(A, name: :A).>(C, replace: :A, name: :C).inspect.must_equal %{[>C]} }
  it { pipe.>(A, name: :A).add(nil, :A, delete: :A).inspect.must_equal %{[]} }
end
