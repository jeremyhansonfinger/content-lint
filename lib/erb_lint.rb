# frozen_string_literal: true

require 'erb_lint/linter'
require 'erb_lint/parser'

# Load linters
Dir[File.expand_path('erb_lint/linters/**/*.rb', File.dirname(__FILE__))].each do |file|
  require file
end
