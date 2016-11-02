# frozen_string_literal: true

describe ContentStyle::Parser do
  describe '#parse' do
    context 'when the file is empty' do
      let(:file) { '' }

      it 'returns a document fragment with only the end marker as a child' do
        expect(described_class.parse(file).class).to eq Nokogiri::HTML::DocumentFragment
        expect(described_class.parse(file).children.size).to eq 1
        expect(described_class.parse(file).child.name).to eq ContentStyle::Parser::END_MARKER_NAME
      end
    end

    context 'when the files has html comments' do
      let(:file) { <<~FILE }
        <!-- START
           -->
      FILE

      it 'returns a document fragment with an html comment as a child' do
        expect(described_class.parse(file).child.comment?).to eq true
      end
    end

    context 'when the files has HOTCOP comments' do
      let(:file) { <<~FILE }
        <!-- HOTCOP START
        Type: template
        Identifier: show.html.erb
        -->
        <p>Other content.</p>
      FILE

      it 'calculates the correct identifier' do
        expect(described_class.get_erb_locations(file)).to include({:line => 3, :erb_location => "show.html.erb"})
      end
    end
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
