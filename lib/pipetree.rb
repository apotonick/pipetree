class Pipetree < Array
  # Allows to implement a pipeline of filters where a value gets passed in and the result gets
  # passed to the next callable object.
  Stop = Class.new

  # options is mutuable.
  # we have a fixed set of arguments here, since array splat significantly slows this down, as in
  # call(input, *options)
  def call(input, options)
    inject(input) do |memo, step|
      res = evaluate(step, memo, options)
      return(Stop) if Stop == res
      res
    end
  end

private
  def evaluate(step, input, options)
    step.call(input, options)
  end

  require "pipetree/inspect"
  include Inspect

  module Macros
    def insert!(new_function, options)
      Pipetree::Insert.(self, new_function, options)
    end
  end
  require "pipetree/insert"
  include Macros

  require "pipetree/ruby_1.9.3"
  include Index193 if RUBY_VERSION == "1.9.3"

  # Collect applies a pipeline to each element of input.
  class Collect < self
    # when stop, the element is skipped. (should that be Skip then?)
    def call(input, options)
      arr = []
      input.each_with_index do |item_fragment, i|
        result = super(item_fragment, options.merge(index: i)) # DISCUSS: NO :fragment set.
        Stop == result ? next : arr << result
      end
      arr
    end

    # DISCUSS: will this make it into the final version?
    class Hash < self
      def call(input, options)
        {}.tap do |hsh|
          input.each { |key, item_fragment|
            hsh[key] = super(item_fragment, options) }# DISCUSS: NO :fragment set.
        end
      end
    end
  end
end
