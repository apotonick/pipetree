require "test_helper"

require "benchmark/ips"
#  0.020000   0.000000   0.020000 (  0.023401)
#  0.050000   0.000000   0.050000 (  0.057883)
Return = ->(params, payload, read, write) {
  read["bla"]
  write["bla."] = Object
  params
}
# Return = ->(params, payload) {
#   payload[:read]["bla"]
#   payload[:write]["bla."] = Object
#   params
# }

pipe = Pipetree[
  *(99999.times.collect{ Return })
]

# puts Benchmark.measure { pipe.("bla", {}, {}, {}) }



#---
# replacing result AND options.
Return1 = ->(input, options) {
  result = input + "*"

  result
}

pipe1 = Pipetree[
  *(99999.times.collect{ Return1 })
]

class Pipetree2 < Pipetree
  def call(input, options)
    inject(input) do |memo, step|
      res, options = evaluate(step, memo, options)
      return(Stop) if Stop == res
      res
    end

  end
end

Return2 = ->(input, options) {
  [(result = (input + "*")), options]
}

pipe2 = Pipetree2[
  *(99999.times.collect{ Return2 })
]

Benchmark.ips do |x|
  x.report { pipe1.("", {}) }
  x.report { pipe2.("", {}) }
end
