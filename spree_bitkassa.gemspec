# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_bitkassa'
  s.version     = '0.0.1'
  s.summary     = "Bitkassa Integration for Spree"
  s.description = File.read(File.join(File.dirname(__FILE__), "README.md"))
  s.required_ruby_version = '>= 2.0.0'

  s.author    = "Bèr Kessels"
  s.email     = "gems@berk.es"
  s.homepage  = "http://berk.es"

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 3.0.4'

  s.add_development_dependency 'capybara', '~> 2.4'
  s.add_development_dependency "launchy", "~> 2.4"
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl', '~> 4.5'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'rspec-rails',  '~> 3.1'
  s.add_development_dependency 'sass-rails', '~> 5.0.0.beta1'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency "byebug"
  s.add_development_dependency "rb-readline"
end
