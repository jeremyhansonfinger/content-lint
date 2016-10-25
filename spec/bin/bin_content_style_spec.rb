# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Run command `content-style text/html`', type: :aruba do
  context 'when an html file containing a violation is located in `test/html` and config file is
          located at `config/content-style.yml`' do
    before(:each) do
      run_simple 'content-style test/html'
    end
    it 'writes an error message for violation to stdout' do
      expect(last_command_started.stdout.chomp).to include 'dropdown'
    end
  end
end
