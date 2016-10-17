# frozen_string_literal: true

require 'spec_helper'

describe ERBLint::Parser do
  describe '#parse' do
    context 'when the file is empty' do
      let(:file) { '' }

      it 'returns a document fragment with only the end marker as a child' do
        expect(described_class.parse(file).class).to eq Nokogiri::HTML::DocumentFragment
        expect(described_class.parse(file).children.size).to eq 1
        expect(described_class.parse(file).child.name).to eq ERBLint::Parser::END_MARKER_NAME
      end
    end

    # context 'when tags are not properly closed' do
    #   let(:file) { <<~FILE.chomp }
    #     <div>
    #   FILE

    #   it 'raises a general parsing error' do
    #     expect { described_class.parse(file) }.to raise_error(
    #       described_class::ParseError,
    #       'File could not be successfully parsed. Ensure all tags are properly closed.'
    #     )
    #   end
    # end
  end

  describe '#file_is_empty?' do
    let(:file_tree) { described_class.parse(file) }

    context 'when the file is empty' do
      let(:file) { '' }

      it 'returns true' do
        expect(described_class.file_is_empty?(file_tree)).to be_truthy
      end
    end

    context 'when the file has content' do
      let(:file) { 'content' }

      it 'returns false' do
        expect(described_class.file_is_empty?(file_tree)).to be_falsy
      end
    end

    context 'when the file contains only a newline' do
      let(:file) { "\n" }

      it 'returns false' do
        expect(described_class.file_is_empty?(file_tree)).to be_falsy
      end
    end
  end
end
