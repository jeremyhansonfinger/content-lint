# frozen_string_literal: true
require 'nokogiri'
require 'htmlentities'
require 'uri'

module ERBLint
  # Contains the logic for generating the file tree structure used by linters.
  module Parser
    END_MARKER_NAME = 'erb_lint_end_marker'

    class << self
      def parse(file_content)
        final_file_content = add_end_marker(file_content)

        file_tree = Nokogiri::HTML.fragment(final_file_content)

        ensure_valid_tree(file_tree)

        file_tree
      end

      def file_is_empty?(file_tree)
        top_level_elements = file_tree.children
        top_level_elements.size == 1 && top_level_elements.last.name == END_MARKER_NAME
      end

      def get_text_nodes(nodes)
        nodes.search('.//text()[not(self::script)]')
      end

      def add_end_marker(file_content)
        file_content + <<~END_MARKER.chomp
          <#{END_MARKER_NAME}>
            This is used to calculate the line number of the last line.
            This is only necessary until Text#line is fixed in Nokogiri.
          </#{END_MARKER_NAME}>
        END_MARKER
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
        emails = /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/.match(text).to_a
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

      private

      def ensure_valid_tree(_file_tree)
        true
      end
    end

    class ParseError < StandardError
    end
  end
end
