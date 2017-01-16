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

  def inspect_func(func)
    func
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
