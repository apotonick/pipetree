module Pipetree::Function
  class Insert
    Operations = [:delete, :replace, :before, :after, :append, :prepend]

    # DISCUSS: all methods write to original array.
    def call(arr, operation, *args)
      # arr = arr.dup
      raise "[Pipetree] Unknown Insert operation #{args.inspect}" unless Operations.include?(operation)

      send("#{operation}!", arr, *args) # replace!(arr, Old, New)

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

    def delete!(arr, old_func, *)
      index = arr.index(old_func)
      arr.delete_at(index)

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
