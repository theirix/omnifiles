# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omnifiles/version'

Gem::Specification.new do |spec|
  spec.name          = "omnifiles"
  spec.version       = OmniFiles::VERSION
  spec.authors       = ["theirix"]
  spec.email         = ["theirix@gmail.com"]
  spec.summary       = %q{File storage and URL shortener.}
  spec.description   = %q{File storage and URL shortener.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "sinatra", "~> 1.4.5"
  spec.add_development_dependency "sinatra-assetpack", "~> 0.3.3"
  spec.add_development_dependency "ruby-filemagic", "~> 0.6.0"
  spec.add_development_dependency "sqlite3", "~> 1.3.10"
  spec.add_development_dependency "haml", "~> 4.0.0"
  spec.add_development_dependency "settingslogic", "~> 2.0.0"
  spec.add_development_dependency "thin", "~> 1.6.0"
end
