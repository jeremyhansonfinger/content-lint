# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = 'content-style'
  s.version = '0.0.1'
  s.executables = ['content-style']
  s.authors = ['Jeremy Hanson-Finger']
  s.email = ['jeremy.hansonfinger@shopify.com']
  s.summary = 'Content lint tool'
  s.description = 'Content lint tool.'
  s.homepage = 'https://github.com/jeremyhansonfinger/content-style'
  s.license = 'MIT'
  s.files = Dir['**/*.rb']

  s.add_dependency 'nokogiri', '~> 1.6', '>= 1.6.8'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'aruba'
end
