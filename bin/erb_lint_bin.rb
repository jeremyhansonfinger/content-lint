#!/usr/bin/env ruby
# frozen_string_literal: true

require 'local_content_style'
require 'YAML'
# require 'pry'

command = ARGV[0]
file_path = File.expand_path(command)
file = File.read(file_path)
linter_config = YAML.load(File.read('config/config.yml'))
linter = LocalContentStyle::Linter.new(linter_config)
errors = linter.lint_file(file)
errors.each do |e|
  m = e[:message]
  l = e[:line]
  c = e[:column]
  puts file_path.to_s + ":#{l}:#{c}: C: #{m}"
end
