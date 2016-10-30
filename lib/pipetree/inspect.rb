module Pipetree::Inspect
  # TODO: implement for nested
  # TODO: remove in Representable::Debug.
  def inspect(options={ style: :line })
    names = each_with_index.collect do |func, i|
      [i, inspect_for(func)]
    end

    if options[:style] == :line
      string = names.collect { |i, name| "#{name}" }.join("|>")
      return "[#{string}]"
    end

    string = names.collect do |i, name|
      index = sprintf("%2d", i)
      "#{index}|>#{name}"
    end.join("\n")
      # name  = sprintf("%-60.300s", name) # no idea what i'm doing here.
      # "#{index}) #{name} #{func.source_location.join(":")}"
    "\n#{string}"
  end

  def inspect_for(func)
    File.readlines(func.source_location[0])[func.source_location[1]-1].match(/^\s+([\w\:]+)/)[1]
  end
end
