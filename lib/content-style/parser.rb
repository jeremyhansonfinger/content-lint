# frozen_string_literal: true

require 'nokogiri'
require 'uri'

module ContentStyle
  # Contains the logic for generating the file tree structure used by linters.
  module Parser
    END_MARKER_NAME = 'content_style_end_marker'
    class << self
      def parse(file_content)
        final_file_content = add_end_marker(file_content)

        file_tree = Nokogiri::HTML.fragment(final_file_content)

        file_tree
      end

      def get_erb_locations(file_content)
        hotcop_lines = []
        hotcop_identifiers = []
        current_line_number = 1
        s = StringScanner.new(file_content)
        while (line_content = s.scan_until(/\n/))
          if line_content =~ /HOTCOP START/
            identifier_line_number = current_line_number + 2
            hotcop_lines.push(identifier_line_number)
          end
          if current_line_number == hotcop_lines.last
            identifier = /Identifier\: (.*)/.match(line_content)[1]
            hotcop_identifiers.push(
              line: current_line_number,
              erb_location: identifier
            )
          end
          current_line_number += 1
        end
        hotcop_identifiers
      end

      def file_is_empty?(file_tree)
        top_level_elements = file_tree.children
        top_level_elements.size == 1 && top_level_elements.last.name == END_MARKER_NAME
      end

      def get_text_nodes(nodes)
        nodes.search('.//text()[not(self::script)]')
      end

      def add_end_marker(file_content)
        end_marker = "<#{END_MARKER_NAME}>content style end marker</#{END_MARKER_NAME}>"
        file_content + end_marker
        # This is used to calculate the line number of the last line. This
        # is only necessary until Text#line is fixed in Nokogiri.
      end

      def strip_uris(text)
        uris = URI.extract(text)
        uri_length = []
        if uris
          uris.each do |u|
            uri_length.push(u.to_s.length)
          end
          uri_hash = Hash[uris.zip(uri_length)]
          uri_hash.each do |k, v|
            xs = 'x' * v
            text.gsub!(k, xs)
          end
          text
        end
      end

      def strip_emails(text)
        emails = /[^@\s]+@([^@\s]+\.)+[^@\s]+/.match(text).to_a
        email_length = []
        if emails
          emails.each do |e|
            email_length.push(e.to_s.length)
          end
          email_hash = Hash[emails.zip(email_length)]
          email_hash.each do |k, v|
            xs = 'x' * v
            text.gsub!(k, xs)
          end
          text
        end
      end
    end
  end
end
