# frozen_string_literal: true

# rubocop:disable ClassLength
require 'nokogiri'

module ContentStyle
  # Checks for content style guide violations in the text nodes of HTML files.
  class Linter
    # rubocop:disable AbcSize
    def initialize(config)
      @exceptions = config.fetch('exceptions', [])

      @content_ruleset = config.fetch('rule_set', []).flat_map do |rule|
        suggestion = rule.fetch('suggestion', '')
        context = rule.fetch('context', '')
        pattern_description = rule.fetch('pattern_description', '')
        case_insensitive = rule.fetch('case_insensitive', false)
        violation_string_or_array = rule.fetch('violation', [])
        violation_array = [violation_string_or_array].flatten
        violation_array.map do |violating_pattern|
          { 
            suggestion: suggestion,
            case_insensitive: case_insensitive,
            pattern_description: pattern_description,
            context: context,

            violating_pattern: violating_pattern,
            regex_case_sensitive: /(#{violating_pattern})\b/,
            regex_case_insensitive: /(#{violating_pattern})\b/i,
            regex_ignoring_initial_cap_violations: /[^.]\s+(#{violating_pattern})\b/,
          }
        end
      end.freeze

      @addendum = config.fetch('addendum', '')
    end
    # rubocop:enable AbcSize

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
            clean_lines(line_content, current_line_number, lines)
            current_line_number += 1
          end
        else
          line_content = text_node.text
          clean_lines(line_content, current_line_number, lines)
        end
      end
      lines
    end

    def clean_lines(line_content, current_line_number, lines)
      uri_free_line_content = Parser.strip_uris(line_content)
      final_line_content = Parser.strip_emails(uri_free_line_content)
      lines.push(text: final_line_content, number: current_line_number)
    end

    def generate_errors(text, line_number)
      violated_rules(text).map do |violated_rule|
        suggestion = violated_rule[:suggestion]
        pattern_description = violated_rule[:pattern_description]
        context = violated_rule[:context]
        violation = pattern_description.empty? ? violated_rule[:violating_pattern] : pattern_description
        message = if !context.empty?
                    "Double check that `#{violation}` isn't used in place of `#{suggestion}`. #{context}.".strip
                  else
                    "Don't use `#{violation}`. Do use `#{suggestion}`.".strip
                  end
        {
          line: line_number, text: text.strip, message: message
        }
      end
    end

    def violated_rules(text)
      @content_ruleset.select do |content_rule|
        violating_pattern = content_rule[:violating_pattern]
        suggestion = content_rule[:suggestion]
        clean_text = strip_suggestions_and_exceptions_from_text(suggestion, @exceptions, text)
        next if conflicts(violating_pattern, clean_text)

        if content_rule[:case_insensitive] == true 
          content_rule[:regex_case_insensitive].match(clean_text)
        elsif suggestion_lowercase_violation_uppercase(suggestion, violating_pattern)
          content_rule[:regex_ignoring_initial_cap_violations].match(clean_text)
        else
          content_rule[:regex_case_sensitive].match(clean_text)
        end
      end
    end

    def conflicts(violating_pattern, text)
      @content_ruleset.any? do |content_rule|
        s = content_rule[:suggestion]
        s.length > violating_pattern.length &&
        s.include?(violating_pattern) &&
        text.include?(s)
      end
    end

    def strip_suggestions_and_exceptions_from_text(suggestion, exceptions, text)
      suggestion_exes = 'x' * suggestion.length
      working_text = text.gsub(/#{suggestion}\b/, suggestion_exes)
      exceptions.each do |exception|
        exception_exes = 'x' * exception.length
        working_text.gsub!(/#{exception}\b/, exception_exes)
      end
      working_text
    end

    def suggestion_lowercase_violation_uppercase(suggestion, violating_pattern)
      suggestion_first_character_lowercase = suggestion.match(/\A[a-z]/)
      violation_first_character_uppercase = violating_pattern.match(/\A[A-Z]/)
      violation_not_compound = !violating_pattern.match(/[A-Z].*[A-Z]/)
      suggestion_first_character_lowercase && violation_first_character_uppercase && violation_not_compound
    end
  end
end

# rubocop:enable ClassLength
