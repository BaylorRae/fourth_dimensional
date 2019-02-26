
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

  spec.files         = Dir['lib/**/*.rb']
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'activemodel', '>= 3.0'
  spec.add_dependency 'activesupport', '>= 3.0'

  spec.add_development_dependency 'activerecord', '>= 3.0'
  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "sdoc", "~> 1.0"
  spec.add_development_dependency "simplecov", "~> 0.16"
  spec.add_development_dependency "sqlite3", "~> 1.3", "< 1.4"
end
