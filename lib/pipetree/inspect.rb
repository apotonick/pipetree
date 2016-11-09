module Pipetree::Inspect
  # TODO: implement for nested
  # TODO: remove in Representable::Debug.
  def inspect(options={ style: :line })
    names = each_with_index.collect do |func, i|
      [i, inspect_func(func)]
    end

    return inspect_line(names) if options[:style] == :line
    inspect_rows(names)
  end

  # open source file to retrieve the constant name.
  def inspect_func(func)
    return inspect_object(func) unless func.is_a?(Proc)
    inspect_proc(func)
  end

  def inspect_object(obj)
    obj.inspect.sub(/0x\w+/, "")
  end

  def inspect_proc(proc)
    File.readlines(proc.source_location[0])[proc.source_location[1]-1].match(/^\s+([\w\:]+)/)[1]
  end

  def inspect_line(names)
    string = names.collect { |i, name| "#{name}" }.join("|>")
    "[#{string}]"
  end

  def inspect_rows(names)
    string = names.collect do |i, name|
      index = sprintf("%2d", i)
      inspect_row(index, name)
    end.join("\n")
      # name  = sprintf("%-60.300s", name) # no idea what i'm doing here.
      # "#{index}) #{name} #{func.source_location.join(":")}"
    "\n#{string}"
  end

  def inspect_row(index, name)
    "#{index}|>#{name}"
  end
end
