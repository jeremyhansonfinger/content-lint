#!/usr/bin/env ruby
# frozen_string_literal: true

require 'erb_lint'
require 'YAML'
# require 'pry'

command = ARGV[0]
file_path = File.expand_path(command)
file = File.read(file_path)
linter_config = YAML.load(File.read('config/config.yml'))
config = linter_config.dig('linters', 'ContentStyle')
linter = ERBLint::Linter::ContentStyle.new(config)

errors = linter.lint_file(ERBLint::Parser.parse(file))

if errors
  puts config.fetch('addendum', '')
end

errors.each do |e|
  m = e[:message]
  l = e[:line]
  puts file_path.to_s + ":#{l}: #{m}"
end
