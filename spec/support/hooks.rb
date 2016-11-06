# frozen_string_literal: true

require_relative 'aruba'

Aruba.configure do |config|
  config.before :command do
    config_directory = 'config'
    config_file = 'config/content-style.yml'
    config_content = <<~FILE
---

ContentStyle:
  enabled: true
  addendum: 'Questions?'
  filetype: 'html'
  csv: true
  exceptions:
    - 'manual change'
    - 'Amazon docs'
  excluded_html_files:
    - 'test/html/exclusion_test.html'
  excluded_source_folders:
    - 'app/excluded'
  rule_set:
    - violation:
        - 'dropdown'
        - 'drop down'
        - 'droop down'
        - 'drip down'
      case_insensitive: true
      suggestion: 'drop-down'
FILE

    html_directory = 'test/html'
    html_file = 'test/html/test.html'
    html_content = <<~FILE
    <!-- HOTCOP START
        Type: template
        Identifier: before.html.erb
    -->
    <p>
      Holler at our dropdown team at
      <a href="mailto:beta@shop.com"></a>.
      You'll never hear from us.
    </p>
     <!-- HOTCOP START
        Type: template
        Identifier: after.html.erb
    -->
FILE

    excluded_html_file = 'test/html/exclusion_test.html'
    excluded_content = <<~FILE
    <p>
      Holler at our droop down team at
      <a href="mailto:beta@shop.com"></a>.
      You'll never hear from us.
    </p>
FILE
    excluded_source_directory_file = 'app/excluded/exclusion_test.html.erb'
    excluded_source_directory_content = <<~FILE
    <!-- HOTCOP START
        Type: template
        Identifier: app/excluded/exclusion_test.html.erb
    -->
    <p>
      Holler at our drip down team at
      <a href="mailto:beta@shop.com"></a>.
      You'll never hear from us.
    </p>
FILE
    create_directory(config_directory)
    write_file(config_file, config_content)
    create_directory(html_directory)
    write_file(html_file, html_content)
    write_file(excluded_html_file, excluded_content)
    write_file(excluded_source_directory_file, excluded_source_directory_content)
  end
end
