lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "pipetree/version"

Gem::Specification.new do |spec|
  spec.name          = "pipetree"
  spec.version       = Pipetree::VERSION
  spec.authors       = ["Nick Sutterer"]
  spec.email         = ["apotonick@gmail.com"]
  spec.description   = %q{Functional nested pipeline dialect for Ruby.}
  spec.summary       = %q{Functional nested pipeline dialect that reduces runtime logic, overriding and awkward module inclusion.}
  spec.homepage      = "https://github.com/apotonick/pipetree"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end
