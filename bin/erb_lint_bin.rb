#!/usr/bin/env ruby
# frozen_string_literal: true

require 'erb_lint'
require 'YAML'

command = ARGV[0]
config_file = YAML.load(File.read('config/config.yml'))
config = config_file.fetch('ContentStyle')
filetype = config.fetch('filetype')
dir_path = File.expand_path(command)
@linter = ERBLint::Linter::ContentStyle.new(config)
files = Dir.glob(dir_path + '/**/*.' + filetype)

files.each do |file|
  file_content = File.read(file)
  file_path = File.expand_path(file)
  @violations = @linter.lint_file(ERBLint::Parser.parse(file_content))
  @violations.each do |v|
    m = v[:message]
    l = v[:line]
    puts file_path.to_s + ":#{l}: #{m}"
  end
end

puts config.fetch('addendum', '') if @violations
