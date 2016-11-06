# frozen_string_literal: true

require 'content_style'

describe ContentStyle::HotcopPartner do
  describe 'Gather source file identifiers' do
    context 'when the files has HOTCOP comments' do
      let(:file) { <<~FILE }
        <!-- HOTCOP START
        Type: template
        Identifier: show.html.erb
        -->
        <p>Other content.</p>
      FILE

      it 'calculates the correct identifier' do
        expect(described_class.get_source_locations(file)).to include('show.html.erb')
      end
    end
  end
end
