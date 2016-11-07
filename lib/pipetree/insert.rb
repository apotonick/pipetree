module Pipetree::Function
  class Insert
    def call(arr, func, options)
      # arr = arr.dup
      operations = [:delete, :replace, :before, :after, :append, :prepend]

      # replace!(arr, options[:replace], func)
      options.keys.reverse.each { |k| operations.include?(k) and return send("#{k}!", arr, options[k], func) }

      raise "[Pipetree] Unknown command #{options.inspect}" # TODO: test.
      # arr
    end

  private
    def replace!(arr, old_func, new_func)
      arr[arr.index(old_func)] = new_func

      # arr.each_with_index { |func, index|
      #   if func.is_a?(::Pipetree::Collect)
      #     arr[index] = Collect[*Pipeline::Insert.(func, new_func, replace: old_func)]
      #   end

      #   arr[index] = new_func if func==old_func
      # }
      arr
    end

    def delete!(arr, _, removed_func)
      index = arr.index(removed_func)
      arr.delete_at(index)

      # TODO: make nice.
      # arr.each_with_index { |func, index|
      #   if func.is_a?(Collect)
      #     arr[index] = Collect[*Pipeline::Insert.(func, removed_func, delete: true)]
      #   end
      # }

      arr
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
