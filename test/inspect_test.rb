# require "test_helper"

# class InspectTest < Minitest::Spec
#   module M
#   end

#   M::AlphaConstant = ->(*) { }
#   M::Beta          = ->(*) { }
#   Callable         = Object.new

#   let (:pipe) { ::Pipetree[M::Beta, M::AlphaConstant, M::Beta, M::AlphaConstant, M::Beta, M::AlphaConstant, M::Beta, M::AlphaConstant, M::Beta, M::AlphaConstant, M::Beta, Callable] }

#   it do
#     puts pipe.inspect
#     puts pipe.inspect(style: :rows)


#     pipe.inspect(style: :rows).must_equal %{
#  0|>M::Beta
#  1|>M::AlphaConstant
#  2|>M::Beta
#  3|>M::AlphaConstant
#  4|>M::Beta
#  5|>M::AlphaConstant
#  6|>M::Beta
#  7|>M::AlphaConstant
#  8|>M::Beta
#  9|>M::AlphaConstant
# 10|>M::Beta
# 11|>#<Object:>}
#   end

#   # different separator
#   it { ::Pipetree[M::AlphaConstant,M::Beta,Callable].inspect.must_equal %{[M::AlphaConstant|>M::Beta|>#<Object:>]} }
# end
