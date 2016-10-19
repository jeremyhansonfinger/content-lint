# frozen_string_literal: true

require 'nokogiri'
require 'parser'

module ContentStyle
  # Checks for content style guide violations in the text nodes of HTML files.
  class Linter
    def initialize(config)
      @content_ruleset = []
      config.fetch('rule_set', []).each do |rule|
        suggestion = rule.fetch('suggestion', '')
        pattern_description = rule.fetch('pattern_description', '')
        case_insensitive = rule.fetch('case_insensitive', false)
        violation_string_or_array = rule.fetch('violation', [])
        violation_array = [violation_string_or_array].flatten
        violation_array.each do |violating_pattern|
          @content_ruleset.push(
            violating_pattern: violating_pattern,
            suggestion: suggestion,
            case_insensitive: case_insensitive,
            pattern_description: pattern_description
          )
        end
      end
      @content_ruleset.freeze
      @addendum = config.fetch('addendum', '')
    end

    def lint_file(file_tree)
      errors = []
      text_nodes = Parser.get_text_nodes(file_tree)
      text_nodes.each do |text_node|
        node_has_content = text_node.text =~ /[^\n\s]/
        next unless node_has_content && !text_node.cdata?
        content_lines = index_lines(text_node)
        content_lines.each do |line|
          errors.concat(generate_errors(line[:text], line[:number]))
        end
      end
      errors
    end

    private

    def index_lines(text_node)
      lines = []
      current_line_number = text_node.parent.line
      unless text_node.parent.nil?
        s = StringScanner.new(text_node.text)
        if s.check_until(/\n/)
          while (line_content = s.scan_until(/\n/))
            index_multilines(line_content, current_line_number, lines)
            current_line_number += 1
          end
        else
          line_content = text_node.text
          index_single_lines(line_content, current_line_number, lines)
        end
      end
      lines
    end

    def index_multilines(line_content, current_line_number, lines)
      uri_free_line_content = Parser.strip_uris(line_content)
      final_line_content = Parser.strip_emails(uri_free_line_content)
      lines.push(text: final_line_content, number: current_line_number)
    end

    def index_single_lines(line_content, current_line_number, lines)
      uri_free_line_content = Parser.strip_uris(line_content)
      final_line_content = Parser.strip_emails(uri_free_line_content)
      lines.push(text: final_line_content, number: current_line_number)
    end

    def generate_errors(text, line_number)
      violated_rules(text).map do |violated_rule|
        suggestion = violated_rule[:suggestion]
        pattern_description = violated_rule[:pattern_description]
        violation = pattern_description.empty? ? violated_rule[:violating_pattern] : pattern_description
        {
          line: line_number,
          message: "Don't use `#{violation}`. Do use `#{suggestion}`.".strip # #{@addendum}".strip
        }
      end
    end

    def violated_rules(text)
      @content_ruleset.select do |content_rule|
        violating_pattern = content_rule[:violating_pattern]
        suggestion = content_rule[:suggestion]
        clean_text = strip_suggestions_from_text(suggestion, text)
        case_insensitive = content_rule[:case_insensitive] == true
        match_case_insensitive = /(#{violating_pattern})\b/i.match(clean_text)
        match_case_sensitive = /(#{violating_pattern})\b/.match(clean_text)
        match_ignoring_initial_cap_violations = /[^\.]\s(#{violating_pattern})\b/.match(clean_text)
        if case_insensitive
          match_case_insensitive
        elsif !case_insensitive && suggestion_lowercase_violation_uppercase(suggestion, violating_pattern)
          match_ignoring_initial_cap_violations
        else
          match_case_sensitive
        end
      end
    end

    def strip_suggestions_from_text(suggestion, text)
      xs = 'x' * suggestion.length
      text.gsub(/#{suggestion}/, xs)
    end

    def suggestion_lowercase_violation_uppercase(suggestion, violating_pattern)
      suggestion_first_character_lowercase = suggestion.match(/\A[a-z]/)
      violation_first_character_uppercase = !violating_pattern.match(/\A[A-Z]/)
      suggestion_first_character_lowercase && violation_first_character_uppercase
    end
  end
end
