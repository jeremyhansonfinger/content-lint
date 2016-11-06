# frozen_string_literal: true

require 'nokogiri'
require 'content-style/parser'
require 'content-style/linter'
require 'content-style/hotcop_partner'

module ContentStyle
  ROOT = File.expand_path('../..', __FILE__)
end
