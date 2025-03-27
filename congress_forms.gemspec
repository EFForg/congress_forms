lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'congress_forms/version'

Gem::Specification.new do |spec|
  spec.name          = "congress_forms"
  spec.version       = CongressForms::VERSION
  spec.authors       = ["Peter Woo"]
  spec.email         = ["peterw@eff.org"]

  spec.summary       = %q{...}
  spec.homepage      = "https://github.com/efforg/congress_forms"
  spec.license       = "GPL-3.0"

  spec.required_ruby_version = ">= 3.0"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib", "cwc/lib"]

  spec.add_development_dependency "pry", "~> 0.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "dotenv", "~> 2.5"

  spec.add_dependency "capybara", "~> 3.40.0"
  spec.add_dependency "selenium-devtools"
  spec.add_dependency "nokogiri", ">= 1.8.2"
  spec.add_dependency "rest-client", "~> 2.0"
end
