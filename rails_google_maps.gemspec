# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails_google_maps/version'

Gem::Specification.new do |gem|
  gem.name          = "rails-google-maps"
  gem.version       = RailsGoogleMaps::VERSION
  gem.authors       = ["Yuri Ratanov"]
  gem.email         = ["yratanov@gmail.com"]
  gem.description   = 'Provides simple way to add google maps to your app'
  gem.summary       = 'Provides simple way to add google maps to your app'
  gem.homepage      = 'http://github.com/yratanov/rails_google_maps'

  gem.files        = `git ls-files`.split("\n")
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'rails', '~>3.0'
  gem.add_dependency 'jquery-rails'
  gem.add_dependency 'railties', '~> 3.1'
end
