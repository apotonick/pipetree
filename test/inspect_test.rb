require "test_helper"

class InspectTest < Minitest::Spec
  AlphaConstant = ->(*) { }
  Beta          = ->(*) { }

  let (:pipe) { ::Pipetree[Beta, AlphaConstant, Beta, AlphaConstant, Beta, AlphaConstant, Beta, AlphaConstant, Beta, AlphaConstant, Beta] }

  it do
    puts pipe.inspect


    pipe.inspect.must_equal %{ 0) Beta
 1) AlphaConstant
 2) Beta
 3) AlphaConstant
 4) Beta
 5) AlphaConstant
 6) Beta
 7) AlphaConstant
 8) Beta
 9) AlphaConstant
10) Beta}
  end

  # different separator
  it { ::Pipetree[AlphaConstant,Beta].inspect(",").must_equal %{ 0) AlphaConstant, 1) Beta} }
end
