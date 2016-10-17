# content-style

`content-style` is a tool to help lint your HTML files for content style violations.

## Requirements

* Ruby 2.2.0+ (Runtime)
* Ruby 2.3.0+ (Development)
 - This is due to the use of the tilde-heredoc `<<~` syntax in some tests.
* If working with erb content, Hotcop
    * Install hotcop in the repo you want to test.
    * Run your integration tests (`bundle exec rake spec`) to generate HTML files in `test/html`.
    * (Generating html files with hotcop is required because nokogiri can’t handle parsing complex html.erb files.)

## Installation

Add the following to your `gemfile` and run `bundle install`:

```ruby
gem 'content-lint', git: 'git@github.com:jeremyhansonfinger/content-style.git'
```

You may run into problems installing nokogiri because it's the worst. If the install fails, try [this resource](http://www.nokogiri.org/tutorials/installing_nokogiri.html) or google `nokogiri won't install` because lots of people have the same problem.

## Configuration

The configuration comes from a `content-style.yml` file located in the `config` folder of your repo:

```yml
---

ContentStyle:
  enabled: true
  filetype: 'html'
  addendum: 'Questions? Keep them to yourself.' 
  rule_set:
    - violation:
        - 'dropdown'
        - 'drop down'
      case_insensitive: true
      suggestion: 'drop-down'
```

`filetype` controls what file extension content-style looks for in the directory you run it on.

### Rule set

content-style will find any words or phrases that violate the rule set that you provide.

This `rule_set` is specified as a list of rules, each with a `violation` set and
a corresponding `suggestion`. Optionally, you can also add a `case_insensitive:
true` value to make content-style ignore case when searching for violations.
If your `violation` is a regex pattern, you can add a `pattern_description` string
to replace the pattern in the error message.

```yml
rule_set:
    - violation:
        - 'application'
        - 'program'
      case_insensitive: true
      suggestion: 'app'

    - violation:
        - 'support page'
      suggestion: 'Lintercorp Help Center'

    - violation: '\d+ ?(—|-) ?\d+'
      suggestion: '— (en dash) in number ranges'
      pattern_description: '- (hyphen) or — (em dash) in number ranges'

```

You can also specify an addendum to be added to the end of the list of errors
using the `addendum` option. 

The error message format is: `"#{path_to_file}:#{line_number}: Don't use #{violation}. Do use #{suggestion}"` 

Option | Description
-----------------------|-----------------------------------------------------------------------------------
`rule_set`             | A list of rules, each with a `violation` and `suggestion` option.
`violation`            | A list of strings or regex patterns that specify unwanted text content.
`suggestion`           | A suggested replacement for the unwanted text content defined in `violation`.
`case_insensitive`     | A Boolean value that determines whether the rule is case sensitive. (Optional, defaults to false if not included)
`pattern_description`  | A string that appears in place of the regex pattern as the violation in the error message. (Optional) 
`addendum`             | A string to be included at the end of every error message of the rule set. (Optional)

## Usage

Once content-style is installed and confiured, running the following command in your shell:

```shell
bundle exec content-lint absolute/path/to/your/html/files
```

results in the following lines being written to stdout (which can be redirected as required):

```
absolute/path/to/your/html/files/file_1.html:48: Don't use `support page`. Do use `Lintercorp Help Center`.
absolute/path/to/your/html/files/file_1.html:96: Don't use `application`. Do use `app`.
absolute/path/to/your/html/files/file_2.html:101: Don't use `- (hyphen) or — (em dash) in number ranges`. Do use `— (en dash) in number ranges`.
```

## Testing

To run tests:

1. run `bundle install` to install `rspec`

2. `bundle exec rspec spec` to run the test suite.

## License

This project is released under the [MIT license](LICENSE.txt).
