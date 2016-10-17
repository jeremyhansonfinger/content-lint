# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = 'erb_lint'
  s.version = '0.0.0'
  s.authors = ['Justin Chan']
  s.email = ['justin.the.c@gmail.com']
  s.summary = 'ERB lint tool'
  s.description = 'ERB Linter tool.'
  s.homepage = 'https://github.com/justinthec/erb-lint'
  s.license = 'MIT'

  s.files = Dir['lib/**/*.rb']

  s.add_dependency 'nokogiri'
  s.add_dependency 'htmlentities'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-nav'
end
