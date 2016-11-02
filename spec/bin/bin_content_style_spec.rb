# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Run command `content-style test/html`', type: :aruba do
  context 'when an html file containing a violation is located in `test/html` and config file is
  located at `config/content-style.yml`' do
    before(:each) do
      run_simple 'bin/content-style test/html'
    end
    it 'writes the correct error message for violation to stdout' do
      expect(last_command_started.stdout.chomp).to include 'dropdown'
    end
    it 'writes the correct erb file location to stdout' do
      expect(last_command_started.stdout.chomp).to include 'before.html.erb'
      expect(last_command_started.stdout.chomp).not_to include 'after.html.erb'
    end
    it 'writes the correct text to stdout' do
      expect(last_command_started.stdout.chomp).to include 'Holler at our dropdown team'
    end
  end

  context 'when a file marked for exclusion contains a violation' do
    before(:each) do
      run_simple 'bin/content-style test/html'
    end
    it 'does not write error message for violation in excluded file' do
      expect(last_command_started.stdout.chomp).to include 'dropdown'
      expect(last_command_started.stdout.chomp).not_to include 'droop down'
    end
  end

  context 'when csv output is enabled' do
    let(:csv) do
      'test/html/content-style-output.csv'
    end
    let(:dropdown) do
      /dropdown/
    end
    before(:each) do
      run_simple 'bin/content-style test/html'
    end
    it 'generates a CSV file with the correct error message' do
      expect(csv).to be_an_existing_file
      expect(csv).to have_file_content dropdown
    end
  end
end
