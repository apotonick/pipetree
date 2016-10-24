module Pipetree::Function
  class Insert
    def call(arr, func, options)
      # arr = arr.dup
      return delete!(arr, func) if options[:delete]
      return replace!(arr, options[:replace], func) if options[:replace]
      return before!(arr, options[:before], func)   if options[:before]
      return after!(arr, options[:after], func)   if options[:after]
      return append!(arr, options[:append], func)   if options[:append]
      return prepend!(arr, options[:prepend], func)   if options[:prepend]

      raise "[Pipetree] Unknown command #{options.inspect}" # TODO: test.
      # arr
    end

  private
    def replace!(arr, old_func, new_func)
      arr.each_with_index { |func, index|
        if func.is_a?(Collect)
          arr[index] = Collect[*Pipeline::Insert.(func, new_func, replace: old_func)]
        end

        arr[index] = new_func if func==old_func
      }
    end

    def delete!(arr, removed_func)
      arr.delete(removed_func)

      # TODO: make nice.
      arr.each_with_index { |func, index|
        if func.is_a?(Collect)
          arr[index] = Collect[*Pipeline::Insert.(func, removed_func, delete: true)]
        end
      }
    end

    # TODO: not nested.
    def before!(arr, old_func, new_func)
      index = arr.index(old_func)
      arr.insert(index, new_func)
    end

    def after!(arr, old_func, new_func)
      index = arr.index(old_func)+1
      arr.insert(index, new_func)
    end

    def append!(arr, old_func, new_func)
      arr << (new_func)
    end

    def prepend!(arr, old_func, new_func)
      arr.unshift(new_func)
    end
  end
end

Pipetree::Insert = Pipetree::Function::Insert.new

#FIXME: all methods write to original array.
