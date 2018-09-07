# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'congress_forms/version'

Gem::Specification.new do |spec|
  spec.name          = "congress_forms"
  spec.version       = CongressForms::VERSION
  spec.authors       = ["Peter Woo"]
  spec.email         = ["peterw@eff.org"]

  spec.summary       = %q{...}
  spec.homepage      = "https://github.com/efforg"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib", "cwc/lib"]

  spec.add_development_dependency "pry"
  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "dotenv"

  spec.add_dependency "capybara-selenium"
  spec.add_dependency "chromedriver-helper"
  spec.add_dependency "nokogiri", ">= 1.8.2"
  spec.add_dependency "rest-client"
end
