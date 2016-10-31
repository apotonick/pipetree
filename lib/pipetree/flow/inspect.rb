require "pipetree/inspect"

module Pipetree::Flow::Inspect
  include ::Pipetree::Inspect

  def inspect_for(on)
    [super(on.proc), on.operator]
  end

  def inspect_line(names)
    string = names.collect { |i, name| "#{name.last}#{name.first}" }.join(",")
    "[#{string}]"
  end

  def inspect_row(index, name)
    "#{index} #{name.last}#{name.first}"
  end
end
