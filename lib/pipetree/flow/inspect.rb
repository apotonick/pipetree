require "pipetree/inspect"

module Pipetree::Flow::Inspect
  include ::Pipetree::Inspect

  Proc = Struct.new(:name, :proc, :operator)

  def inspect_func(step)
    cfg = @step2proc[step]
    [cfg.name || super(cfg.proc), cfg.operator]
  end

  def inspect_line(names)
    string = names.collect { |i, name| "#{name.last}#{name.first}" }.join(",")
    "[#{string}]"
  end

  def inspect_row(index, name)
    "#{index} #{name.last}#{name.first}"
  end

  def inspect_rows(names)
    string = names.collect do |i, (name, operator)|

      op = "#{operator}#{name}"
      padding = 38

      proc = if operator == "<"
        sprintf("%- #{padding}s", op)
      elsif [">", ">>", "&"].include?(operator.to_s)
        sprintf("% #{padding}s", op)
      else
        pad = " " * ((padding - op.length) / 2)
        "#{pad}#{op}#{pad}"
      end

      proc = proc.gsub(" ", "=")

      sprintf("%2d %s", i, proc)
    end.join("\n")
    "\n#{string}"
  end
end
