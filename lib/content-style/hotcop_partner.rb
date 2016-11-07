# frozen_string_literal: true

module ContentStyle
  # Contains the logic for generating the file tree structure used by linters.
  module HotcopPartner
    class << self
      def get_source_locations(file_content)
        hotcop_identifiers = []
        identifier_line_number = 0
        identifier = ''
        file_content.each_line.with_index do |line_content, current_line_number|
          identifier_pattern = /Identifier\: (.*)/.match(line_content)
          if line_content.chomp =~ /HOTCOP START$/
            identifier_line_number = current_line_number + 2
          elsif current_line_number == identifier_line_number && identifier_pattern
            identifier = identifier_pattern[1]
          end
          hotcop_identifiers.push(identifier)
        end
        hotcop_identifiers
      end
    end
  end
end
