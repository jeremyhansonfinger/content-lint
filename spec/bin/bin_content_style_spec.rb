# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Run command `content-style text/html`', type: :aruba do
  context 'when an html file containing a violation is located in `test/html` and config file is
          located at `config/content-style.yml`' do
    before(:each) do
      run_simple 'bin/content-style test/html'
    end
    it 'writes an error message for violation to stdout' do
      expect(last_command_started.stdout.chomp).to include 'dropdown'
    end
  end
end

RSpec.describe 'Run command `content-style text/html`', type: :aruba do
  context 'when a file marked for exclusion contains a violation' do
    before(:each) do
      run_simple 'bin/content-style test/html'
    end
    it 'does not write error message for violation in excluded file' do
      expect(last_command_started.stdout.chomp).to include 'dropdown'
      expect(last_command_started.stdout.chomp).not_to include 'droop down'
    end
  end
end
