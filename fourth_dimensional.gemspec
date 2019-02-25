
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "fourth_dimensional/version"

Gem::Specification.new do |spec|
  spec.name          = "fourth_dimensional"
  spec.version       = FourthDimensional::VERSION
  spec.authors       = ["Baylor Rae'"]
  spec.email         = ["baylor@thecodedeli.com"]

  spec.summary       = %q{Fourth Dimensional is an event sourcing library to account for the state of a
  system in relation to time.}
  spec.description   = %q{Fourth Dimensional is an event sourcing library to account for the state of a
  system in relation to time.}
  spec.homepage      = "https://github.com/baylorrae/fourth_dimensional"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'activemodel', '>= 3.0'
  spec.add_dependency 'activesupport', '>= 3.0'

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "sdoc", "~> 1.0"
  spec.add_development_dependency "simplecov", "~> 0.16"
end
