require 'spec_helper'

RSpec.describe EasyTags::Parsers::Default do
  describe '.parse' do
    it 'returns nil if empty array is passed' do
      expect(described_class.parse('')).to be_empty
    end

    it 'return array of values split by delimiter' do
      expect(described_class.parse('One,Two,Three')).to eq(['One', 'Two', 'Three'])
    end

    context 'inconsistent spacing' do
      it 'trims spaces on tags' do
        expect(described_class.parse('One , Two,  Three and four')).to eq(['One', 'Two', 'Three and four'])
      end
    end
  end

  describe '.filter' do
    it 'strips string' do
      expect(described_class.filter('  One and Two   ')).to eq('One and Two')
    end
  end
end