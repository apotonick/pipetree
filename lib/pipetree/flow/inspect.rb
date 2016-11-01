require "pipetree/inspect"

module Pipetree::Flow::Inspect
  include ::Pipetree::Inspect

  Proc = Struct.new(:proc, :operator)

  def inspect_for(step)
    debug = @debug[step]
    [super(debug.proc), debug.operator]
  end

  def inspect_line(names)
    string = names.collect { |i, name| "#{name.last}#{name.first}" }.join(",")
    "[#{string}]"
  end

  def inspect_row(index, name)
    "#{index} #{name.last}#{name.first}"
  end
end
