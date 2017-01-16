require "pipetree/inspect"

module Pipetree::Railway::Inspect
  include ::Pipetree::Inspect

  def inspect_func(step)
    @inspect[step]
  end

  Operator = { Pipetree::Railway::Left => "<", Pipetree::Railway::Right => ">", }

  def inspect_line(names)
    string = names.collect { |i, (track, name)| "#{Operator[track]}#{name}" }.join(",")
    "[#{string}]"
  end

  def inspect_rows(names)
    string = names.collect do |i, (track, name)|
      operator = Operator[track]

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
